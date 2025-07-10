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
[CCode (cheader_filename = "ipc.h", cprefix = "Ipc", lower_case_cprefix = "ipc_")]

namespace Ipc
{

  namespace Call
    {
      [CCode (returns_floating_reference = true)]
      public static GLib.Variant pack (string name, GLib.Variant arguments);
      public static unowned string unpack (GLib.Variant call, out unowned GLib.Variant arguments);
    }

  namespace Reply
    {
      [CCode (returns_floating_reference = true)]
      public static GLib.Variant pack (GLib.Variant? result, GLib.Error? error = null);
      [CCode (returns_floating_reference = false)]
      public static GLib.Variant unpack (GLib.Variant reply) throws GLib.Error;
    }
}