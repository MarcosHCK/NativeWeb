# Copyright 2025-2026 MarcosHCK
# This file is part of NativeWeb.
#
# NativeWeb is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# NativeWeb is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with NativeWeb. If not, see <http://www.gnu.org/licenses/>.
#

python = import ('python')

resources_dep = declare_dependency \
  (
    dependencies: libgio_dep,
    include_directories: include_directories ('.'),
    sources: import ('gnome').compile_resources
      (
        'resources',
        custom_target \
          (
            command: [ python.find_installation (), files ('genres.py') [0], '@INPUT@', '@OUTPUT@' ],
            depends: webpack,
            input: 'resources.xml.in',
            output: 'resources.xml' ),
        source_dir: meson.current_build_dir ())
  )
