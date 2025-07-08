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
#include <params.h>
#include <webkit/webkit-web-process-extension.h>

#define jsc_value_is_array_like(v) (G_GNUC_EXTENSION ({ \
  ; \
    JSCValue* __value = (v); \
    jsc_value_is_array (__value) \
    || jsc_value_is_array_buffer (__value) \
    || jsc_value_is_typed_array (__value); \
  }))
#define jsc_value_is_nil(v) (G_GNUC_EXTENSION ({ \
  ; \
    JSCValue* __value = (v); \
    jsc_value_is_null (__value) \
    || jsc_value_is_undefined (__value); \
  }))

static GVariant* pack_typearray (JSCValue* param, const GVariantType* variant_type);

GVariant* _nw_extension_param_pack (JSCValue* param, const GVariantType* variant_type)
{
  switch (g_variant_type_peek_string (variant_type) [0])
    {

      case 'a':
        {
          GVariant* variant;
          const GVariantType* child_type = g_variant_type_element (variant_type);

          if (jsc_value_is_array_like (param) == FALSE)
            {
              if (jsc_value_is_nil (param) == FALSE)

                jsc_context_throw (jsc_value_get_context (param), "array-like argument expected");
              variant = g_variant_new_array (child_type, NULL, 0);
            }
          else if (jsc_value_is_typed_array (param))

            variant = pack_typearray (param, child_type);
          else
            {
              GVariantBuilder builder = {0};
              JSCValue* child = NULL;
              JSCValue* lengthv = jsc_value_object_get_property (param, "length");
              guint i, length = jsc_value_to_int32 (lengthv);

              g_variant_builder_init (&builder, variant_type);
              g_object_unref (lengthv);

              for (i = 0; i < length; ++i)
                {
                  child = jsc_value_object_get_property_at_index (param, i);
                  g_variant_builder_add_value (&builder, _nw_extension_param_pack (child, child_type));
                }
              variant = g_variant_builder_end (&builder);
            }
          return variant;
        }

      case 'm':
        {
          GVariant* variant;
          const GVariantType* child_type = g_variant_type_element (variant_type);

          if (param == NULL || jsc_value_is_undefined (param))

            variant = g_variant_new_maybe (child_type, NULL);
          else
            variant = g_variant_new_maybe (child_type, _nw_extension_param_pack (param, child_type));

          return variant;
        }

      case 'b': return g_variant_new_boolean (jsc_value_to_boolean (param));
      case 'y': return g_variant_new_byte ((guchar) jsc_value_to_int32 (param));
      case 'n': return g_variant_new_int16 ((gint16) jsc_value_to_int32 (param));
      case 'q': return g_variant_new_uint16 ((guint16) jsc_value_to_int32 (param));
      case 'i': return g_variant_new_int32 ((gint32) jsc_value_to_int32 (param));
      case 'u': return g_variant_new_uint32 ((guint32) jsc_value_to_int32 (param));
      case 'x': return g_variant_new_int64 ((gint64) jsc_value_to_double (param));
      case 't': return g_variant_new_uint64 ((guint64) jsc_value_to_double (param));
      case 'h': return g_variant_new_int32 ((gint32) jsc_value_to_int32 (param));
      case 'd': return g_variant_new_double ((gdouble) jsc_value_to_double (param));
      case 's': return g_variant_new_take_string (jsc_value_to_string (param));
      case 'o': return g_variant_new_object_path (jsc_value_to_string (param));
      case 'g': return g_variant_new_signature (jsc_value_to_string (param));

      default:
        {
          gchar* type = g_variant_type_dup_string (variant_type);
          g_error ("unknown conversion to variant type %s", type);
        }
    }
}

#define throw(message) \
  G_STMT_START { \
    jsc_context_throw (jsc_value_get_context (param), "array-like argument expected"); \
    return g_variant_new_array (variant_type, NULL, 0); \
  } G_STMT_END

static GVariant* pack_typearray (JSCValue* param, const GVariantType* variant_type)
{
  if (g_variant_type_is_basic (variant_type) == FALSE)

    throw ("array-like argument expected");

  JSCTypedArrayType atype = jsc_value_typed_array_get_type (param);

  gsize length;
  gsize size = jsc_value_typed_array_get_size (param);
  gpointer data = jsc_value_typed_array_get_data (param, &length);

  switch (g_variant_type_peek_string (variant_type) [0])
    {

      case 'y': if (atype != JSC_TYPED_ARRAY_UINT8 && atype != JSC_TYPED_ARRAY_UINT8_CLAMPED)
          throw ("incompatible typed array type");
        return g_variant_new_from_bytes (variant_type, g_bytes_new (data, size), FALSE);
      case 'n': if (atype != JSC_TYPED_ARRAY_INT16)
          throw ("incompatible typed array type");
        return g_variant_new_from_bytes (variant_type, g_bytes_new (data, size), FALSE);
      case 'q': if (atype != JSC_TYPED_ARRAY_UINT16)
          throw ("incompatible typed array type");
        return g_variant_new_from_bytes (variant_type, g_bytes_new (data, size), FALSE);
      case 'h': G_GNUC_FALLTHROUGH;
      case 'i': if (atype != JSC_TYPED_ARRAY_INT32)
          throw ("incompatible typed array type");
        return g_variant_new_from_bytes (variant_type, g_bytes_new (data, size), FALSE);
      case 'u': if (atype != JSC_TYPED_ARRAY_UINT32)
          throw ("incompatible typed array type");
        return g_variant_new_from_bytes (variant_type, g_bytes_new (data, size), FALSE);
      case 'x': if (atype != JSC_TYPED_ARRAY_INT64)
          throw ("incompatible typed array type");
        return g_variant_new_from_bytes (variant_type, g_bytes_new (data, size), FALSE);
      case 't': if (atype != JSC_TYPED_ARRAY_UINT64)
          throw ("incompatible typed array type");
        return g_variant_new_from_bytes (variant_type, g_bytes_new (data, size), FALSE);
      case 'd': switch (atype)
        {
          case JSC_TYPED_ARRAY_FLOAT32:
            {
              gdouble* dst = g_new (gdouble, length);
              gfloat* src = (gfloat*) data;
              guint i;

              for (i = 0; i < length; ++i)

                dst [i] = (gdouble) src [i];
              return g_variant_new_from_bytes (variant_type, g_bytes_new (data, size), FALSE);
            }
          case JSC_TYPED_ARRAY_FLOAT64:
            {
              G_STATIC_ASSERT (sizeof (gdouble) == 8);
              G_STATIC_ASSERT (sizeof (gfloat) == 4);

              return g_variant_new_from_bytes (variant_type, g_bytes_new (data, size), FALSE);
            }

          default: throw ("incompatible typed array type");
        }

      default:
        {
          gchar* type = g_variant_type_dup_string (variant_type);
          g_error ("unknown conversion to variant type %s", type);
        }
    }
}

