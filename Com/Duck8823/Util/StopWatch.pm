package Com::Duck8823::Util::StopWatch;

use Exporter;

@ISA = (Exporter);
@EXPORT = qw(new start stop clear get_time);

use Time::HiRes qw(gettimeofday tv_interval);

sub new {
  my $pkg = shift;
  my $self = {
    start => undef,
    stop  => undef
  };
  return bless($self, $pkg);
}

sub start {
  my $self = shift;
  $self->{start} = [gettimeofday()];
}

sub stop {
  my $self = shift;
  $self->{stop} = tv_interval($self->{start});
}

sub get_time {
  my $self = shift;
  return int($self->{stop} * 1000);
}

sub reset {
  my $self = shift;
  $self = {
    start => undef,
    stop  => undef
  };
}

1;
