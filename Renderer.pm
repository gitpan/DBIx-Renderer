package DBIx::Renderer;

use warnings;
use strict;

use base qw(Exporter);
use DBIx::Renderer::Constants ':all';

# This allows declaration	use DBIx::Renderer ':all';
# to get all the Constants this module imported.

our %EXPORT_TAGS = ( 'all' => $DBIx::Renderer::Constants::EXPORT_TAGS{'all'} );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);
our $VERSION = '0.01';

sub get_renderer {
	my $name = shift;
	my $pkg = "DBIx::Renderer::$name";
	eval "require $pkg";
	die $@ if $@;
	return $pkg->new;
}

1;

__END__

=head1 NAME

DBIx::Renderer - talk SQL by using Perl data structures

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

    my $renderer = DBIx::Renderer::get_renderer('Postgres');
    print $renderer->create_schema($struct);

=head1 DESCRIPTION

I got fed up with having to write different variants of SQL for different
database engines. Also, I was looking for a way to specify a schema
in Perl. The idea is that you construct data structures which are
then rendered into the type of SQL appropriate for the target database
server. Along the way we can make some optimizations and customizations,
such as using database-specific features. For exmaple, we might make
use of Postgres' array data types, but render them into weak relations
for other servers.

Also, outputting the schema in XML might be useful.

=head1 EXPORTS

=over 4

=item :all

Exports all the C<DBIx::Renderer::Constants> constants and functions,
see its manpage for details.

=back

=head1 FUNCTIONS

=over 4

=item get_renderer($name)

Requests construction of a specific DBI renderer. The renderer
is constructed by called a C<new()> constructor on the package
C<DBIx::Renderer::$name>.

=back

=head1 TODO

=over 4

=item test.pl

Write test cases.

=item Renderers

Extend with renderers for other databases, also have an XML renderer.

=item Specify relationships

Allow specification of weak relations or, in fact, any sort of relations
and have the necessary tables created automatically. This would be the
first step in integrating it with something like C<Class::DBI>.

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

perl(1), DBI(3pm).

=cut
