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
#ifndef __NW_ISIGNALABLE_COMPANION__
#define __NW_ISIGNALABLE_COMPANION__ 1
#include <glib-object.h>
#include <params.h>

  struct _NW_Recv_Signal_Data
    {
      JSCValue* func;
      gchar* signal_name;
    };

  static void _nw_isignalable_recv_signal_connect_cb (struct _NW_Recv_Signal_Data* data, const gchar* sn, GVariant* params)
    {

      if (g_str_equal (sn, data->signal_name))
        {
          JSCContext* context = jsc_value_get_context (data->func);
          GPtrArray* param_ar = _nw_extension_params_unpack (params, context);

          JSCValue* result = jsc_value_function_callv (data->func, param_ar->len, (JSCValue**) param_ar->pdata);
          g_object_unref (result);
        }
    }

  static void _nw_isignalable_recv_signal_connect_notify (struct _NW_Recv_Signal_Data* data)
    {
      g_object_unref (data->func);
      g_free (data->signal_name);
      g_slice_free1 (sizeof (*data), data);
    }

  static __inline gulong _nw_isignalable_recv_signal_connect (GObject* pself, const gchar* signal_name, JSCValue* value)
    {
      GCallback callback = G_CALLBACK (_nw_isignalable_recv_signal_connect_cb);
      GClosureNotify notify = (GClosureNotify) _nw_isignalable_recv_signal_connect_notify;

      struct _NW_Recv_Signal_Data data = { .func = g_object_ref (value), .signal_name = g_strdup (signal_name) };
      struct _NW_Recv_Signal_Data* pdata = g_slice_copy (sizeof (data), &data);

    return g_signal_connect_data (pself, "recv-signal", callback, pdata, notify, G_CONNECT_SWAPPED);
    }

#endif // __NW_ISIGNALABLE_COMPANION__