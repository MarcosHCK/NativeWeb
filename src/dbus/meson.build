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

libdbus = static_library \
  (
    'dbus',
    c_args: [ '-DG_LOG_DOMAIN="NativeWeb"', '-DG_LOG_USE_STRUCTURED=1',
      '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
      '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
    dependencies: [ config_dep, libgio_dep ],
    include_directories: include_directories ('.'),
    sources: [ 'address.c', 'address.h' ],
  )

libdbus_dep = declare_dependency \
  (
    dependencies: libgio_dep,
    include_directories: include_directories ('.'),
    link_with: libdbus,
    sources: 'address.vapi',
  )