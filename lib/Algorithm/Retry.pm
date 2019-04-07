package Algorithm::Retry;

# DATE
# VERSION

use 5.010001;
use strict 'subs', 'vars';
use warnings;

use Time::HiRes qw(time);

sub new {
    my ($class, %args) = @_;

    my $argspec = \%{"$class\::argspec"};
    # check known arguments
    for my $arg (keys %args) {
        $argspec->{$arg} or die "$class: Unknown argument '$arg'";
    }
    # check required arguments and set default
    for my $arg (keys %$argspec) {
        if ($argspec->{$arg}{req}) {
            exists($args{$arg})
                or die "$class: Missing required argument '$arg'";
        }
        if (exists $argspec->{$arg}{default}) {
            $args{$arg} //= $argspec->{$arg}{default};
        }
    }
    bless \%args, $class;
}

sub _success_or_failure {
    my ($self, $is_success, $timestamp) = @_;
    $timestamp //= time();
    $self->{_last_timestamp} //= $timestamp;
    $timestamp >= $self->{_last_timestamp} or
        die ref($self).": Decreasing timestamp ".
        "($self->{_last_timestamp} -> $timestamp)";
    $is_success ? $self->_success($timestamp) : $self->_failure($timestamp);
}

sub success {
    my $self = shift;
    $self->_success_or_failure(1, @_);
}

sub failure {
    my $self = shift;
    $self->_success_or_failure(0, @_);
}

1;
#ABSTRACT: Various retry algorithms/strategies

=head1 SYNOPSIS

 use Algorithm::Retry::Constant;

 # 1. instantiate a strategy

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

This distribution provides several classes that implement various retry
strategies.


=head1 SEE ALSO

=cut
