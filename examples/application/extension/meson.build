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

webkitext_cfg = configuration_data ()
webkitext_hdr = files ('extension.h.in') [0]

webkitext_cfg.set_quoted ('WEBKIT_EXTENSION_DIR', meson.current_build_dir ())
webkitext_hdr = configure_file (configuration: webkitext_cfg, input: webkitext_hdr, output: 'extension.h')

shared_module \
  (
    'webappext',
    c_args: [ '-DG_LOG_DOMAIN="NativeWebAppExt"', '-DG_LOG_USE_STRUCTURED=1' ],
    dependencies: [ config_dep, libinterface_dep, libnativewebext_valadep,
      dependency ('gmodule-2.0', required: true) ],
    install: false,
    sources: [ 'extension.c', 'extension.vala', 'interface.vala', webkitext_hdr ],
  )

libextension_dep = declare_dependency \
  (
    include_directories: include_directories ('.'),
    sources: [ webkitext_hdr, 'extension.vapi']
  )