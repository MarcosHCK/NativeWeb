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
#ifndef __H_EXTENSION_PROMISE__
#define __H_EXTENSION_PROMISE__ 1
#include <glib-object.h>
#include <webkit/webkit-web-process-extension.h>

#define NW_TYPE_PROMISE (nw_promise_get_type ())

typedef struct _NWPromise NWPromise;
typedef void NWPromiseCallback (NWPromise* promise, gpointer user_data);

#if __cplusplus
extern "C" {
#endif // __cplusplus

  GType nw_promise_get_type (void) G_GNUC_CONST;

  JSCValue* nw_promise_create (JSCContext* context, NWPromiseCallback callback, gpointer user_data, GDestroyNotify notify);
  JSCContext* nw_promise_get_context (NWPromise* promise);
  NWPromise* nw_promise_ref (NWPromise* promise);
  void nw_promise_reject (NWPromise* promise, JSCValue* value);
  void nw_promise_reject_gerror (NWPromise* promise, GError* error);
  void nw_promise_reject_string (NWPromise* promise, const gchar* message);
  void nw_promise_reject_printf (NWPromise* promise, const gchar* fmt, ...) G_GNUC_PRINTF (2, 3);
  void nw_promise_reject_printf_valist (NWPromise* promise, const gchar* fmt, va_list args) G_GNUC_PRINTF (2, 0);
  void nw_promise_resolve (NWPromise* promise, JSCValue* value);
  void nw_promise_unref (NWPromise* promise);

#if __cplusplus
}
#endif // __cplusplus

#endif // __H_EXTENSION_PROMISE__
