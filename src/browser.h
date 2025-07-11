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
#ifndef __NW_BROWSER__
#define __NW_BROWSER__ 1
#include <webkit/webkit.h>

#define NW_BROWSER_ERROR (nw_browser_error_quark ())

typedef enum
{
  NW_BROWSER_ERROR_FAILED,
} NWBrowserError;

#define NW_TYPE_BROWSER (nw_browser_get_type ())
#define NW_BROWSER(obj) (G_TYPE_CHECK_INSTANCE_CAST((obj), NW_TYPE_BROWSER, NWBrowser))
#define NW_IS_BROWSER(obj) (G_TYPE_CHECK_INSTANCE_TYPE((obj), NW_TYPE_BROWSER))
typedef struct _NWBrowser NWBrowser;

#if __cplusplus
extern "C" {
#endif // __cplusplus

  GType nw_browser_get_type (void) G_GNUC_CONST;
  GQuark nw_browser_error_quark (void) G_GNUC_CONST;

  void nw_browser_add_alias (NWBrowser* browser, const gchar* alias, const gchar* value);
  WebKitWebView* nw_browser_create_view (NWBrowser* browser);
  const gchar* nw_browser_get_app_prefix (NWBrowser* browser);
  const gchar* nw_browser_get_bus_address (NWBrowser* browser);
  GVariant* nw_browser_get_extension_data (NWBrowser* browser);
  const gchar* nw_browser_get_extension_dir (NWBrowser* browser);
  NWBrowser* nw_browser_new (const gchar* extension_dir);
  void nw_browser_set_app_prefix (NWBrowser* browser, const gchar* app_prefix);
  void nw_browser_set_bus_address (NWBrowser* browser, const gchar* bus_address);
  void nw_browser_set_extension_data (NWBrowser* browser, GVariant* data);

#if __cplusplus
}
#endif // __cplusplus

#endif // __NW_BROWSER__
