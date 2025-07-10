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
#include <ipccall.h>

GVariant* ipc_call_pack (const gchar* name, GVariant* arguments)
{
  g_return_val_if_fail (name != NULL, NULL);
  g_return_val_if_fail (arguments != NULL, NULL);
  g_return_val_if_fail (g_variant_check_format_string (arguments, "r", FALSE), NULL);

  GVariant* values [] =
    {
      g_variant_new_string (name),
      arguments,
    };
return g_variant_new_tuple (values, G_N_ELEMENTS (values));
}

const gchar* ipc_call_unpack (GVariant* call, GVariant** arguments)
{
  g_return_val_if_fail (call != NULL, NULL);
  g_return_val_if_fail (g_variant_check_format_string (call, "(sr)", FALSE), NULL);
  GVariant* placeholder = NULL;
  gchar* name = NULL;

  g_variant_get (call, "(&s&r)", &name, arguments ? arguments : &placeholder);
return name;
}