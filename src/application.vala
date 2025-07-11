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

  struct DeferredUrl
    {
      string hint;
      GLib.File url;

      public DeferredUrl (GLib.File url, string hint)
        {
          this.hint = hint;
          this.url = url;
        }
    }

  public class Application : Gtk.Application
    {

      public NativeWeb.Browser browser { get; }
      public NativeWeb.Daemon? daemon { get; }

      private GLib.DBusConnection? _connection = null;
      private GLib.Cancellable? _boot_cancellable = null;
      private GLib.Queue<DeferredUrl?> _deferred = null;
      private bool _register_complete = false;
      private class string? _extension_dir = null;
      private class bool _launch_bus = true;
      private bool ready { get; private set; default = false; }

      public Application (string? application_id)
        {
          Object (application_id: application_id, flags: GLib.ApplicationFlags.HANDLES_OPEN);
        }

      public override void constructed ()
        {
          base.constructed ();

          if (_launch_bus)
            {

              var variable = "NW_DBUS_DAEMON";
              var program = GLib.Environment.get_variable (variable);

              _boot_cancellable = new GLib.Cancellable ();
              (_daemon = new Daemon (null, program)).daemon_terminated.connect (on_daemon_terminated);
            }

          _browser = new NativeWeb.Browser (_extension_dir);
          _browser.add_alias ("^/logo.svg$", @"$resource_base_path/icons/scalable/apps/$application_id.svg");
          _browser.app_prefix = resource_base_path;
          _deferred = new GLib.Queue<DeferredUrl?> ();
        }

      public new virtual bool dbus_register (GLib.DBusConnection connection, string object_path) throws GLib.Error
        {
          _browser.bus_address = _daemon.address;
          return true;
        }

      public new virtual void dbus_unregister (GLib.DBusConnection connection, string object_path)
        {
          _browser.bus_address = null;
        }

      private void on_daemon_terminated (GLib.Error? e)
        {
          var format = "DBus daemon stopped for unknown reasons";
          var message = e != null ? new Message.gerror (e) : new Message.warning (format);

          message.show_orphan (this);
        }

      public override void open (GLib.File[] files, string hint)
        {

          if (_ready)

            foreach (unowned var file in files)
              open_url (file, hint);
          else
            foreach (unowned var file in files)
              _deferred.push_tail (DeferredUrl (file, hint));
        }

      [HasEmitter]
      public virtual signal void open_url (GLib.File url, string hint)
        {
          warning ("NWApplication::open_url call fell in deaf hears");
        }

      public class void set_extension_dir (string extension_dir) requires (_extension_dir == null)
        {
          _extension_dir = extension_dir;
        }

      public override void shutdown ()
        {
          base.shutdown ();

          if (null != _daemon && _register_complete)
            {
              var connection = _connection;
              var object_path = "/org/hck/nativeweb/browser";

              dbus_unregister (connection, object_path);
            }

          if (null != _daemon) base.hold ();

          if (null != _daemon) _daemon.terminate.begin (null, (o, res) =>
            {

              try { _daemon.terminate.end (res); } catch (GLib.Error e)
                {
                  unowned var code = e.code;
                  unowned var domain = e.domain.to_string ();
                  unowned var message = e.message.to_string ();

                  critical ("DBus daemon close error: %s: %u: %s", domain, code, message);
                  return;
                }

              base.release ();
            });
        }

      public override void startup ()
        {
          base.startup ();
          if (null != _daemon) base.hold ();

          if (null != _daemon) _daemon.launch.begin (_boot_cancellable, (o, res) =>
            {

              try { _connection = _daemon.launch.end (res); } catch (GLib.Error e)
                {
                  unowned var code = e.code;
                  unowned var domain = e.domain.to_string ();
                  unowned var message = e.message.to_string ();

                  critical ("DBus daemon setup error: %s: %u: %s", domain, code, message);

                  base.release ();
                  return;
                }

              var object_path = "/org/hck/nativeweb/browser";

              try { _register_complete = dbus_register (_connection, object_path); } catch (GLib.Error e)
                {
                  unowned var code = e.code;
                  unowned var domain = e.domain.to_string ();
                  unowned var message = e.message.to_string ();

                  critical ("DBus interface setup error: %s: %u: %s", domain, code, message);

                  base.quit ();
                  return;
                }

              ready = (_register_complete = true);

              for (DeferredUrl? _url; (_url = _deferred.pop_head ()) != null;)
                open_url (_url.url, _url.hint);
              base.release ();
            });
        }

      public class void suppress_internal_bus ()
        {
          _launch_bus = false;
        }
    }
}