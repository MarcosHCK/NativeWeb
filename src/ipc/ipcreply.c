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
#include <ipcreply.h>

static GVariant* pack_gerror (GError* error)
{

  GVariant* values [] =
    {
      g_variant_new_string (g_quark_to_string (error->domain)),
      g_variant_new_int32 (error->code),
      g_variant_new_string (error->message),
    };
return g_variant_new_tuple (values, G_N_ELEMENTS (values));
}

GVariant* ipc_reply_pack (GVariant* reply, GError* error)
{
  g_return_val_if_fail (reply != NULL || error != NULL, NULL);
  g_return_val_if_fail (reply == NULL || error == NULL, NULL);
  reply = ! reply ? NULL : g_variant_new_variant (reply); 

  GVariant* values [] =
    {
      g_variant_new_maybe ((const GVariantType*) "v", reply),
      g_variant_new_maybe ((const GVariantType*) "(sis)", ! error ?
        NULL : pack_gerror (error)),
    };
return g_variant_new_tuple (values, G_N_ELEMENTS (values));
}

GVariant* ipc_reply_unpack (GVariant* reply, GError** error)
{
  g_return_val_if_fail (g_variant_check_format_string (reply, "(mvm(sis))", FALSE), NULL);
  g_return_val_if_fail (error == NULL || *error == NULL, NULL);

  guint code = 0;
  const gchar* domain = NULL;
  gboolean failed = FALSE;
  const gchar* message = NULL;
  GVariant* params = NULL;

  g_variant_get (reply, "(mvm(&si&s))", &params, &failed, &domain, &code, &message);

  if (G_LIKELY (failed == FALSE))

    return params;
  else
    { if (params) g_variant_unref (params);
      return (g_set_error_literal (error, g_quark_from_string (domain), code, message), NULL); }
}