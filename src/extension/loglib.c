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
#include <glib.h>
#include <loglib.h>
#include <mixin.h>

#define ENUM(type,varname,...) \
  ; \
  struct _##type##EnumTuple \
    { \
      const gchar* name; \
      type value; \
    } varname [] = { __VA_ARGS__ }; \

#define ENUMVAL(nick,value) { nick, value }

#define transfer(val) val); g_object_unref (val

ENUM (GLogLevelFlags, _log_levels,

  ENUMVAL ("recursion", G_LOG_FLAG_RECURSION),
  ENUMVAL ("fatal", G_LOG_FLAG_FATAL),
  ENUMVAL ("error", G_LOG_LEVEL_ERROR),
  ENUMVAL ("critical", G_LOG_LEVEL_CRITICAL),
  ENUMVAL ("warning", G_LOG_LEVEL_WARNING),
  ENUMVAL ("message", G_LOG_LEVEL_MESSAGE),
  ENUMVAL ("info", G_LOG_LEVEL_INFO),
  ENUMVAL ("debug", G_LOG_LEVEL_DEBUG),
  ENUMVAL ("mask", G_LOG_LEVEL_MASK));

#undef ENUMVAL
#undef ENUM

static void loglib_log (GPtrArray* values, gpointer user_data);

JSCValue* _nw_extension_loglib_register (JSCContext* context)
{
  JSCValue* lib = jsc_value_new_object (context, NULL, NULL);
  JSCValue* log = jsc_value_new_function_variadic (context, "log", G_CALLBACK (loglib_log), NULL, NULL, G_TYPE_NONE);

  JSCValue* log_level = jsc_value_new_object (context, NULL, NULL);
  guint i;

  for (i = 0; i < G_N_ELEMENTS (_log_levels); ++i)
    {
      JSCValue* val = jsc_value_new_number (context, (double) _log_levels [i].value);
      jsc_value_object_set_property (log_level, _log_levels [i].name, transfer (val));
    }

  jsc_value_object_set_property (lib, "log", transfer (log));
  jsc_value_object_set_property (lib, "log_level", transfer (log_level));
  jsc_context_set_value (context, "loglib", transfer (lib));
  return lib;
}

#define thrown(n,message) (G_GNUC_EXTENSION ({ jsc_context_throw (jsc_context_get_current (), message); return; }))
#define throw(message) (thrown (0, message))

static void loglib_log (GPtrArray* values, gpointer user_data)
{
  if (values->len < 3) throw ("loglib.log expected at least 3 arguments");
  if (values->len % 2 > 0) throw ("loglib.log fields are key-value tuples: unpaired key");

  if (! jsc_value_is_string ((JSCValue*) values->pdata [0])) throw ("loglib.log expects log domain as first argument (string)");
  if (! jsc_value_is_number ((JSCValue*) values->pdata [1])) throw ("loglib.log expects log level flags as second argument (number)");

  MIXIN_CREATE (GBytes*, bytes, 1 + 32, values->len * 2 + 1);
  MIXIN_CREATE (GLogField, fields, 1 + 16, values->len + 1);
  GLogLevelFlags log_level = jsc_value_to_int32 ((JSCValue*) values->pdata [1]);
  guint i;

  if (TRUE)
    {
      gsize length;
      GBytes* val = (bytes [0] = jsc_value_to_string_as_bytes ((JSCValue*) values->pdata [0]));

      fields [0].key = "GLIB_DOMAIN";
      fields [0].value = g_bytes_get_data (val, & length);
      fields [0].length = length;
    }

  for (i = 0; i < values->len / 2 - 1; ++i)
    {
      GBytes* key = (bytes [1 + (i << 1)] = jsc_value_to_string_as_bytes ((JSCValue*) values->pdata [2 + (i << 1)]));
      GBytes* val = (bytes [2 + (i << 1)] = jsc_value_to_string_as_bytes ((JSCValue*) values->pdata [3 + (i << 1)]));
      gsize length;

      fields [1 + i].key = g_bytes_get_data (key, NULL);
      fields [1 + i].value = g_bytes_get_data (val, & length);
      fields [1 + i].length = length;
    }

  g_log_structured_array (log_level, fields, 1 + values->len);

  MIXIN_DELETE (GBytes*, bytes);
  MIXIN_DELETE (GLogField, fields);
}
