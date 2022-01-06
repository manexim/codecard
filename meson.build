project('com.manexim.codecard', 'vala', 'c', version: '1.0.2')

vapi_dir = meson.current_source_dir() / 'vapi'
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

# Include the translations module
i18n = import('i18n')

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

gtk_plus_3_dep = dependency('gtk+-3.0')
granite_dep = dependency('granite')
gtksourceview_dep = dependency('gtksourceview-4')
libhandy_dep = dependency('libhandy-1', version: '>=1.0.0')
libportal_dep = dependency('libportal')

dependencies = [
    gtk_plus_3_dep,
    granite_dep,
    gtksourceview_dep,
    libhandy_dep,
    libportal_dep,
]

subdir('src')
subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')
