package Template;

use warnings;
use strict;

sub MarkDown()
{
  my ( $obj, @args ) = @_;
  return $obj->DefaultViewMarkdown( @args );
}

sub Directory()
{
  my ( $obj, @args ) = @_;
  return $obj->DefaultViewDirectory( @args );
}

1;
