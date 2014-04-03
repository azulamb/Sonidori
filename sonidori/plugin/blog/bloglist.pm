package blog::bloglist;

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
  my ( $self, $sonidori, $path ) = ( @_, '', '', '' );

  if ( $path eq '' )
  {
    $path = $sonidori->{ 'ENV' }{ 'filepath' };
  }

  until ( -d $path )
  {
    my ( @dir ) = split( /\//, $path );
    pop( @dir );
    $path = join( '/', @dir );
    if ( $path eq '' ){ last; }
  }

  my @dirlist = &Common::DirectoryList( $path );

  my $spath = $path;
  $spath =~ s/$sonidori->{ 'SYSTEM' }{ 'BLOG_DIR' }//;
  $spath =~ s/^\///;
  $spath =~ s/^\.//;
  $spath =~ s/\/+/\//g;

  my @dirs = ();
  my @files = ();
  my $tail = '.' . $sonidori->{ 'SYSTEM' }{ 'TAIL' };
  foreach ( @dirlist )
  {
    if ( -f $path . '/' . $_ )
    {
      if ( $_ =~ /($tail)$/ )
      {
        push ( @files, $_ );
      }
    } else
    {
      push ( @dirs, $_ );
    }
  }

  @dirs = sort{ $a cmp $b }( @dirs );
  @files = sort{ $a cmp $b }( @files );

  my $html = "<ul>\n";

  ################
  # Todo: Blog List
  ################

#  if ( $spath ne '' )
#  {
#    my ( @name ) = split( /\//, $spath );
#    pop( @name );
#    my $updir = join( '/', @name );
#    if ( $updir eq '' ){ $updir = '.'; }
#    $html .= sprintf( '<li id="dir"><a href="%s?blog=%s&%s">%s</a></li>%s', $sonidori->{ 'SYSTEM' }{ 'CGI' }, &Common::URLEncode( $updir ), $sonidori->CreateGetData(), '../', "\n" );
#    $spath .= '/';
#  }

#  foreach ( @dirs )
#  {
#    $html .= sprintf( '<li id="dir"><a href="%s?blog=%s&%s">%s/</a></li>%s', $sonidori->{ 'SYSTEM' }{ 'CGI' }, &Common::URLEncode( $spath . $_ ), $sonidori->CreateGetData(), $_, "\n" );
#  }
#  foreach ( @files )
#  {
#    my ( @name ) = split( /\./, $_ );
#    my $tail = pop( @name );
#    my $name = join( '.', @name );
#    $html .= sprintf( '<li id="file"><a href="%s?blog=%s%s&%s">%s</a></li>%s', $sonidori->{ 'SYSTEM' }{ 'CGI' }, &Common::URLEncode( $spath . $name ), $tail eq 'md' ? '' : 'tail=' . $tail, $sonidori->CreateGetData(), $name, "\n" );
#  }
  $html .= "</ul>\n";

  return $html;
}

1;
