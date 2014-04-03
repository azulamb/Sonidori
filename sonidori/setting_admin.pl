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
    # Enable directory list(not 0).
    'ENABLE_DIRECTORY'      => 1,

    # Data directory.
    'PUBLIC_DIR'            => '../public_html/wiki',

    # Blog directory.
    'BLOG_DIR'              => '../public_html/blog',

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
    'ADMIN_UPLOADER'        => './uploader.cgi',
    # Markdown preview.
    'ADMIN_PREVIEW'         => './markdown_preview.cgi',

    # HTTP Header(editable by plugin or template).
    'HTTP_HEADER'           => [ 'Content-type: text/html' ],
  );

  return \%SYSTEM;
}

1;
