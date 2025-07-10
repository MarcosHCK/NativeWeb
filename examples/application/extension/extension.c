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
#include <gmodule.h>
#include <nativewebext.h>
#include <webkit/webkit-web-process-extension.h>

static void on_register (NWExtension* extension, JSCContext* context, WebKitWebPage* web_page)
{
  (void) extension;
  (void) context;
  (void) web_page;
}

G_MODULE_EXPORT void webkit_web_process_extension_initialize_with_user_data (WebKitWebProcessExtension* wk_extension, const GVariant* user_data G_GNUC_UNUSED)
{
  g_info (PACKAGE_TARNAME " extension loaded");

  gpointer object = nw_extension_new_default (wk_extension);
  g_signal_connect (object, "register", G_CALLBACK (on_register), object);
}
