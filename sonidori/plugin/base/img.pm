package base::img;

use warnings;
use strict;
use utf8;

sub new()
{
  my ( $package ) = @_;

  my $hash = {};

  return bless ( $hash, $package );
}

sub Inline()
{
  my ( $self, $sonidori, $img ) = ( @_, '', '', '' );
  return sprintf ( '<img src="%s" />', $img );
}

1;
