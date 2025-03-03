/* Copyright 2025-2026 MarcosHCK
 * This file is part of NativeWeb.
 *
 * NativeWeb is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * NativeWeb is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with NativeWeb. If not, see <http://www.gnu.org/licenses/>.
 */

function setupLogLib ()
{
  loglib.domain = 'NativeWebJs';

  ([ 'error', 'critical', 'warning', 'message', 'info', 'debug' ]).forEach (e =>
    {
      const level = loglib.log_level[e]
      loglib[e] = (value => loglib.log (loglib.domain, level, 'MESSAGE', value))
    })
}

setupLogLib ()
