package DBIx::Renderer::Base;

use warnings;
use strict;

use DBIx::Renderer::Constants ':all';

our $VERSION = '0.01';

sub new {
        my $this = shift;
        my $class = ref($this) || $this;
        my $self = {};
        bless $self, $class;
        $self->_init(@_);
        return $self;
}

sub _init { }

sub create_index {
	my ($self, $indexname, $tablename, @fields) = @_;
	return '' unless @fields;
	return "CREATE INDEX $tablename\_$indexname\_idx ON $tablename (" .
	    join(', ' => @fields) . ");\n";
}

sub create_table {
	my ($self, $tablename, $tabledef) = @_;
	my @tabledef = @$tabledef;   # so we can splice w/o harm
	my @cols;
	while (my ($colname, $coldef) = splice(@tabledef, 0, 2)) {
		my $coltext = $colname . ' ' .  $self->get_type_name($coldef);
		$coltext .= ' ' . join ' ' => $self->get_attr_names($coldef);
		push @cols, $coltext;
	}

	my $sql = "CREATE TABLE $tablename (\n";
	$sql .= join ",\n" => map { "\t$_" } @cols;

	my @pk = $self->get_pk_fields($tabledef);
	$sql .= ",\n\tPRIMARY KEY (" . join(', ' => @pk) . ")" if @pk;

	$sql .= "\n);\n";

	# index for primary key fields and fields marked as index
	$sql .= $self->create_index('', $tablename, @pk);
	my @index = $self->get_index_fields($tabledef);
	if (@index) {
		$sql .= $self->create_index($_, $tablename, $_) for @index;
	}

	return $sql;
}

sub create_schema {
	my ($self, $struct) = @_;
	my @struct = @$struct;   # so we can splice w/o harm
	my $sql;
	while (my ($tablename, $tabledef) = splice(@struct, 0, 2)) {
		$sql .= $self->create_table($tablename, $tabledef);
	}
	return $sql;
}

sub get_type_name {
	my ($self, $coldef) = @_;
	return $self->get_const_name($coldef->{type}, $coldef->{size});
}

sub find_fields {
	my ($self, $tabledef, $wanted) = @_;
	my @found;
	my @tabledef = @$tabledef;   # so we can splice w/o harm
	while (my ($colname, $coldef) = splice(@tabledef, 0, 2)) {
		push @found, $colname if exists $coldef->{$wanted};
	}
	return @found;
}

sub get_pk_fields {
	my ($self, $tabledef) = @_;
	return $self->find_fields($tabledef, 'PK');
}

sub get_index_fields {
	my ($self, $tabledef) = @_;
	return $self->find_fields($tabledef, 'INDEX');
}

sub get_attr_names {
	my ($self, $coldef) = @_;
	my $attrs = $self->get_attr($coldef);
	my @out;
	while (my ($attr, $val) = each %$attrs) {
		push @out, $self->get_const_name($attr, $val);
	}
	@out;
}

sub get_attr {
	# return a subset of the column definition consisting only of attrs
	my ($self, $coldef) = @_;
	my %attrs = map { $_ => 1 } get_attrs();
	my $out;
	while (my ($k, $v) = each %$coldef) {
		# check if it is an attribute
		$out->{$k} = $v if exists $attrs{$k};
	}
	return $out;
}

sub get_const_name {
	my ($self, $const, @args) = @_;

	my %name = (
		INT4      => 'int4',
		FLOAT4    => 'float4',
		TEXT      => 'text',
		BOOL      => 'bool',
		TIMESTAMP => 'timestamp',

		NOTNULL   => 'NOT NULL',
		UNIQUE    => 'UNIQUE',
	);

# print "got <$const>, <@args>\n";
	return $name{$const} if exists $name{$const};

	# when dealing with CHAR or VARCHAR, we get the size as the
	# first arguments in @args

	return 'char(' . shift(@args) . ')'    if $const eq 'CHAR';
	return 'varchar(' . shift(@args) . ')' if $const eq 'VARCHAR';
	return 'DEFAULT ' . shift(@args)       if $const eq 'DEFAULT';

	# unknown
	return '';
}

sub expand {
	my $l = shift;
	if (ref($l) eq 'ARRAY') {
		local $_;
		return map { expand($_) } @$l;
	} else {
		return $l;
	}
}

1;

__END__

=head1 NAME

DBIx::Renderer::Base - base class for DBI renderers

=head1 SYNOPSIS

  package DBIx::Renderer::MyRenderer;
  use base 'DBIx::Renderer::Base;

=head1 DESCRIPTION

