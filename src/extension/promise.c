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
#include <promise.h>

struct _NWPromise
{
  guint refs;
  JSCContext* context;
  JSCValue* reject;
  JSCValue* resolve;
};

struct _Shelter
{
  NWPromiseCallback* callback;
  GDestroyNotify destroy_notify;
  gpointer user_data;
};

#define _g_object_unref0(var) ((var == NULL) ? NULL : (var = (g_object_unref (var), NULL)))

G_DEFINE_BOXED_TYPE (NWPromise, nw_promise, nw_promise_ref, nw_promise_unref)

static void nothing (void) { }

static NWPromise* _nw_promise_new (JSCContext* context, JSCValue* reject, JSCValue* resolve)
{
  NWPromise* promise;

  (promise = g_slice_new (NWPromise))->refs = 1;

  promise->context = g_object_ref (context);
  promise->reject = reject != NULL ? g_object_ref (reject) : jsc_value_new_function (context, NULL, nothing, NULL, NULL, G_TYPE_NONE, 0);
  promise->resolve = resolve != NULL ? g_object_ref (resolve) : jsc_value_new_function (context, NULL, nothing, NULL, NULL, G_TYPE_NONE, 0);
  return promise;
}

static void call (JSCValue* resolve, JSCValue* reject, struct _Shelter* data)
{
  NWPromise* promise;
  JSCContext* context = jsc_context_get_current ();

  data->callback (promise = _nw_promise_new (context, reject, resolve), data->user_data);
  nw_promise_unref (promise);
}

static void notify (struct _Shelter* self)
{
  g_clear_pointer (& self->user_data, self->destroy_notify);
  g_slice_free (struct _Shelter, self);
}

JSCValue* nw_promise_create (JSCContext* context, NWPromiseCallback callback, gpointer user_data, GDestroyNotify destroy_notify)
{
  g_return_val_if_fail (context != NULL, NULL);
  g_return_val_if_fail (callback != NULL, NULL);
  JSCValue *actuator, *namespace, *promise;

  destroy_notify = destroy_notify != NULL ? destroy_notify : (GDestroyNotify) nothing;

  struct _Shelter data = { .callback = callback, .destroy_notify = destroy_notify, .user_data = user_data };
  struct _Shelter* pdata = g_slice_dup (struct _Shelter, &data);

  GType parameter_types [] = { JSC_TYPE_VALUE, JSC_TYPE_VALUE };
  GType return_type = G_TYPE_NONE;

  actuator = jsc_value_new_functionv (context, NULL, G_CALLBACK (call), pdata, (GDestroyNotify) notify, return_type, 2, parameter_types);
  promise = jsc_value_constructor_callv ((namespace = jsc_context_get_value (context, "Promise")), 1, &actuator);
  return (g_object_unref (actuator), g_object_unref (namespace), promise);
}

JSCContext* nw_promise_get_context (NWPromise* promise)
{
  g_return_val_if_fail (promise != NULL, NULL);
  return promise->context;
}

NWPromise* nw_promise_ref (NWPromise* promise)
{
  g_return_val_if_fail (promise != NULL, NULL);
  return (g_atomic_int_inc (&promise->refs), promise);
}

static __inline void finish (NWPromise* self, JSCValue* value, JSCValue* callback)
{

  value = value != NULL ? g_object_ref (value) : jsc_value_new_undefined (self->context);

  g_object_unref (jsc_value_function_callv (callback, 1, &value));
  g_object_unref (value);
}

void nw_promise_reject (NWPromise* promise, JSCValue* value)
{
  g_return_if_fail (promise != NULL);
  g_return_if_fail (value == NULL || JSC_IS_VALUE (value));
  finish (promise, value, promise->reject);
}

gchar* nw_gerror_to_message (GError* error, gchar** name);

void nw_promise_reject_gerror (NWPromise* promise, GError* error)
{
  g_return_if_fail (promise != NULL);
  g_return_if_fail (error != NULL);
  gchar* message = nw_gerror_to_message (error, NULL);
  JSCValue* value_ = jsc_value_new_string (promise->context, message);
  g_free (message);

  finish (promise, value_, promise->reject);
  g_object_unref (value_);
}

void nw_promise_reject_string (NWPromise* promise, const gchar* message)
{
  g_return_if_fail (promise != NULL);
  g_return_if_fail (message != NULL);
  JSCValue* value_ = jsc_value_new_string (promise->context, message);

  finish (promise, value_, promise->reject);
  g_object_unref (value_);
}

void nw_promise_reject_printf (NWPromise* promise, const gchar* fmt, ...)
{
  g_return_if_fail (promise != NULL);
  g_return_if_fail (fmt != NULL);
  va_list l;

  va_start (l, fmt);
  nw_promise_reject_printf_valist (promise, fmt, l);
  va_end (l);
}

void nw_promise_reject_printf_valist (NWPromise* promise, const gchar* fmt, va_list args)
{
  g_return_if_fail (promise != NULL);
  g_return_if_fail (fmt != NULL);
  gchar* message = NULL;

  nw_promise_reject_string (promise, message = g_strdup_vprintf (fmt, args));
  g_free (message);
}

void nw_promise_resolve (NWPromise* promise, JSCValue* value)
{
  g_return_if_fail (promise != NULL);
  g_return_if_fail (value == NULL || JSC_IS_VALUE (value));
  finish (promise, value, promise->resolve);
}

void nw_promise_unref (NWPromise* promise)
{
  g_return_if_fail (promise != NULL);

  if (g_atomic_int_dec_and_test (&promise->refs))
    {
      _g_object_unref0 (promise->context);
      _g_object_unref0 (promise->reject);
      _g_object_unref0 (promise->resolve);
      g_slice_free (NWPromise, promise);
    }
}
