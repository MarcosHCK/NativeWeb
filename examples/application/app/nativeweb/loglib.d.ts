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
/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-namespace */

declare global
{
  namespace loglib
    {
      enum log_level
        {
          critical,
          debug,
          error,
          info,
          mask,
          message,
          recurse,
          warning,
        }

      function critical (contents: string): void;
      function debug (contents: string): void;
      function error (contents: string): void;
      function info (contents: string): void;
      function message (contents: string): void;
      function warning (contents: string): void;

      function log (log_domain: string, log_level: log_level, ...first_field: any): void;
    }
}

export { }