This base class for DBI renderers defines some general mechanisms that
might be of use to actual renderers. It's not required that a specific
renderer subclasses this class, but it does need to support the renderer
API (which hasn't been formalized).

=head1 METHODS

=over 4

=item new

Constructs the renderer object and returns it.

=item _init

Object initialization. Does nothing in this class, but is called by
C<new()>, so subclasses can override this method.

=item create_index($indexname, $tablename, @fields)

Returns the SQL necessary to create an index called C<$indexname> on
table C<$tablename> for the specified fields. An example might be

	CREATE INDEX product_idx ON product (title);

=item create_table($tablename, $tabledef)

Returns the SQL necessary to create a table called C<$tablename> using
field definitions given in the array reference C<$tabledef>. Each
field definition is a hash with the fieldname being the key and the
field specification being the value. The field specification, in turn,
is a reference to an array consisting of attributes. The attributes are
themselves hashes with the key being the attribute name (e.g., 'int4',
'bool', 'index', 'unique') and the value being the attribute parameters
(e.g. the size of varchar fields, or an id for grouping index fields).

Instead of saying "hashes", I should really say key-value pairs, since
they are stored in a list. But they are interpreted as hashes.

All this sounds a bit abstract, so maybe looking at that data structure
helps. This has been produced with C<Data::Dumper> but rolled into hashes
and lined up to make it more obvious what's going on.

    use DBIx::Renderer ':all';

    # mandatory name
    use constant TYPE_MANDNAME => ( VARCHAR(255), NOTNULL );

    my $struct = [
	    product => [
		    id         => { TYPE_ID },
		    name       => { TYPE_MANDNAME, INDEX },
		    short_desc => { TEXT },
		    long_desc  => { TEXT },
		    image      => { VARCHAR(255) },
		],
    ];

constructs a structure looking like this:

    product => [
      id => {
          'NOTNULL' => 1,
          'type'    => 'INT4',
          'PK'      => 1
        },
      name => {
          'NOTNULL' => 1,
          'size'    => 255,
          'INDEX'   => 1,
          'type'    => 'VARCHAR'
        },
      short_desc => {
          'type'    => 'TEXT'
        },
      long_desc => {
          'type'    => 'TEXT'
        },
      image => {
          'size'    => 255,
          'type'    => 'VARCHAR'
        }
    ];

=item create_schema($schema)

Constructs all SQL commands necessary to create the specified database
schema. C<$schema> is an array reference consisting of table definitions
as shown above. The method then calls C<create_table> and C<create_index>
to generate the SQL and returns the string.

=item get_type_name($coldef)

Helper method that returns this SQL version's name for the type specified
in the column definition.

=item find_fields($tabledef, $wanted)

Helper method that searches the given table definition for fields whose
definition have the C<$wanted> attribute. For example, to find all
primary key fields of a table, use

	@pk_fields = $self->find_fields($tabledef, 'PK');

=item get_pk_fields($tabledef)

Helper method that returns a list of primary key fields for the given
table definition.

=item get_index_fields($tabledef)

Helper method that returns a list of indexed fields for the given table
definition.

=item get_attr_names($coldef)

Returns the SQL corresponding to a field's specification. 

For example, the following field definition

      name => {
          'size'  => 255,
          'type'  => 'VARCHAR'
          'UNIQUE'=> 1,
        }

might return

	VARCHAR(255) UNIQUE

=item get_attr($coldef)

Return a field's attributes by scanning the C<$coldef> for attributes as
defined in C<DBIx::Renderer::Constants>. The term 'attributes' is used
here to mean things like 'NOTNULL', 'UNIQUE', 'DEFAULT', but not data
types or whether the field is a primary key or indexed.

=item get_const_name($const, @args)

This method takes a constant as defined in C<DBIx::Renderer::Constants>
and an optional list of arguments (e.g., a varchar has the size as its
argument) and returns the appropriate name for this SQL version. The
default method implemented in this class, for example, returns
'VARCHAR(255)' when called as C<get_const_name('VARCHAR', 255)>. Other
SQL dialects may have a different name for it.

=item expand($l)

Helper function (not a method) that takes a scalar and recursively
expands array references to create a flat array reference, which it
returns. If the scalar isn't an array reference to begin with, it just
returns the scalar.

This function is useful for constructing the structures mentioned above,
since you can combine attributes by creating an array reference containing
them, but then inserting this combination into a surrounding definition
creates nested array references, so we use this function to flatten
them. Check the source for details.

=back

=head1 BUGS

None known so far. If you find any bugs or oddities, please do inform the
author.

=head1 AUTHOR

Marcel GrE<uuml>nauer <marcel@codewerk.com>

=head1 COPYRIGHT

Copyright 2001 Marcel GrE<uuml>nauer. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), DBI(3pm), DBIx::Renderer(3pm), DBIx::Renderer::Constants(3pm).

=cut
