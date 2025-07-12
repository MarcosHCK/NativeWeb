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
#include <config.h>
#include <address.h>

#define _g_free0(var) ((var == NULL) ? NULL : (var = (g_free (var), NULL)))

static void _option_free (gpointer mem)
{
  NWDBusAddressOption* option;

  if ((option = (NWDBusAddressOption*) mem) != NULL)
    {
      nw_dbus_address_option_clear (option);
      g_slice_free (NWDBusAddressOption, mem);
    }
}

void nw_dbus_address_clear (NWDBusAddress* option)
{
  g_list_free_full (option->options, _option_free);
  _g_free0 (option->transport);
}

void nw_dbus_address_option_clear (NWDBusAddressOption* option)
{
  _g_free0 (option->key);
  _g_free0 (option->value);
}

static GList* parse_options (const gchar* str, gsize length)
{
  if (length == 0) return NULL;

  const gchar* cur = str;
  const gchar* last = NULL;
  const gchar* next = NULL;

  GList* list = NULL;
  NWDBusAddressOption opt;

  for (; cur != NULL; cur = next)
    {

      if ((next = last = g_strstr_len (cur, length, ",")) != NULL)

        ++next;
      else
        last = str + length;

      const gchar* sep;

      if ((sep = g_strstr_len (cur, last - cur, "=")) == NULL)
        g_error ("bad address");

      gchar* key = g_strndup (cur, sep - cur);
      gchar* value = g_strndup (1 + sep, last - (1 + sep));

      nw_dbus_address_option_init (&opt, key, value);

      list = g_list_append (list, g_slice_copy (sizeof (opt), &opt));
    }
return list;
}

void nw_dbus_address_init (NWDBusAddress* option, const gchar* address)
{
  const gchar* cur = address;
  const gchar* last = NULL;
  const gchar* next = NULL;
  guint i, length;

  for (i = 0, length = strlen (address); cur != NULL; cur = next, ++i)
    {

      if ((next = last = g_strstr_len (cur, length, ":")) != NULL)

        ++next;
      else
        last = address + length;

      switch (i)
        {
          case 0: option->transport = g_strndup (cur, last - cur);
            break;
          case 1: option->options = parse_options (cur, last - cur);
            break;
          default: g_error ("bad address");
    }}
}

void nw_dbus_address_option_init (NWDBusAddressOption* option, gchar* key, gchar* value)
{
  option->key = key;
  option->value = value;
}