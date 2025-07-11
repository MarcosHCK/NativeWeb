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
[CCode (cprefix = "NWA", lower_case_cprefix = "nwa_")]

namespace NativeWebApp
{

  public class Application : NativeWeb.Application
    {

      construct
        {
          add_actions (this);
          set_version (Config.PACKAGE_STRING);
        }

      class construct
        {
          set_extension_dir (EXTENSION_DIR);
        }

      public static int main (string[] args)
        {
          try { return (new Application ()).run (args); } catch (GLib.Error e)
            { critical (@"$(e.domain): $(e.code): $(e.message)"); return 1; }
        }

      public Application () throws GLib.Error
        {
          Object (application_id: "org.hck.nativeweb.app", flags: GLib.ApplicationFlags.HANDLES_OPEN);
        }

      public override void activate ()
        {
          base.activate ();
          activate_action ("landpage", null);
        }

      private new void add_action (string name, GLib.VariantType? parameter_type, owned GLib.SimpleActionActivateCallback callback)
        {
          add_action_ (this, name, parameter_type, (owned) callback);
        }

      static void add_action_ (GLib.Application self, string name, GLib.VariantType? parameter_type, owned GLib.SimpleActionActivateCallback callback)
        {
          GLib.SimpleAction action;
          (action = new GLib.SimpleAction (name, parameter_type)).activate.connect ((a, p) => callback (a, p));
          self.add_action (action);
        }

      static void add_actions (Application self)
        {
          unowned var ref = self;
          self.add_action ("landpage", null, () => @ref.open ({ GLib.File.new_for_uri ("app:///") }, ""));
          self.add_action ("quit", null, () => { foreach (unowned var window in @ref.get_windows ()) window.close (); });
        }

      public override void constructed ()
        {
          base.constructed ();
          browser.add_alias ("^/([-_a-zA-Z]+)$", @"$resource_base_path/page/\\1.html");
          browser.add_alias ("^/$", @"$resource_base_path/page/index.html");
          browser.app_prefix = @"$resource_base_path/page";
        }

      public override void open (GLib.File[] files, string hint)
        {
          foreach (unowned var file in files) open_file (file, hint);
        }

      private void open_file (GLib.File file, string hint)
        {
          var window = new NativeWeb.Window.without_titlebar (this, browser);

          window.present ();
          window.load_uri (file.get_uri ());
        }
    }
}