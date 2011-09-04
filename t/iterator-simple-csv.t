#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use File::Temp;
use Test::Most;
use Const::Fast;

const my $TEST_CSV => <<'EOT';
Foo,Bar,"Baz Quux"
1,2,3
4,5,6
EOT

use_ok( 'Iterator::Simple::CSV', 'icsv' );

my $tmpfile = File::Temp->new;
$tmpfile->write( $TEST_CSV );
$tmpfile->close;

{
    note "Testing no-opts";
    ok my $it = icsv( $tmpfile->filename );

    is_deeply $it->next, ["Foo", "Bar", "Baz Quux"];
    is_deeply $it->next, [1,2,3];
    is_deeply $it->next, [4,5,6];
    ok ! $it->next;
}

{
    note "Testing skip_header";
    ok my $it = icsv( $tmpfile->filename, skip_header => 1 );
    is_deeply $it->next, [1,2,3];
    is_deeply $it->next, [4,5,6];
    ok ! $it->next;
}

{
    note "Testing use_header";
    ok my $it = icsv( $tmpfile->filename, use_header => 1 );
    is_deeply $it->next, { "Foo" => 1, "Bar" => 2, "Baz Quux" => 3 };
    is_deeply $it->next, { "Foo" => 4, "Bar" => 5, "Baz Quux" => 6 };
    ok ! $it->next;
}

done_testing();
