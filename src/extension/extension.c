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
#include <webkit/webkit-web-process-extension.h>

static gpointer extension = NULL;
gpointer nw_extension_get_default (void) G_GNUC_PURE;
gpointer nw_extension_new_default (WebKitWebProcessExtension* wk_extension, GVariant* parameters);

GType nw_extension_get_type (void) G_GNUC_CONST;
WebKitScriptWorld* nw_extension_get_script_world (gpointer extension);

#define g_value_init_set(value,suffix,gtype,...) (G_GNUC_EXTENSION ({ \
 ; \
    GType __gtype = ((gtype)); \
    GValue* __value = ((value)); \
    g_value_init (__value, __gtype); \
    g_value_set_##suffix (__value, __VA_ARGS__); \
  }))

#define g_value_unsets(values,n_values) (G_GNUC_EXTENSION ({ \
 ; \
    guint __i; \
    const guint __n_values = ((n_values)); \
    GValue* __values = ((values)); \
 ; \
    for (__i = 0; __i < __n_values; ++__i) g_value_unset (&__values [__i]); \
  }))

static void on_page_created (WebKitWebProcessExtension* wk_extension G_GNUC_UNUSED, WebKitWebPage* page, gpointer pself)
{
  JSCContext* context;
  WebKitScriptWorld* script_world;

  script_world = nw_extension_get_script_world (pself);
  /* Force the creation of an javascript context for this page */
  context = webkit_frame_get_js_context_for_script_world (webkit_web_page_get_main_frame (page), script_world);
  (void) context;

  g_object_unref (context);
}

static void __attribute__((destructor)) nw_extension_destroy_default (void)
{
  g_info ("Web-Process-Extension unloaded");
  g_clear_object (&extension);
}

gpointer nw_extension_get_default (void)
{
  g_assert (NULL != extension);
  return extension;
}

gpointer nw_extension_new_default (WebKitWebProcessExtension* wk_extension, GVariant* parameters)
{
  g_return_val_if_fail (WEBKIT_IS_WEB_PROCESS_EXTENSION (wk_extension), NULL);
  g_return_val_if_fail (parameters == NULL || g_variant_check_format_string (parameters, "(smsm*)", FALSE), NULL);

  g_info ("Web-Process-Extension loaded");

  if (g_once_init_enter_pointer (&extension))
    {
      GError* tmperr = NULL;
      GType gtype = nw_extension_get_type ();
      const gchar* names [] = { "parameters", "wk_extension" };
      GValue values [G_N_ELEMENTS (names)] = {0};

      g_value_init_set (&values [0], variant, G_TYPE_VARIANT, parameters);
      g_value_init_from_instance (&values [1], wk_extension);

      gpointer object = g_object_new_with_properties (gtype, G_N_ELEMENTS (names), names, values);
      gboolean success = g_initable_init (G_INITABLE (object), NULL, &tmperr);

      if ((g_value_unsets (values, G_N_ELEMENTS (names)), (void) success), G_UNLIKELY (tmperr != NULL))

        { g_error ("%s: %u: %s", g_quark_to_string (tmperr->domain), tmperr->code, tmperr->message);
          g_clear_object (&object); }
      else
        g_signal_connect_object (wk_extension, "page-created", G_CALLBACK (on_page_created), object, 0);

      g_once_init_leave_pointer (&extension, object);
    }
return extension;
}
