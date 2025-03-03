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
#include <browser.h>
#include <ipclib.h>

G_DEFINE_QUARK (h-browser-error-quark, nw_browser_error)

static void nw_browser_g_initable_iface (GInitableIface* iface);

#define NW_BROWSER_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST((klass), H_TYPE_BROWSER, NWBrowserClass))
#define NW_IS_BROWSER_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE((klass), H_TYPE_BROWSER))
#define NW_BROWSER_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS((obj), H_TYPE_BROWSER, NWBrowserClass))
typedef struct _NWBrowserClass NWBrowserClass;

#define _webkit_user_style_sheet_unref0(var) ((var == NULL) ? NULL : (var = (webkit_user_style_sheet_unref (var), NULL)))
#define _webkit_user_script_unref0(var) ((var == NULL) ? NULL : (var = (webkit_user_script_unref (var), NULL)))
#define _g_object_unref0(var) ((var == NULL) ? NULL : (var = (g_object_unref (var), NULL)))
#define _g_bytes_unref0(var) ((var == NULL) ? NULL : (var = (g_bytes_unref (var), NULL)))
#define _g_error_free0(var) ((var == NULL) ? NULL : (var = (g_error_free (var), NULL)))
#define _g_free0(var) ((var == NULL) ? NULL : (var = (g_free (var), NULL)))
typedef struct _Alias Alias;
typedef struct _UserMessageHandler UserMessageHandler;

static void on_emit (NWBrowser* browser, const gchar* name, GVariant* params);
static void on_user_message_received_complete (IpcEndpoint* endpoint, GAsyncResult* res, WebKitUserMessage* message);

struct _NWBrowser
{
  GObject parent;

  /*<private>*/
  GList* aliases;
  gchar* app_prefix;
  gchar* extension_dir;
  IpcEndpoint* user_message_endpoint;

  /*<private>*/
  WebKitWebContext* context;
  WebKitSettings* settings;
  WebKitUserContentManager* user_content;
};

struct _NWBrowserClass
{
  GObjectClass parent_class;
};

struct _Alias
{
  GRegex* regex;
  gchar* replacement;
};

enum
{
  prop_0,
  prop_app_prefix,
  prop_extension_dir,
  prop_number,
};

G_DEFINE_TYPE_WITH_CODE (NWBrowser, nw_browser, G_TYPE_OBJECT, G_IMPLEMENT_INTERFACE (G_TYPE_INITABLE, nw_browser_g_initable_iface))
static GParamSpec* properties [prop_number] = {0};

static void _alias_free (gpointer pself)
{
  g_regex_unref (((Alias*) pself)->regex);
  g_free (((Alias*) pself)->replacement);
  g_slice_free (Alias, pself);
}

static void nw_browser_init (NWBrowser* self)
{
  self->aliases = NULL;
  self->user_message_endpoint = ipc_endpoint_new ();

  g_signal_connect_object (self->user_message_endpoint, "emit", G_CALLBACK (on_emit), self, G_CONNECT_SWAPPED);
}

static void nw_browser_class_dispose (GObject* pself)
{
  g_object_unref (((NWBrowser*) pself)->context);
  g_object_unref (((NWBrowser*) pself)->settings);
  g_object_unref (((NWBrowser*) pself)->user_content);
  g_object_unref (((NWBrowser*) pself)->user_message_endpoint);

  G_OBJECT_CLASS (nw_browser_parent_class)->dispose (pself);
}

static void nw_browser_class_finalize (GObject* pself)
{
  g_list_free_full (((NWBrowser*) pself)->aliases, _alias_free);

  G_OBJECT_CLASS (nw_browser_parent_class)->finalize (pself);
}

