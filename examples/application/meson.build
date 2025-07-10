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

subdir ('app')
subdir ('extension')
subdir ('resources')

executable \
  (
    'application',
    c_args: [ '-DG_LOG_DOMAIN="NativeWebApp"', '-DG_LOG_USE_STRUCTURED=1' ],
    dependencies: [ config_dep, libextension_dep, libgtk4_dep, libnativeweb_valadep, resources_dep ],
    include_directories: include_directories ('.'),
    sources: [ 'application.vala', 'config.vapi' ],
  )