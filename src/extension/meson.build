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

# apis

params = files ('params.c', 'params.h', 'params.vapi')
promise = files ('promise.c', 'promise.h', 'promise.vapi')
proxy = files ('iattributable.vala', 'iinvocable.vala', 'isignalable.h', 'isignalable.vala', 'proxybase.vala')

apis = [ 'gerror.vala', params, promise, proxy ]

# libs

browserlib = files ('browser.vala')
loglib = files ('loglib.c', 'loglib.h', 'loglib.vapi')
utf8lib = files ('utf8.vala')

libs = [ browserlib, loglib, utf8lib ]

# module

libnativewebext = library \
  (
    'nativewebext',
    c_args: [ '-DG_LOG_DOMAIN="NativeWebExt"', '-DG_LOG_USE_STRUCTURED=1',
      '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
      '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
    dependencies: [ config_dep, libipc_valadep.as_link_whole (), libgio_dep, libwebkitgtkext_dep ],
    sources: [ apis, 'extension.c', 'extension.vala', libs, 'module.vala', 'mixin.h', params, promise,
      import ('gnome').compile_resources ('resources', 'resources.xml') ],
  )

libnativewebext_dep = declare_dependency \
  (
    dependencies: [ libgio_dep, libwebkitgtkext_dep ],
    include_directories: include_directories ('.'),
    link_with: libnativewebext,
  )

libnativewebext_valadep = declare_dependency \
  (
    dependencies: libnativewebext_dep,
    sources: [ 'promise.vapi' ]
  )

meson.override_dependency ('nativewebext', libnativewebext_dep)
meson.override_dependency ('nativewebext-vala', libnativewebext_valadep)