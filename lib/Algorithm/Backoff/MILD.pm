package Algorithm::Backoff::MILD;

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
        %Algorithm::Backoff::attr_delay_multiple_on_failure,
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

    my $delay = $self->{_prev_delay} * $self->{delay_multiple_on_failure};

    $delay;
}

1;
#ABSTRACT: Multiplicative Increment, Linear Decrement (MILD) backoff

=head1 SYNOPSIS

 use Algorithm::Backoff::MILD;

 # 1. instantiate

 my $ab = Algorithm::Backoff::MILD->new(
     #consider_actual_delay => 1, # optional, default 0
     #max_actual_duration   => 0, # optional, default 0 (retry endlessly)
     #max_attempts          => 0, # optional, default 0 (retry endlessly)
     #jitter_factor         => 0.25, # optional, default 0
     #min_delay             => 2, # optional, default 0
     #max_delay             => 100, # optional
     initial_delay              => 1,   # required
     delay_multiple_on_failure  => 1.5, # required
     delay_increment_on_success => -2,  # required
 );

 # 2. log success/failure and get a new number of seconds to delay, timestamp is
 # optional but must be monotonically increasing.

 # for example, using the parameters initial_delay=1,
 # delay_multiple_on_failure=1.5, delay_increment_on_success=-2, min_delay=0.5:

 my $secs;
 $secs = $ab->failure();   # => 1    (= initial_delay)
 $secs = $ab->failure();   # => 1.5  (1 * 1.5)
 $secs = $ab->failure();   # => 2.25 (1.5 * 1.5)
 $secs = $ab->success();   # => 0.25 (2.25 - 2)
 $secs = $ab->success();   # => 1 (max(0.25 - 2, 0.5, 1))
 $secs = $ab->failure();   # => 1.5 (1 * 1.5)
 $secs = $ab->success();   # => 0 (= delay_on_success)


=head1 DESCRIPTION

Upon failure, this backoff algorithm calculates the next delay as:

 D1 = initial_delay
 D2 = max(min(D1 * delay_multiple_on_failure, max_delay), min_delay)
 ...

Upon success, the next delay is calculated as:

 D1 = initial_delay
 D2 = max(D1 + delay_increment_on_success, min_delay, initial_delay)

C<initial_delay>, C<delay_multiple_on_failure>, and
C<delay_increment_on_success> are required. C<initial_delay> and C<min_delay>
should be larger than zero; otherwise the next delays will all be zero.

There are limits on the number of attempts (`max_attempts`) and total duration
(`max_actual_duration`).

It is recommended to add a jitter factor, e.g. 0.25 to add some randomness to
avoid "thundering herd problem".


=head1 SEE ALSO

L<Algorithm::Backoff::LILD>

L<Algorithm::Backoff::LIMD>

L<Algorithm::Backoff::MIMD>

L<Algorithm::Backoff>

Other C<Algorithm::Backoff::*> classes.

=cut
