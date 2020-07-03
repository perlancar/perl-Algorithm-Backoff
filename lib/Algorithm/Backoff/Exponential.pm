package Algorithm::Backoff::Exponential;

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
        %Algorithm::Backoff::attr_initial_delay,
        exponent_base => {
            schema => 'ufloat*',
            default => 2,
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
    my $delay = $self->{initial_delay} *
        $self->{exponent_base} ** ($self->{_attempts}-1);
}

1;
#ABSTRACT: Backoff exponentially

=head1 SYNOPSIS

 use Algorithm::Backoff::Exponential;

 # 1. instantiate

 my $ab = Algorithm::Backoff::Exponential->new(
     #consider_actual_delay => 1, # optional, default 0
     #max_actual_duration   => 0, # optional, default 0 (retry endlessly)
     #max_attempts          => 0, # optional, default 0 (retry endlessly)
     #jitter_factor         => 0.25, # optional, default 0
     initial_delay          => 5, # required
     #max_delay             => 100, # optional
     #exponent_base         => 2, # optional, default 2 (binary exponentiation)
     #delay_on_success      => 0, # optional, default 0
 );

 # 2. log success/failure and get a new number of seconds to delay, timestamp is
 # optional but must be monotonically increasing.

 # for example, using the parameters initial_delay=5, max_delay=100:

 my $secs;
 $secs = $ab->failure();   # =>  5 (= initial_delay)
 $secs = $ab->failure();   # => 10 (5 * 2^1)
 $secs = $ab->failure();   # => 20 (5 * 2^2)
 $secs = $ab->failure();   # => 33 (5 * 2^3 - 7)
 $secs = $ab->failure();   # => 80 (5 * 2^4)
 $secs = $ab->failure();   # => 100 ( min(5 * 2^5, 100) )
 $secs = $ab->success();   # => 0 (= delay_on_success)

Illustration using CLI L<show-backoff-delays> (10 failures followed by 3
successes):

 % show-backoff-delays -a Exponential --initial-delay 1 --max-delay 200 \
     0 0 0 0 0   0 0 0 0 0   1 1 1
 1
 2
 4
 8
 16
 32
 64
 128
 200
 200
 0
 0
 0


=head1 DESCRIPTION

This backoff algorithm calculates the next delay as:

 initial_delay * exponent_base ** (attempts-1)

Only the C<initial_delay> is required. C<exponent_base> is 2 by default (binary
exponential). For the first failure attempt (C<attempts> = 1) the delay equals
the initial delay. Then it is doubled, quadrupled, and so on (using the default
exponent base of 2).

There are limits on the number of attempts (`max_attempts`) and total duration
(`max_actual_duration`).

It is recommended to add a jitter factor, e.g. 0.25 to add some randomness to
avoid "thundering herd problem".


=head1 SEE ALSO

L<https://en.wikipedia.org/wiki/Exponential_backoff>

L<Algorithm::Backoff>

Other C<Algorithm::Backoff::*> classes.

=cut
