package base::editlink;

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
  if ( $sonidori->{ 'SYSTEM' }{ 'ENABLE_EDIT' } == 0 )
  {
    return '';
  } elsif( $sonidori->{ 'GET' }{ 'edit' } ne '' )
  {
    return '<div class="editlink">編集</div>';
  }
  return sprintf ( '<div class="editlink"><a href="%s?page=%s&edit=1">編集</a></div>', $sonidori->{ 'SYSTEM' }{ 'CGI' }, &Common::URLEncode( $sonidori->{ 'ENV' }{ 'page' } ) );
}

1;
