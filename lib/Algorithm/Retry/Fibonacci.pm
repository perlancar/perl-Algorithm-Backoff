package Algorithm::Retry::Fibonacci;

# DATE
# VERSION

use strict;
use warnings;

use parent qw(Algorithm::Retry);

our %SPEC;

$SPEC{new} = {
    v => 1.1,
    is_class_meth => 1,
    is_func => 0,
    args => {
        %Algorithm::Retry::attr_consider_actual_delay,
        %Algorithm::Retry::attr_max_attempts,
        %Algorithm::Retry::attr_jitter_factor,
        %Algorithm::Retry::attr_delay_on_success,
        %Algorithm::Retry::attr_max_delay,
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

 use Algorithm::Retry::Fibonacci;

 # 1. instantiate

 my $ar = Algorithm::Retry::Fibonacci->new(
     #max_attempts     => 0, # optional, default 0 (retry endlessly)
     #jitter_factor    => 0.25, # optional, default 0
     initial_delay1    => 2, # required
     initial_delay2    => 3, # required
     #max_delay        => 20, # optional
     #delay_on_success => 0, # optional, default 0
 );

 # 2. log success/failure and get a new number of seconds to delay, timestamp is
 # optional but must be monotonically increasing.

 my $secs;
 $secs = $ar->failure();   # =>  2 (= initial_delay1)
 $secs = $ar->failure();   # =>  3 (= initial_delay2)
 $secs = $ar->failure();   # =>  5 (= 2+3)
 $secs = $ar->failure();   # =>  8 (= 3+5)
 sleep 1;
 $secs = $ar->failure();   # => 12 (= 5+8 -1)
 $secs = $ar->failure();   # => 20 (= min(13+8, 20) = max_delay)

 $secs = $ar->success();   # =>  0 (= delay_on_success)

=head1 DESCRIPTION

This backoff algorithm calculates the next delay using Fibonacci sequence. For
example, if the two initial numbers are 2 and 3:

 2, 3, 5, 8, 13, 21, ...

C<initial_delay1> and C<initial_delay2> are required. The other attributes are
optional. It is recommended to add a jitter factor, e.g. 0.25 to add some
randomness.


=head1 SEE ALSO

L<https://en.wikipedia.org/wiki/Fibonacci_number>

L<Algorithm::Retry>

Other C<Algorithm::Retry::*> classes.

=cut