static void nw_browser_class_get_property (GObject* pself, guint property_id, GValue* value, GParamSpec* pspec)
{
  switch (property_id)
    {
      case prop_app_prefix: g_value_set_string (value, nw_browser_get_app_prefix ((NWBrowser*) pself)); break;
      case prop_extension_dir: g_value_set_string (value, nw_browser_get_extension_dir ((NWBrowser*) pself)); break;
      default: G_OBJECT_WARN_INVALID_PROPERTY_ID (pself, property_id, pspec);
    }}

static void nw_browser_class_set_property (GObject* pself, guint property_id, const GValue* value, GParamSpec* pspec)
{

  NWBrowser* self = (NWBrowser*) pself;

  switch (property_id)
    {
      case prop_app_prefix: nw_browser_set_app_prefix ((NWBrowser*) pself, g_value_get_string (value)); break;
      case prop_extension_dir: _g_free0 (self->extension_dir);
                               if (g_value_get_string (value) == NULL)
                                  self->extension_dir = g_value_dup_string (value);
        break;
      default: G_OBJECT_WARN_INVALID_PROPERTY_ID (pself, property_id, pspec);
    }}

static void on_emit (NWBrowser* self, const gchar* name, GVariant* params)
{
  WebKitWebContext* context = NULL;
  WebKitUserMessage* message = NULL;

  context = self->context;
  message = webkit_user_message_new (name, params);
  webkit_web_context_send_message_to_all_extensions (context, message);
}

static void report_missing (GUri* uri, WebKitURISchemeRequest* request)
{
  GUriHideFlags flags1 = G_URI_HIDE_AUTH_PARAMS;
  GUriHideFlags flags2 = G_URI_HIDE_PASSWORD;
  GUriHideFlags flags3 = G_URI_HIDE_USERINFO;
  GUriHideFlags flags = flags1 | flags2 | flags3;
  gchar* path;
  GError* tmperr = NULL;

  path = g_uri_to_string_partial (uri, flags);
  tmperr = g_error_new (G_IO_ERROR, G_IO_ERROR_NOT_FOUND, "resource not found: %s", path);
  g_uri_unref (uri);

  webkit_uri_scheme_request_finish_error (request, tmperr);

  g_error_free (tmperr);
  g_free (path);
}

static void on_uri_scheme_request_resource (WebKitURISchemeRequest* request, gpointer pself)
{
  GError* tmperr = NULL;
  NWBrowser* self = (NWBrowser*) pself;

  const gchar* uri_ref = webkit_uri_scheme_request_get_uri (request);

  GUri* base_uri = g_uri_build (0, "app", NULL, NULL, 0, "/", NULL, NULL);
  GUri* uri = g_uri_parse_relative (base_uri, uri_ref, 0, &tmperr);

  GBytes* bytes = NULL;
  GList* list = NULL;

  if ((g_uri_unref (base_uri)), G_UNLIKELY (tmperr != NULL))
    {
      webkit_uri_scheme_request_finish_error (request, tmperr);
      g_error_free (tmperr);
      return;
    }
  else do
    {
      GRegex* regex = ! list ? NULL : ((Alias*) list->data)->regex;
      gchar* replacement = ! list ? NULL : ((Alias*) list->data)->replacement;
      gchar* name;

      if (list == NULL)
        name = g_build_filename (self->app_prefix, g_uri_get_path (uri), NULL);

      else if (! g_regex_match_all (regex, g_uri_get_path (uri), 0, NULL))
        name = NULL;

      else
        {
          uri_ref = g_uri_get_path (uri);

          if ((name = g_regex_replace (regex, uri_ref, -1, 0, replacement, 0, &tmperr)), G_UNLIKELY (tmperr != NULL))
            {
              webkit_uri_scheme_request_finish_error (request, tmperr);
              g_error_free (tmperr);
              return;
            }}

      if (name != NULL && ((bytes = g_resources_lookup_data (name, 0, &tmperr)), G_UNLIKELY (tmperr == NULL)))
        {
          gsize size;
          guchar* data = (guchar*) g_bytes_get_data (bytes, &size);

          gchar* content_type = g_content_type_guess (name, data, size, NULL);
          GInputStream* stream = g_memory_input_stream_new_from_bytes (bytes);

          g_bytes_unref (bytes);
          g_uri_unref (uri);

          webkit_uri_scheme_request_finish (request, stream, size, content_type);

          g_object_unref (stream);
          g_free (content_type);
          return;
        }
      else if (G_UNLIKELY (name != NULL))
        {

          if (g_error_matches (tmperr, G_RESOURCE_ERROR, G_RESOURCE_ERROR_NOT_FOUND))

            _g_error_free0 (tmperr);
          else
            {
              webkit_uri_scheme_request_finish_error (request, tmperr);
              g_error_free (tmperr);
              return;
            }}}
  while ((list = (list ? list->next : self->aliases)) != NULL);
  report_missing (uri, request);
}

