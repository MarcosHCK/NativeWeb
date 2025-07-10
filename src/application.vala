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

  public class Application : Gtk.Application
    {

      private class string? _extension_dir = null;
      public NativeWeb.Browser browser { get; }

      public override void constructed ()
        {
          base.constructed ();
          _browser = new NativeWeb.Browser (_extension_dir);
          _browser.add_alias ("^/logo.svg$", @"$resource_base_path/icons/scalable/apps/$application_id.svg");
          _browser.app_prefix = resource_base_path;
        }

      public class void setup_extension_dir (string extension_dir) requires (_extension_dir == null)
        {
          _extension_dir = extension_dir;
        }
    }
}