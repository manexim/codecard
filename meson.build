# Project name, programming language and version
project (
    'com.manexim.codecard',
    'c', 'vala',
    version: '1.1.0'
)

# Translation module
i18n = import ('i18n')

# Project arguments
add_project_arguments (
    '-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name ()),
    language: 'c'
)

config_data = configuration_data ()
config_data.set('APP_ID', meson.project_name ())
config_data.set('APP_VERSION', meson.project_version ())

config_file = configure_file (
    input: 'src/Constants.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

# Listing dependencies
dependencies = [
    dependency ('gtk+-3.0'),
    dependency ('granite'),
    dependency('gtksourceview-4'),
    dependency ('libhandy-1')
]

subdir ('src')

# Defining executable
executable (
    meson.project_name (),
    sources,
    config_file,
    dependencies: dependencies,
    install: true
)

subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')
