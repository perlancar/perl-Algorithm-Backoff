package Algorithm::Retry::Constant;

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
#ABSTRACT: Retry using a constant wait time

=head1 SYNOPSIS

 use Algorithm::Retry::Constant;

 # 1. instantiate

 my $ar = Algorithm::Retry::Constant->new(
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

This retry strategy is one of the simplest: it waits X second(s) after each
failure, or Y second(s) (default 0) after a success. Some randomness can be
introduced to avoid "thundering herd problem".


=head1 SEE ALSO

L<Algorithm::Retry>

Other C<Algorithm::Retry::*> classes.

=cut
