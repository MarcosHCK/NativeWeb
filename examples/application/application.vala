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

      private Interface example;

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
          return (new Application ()).run (args);
        }

      public Application ()
        {
          base ("org.hck.nativeweb.app");
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

      uint interface_id;

      public override bool dbus_register (GLib.DBusConnection connection, string object_path) throws GLib.Error
        {
          base.dbus_register (connection, object_path);
          interface_id = connection.register_object<Interface> (object_path, example = new InterfaceImpl ());
        return true;
        }

      public override void dbus_unregister (GLib.DBusConnection connection, string object_path)
        {
          connection.unregister_object (interface_id);
        }

      public override void open_url (GLib.File url, string hint)
        {
          var uri = url.get_uri ();
          var window = new NativeWeb.Window.without_titlebar (this, browser);

          window.present ();
          window.load_uri (uri);
        }
    }
}