package SETTING;

use warnings;
use strict;
use utf8;

################################################################################
# Setting
################################################################################

sub GetSetting()
{
  my %SYSTEM = (

    # Enable edit(not 0)
    'ENABLE_EDIT'           => 0,

    # Enable directory list(not 0).
    'ENABLE_DIRECTORY'      => 1,

    # Data directory.
    'PUBLIC_DIR'            => './wiki',

    # Blog directory.
    'BLOG_DIR'              => './blog',

    # CGI Script.
    'CGI'                   => '',

    # Index page.
    'INDEX_PAGE'            => 'FrontPage',

    # Template name.
    'TEMPLATE'              => '.template.pl',

    # Default extension.
    'TAIL'                  => 'md',

    # Sonidori path.
    'SONIDORI_PATH'         => '../sonidori',

    # Plugin directory
    'PLUGIN_DIR'            => 'plugin',

    # Enable plugin list.
    'INSTALLED_PLUGIN_FILE' => 'plugins.txt',

    # HTML Template.
    'HTML_TEMPLATE'         =>
    {
            'PC'            => '../sonidori/template/template.html',
            'Android'       => '../sonidori/template/template.html',
            'AndroidMobile' => '../sonidori/template/template_mobile.html',
            'iPhone'        => '../sonidori/template/template_mobile.html',
            'WindowsPhone'  => '../sonidori/template/template_mobile.html',
    },

    # Admin Tools.
    # Uploader.
    'ADMIN_UPLOADER'        => '',
    # Markdown preview.
    'ADMIN_PREVIEW'         => '',

    # HTTP Header(editable by plugin or template).
    'HTTP_HEADER'           => [ 'Content-type: text/html' ],
  );

  return \%SYSTEM;
}

1;
