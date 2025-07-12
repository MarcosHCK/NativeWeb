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

# libs

subdir ('dbus')
subdir ('ipc')
subdir ('process')

# components

subdir ('extension')
subdir ('resources')

browserlib = files ('browser.c', 'browser.h', 'browser.vapi')
supportlib = files ('daemon.vala', 'delayed.vala', 'dragger.vala')
widgetlib = files ('headerbar.vala', 'message.vala', 'window.vala')

libs = [ browserlib, supportlib, widgetlib ]

libnativeweb = library \
  (
    'nativeweb',
    c_args: [ '-DG_LOG_DOMAIN="NativeWeb"', '-DG_LOG_USE_STRUCTURED=1',
      '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
      '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
    dependencies: [ config_dep, libgtk4_dep, libwebkitgtk_dep,
      cc.find_library ('m', required: false),
      libdbus_dep.as_link_whole (),
      libipc_valadep,
      libprocess_dep.as_link_whole (),
      libresources_dep.as_link_whole () ],
    sources: [ 'application.vala', 'config.vapi', libs ],
  )

libnativeweb_dep = declare_dependency \
  (
    dependencies: [ libgtk4_dep, libwebkitgtk_dep ],
    include_directories: include_directories ('.'),
    link_with: libnativeweb,
  )

libnativeweb_valadep = declare_dependency \
  (
    dependencies: libnativeweb_dep,
    sources: 'browser.vapi',
  )

meson.override_dependency ('nativeweb', libnativeweb_dep)
meson.override_dependency ('nativeweb-vala', libnativeweb_valadep)