static void nw_browser_class_init (NWBrowserClass* klass)
{
  G_OBJECT_CLASS (klass)->dispose = nw_browser_class_dispose;
  G_OBJECT_CLASS (klass)->finalize = nw_browser_class_finalize;
  G_OBJECT_CLASS (klass)->get_property = nw_browser_class_get_property;
  G_OBJECT_CLASS (klass)->set_property = nw_browser_class_set_property;

  const GParamFlags flags1 = G_PARAM_READWRITE | G_PARAM_CONSTRUCT | G_PARAM_STATIC_STRINGS;

  properties [prop_app_prefix] = g_param_spec_string ("app-prefix", "app-prefix", "app-prefix", NULL, flags1);
  properties [prop_extension_dir] = g_param_spec_string ("extension-dir", "extension-dir", "extension-dir", NULL, flags1);
  g_object_class_install_properties (G_OBJECT_CLASS (klass), prop_number, properties);
}

static void on_initialize_web_extensions (WebKitWebContext* context, NWBrowser* self)
{
  GVariantBuilder builder = G_VARIANT_BUILDER_INIT ((const GVariantType*) "(s)");

  g_variant_builder_add_value (&builder, g_variant_new_take_string (g_uuid_string_random ()));

  GVariant* user_data = g_variant_builder_end (&builder);

  if (self->extension_dir != NULL)
  webkit_web_context_set_web_process_extensions_directory (context, self->extension_dir);
  webkit_web_context_set_web_process_extensions_initialization_user_data (context, user_data);
}

static gboolean on_user_message_received (WebKitWebContext* context, WebKitUserMessage* message, NWBrowser* self)
{
  const gchar* name = webkit_user_message_get_name (message);
  GVariant* params = webkit_user_message_get_parameters (message);

  ipc_endpoint_handle (self->user_message_endpoint, name, params, NULL, (GAsyncReadyCallback) on_user_message_received_complete, message);
return (g_object_ref (message), TRUE);
}

static void on_user_message_received_complete (IpcEndpoint* endpoint, GAsyncResult* res, WebKitUserMessage* message)
{
  GVariant* result = NULL;
  GError* tmperr = NULL;

  if ((result = ipc_endpoint_handle_finish (endpoint, res, &tmperr)), G_UNLIKELY (tmperr != NULL))
    {
      const guint code = tmperr->code;
      const gchar* domain = g_quark_to_string (tmperr->domain);
      const gchar* message_ = tmperr->message;

      g_warning ("%s: %u: %s", domain, code, message_);
      g_error_free (tmperr);
    }
  else
    {
      const gchar* name;
      WebKitUserMessage* reply;

      name = webkit_user_message_get_name (message);
      reply = webkit_user_message_new (name, result);

      webkit_user_message_send_reply (message, reply);
      g_variant_unref (result);
    }

  g_object_unref (message);
}

