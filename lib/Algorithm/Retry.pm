package Algorithm::Retry;

# DATE
# VERSION

use 5.010001;
use strict 'subs', 'vars';
use warnings;

use Time::HiRes qw(time);

our %attrspec = (
    max_attempts => {
        summary => 'Maximum number consecutive failures before giving up',
        schema => 'nonnegint*',
        default => 0,
        description => <<'_',

0 means to retry endlessly without ever giving up. 1 means to give up after a
single failure (i.e. no retry attempts). 2 means to retry once after a failure.
Note that after a success, the number of attempts is reset (as expected). So if
max_attempts is 3, and if you fail twice then succeed, then on the next failure
the algorithm will retry again for a maximum of 3 times.

_
    },
    jitter_factor => {
        summary => 'How much to add randomness',
        schema => ['float*', between=>[0, 0.5]],
        description => <<'_',

If you set this to a value larger than 0, the actual delay will be between a
random number between original_delay * (1-jitter_factor) and original_delay *
(1+jitter_factor).

_
    },
);

sub new {
    my ($class, %args) = @_;

    my $attrspec = \%{"$class\::attrspec"};
    # check known attributes
    for my $arg (keys %args) {
        $attrspec->{$arg} or die "$class: Unknown attribute '$arg'";
    }
    # check required attributes and set default
    for my $attr (keys %$attrspec) {
        if ($attrspec->{$attr}{req}) {
            exists($args{$attr})
                or die "$class: Missing required attribute '$attr'";
        }
        if (exists $attrspec->{$attr}{default}) {
            $args{$attr} //= $attrspec->{$attr}{default};
        }
    }
    $args{_attempts} = 0;
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
    $self->{_attempts} = 0;
    $self->_add_jitter($self->_success_or_failure(1, @_));
}

sub failure {
    my $self = shift;
    $self->{_attempts}++;
    return -1 if $self->{max_attempts} &&
        $self->{_attempts} >= $self->{max_attempts};
    $self->_add_jitter($self->_success_or_failure(0, @_));
}

sub _add_jitter {
    my ($self, $delay) = @_;
    return $delay unless $delay && $self->{jitter_factor};
    my $min = $delay * (1-$self->{jitter_factor});
    my $max = $delay * (1+$self->{jitter_factor});
    $min + ($max-$min)*rand();
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
