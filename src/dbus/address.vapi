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

  [CCode (cheader_filename = "dbus/address.h", destroy_function = "nw_dbus_address_clear")]
  internal struct DBusAddress
    {
      public GLib.List<DBusAddressOption> options;
      public string transport;
      public DBusAddress (string address);

      public unowned string? lookup_option (string key)
        {
          for (unowned GLib.List<DBusAddressOption?> list = options; list != null; list = list.next)
            {
              if (key == list.data.key) return list.data.value;
            }
        return null;
        }
    }

  [CCode (cheader_filename = "dbus/address.h", destroy_function = "nw_dbus_address_option_clear")]
  internal struct DBusAddressOption
    {
      public string key;
      public string value;
      public DBusAddressOption (owned string key, owned string value);
    }
}