static gboolean nw_browser_g_initable_iface_init (GInitable* pself, GCancellable* cancellable, GError** error)
{
  NWBrowser* self = NW_BROWSER (pself);

  self->context = g_object_new (WEBKIT_TYPE_WEB_CONTEXT, NULL);

  g_signal_connect (self->context, "initialize-web-process-extensions", G_CALLBACK (on_initialize_web_extensions), self);
  g_signal_connect (self->context, "user-message-received", G_CALLBACK (on_user_message_received), self);

  self->settings = g_object_new (WEBKIT_TYPE_SETTINGS, "default-charset", "UTF-8", "enable-developer-extras", DEVELOPER, "enable-fullscreen", FALSE, NULL);
  self->user_content = g_object_new (WEBKIT_TYPE_USER_CONTENT_MANAGER, NULL);

  WebKitSecurityManager* security = webkit_web_context_get_security_manager (self->context);

  webkit_web_context_set_cache_model (self->context, WEBKIT_CACHE_MODEL_DOCUMENT_BROWSER);
  webkit_web_context_register_uri_scheme (self->context, "app", on_uri_scheme_request_resource, self, NULL);
  webkit_security_manager_register_uri_scheme_as_secure (security, "app");
return TRUE;
}

static void nw_browser_g_initable_iface (GInitableIface* iface)
{
  iface->init = nw_browser_g_initable_iface_init;
}

void nw_browser_add_alias (NWBrowser* browser, const gchar* alias, const gchar* value)
{
  g_return_if_fail (NW_IS_BROWSER (browser));
  g_return_if_fail (alias != NULL);
  g_return_if_fail (value != NULL);
  GError* error = NULL;
  GRegex* regex;

  if ((regex = g_regex_new (alias, G_REGEX_OPTIMIZE, 0, &error)), G_UNLIKELY (error == NULL))
    {
      Alias reg = { .regex = regex, .replacement = g_strdup (value) };
      browser->aliases = g_list_append (browser->aliases, g_slice_dup (Alias, &reg));
    }
  else
    {
      const guint code = error->code;
      const gchar* domain = g_quark_to_string (error->domain);
      const gchar* message = error->message;

      g_error ("%s: %u: %s", domain, code, message);
      g_error_free (error);
    }
}

void nw_browser_add_user_message_handler (NWBrowser* browser, IpcHandler* handler, const gchar* name, const GVariantType* param_type)
{
  g_return_if_fail (NW_IS_BROWSER (browser));
  g_return_if_fail (IPC_IS_HANDLER (handler));

  ipc_endpoint_add_handler (browser->user_message_endpoint, handler, name, param_type);
}

void nw_browser_remove_user_message_handler (NWBrowser* browser, const gchar* name)
{
  g_return_if_fail (NW_IS_BROWSER (browser));
  g_return_if_fail (name != NULL);

  ipc_endpoint_delete_handler (browser->user_message_endpoint, name);
}

WebKitWebView* nw_browser_create_view (NWBrowser* browser)
{
  g_return_val_if_fail (NW_IS_BROWSER (browser), NULL);

  WebKitWebView* webview = g_object_new (WEBKIT_TYPE_WEB_VIEW,
      "settings", browser->settings,
      "user-content-manager", browser->user_content,
      "web-context", browser->context,
      NULL);

  return webview;
}

const gchar* nw_browser_get_app_prefix (NWBrowser* browser)
{
  g_return_val_if_fail (NW_IS_BROWSER (browser), NULL);
  return browser->app_prefix;
}

const gchar* nw_browser_get_extension_dir (NWBrowser* browser)
{
  g_return_val_if_fail (NW_IS_BROWSER (browser), NULL);
  return browser->extension_dir;
}

NWBrowser* nw_browser_new (const gchar* extension_dir, GCancellable* cancellable, GError** error)
{
  return g_initable_new (NW_TYPE_BROWSER, cancellable, error, "extension-dir", extension_dir, NULL);
}

void nw_browser_set_app_prefix (NWBrowser* browser, const gchar* app_prefix)
{
  g_return_if_fail (NW_IS_BROWSER (browser));
  _g_free0 (browser->app_prefix);

  browser->app_prefix = g_strdup (app_prefix);
}