#undef throw

GVariant* _nw_extension_params_pack (GPtrArray* params, const GVariantType* variant_type)
{
  g_return_val_if_fail (variant_type == NULL || g_variant_type_is_definite (variant_type), NULL);
  g_return_val_if_fail (variant_type == NULL || g_variant_type_is_tuple (variant_type), NULL);
  if (variant_type == NULL) return NULL;

  GVariantBuilder builder = G_VARIANT_BUILDER_INIT (variant_type);
  const GVariantType* item = NULL;
  guint i;
  JSCValue* param = NULL;

  for (i = 0, item = g_variant_type_first (variant_type); item != NULL; ++i, item = g_variant_type_next (item))
    {

      if (i < params->len)

        param = (JSCValue*) params->pdata [i];
      else
        {
          if (g_variant_type_is_maybe (item))

            param = NULL;
          else
            g_error ("more values expected (got %u, expected %u)", params->len, (guint) g_variant_type_n_items (variant_type));
        }

      g_variant_builder_add_value (&builder, _nw_extension_param_pack (param, item));
    }
  return g_variant_builder_end (&builder);
}

JSCValue* _nw_extension_param_unpack (GVariant* param, JSCContext* context)
{
  gchar* vtype = NULL;

  do { switch ((vtype = g_variant_get_type_string (param)) [0])
    {

      case 'v':
        {
          GVariant* old = param;
          param = g_variant_get_variant (param);

          g_variant_unref (old);
          continue;
        }

      case 'a': G_GNUC_FALLTHROUGH; case '(':
        {
          GPtrArray* inner = _nw_extension_params_unpack (param, context);
          JSCValue* value = jsc_value_new_array_from_garray (context, inner);
          return value;
        }

      case 'm':
        {
          GVariant* new;

          if ((new = g_variant_get_maybe (param)) != NULL)

            { param = new; continue; }
          else
            { return jsc_value_new_null (context); }
        }

      case 'b': return jsc_value_new_boolean (context, g_variant_get_boolean (param));
      case 'y': return jsc_value_new_number (context, (double) g_variant_get_byte (param));
      case 'n': return jsc_value_new_number (context, (double) g_variant_get_int16 (param));
      case 'q': return jsc_value_new_number (context, (double) g_variant_get_uint16 (param));
      case 'i': return jsc_value_new_number (context, (double) g_variant_get_int32 (param));
      case 'u': return jsc_value_new_number (context, (double) g_variant_get_uint32 (param));
      case 'x': return jsc_value_new_number (context, (double) g_variant_get_int64 (param));
      case 't': return jsc_value_new_number (context, (double) g_variant_get_uint64 (param));
      case 'h': return jsc_value_new_number (context, (double) g_variant_get_int32 (param));
      case 'd': return jsc_value_new_number (context, (double) g_variant_get_double (param));
      case 's': G_GNUC_FALLTHROUGH;
      case 'o': G_GNUC_FALLTHROUGH;
      case 'g': return jsc_value_new_string (context, g_variant_get_string (param, NULL));
      default: g_error ("unknown conversion from variant type %s", (gchar*) g_variant_get_type (param));
    }
  break; } while (TRUE);
}

GPtrArray* _nw_extension_params_unpack (GVariant* params, JSCContext* context)
{
  g_return_val_if_fail (params != NULL, NULL);
  const GVariantType* variant_type = g_variant_get_type (params);
  g_return_val_if_fail (g_variant_type_is_definite (variant_type), NULL);
  g_return_val_if_fail (g_variant_type_is_container (variant_type), NULL);
  gsize n_children = g_variant_n_children (params);

  GPtrArray* values = g_ptr_array_sized_new (n_children);
  GVariant* child = NULL;
  GVariantIter iter = {0};

  g_ptr_array_set_free_func (values, g_object_unref);
  g_variant_iter_init (&iter, params);

  for (; (child = g_variant_iter_next_value (&iter)) != NULL;)
    {

      g_ptr_array_add (values, _nw_extension_param_unpack (child, context));
      g_variant_unref (child);
    }
return values;
}
