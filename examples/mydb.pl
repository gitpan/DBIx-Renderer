#!/usr/bin/perl

use warnings;
use strict;
use DBIx::Renderer ':all';

use constant TYPE_NAME     => VARCHAR(40);
use constant TYPE_PASSWORD => ( VARCHAR(20), NOTNULL );
use constant TYPE_MANDNAME => ( VARCHAR(255), NOTNULL );  # mandatory name
use constant TYPE_PRICE    => ( FLOAT4, NOTNULL, DEFAULT(0) );

my $struct = [
	category => [
		id        => { TYPE_ID },
		name      => { TYPE_MANDNAME },
		parent_id => { INT4, INDEX },
	    ],
	set => [
		id   => { TYPE_ID },
		name => { TYPE_MANDNAME },
	    ],
	price => [
		id       => { TYPE_ID },
		shop_id  => { TYPE_FK },
		quantity => { INT4, NOTNULL },
		price    => { TYPE_PRICE },
	    ],
	product => [
		id         => { TYPE_ID },
		name       => { TYPE_MANDNAME, INDEX },
		short_desc => { TEXT },
		long_desc  => { TEXT },
		image      => { VARCHAR(255) },
	    ],
	product_category => [
		product_id  => { TYPE_ID },
		category_id => { TYPE_ID, INDEX },
	    ],
	product_set => [
		product_id  => { TYPE_ID },
		set_id      => { TYPE_ID, INDEX },
	    ],
	sessions => [
		id        => { CHAR(32), NOTNULL, PK },
		a_session => { TEXT },
	    ],
	basket => [
		sessions_id => { CHAR(32), NOTNULL, PK },
		shop_id     => { TYPE_ID },
		product_id  => { TYPE_ID },
		quantity    => { INT4, NOTNULL },
		notes       => { TEXT },
	    ],
	shop => [
		id          => { TYPE_ID },
		name        => { TYPE_MANDNAME },
		open        => { BOOL },
		description => { TEXT },
		image       => { VARCHAR(255) },
	    ],
	shop_admin => [
		username    => { TYPE_PASSWORD, PK },
		password    => { TYPE_PASSWORD },
		shop_id     => { TYPE_FK },
		person_id   => { TYPE_FK },
		address_id  => { TYPE_FK },
	    ],
	person => [
		id            => { TYPE_ID },
		first_name    => { VARCHAR(40) },
		last_name     => { VARCHAR(40) },
		email         => { VARCHAR(80) },
		telephone_day => { VARCHAR(40) },
		telephone_eve => { VARCHAR(40) },
		mobile        => { VARCHAR(40) },
		fax           => { VARCHAR(40) },
	    ],
	customer => [
		id                  => { TYPE_ID },
		password            => { TYPE_PASSWORD },
		person_id           => { TYPE_FK },
		address_id          => { TYPE_FK },   # contact address
		bonus_points        => { INT4 },
		currency_id         => { CHAR(3) },  # shown w/ native price
		order_status_emails => { BOOL },  # want to receive them?
		information_emails  => { BOOL },  # want to receive them?
	    ],
	address => [
		id      => { TYPE_ID },
		street  => { VARCHAR(255) },
		town    => { VARCHAR(255) },
		state   => { VARCHAR(255) },  # or county
		zip     => { VARCHAR(40) },   # or postcode
		country => { VARCHAR(255) },
	    ],
	customer_address => [
		id          => { TYPE_ID },
		customer_id => { TYPE_FK },
		address_id  => { TYPE_FK },
		mnemonic    => { VARCHAR(40), UNIQUE },
		status      => { INT4 },
	    ],
	card_type => [
		# visa, master card etc.
		id   => { TYPE_ID },
		name => { TYPE_MANDNAME },
	    ],
	card => [
		id           => { TYPE_ID },
		name         => { VARCHAR(40) },  # on card
		card_number  => { VARCHAR(40) },
		card_type_id => { TYPE_FK },
		issue        => { INT4 }, # or start date, for switch
		expiry_month => { INT4 },
		expiry_year  => { INT4 },
	    ],
	customer_card => [
		customer_id => { TYPE_ID },
		card_id     => { TYPE_ID },
		mnemonic    => { VARCHAR(40), UNIQUE },
		status      => { INT4 },
	    ],
	inventory => [
		product_id => { TYPE_ID },
		shop_id    => { TYPE_ID },
		stock_qty  => { INT4 },
		new_item   => { BOOL },
		sale_item  => { BOOL },
	    ],
	orders => [
		id          => { TYPE_ID },
		customer_id => { TYPE_FK },
		date        => { TIMESTAMP },
		address_id  => { TYPE_FK },
		card_id     => { TYPE_FK },
		status      => { TEXT },   # of order
	    ],
	ordered_products => [
		orders_id   => { TYPE_ID },
		product_id  => { TYPE_ID },
		shop_id     => { TYPE_ID },
		qty         => { INT4 },
		price       => { TYPE_PRICE },  # curr price might differ
		notes       => { TEXT },  # 'green', 'region 2 dvd' etc.
		status      => { TEXT },  # 'shipped date', 'in progress' etc.
	    ],
	currency => [
		id       => { CHAR(3), NOTNULL, PK },
		symbol   => { CHAR(10) },
	    ],
	currency_rates => [
		currency_id => { CHAR(3), NOTNULL, PK },
		rate        => { FLOAT4 },
	    ],
];

# use Data::Dumper; print Dumper($struct); exit;

my $renderer = DBIx::Renderer::get_renderer('Postgres');
print $renderer->create_schema($struct);

__END__

=head1 NAME

mydb.pl - DBIx::Renderer demonstration program

=head1 SYNOPSIS

./mydb.pl | psql

=head1 DESCRIPTION

This is a demonstration program for C<DBIx::Renderer>, using the Postgres
renderer to construct a sample shop database. Its output should be bona
fide SQL that can be passed to Postgres.

=head1 NOTES

For extra brownie points, install C<GraphViz::DBI> (also by yours truly
and available from CPAN) and use C<dbigraph.pl> to graph the tables and
their connections. You should arrive at the same graph as was bundled
in the C<exmaples/> directory of C<GraphViz::DBI>, since this is the
database used to create it.

=head1 BUGS

None known.

=head1 AUTHOR

Marcel GrE<uuml>nauer E<lt>marcel@codewerk.comE<gt>

=head1 COPYRIGHT

Copyright 2001 Marcel GrE<uuml>nauer. All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

DBI(3pm).

=cut

