project('spotify-dbus-enhancer', 'vala', 'c')

if get_option('buildtype').startswith('debug')
    add_project_arguments('-Db_sanitize=address', language : ['c'])
endif

dependencies = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('gio-2.0')
]

find_result = run_command('find',  'src/', '-name', '*.vala', check: true)
output = find_result.stdout().strip()

sources = find_result.stdout().strip().split('\n')

executable('spotify-notifix', sources, dependencies: dependencies, install: true)
