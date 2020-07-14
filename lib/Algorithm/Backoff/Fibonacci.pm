package Algorithm::Backoff::Fibonacci;

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
        initial_delay1 => {
            summary => 'Initial delay for the first attempt after failure, '.
                'in seconds',
            schema => 'ufloat*',
            req => 1,
        },
        initial_delay2 => {
            summary => 'Initial delay for the second attempt after failure, '.
                'in seconds',
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
    if ($self->{_attempts} == 1) {
        $self->{_delay_n_min_1} = 0;
        $self->{_delay_n}       = $self->{initial_delay1};
    } elsif ($self->{_attempts} == 2) {
        $self->{_delay_n_min_1} = $self->{initial_delay1};
        $self->{_delay_n}       = $self->{initial_delay2};
    } else {
        my $tmp                   = $self->{_delay_n};
        $self->{_delay_n}         = $self->{_delay_n_min_1} + $self->{_delay_n};
        $self->{_delay_n_min_1}   = $tmp;
        $self->{_delay_n};
    }
}

1;
#ABSTRACT: Backoff using Fibonacci sequence

=head1 SYNOPSIS

 use Algorithm::Backoff::Fibonacci;

 # 1. instantiate

 my $ab = Algorithm::Backoff::Fibonacci->new(
     #consider_actual_delay => 1, # optional, default 0
     #max_actual_duration   => 0, # optional, default 0 (retry endlessly)
     #max_attempts          => 0, # optional, default 0 (retry endlessly)
     #jitter_factor         => 0.25, # optional, default 0
     initial_delay1         => 2, # required
     initial_delay2         => 3, # required
     #max_delay             => 20, # optional
     #delay_on_success      => 0, # optional, default 0
 );

 # 2. log success/failure and get a new number of seconds to delay, timestamp is
 # optional but must be monotonically increasing.

 my $secs;
 $secs = $ab->failure();   # =>  2 (= initial_delay1)
 $secs = $ab->failure();   # =>  3 (= initial_delay2)
 $secs = $ab->failure();   # =>  5 (= 2+3)
 $secs = $ab->failure();   # =>  8 (= 3+5)
 sleep 1;
 $secs = $ab->failure();   # => 12 (= 5+8 -1)
 $secs = $ab->failure();   # => 20 (= min(13+8, 20) = max_delay)

 $secs = $ab->success();   # =>  0 (= delay_on_success)

Illustration using CLI L<show-backoff-delays> (10 failures followed by 3
successes):

 % show-backoff-delays -a Fibonacci --initial-delay1 0 --initial-delay2 1 \
     0 0 0 0 0   0 0 0 0 0   1 1 1
 0
 1
 1
 2
 3
 5
 8
 13
 21
 34
 0
 0
 0


=head1 DESCRIPTION

This backoff algorithm calculates the next delay using Fibonacci sequence. For
example, if the two initial numbers are 2 and 3:

 2, 3, 5, 8, 13, 21, ...

C<initial_delay1> and C<initial_delay2> are required. The other attributes are
optional.

There are limits on the number of attempts (`max_attempts`) and total duration
(`max_actual_duration`).

It is recommended to add a jitter factor, e.g. 0.25 to add some randomness to
avoid "thundering herd problem".


=head1 SEE ALSO

L<https://en.wikipedia.org/wiki/Fibonacci_number>

L<Algorithm::Backoff>

Other C<Algorithm::Backoff::*> classes.

=cut
