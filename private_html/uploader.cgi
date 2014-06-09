#!/usr/bin/perl --

use strict;
use warnings;
no warnings qw(once);
use CGI;

########################################
# Setting                              #
########################################

require './setting.pl';

#our $DOCROOT = '.';
#our $DIRPARMISIION  = 0705;
#our $BUFFERSIZE = 1024;
#our $MAXSIZE = 0;
#our $JSONCONTENTTYPE = 'Content-Type: application/json; charset=utf-8';

########################################
# Program                              #
########################################

print &Main();

sub Main()
{
  my $query = new CGI;

  my $ref = &Decode( $query->param( 'ref' ) );

  my $upfile = ( $query->param( 'upfile' ) );

  # File size check.
  if ( $STEELBLUESETTING::MAXSIZE > 0 )
  {
    my ( @state ) = stat( $upfile );
    if ( $STEELBLUESETTING::MAXSIZE < $state[ 7 ] ){ return &Error( $ref, sprintf( 'File size over(max:%dB).', $STEELBLUESETTING::MAXSIZE ) ); }
  }

  # Path check.
  my $path = &Decode( $query->param( 'path' ) );
  if ( $path =~ /(\.\.)/ || $path =~ /^(\/)/ ){ return &Error( $ref, 'Upload path error.' ); }
  if ( $path eq '' ){ $path = './'; }

  #if ( !( $upfile ) || $upfile =~ /(\/)$/ || $upfile =~ /([^ \da-zA-Z\_\-\+\=\(\) \"\'\:\;\&\%\$\#\@\!\?\<\>\[\]\{\}\.\,])/ ){ return &Error( $ref, sprintf( 'File name illegal.(%s)', ($upfile?$upfile:'nofile') ) ); }
  if ( !( $upfile ) || $upfile =~ /(\/)$/ ){ return &Error( $ref, sprintf( 'File name illegal.(%s)', ($upfile?$upfile:'nofile') ) ); }

  # Directory check & create filepath;
  unless ( -d $STEELBLUESETTING::DOCROOT . '/' . $path )
  {
    my $name;
    my ( @el ) = split( /\//, $path );

    if ( $path =~ /(\/)$/ )
    {
      # Path is directory.
      $name = &Decode( $upfile );
    } else
    {
      # Path is filepath.
      $name = pop( @el );
    }

    # Make directory.
    $path = shift( @el ) . '/';
    foreach ( @el )
    {
      unless ( -d $STEELBLUESETTING::DOCROOT . '/' . $path . $_ ){ mkdir( $STEELBLUESETTING::DOCROOT . '/' . $path . $_, $STEELBLUESETTING::DIRPARMISIION ); }
      $path .= $_ . '/';
    }

    $path .= $name;
  } else
  {
    my ( $name ) = ( &Decode( $upfile ), '' );
    $path .= ( ($path =~ /(\/)$/) ? '' : '/' ) . $name;
  }

  $path = $STEELBLUESETTING::DOCROOT . '/' . $path;

  # File copy.
  if ( !($upfile) || &CopyFile( $path, $upfile ) ){ return &Error( $ref, sprintf( 'Cannot create file.(%s)', $path ) ); }

  close( $upfile );
&DebugOut( $path );
  return &Success( $ref );
}

sub CopyFile()
{
  my ( $path, $upfile ) = ( @_ );
  my $buffer;

  if ( open( OUT, ">$path" ) )
  {
    binmode( OUT );
    while( read( $upfile, $buffer, $STEELBLUESETTING::BUFFERSIZE ) )
    {
      print OUT $buffer;
    }
    close( OUT );
    return 0;
  }
  return 1;
}

sub Location()
{
  return sprintf( 'Location:%s', $_[ 0 ] ) . "\n\n";
}

sub Success()
{
  my ( $ref ) = ( @_ );
  if ( $ref ) { return &Location( $ref ); }
  return sprintf( '%s{"result":"success"}', $STEELBLUESETTING::JSONCONTENTTYPE . "\n\n" );
}

sub Error()
{
  my ( $ref, $msg ) = ( @_ );
  if ( $ref ) { return &Location( $ref ); }
  my $html = sprintf( '%s{"result":"failure","msg":"%s"}', $STEELBLUESETTING::JSONCONTENTTYPE . "\n\n", $msg );
  &DebugOut( $html );
  return $html;
}

sub Decode()
{
  my ( $val ) = ( @_, "" );
  $val =~ tr/+/ /;
  $val =~ s/%([0-9a-fA-F][0-9a-fA-F])/pack('C', hex($1))/eg;
  return $val;
}

sub DebugOut()
{
  if( open(LOG,'>error_upload') ){print LOG $_[ 0 ];close(LOG);}
}
