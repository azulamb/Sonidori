package base::breadcrumbs;

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
  my ( $self, $sonidori ) = ( @_, '', '' );

  my $path = $sonidori->{ 'ENV' }{ 'filepath' };
  my $spath = $path;

  $path =~ s/$sonidori->{ 'SYSTEM' }{ 'PUBLIC_DIR' }//;
  $path =~ s/^\///;
  $path =~ s/^\.//;
  $path =~ s/\/+/\//g;

  if ( $path =~ /\./ )
  {
    my @name = split( /\./, $path );
    pop( @name );
    $path = join( '.', @name );
  }
  if ( $path eq '' ){ $path = '.'; }

  my @dir = split ( /\//, $path );
  my $last = sprintf( '<a href="%s?%s=%s&%s">%s</a>', $sonidori->{ 'SYSTEM' }{ 'CGI' }, (-f $spath) ? 'page' : 'dir', &Common::URLEncode( $path ), $sonidori->CreateGetData(), pop( @dir ) );

  $spath = '';
  foreach ( @dir )
  {
    if ( $spath eq '' ){ $spath = $_; } else{ $spath = $spath . '/' . $_; }
    $_ = sprintf ( '<a href="%s?dir=%s&%s">%s</a>', $sonidori->{ 'SYSTEM' }{ 'CGI' }, &Common::URLEncode( $spath ), $sonidori->CreateGetData(), $_ );
  }

  if ( $path ne '.' ){ unshift ( @dir, sprintf ( '<a href="%s?dir=%s&%s">%s</a>', $sonidori->{ 'SYSTEM' }{ 'CGI' }, &Common::URLEncode( '.' ), $sonidori->CreateGetData(), '.' ) ); }

  return '<div>' . join( ' / ', @dir, $last ) . '</div>';
}

1;
