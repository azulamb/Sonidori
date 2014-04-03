package admin::Install;

use warnings;
use strict;
use utf8;

sub Install()
{
  my ( $obj ) = @_;
  $obj->AddInlinePlugin( '', 'admin::plugin' );

}

1;
