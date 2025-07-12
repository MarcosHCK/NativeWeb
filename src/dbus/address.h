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
#ifndef __NW_DBUS_ADDRESS__
#define __NW_DBUS_ADDRESS__ 1
#include <gio/gio.h>

typedef struct _NWDBusAddress NWDBusAddress;
typedef struct _NWDBusAddressOption NWDBusAddressOption;

#if __cplusplus
extern "C" {
#endif // __cplusplus

  struct _NWDBusAddress
    {
      GList* options;
      gchar* transport;
    };

  struct _NWDBusAddressOption
    {
      gchar* key;
      gchar* value;
    };

  G_GNUC_INTERNAL void nw_dbus_address_clear (NWDBusAddress* option);
  G_GNUC_INTERNAL void nw_dbus_address_option_clear (NWDBusAddressOption* option);

  G_GNUC_INTERNAL void nw_dbus_address_init (NWDBusAddress* option, const gchar* address);
  G_GNUC_INTERNAL void nw_dbus_address_option_init (NWDBusAddressOption* option, gchar* key, gchar* value);

#if __cplusplus
}
#endif // __cplusplus

#endif // __NW_DBUS_ADDRESS__