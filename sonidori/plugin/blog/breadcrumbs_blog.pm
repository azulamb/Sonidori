package blog::breadcrumbs_blog;

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
  my ( $self, $sonidori ) = ( @_, '' );

  my $path = $sonidori->{ 'GET' }{ 'blog' };
  if ( $path eq '' ){ $path = 'top'; }
  $path =~ /([0-9]+)/;
  my $spath = $1;

  my @dir = ();

  if ( $spath )
  {
    if ( $spath =~ /([0-9]{4})([0-9]{2})([0-9]{2})/ )
    {
      @dir = ( $1, $2, $3 );
    } elsif ( $spath =~ /([0-9]{4})([0-9]{2})/ )
    {
      @dir = ( $1, $2 );
    } elsif ( $spath =~ /([0-9]{4})/ )
    {
      @dir = ( $1 );
    }

  }

  $spath = '';
  foreach ( @dir )
  {
    $spath .= $_;
    $_ = sprintf ( '<a href="%s?blog=%s&%s">%s</a>', $sonidori->{ 'SYSTEM' }{ 'CGI' }, $spath, $sonidori->CreateGetData(), $_ );
  }

  return '<div>' . join( ' / ', @dir ) . '</div>';
}

1;
