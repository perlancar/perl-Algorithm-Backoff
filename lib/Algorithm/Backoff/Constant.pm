package Algorithm::Backoff::Constant;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict;
use warnings;

use parent qw(Algorithm::Backoff);

our %SPEC;

$SPEC{new} = {
    v => 1.1,
    is_class_meth => 1,
    is_func => 0,
    args => {
        %Algorithm::Backoff::attr_consider_actual_delay,
        %Algorithm::Backoff::attr_max_actual_duration,
        %Algorithm::Backoff::attr_max_attempts,
        %Algorithm::Backoff::attr_jitter_factor,
        %Algorithm::Backoff::attr_delay_on_success,
        %Algorithm::Backoff::attr_min_delay,
        %Algorithm::Backoff::attr_max_delay,
        delay => {
            summary => 'Number of seconds to wait after a failure',
            schema => 'ufloat*',
            req => 1,
        },
    },
    result_naked => 1,
    result => {
        schema => 'obj*',
    },
};

sub _success {
    my ($self, $timestamp) = @_;
    $self->{delay_on_success};
}

sub _failure {
    my ($self, $timestamp) = @_;
    $self->{delay};
}

1;
#ABSTRACT: Backoff using a constant delay

=head1 SYNOPSIS

 use Algorithm::Backoff::Constant;

 # 1. instantiate

 my $ab = Algorithm::Backoff::Constant->new(
     #consider_actual_delay => 1, # optional, default 0
     #max_actual_duration   => 0, # optional, default 0 (retry endlessly)
     #max_attempts          => 0, # optional, default 0 (retry endlessly)
     #jitter_factor         => 0, # optional, set to positive value to add randomness
     delay                  => 2, # required
     #delay_on_success      => 0, # optional, default 0
 );

 # 2. log success/failure and get a new number of seconds to delay, timestamp is
 # optional argument (default is current time) but must be monotonically
 # increasing.

 my $secs = $ab->failure(1554652553); # => 2
 my $secs = $ab->success();           # => 0
 my $secs = $ab->failure();           # => 2

Illustration using CLI L<show-backoff-delays> (5 failures followed by 3
successes):

 % show-backoff-delays -a Constant --delay 2 \
     0 0 0 0 0   1 1 1
 2
 2
 2
 2
 2
 0
 0
 0


=head1 DESCRIPTION

This backoff strategy is one of the simplest: it waits X second(s) after each
failure, or Y second(s) (default 0) after a success. There are limits on the
number of attempts (`max_attempts`) and total duration (`max_actual_duration`).
Some randomness can be introduced to avoid "thundering herd problem".


=head1 SEE ALSO

L<Algorithm::Backoff>

Other C<Algorithm::Backoff::*> classes.

=cut
