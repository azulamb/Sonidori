package Common;

# Common Library

use warnings;
use strict;
use utf8;
use open IO => ":utf8";

# Please install Perl Module.
use Text::Markdown 'markdown';

sub DirectoryList( \$ )
{
  my ( $dir ) = @_;
  my @ret = ();

  if ( -d $dir && opendir( DIR, $dir ) )
  {
    foreach ( readdir( DIR ) )
    {
      unless ( $_ =~ /^\./ )
      {
        push( @ret, $_ );
      }
    }
    close ( DIR );
  }

  return @ret;
}

sub OpenFile( \$ )
{
  my ( $file ) = ( @_, '' );
  my @ret;

  if ( -r $file && open( FILE, $file ) )
  {
    @ret = <FILE>;
    close( FILE );
  }

  return @ret;
}

sub OpenBinFile( \$ )
{
  my @ret;

  if ( open( FILE, $_[ 0 ] ) )
  {
    binmode FILE;
    @ret = <FILE>;
    close( FILE );
  }

  return @ret;
}

sub URLEncode
{
  my( @encode ) = @_;
  foreach ( @encode )
  {
    $_ =~ s/([^\w\=\& ])/'%'.unpack("H2", $1)/eg;
    $_ =~ tr/ /+/;
  }
  if ( scalar( @encode ) == 1 )
  {
    return $encode[0];
  } else
  {
    return @encode;
  }
}

sub Markdown( \$ )
{
  my ( $text ) = ( @_, '' );
  return markdown ( $text, { empty_element_suffix => '>', tab_width => 2, } );
}

# PC, Android, AndroidMobile, iPhone, WindowsPhone
sub GetPageType()
{
  my $ua = exists( $ENV{ 'HTTP_USER_AGENT' } ) ? $ENV{ 'HTTP_USER_AGENT' } : '';

  if ( $ua =~ /Android/ )
  {
    if ( $ua =~ /Mobile/ ){ return 'AndroidMobile'; }
    return 'Android';
  }

  if ( $ua =~ /iPhone/ )
  {
    return 'iPhone';
  }

  if ( $ua =~ /Windows.+Phone/ )
  {
    return 'WindowsPhone';
  }

  return 'PC';
}

sub IsRequestPC()
{
  my $type = &Common::GetPageType();
  return ( $type eq 'PC' );
}

sub IsRequestPCTablet()
{
  my $type = &Common::GetPageType();
  return ( $type eq 'PC' || $type eq 'Android' );
}

sub IsRequestSmartPhone()
{
  my $type = &Common::GetPageType();
  return ( $type eq 'Android' || $type eq 'iPhone' || $type eq 'WindowsPhone' );
}

sub DateRFC1123()
{
  my ( $time ) = ( @_, -1 );

  if ( $time < -1 )
  {
    $time = time();
  }

  my ( $sec, $min, $hour, $day, $mon, $year, $week ) = localtime( $time );

  my @WEEK = ( 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' );
  my @MON = ( 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' );
  return sprintf( '%s, %d %s %d %02d:%02d:%02d GMT', $WEEK[ $week ], $day, $MON[ $mon ], 1900 + $year, $hour, $min, $sec );
}

1;
