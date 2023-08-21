#!/usr/bin/perl
# t/tlock-1.pl
use strict;
use experimental qw(signatures);

use Test::More 'no_plan';

my ($dir , $tdir);
BEGIN {
    use File::Basename qw(dirname);
    use Cwd qw(abs_path);
    $tdir = dirname(abs_path($0));
    $dir = $tdir =~ s/[^\/]+$/lib/r;
    };

use lib $dir;
use Sys::Tlock dir => $tdir.'/' , conf => $tdir.'/test-1.conf';

ok (not tlock_taken 'test-1');
ok (not defined tlock_expiry 'test-1');
ok (not -d $tdir.'/tlock.test-1');

my $token = tlock_take 'test-1' , 600;

ok (tlock_alive 'test-1' , $token);
ok (tlock_taken 'test-1');
ok ((tlock_expiry 'test-1') == ($token + 600));
ok (-d $tdir.'/tlock.test-1');

ok (not tlock_take 'test-1' , 600);

ok (tlock_renew 'test-1' , $token , 600);

ok (tlock_alive 'test-1' , $token);
ok (tlock_taken 'test-1');
ok ((tlock_expiry 'test-1') >= ($token + 600));
ok (-d $tdir.'/tlock.test-1');

ok (not tlock_take 'test-1' , 600);

ok (tlock_release 'test-1' , $token);

ok (not tlock_alive 'test-1' , $token);
ok (not tlock_taken 'test-1');
ok (not defined tlock_expiry 'test-1');
ok (not -d $tdir.'/tlock.test-1');

__END__
