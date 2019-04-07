package Algorithm::Retry::Constant;

# DATE
# VERSION

use strict;
use warnings;

use parent qw(Algorithm::Retry);

our %argspec = (
    delay_on_failure => {
        summary => 'Number of seconds to wait after a failure',
        schema => 'nonnegnum*',
        req => 1,
    },
    delay_on_success => {
        summary => 'Number of seconds to wait after a success',
        schema => 'nonnegnum*',
        default => 0,
    },
);

sub _success {
    my ($self, $timestamp) = @_;
    $self->{delay_on_success};
}

sub _failure {
    my ($self, $timestamp) = @_;
    $self->{delay_on_failure};
}

1;
#ABSTRACT: Retry endlessly using a constant wait

=head1 SYNOPSIS

 use Algorithm::Retry::Constant;

 # 1. instantiate

 my $ar = Algorithm::Retry::Constant->new(
     delay_on_failure  => 2, # required
     #delay_on_success => 0, # optional, default 0
 );

 # 2. log success/failure and get a new number of seconds to delay, timestamp is
 # optional but must be monotonically increasing.

 my $secs = $ar->failure(1554652553); # => 2
 my $secs = $ar->success();           # => 0
 my $secs = $ar->failure();           # => 2


=head1 DESCRIPTION

This retry strategy is one of the simplest: it waits X second(s) after each
failure, or Y second(s) (default 0) after a success.


=head1 SEE ALSO

Other C<Algorithm::Retry::*> classes.

=cut
