#!perl

use strict;
use warnings;
use Test::Exception;
use Test::More 0.98;

use Algorithm::Retry::Constant;

my $ar = Algorithm::Retry::Constant->new(
    delay_on_failure => 2,
    delay_on_success => 1,
);

subtest "timestamp must not decrease" => sub {
    $ar->success(2);
    dies_ok { $ar->success(1) };
};

DONE_TESTING:
done_testing;
