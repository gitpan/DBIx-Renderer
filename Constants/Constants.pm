package DBIx::Renderer::Constants;

use warnings;
use strict;

use base qw(Exporter);

# This allows declaration	use DBIx::Renderer::Constants ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	INT4 FLOAT4 TEXT BOOL TIMESTAMP CHAR VARCHAR 
	NOTNULL UNIQUE DEFAULT
	PK INDEX
	TYPE_ID TYPE_FK
	get_types get_attrs get_markers
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);
our $VERSION = '0.01';

# The actual constants

# types

our @type   = qw/INT4 FLOAT4 TEXT BOOL TIMESTAMP CHAR VARCHAR/;
our @attr   = qw/NOTNULL UNIQUE DEFAULT/;
our @marker = qw/PK INDEX/;

# declared manually so we can use prototypes, as they can't be effectively
# declared at run-time

use constant INT4      => ( type => 'INT4'      );
use constant FLOAT4    => ( type => 'FLOAT4'    );
use constant TEXT      => ( type => 'TEXT'      );
use constant BOOL      => ( type => 'BOOL'      );
use constant TIMESTAMP => ( type => 'TIMESTAMP' );

use constant NOTNULL => ( NOTNULL => 1 );
use constant UNIQUE  => ( UNIQUE => 1  );
use constant PK      => ( PK => 1      );
use constant INDEX   => ( INDEX => 1   );

sub CHAR      { type => 'CHAR',    size => +shift }
sub VARCHAR   { type => 'VARCHAR', size => +shift }
sub DEFAULT   { DEFAULT => +shift }

# some predefined groups of types and/or attributes

use constant TYPE_ID => ( INT4(), NOTNULL(), PK() );
use constant TYPE_FK => ( INT4(), NOTNULL() );

sub get_types   { @type   }
sub get_attrs   { @attr   }
sub get_markers { @marker }

1;

__END__

=head1 NAME

DBIx::Renderer::Constants - constants for the DBI rendering framework

=head1 SYNOPSIS

    use DBIx::Renderer ':all';

    # mandatory name
    use constant TYPE_MANDNAME => ( VARCHAR(255), NOTNULL );

    my $struct = [
	    category => [
		    id        => { TYPE_ID },
		    name      => { TYPE_MANDNAME },
		    parent_id => { INT4, INDEX },
		],
    ];

=head1 DESCRIPTION

This module defines a range of constants and helper functions for use
in writing and talking to DBI renderers. Typically you won't use this
module directly, but import ':all' from C<DBIx::Renderer>, which passes
this module's exports along.

=head1 EXPORTS

The following constants and functions are exported:

=over 4

=item INT4 FLOAT4 TEXT BOOL TIMESTAMP

Constants for those data types; specific DBI renderers can then decide
how to render these constants in their SQL dialect. Actually they return
a hash element consisting of the key 'type' and the actual constant
as the value, so it doesn't make sense to specify more than one type;
the last one specified wins.

=item CHAR($size) VARCHAR($size)

These aren't actually constants but functions that take the size as a
parameter, as shown in the synopsis. In addition to the 'type' hash
key and its value, these functions also return a 'size' hash key and
its value.

=item DEFAULT

Like C<CHAR> and C<VARCHAR>, this function returns a hash element with
'DEFAULT' as its key (as every field can have only one default value)
and the actual default as its value.

=item NOTNULL UNIQUE PK INDEX

Defines constants for marking a field to be not nullable or to be unique,
or for specifying that this field is a primary key or that it should be
indexed. Per usual, these constants are a hash element with the constant's
name as the key and 1 as its value.

=item TYPE_ID TYPE_FK

These two are "complex" types; a C<TYPE_ID> being a not-nullable primary
key of type int4, and C<TYPE_FK> being a notnullable int4 used as a
foreign key into some other table.

=item get_types()

Returns a list of all possible data types.

=item get_attrs()

Returns a list of all possible field attributes (such as 'not nullable',
'unique value', 'has a default value').

=item get_markers()

Returns a list of all field markers (such as 'primary key' or 'indexed
field').

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

perl(1), DBI(3pm), DBIx::Renderer(3pm).

=cut
