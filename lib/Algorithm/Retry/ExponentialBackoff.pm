package Algorithm::Retry::ExponentialBackoff;

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
        %Algorithm::Retry::attr_max_attempts,
        %Algorithm::Retry::attr_jitter_factor,
        %Algorithm::Retry::attr_delay_on_success,
        %Algorithm::Retry::attr_max_delay,
        initial_delay => {
            summary => 'Initial delay for the first attempt after failure, '.
                'in seconds',
            schema => 'ufloat*',
            req => 1,
        },
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

 use Algorithm::Retry::ExponentialBackoff;

 # 1. instantiate

 my $ar = Algorithm::Retry::ExponentialBackoff->new(
     #max_attempts     => 0, # optional, default 0 (retry endlessly)
     #jitter_factor    => 0.25, # optional, default 0
     initial_delay     => 5, # required
     #max_delay        => 100, # optional
     #exponent_base    => 2, # optional, default 2 (binary exponentiation)
     #delay_on_success => 0, # optional, default 0
 );

 # 2. log success/failure and get a new number of seconds to delay, timestamp is
 # optional but must be monotonically increasing.

 # for example, using the parameters initial_delay=5, max_delay=100:

 my $secs;
 $secs = $ar->failure();   # =>  5 (= initial_delay)
 $secs = $ar->failure();   # => 10 (5 * 2^1)
 $secs = $ar->failure();   # => 20 (5 * 2^2)
 sleep 7;
 $secs = $ar->failure();   # => 33 (5 * 2^3 - 7)
 $secs = $ar->failure();   # => 80 (5 * 2^4)
 $secs = $ar->failure();   # => 100 ( min(5 * 2^5, 100) )
 $secs = $ar->success();   # => 0 (= delay_on_success)


=head1 DESCRIPTION

This backoff algorithm calculates the next delay as:

 initial_delay * exponent_base ** (attempts-1)

Only the C<initial_delay> is required. C<exponent_base> is 2 by default (binary
expoential). For the first failure attempt (C<attempts> = 1) the delay equals
the initial delay. Then it is doubled, quadrupled, and so on (using the default
exponent base of 2).

It is recommended to add a jitter factor, e.g. 0.25 to add some randomness.


=head1 SEE ALSO

L<https://en.wikipedia.org/wiki/Exponential_backoff>

L<Algorithm::Retry>

Other C<Algorithm::Retry::*> classes.

=cut
