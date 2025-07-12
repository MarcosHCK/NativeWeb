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
[CCode (cprefix = "NWA", lower_case_cprefix = "nwa_")]

namespace NativeWebApp
{

  [DBus (name = "org.hck.nativeweb.app.ExampleInterface")]

  public interface Interface : GLib.Object
    {
      [DBus (name = "RandomUUID")] public abstract string random_uuid () throws GLib.Error;
      [DBus (name = "Store")] public abstract string store { owned get; set; }

      [CCode (cname = "const GDBusInterfaceInfo", cheader_filename = "gio/gio.h")]
      extern struct Nothing { }
      [CCode (cname = "_nwa_interface_dbus_interface_info")]
      extern static Nothing _info;

      public static unowned GLib.DBusInterfaceInfo get_interface_info ()
        {
          return (GLib.DBusInterfaceInfo) &_info;
        }

      public static async Interface get_proxy (GLib.DBusConnection connection, string? name, string object_path, GLib.DBusProxyFlags flags, GLib.Cancellable? cancellable) throws GLib.Error
        {
          return yield connection.get_proxy<Interface> (name, object_path, flags, cancellable);
        }
    }

  public class InterfaceImpl : GLib.Object, Interface
    {

      public string random_uuid () throws GLib.Error
        {
          return GLib.Uuid.string_random ();
        }

      private string _store = "";
      public string store { owned get { return _store; } set { _store = value; } }
    }
}