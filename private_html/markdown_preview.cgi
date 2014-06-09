#!/usr/bin/perl --

use strict;
use warnings;

require bytes;

use Text::Markdown 'markdown';
use Encode;

########################################
# Setting                              #
########################################

our $POST_MAX = 0;

########################################
# Program                              #
########################################

my $html = &Main();
print "Content-type: text/html\n";
print "Content-length: " . bytes::length( $html ) . "\n";
print "\n";
print $html;

sub Main()
{
  my $query = '';
  my %opt;
  if ( exists( $ENV{ 'CONTENT_LENGTH' } ) )
  {
    if ( $POST_MAX > 0 && $ENV{ 'CONTENT_LENGTH' } > $POST_MAX )
    {
      return "Size over.";
    }
    read (STDIN, $query, $ENV{'CONTENT_LENGTH'});
    $query = &Decode( $query );
  }

  if ( exists( $ENV{ 'QUERY_STRING' } ) )
  {
    my @args = split( /&/, $ENV{ 'QUERY_STRING' } );
    foreach( @args )
    {
      my ( $name, $val ) = split( /=/, $_, 2 );
      $opt{ $name } = &Decode( decode_utf8( $val ) );
    }
  }

  return encode_utf8( markdown( $query, { empty_element_suffix => '>', tab_width => 2, } ) );
}

sub Decode()
{
  my ( $query ) = ( @_ );
  $query =~ tr/+/ /;
  $query =~ s/%([0-9a-fA-F][0-9a-fA-F])/pack('C', hex($1))/eg;
  return decode_utf8( $query );
}
