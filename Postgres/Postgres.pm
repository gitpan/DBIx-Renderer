package DBIx::Renderer::Postgres;

use warnings;
use strict;

use base qw(DBIx::Renderer::Base);

our $VERSION = '0.01';

1;

__END__

=head1 NAME

DBIx::Renderer::Postgres - DBI renderer for the Postgres SQL variant

=head1 SYNOPSIS

    use DBIx::Renderer ':all';
    my $struct = [ ... ];
    my $renderer = DBIx::Renderer::get_renderer('Postgres');
    print $renderer->create_schema($struct);

=head1 DESCRIPTION

This is the renderer for the Postgres dialect of SQL. There's actually
nothing to do, since C<DBIx::Renderer::Base> is written to output
Postgres' version of SQL, which should be largely compatible with other
SQL versions; hence it all went into the base class.

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

perl(1), DBI(3pm), DBIx::Renderer(3pm), DBIx::Renderer::Base(3pm).

=cut
