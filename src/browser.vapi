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
[CCode (cprefix = "NW", lower_case_cprefix = "nw_")]

namespace NativeWeb
{

  [CCode (cheader_filename = "browser.h")]

  public class Browser : GLib.Object, GLib.Initable
    {
      public string app_prefix { get; set; }
      public Browser (GLib.Cancellable? cancellable = null) throws GLib.Error;
      public void add_alias (string alias, string value);
      public void add_user_message_handler (Ipc.Handler handler, string name, [CCode (type = "const GVariantType*")] GLib.VariantType? param_types = null);
      public void remove_user_message_handler (string name);
      [CCode (returns_floating_reference = true)]
      public WebKit.WebView create_view ();
    }}
