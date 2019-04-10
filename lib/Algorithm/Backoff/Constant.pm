package Algorithm::Backoff::Constant;

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
        %Algorithm::Backoff::attr_max_attempts,
        %Algorithm::Backoff::attr_jitter_factor,
        %Algorithm::Backoff::attr_delay_on_success,
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

 my $ar = Algorithm::Backoff::Constant->new(
     #consider_actual_delay => 1, # optional, default 0
     #max_attempts     => 0, # optional, default 0 (retry endlessly)
     #jitter_factor    => 0, # optional, set to positive value to add randomness
     delay             => 2, # required
     #delay_on_success => 0, # optional, default 0
 );

 # 2. log success/failure and get a new number of seconds to delay, timestamp is
 # optional argument (default is current time) but must be monotonically
 # increasing.

 my $secs = $ar->failure(1554652553); # => 2
 my $secs = $ar->success();           # => 0
 my $secs = $ar->failure();           # => 2


=head1 DESCRIPTION

This backoff strategy is one of the simplest: it waits X second(s) after each
failure, or Y second(s) (default 0) after a success. Some randomness can be
introduced to avoid "thundering herd problem".


=head1 SEE ALSO

L<Algorithm::Backoff>

Other C<Algorithm::Backoff::*> classes.

=cut
