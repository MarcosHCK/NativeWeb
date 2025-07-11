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
[CCode (cprefix = "NW", lower_case_cprefix = "nw_")]

namespace NativeWeb
{

  public abstract class ProxyBase : GLib.Object, IInvocable, ISignalable
    {

      public string header { get; protected set; }
      public Extension extension { get { return Extension.get_default (); } }

      construct
        {
          header = _G_TYPE_FROM_INSTANCE ().name ();
          extension.recv_message.connect (on_recv_message);
        }

      [CCode (cheader_filename = "glib.h", cname = "G_TYPE_FROM_INSTANCE")]
      private extern GLib.Type _G_TYPE_FROM_INSTANCE ();

      private void on_recv_message (string name, GLib.Variant message)
        {
          if (name == _header) consume (message);
        }

      protected async GLib.Variant? send (GLib.Variant _message) throws GLib.Error
        {
          return yield extension.send_message (_header, _message);
        }
    }
}
