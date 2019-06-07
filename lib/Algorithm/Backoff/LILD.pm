package Algorithm::Backoff::LILD;

# DATE
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
        %Algorithm::Backoff::attr_max_delay,
        %Algorithm::Backoff::attr_min_delay,
        %Algorithm::Backoff::attr_initial_delay,
        %Algorithm::Backoff::attr_delay_increment_on_failure,
        %Algorithm::Backoff::attr_delay_increment_on_success,
    },
    result_naked => 1,
    result => {
        schema => 'obj*',
    },
};

sub _success {
    my ($self, $timestamp) = @_;

    unless (defined $self->{_prev_delay}) {
        return $self->{_prev_delay} = $self->{initial_delay};
    }

    my $delay = $self->{_prev_delay} + $self->{delay_increment_on_success};

    $delay;
}

sub _failure {
    my ($self, $timestamp) = @_;

    unless (defined $self->{_prev_delay}) {
        return $self->{_prev_delay} = $self->{initial_delay};
    }

    my $delay = $self->{_prev_delay} + $self->{delay_increment_on_failure};

    $delay;
}

1;
#ABSTRACT: Linear Increment, Linear Decrement (LILD) backoff

=head1 SYNOPSIS

 use Algorithm::Backoff::LILD;

 # 1. instantiate

 my $ab = Algorithm::Backoff::LILD->new(
     #consider_actual_delay => 1, # optional, default 0
     #max_actual_duration   => 0, # optional, default 0 (retry endlessly)
     #max_attempts          => 0, # optional, default 0 (retry endlessly)
     #jitter_factor         => 0.25, # optional, default 0
     min_delay              => 1, # optional, default 0
     #max_delay             => 100, # optional
     initial_delay              =>  3, # required
     delay_increment_on_failure =>  4, # required
     delay_increment_on_success => -5, # required
 );

 # 2. log success/failure and get a new number of seconds to delay, timestamp is
 # optional but must be monotonically increasing.

 # for example, using the parameters initial_delay=3,
 # delay_increment_on_failure=4, delay_increment_on_success=-5, min_delay=1:

 my $secs;
 $secs = $ab->failure();   # => 3  (= initial_delay)
 $secs = $ab->failure();   # => 7  (3 + 4)
 $secs = $ab->failure();   # => 11 (7 + 4)
 $secs = $ab->success();   # => 6  (11 - 5)
 $secs = $ab->success();   # => 1  (6 - 5)
 $secs = $ab->success();   # => 1  (max(1 - 5, 0, min_delay=1))
 $secs = $ab->failure();   # => 5  (1 + 4)

Illustration using CLI L<show-backoff-delays> (3 failures followed by 5
successes, followed by 3 failures):

 % show-backoff-delays -a LILD --initial-delay 3 --min-delay 1 \
     --delay-increment-on-failure 4 --delay-increment-on-success -5 \
     0 0 0   1 1 1 1  0 0 0
 3
 7
 11
 6
 1
 1
 1
 5
 9
 13


=head1 DESCRIPTION

Upon failure, this backoff algorithm calculates the next delay as:

 D1 = initial_delay
 D2 = max(min(D1 + delay_increment_on_failure, max_delay), min_delay)
 ...

Upon success, the next delay is calculated as:

 D1 = initial_delay
 D2 = max(D1 + delay_increment_on_success, min_delay, initial_delay)
 ...

C<initial_delay>, C<delay_increment_on_failure>, and
C<delay_increment_on_success> are required.

There are limits on the number of attempts (`max_attempts`) and total duration
(`max_actual_duration`).

It is recommended to add a jitter factor, e.g. 0.25 to add some randomness to
avoid "thundering herd problem".


=head1 SEE ALSO

L<Algorithm::Backoff::LIMD>

L<Algorithm::Backoff::MILD>

L<Algorithm::Backoff::MIMD>

L<Algorithm::Backoff>

Other C<Algorithm::Backoff::*> classes.

=cut
