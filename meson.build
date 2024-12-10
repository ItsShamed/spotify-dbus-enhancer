project('spotify-dbus-enhancer', 'vala', 'c')

dependencies = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('gio-2.0')
]

find_result = run_command('find',  'src/', '-name', '*.vala', check: true)
output = find_result.stdout().strip()

sources = find_result.stdout().strip().split('\n')

executable('spotify-notifix', sources, dependencies: dependencies)
