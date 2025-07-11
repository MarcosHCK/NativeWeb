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

  public class Daemon : GLib.Object, GLib.AsyncInitable
    {

    #if DEVELOPER
      public string _config = Config.SOURCE_DIR + "/daemon.conf";
    #else // DEVELOPER
      public string _config = Config.DATA_DIR + "/dbus" + "/daemon.conf";
    #endif // DEVELOPER
      public string _program = "dbus-daemon";

      public string? address { get; private set; }
      public string? config { get { return _config; } construct { if (null != value) _config = value; } }
      public string? program { get { return _program; } construct { if (null != value) _program = value; } }

      private ProcessWatch? _tracker;
      public signal void daemon_terminated (GLib.Error? error);

      public Daemon (string? config = null, string? program = null)
        {
          Object (config: config, program: program);
        }

      async GLib.DBusConnection connect_to (string address, GLib.Cancellable? cancellable) throws GLib.Error
        {
          var flags1 = GLib.DBusConnectionFlags.AUTHENTICATION_CLIENT;
          var flags2 = DBusConnectionFlags.MESSAGE_BUS_CONNECTION;
          var flags = flags1 | flags2;
        return yield new GLib.DBusConnection.for_address (address, flags, null, cancellable);
        }

      private void daemon_terminated_ (GLib.Error? error)
        {
          daemon_terminated (error);
        }

      public async GLib.DBusConnection launch (GLib.Cancellable? cancellable = null) throws GLib.Error requires (null == _tracker)
        {
          var flags = GLib.SubprocessFlags.STDOUT_PIPE;
          var argv = new string [] { _program, "--config-file", _config, "--print-address" };
          var launcher = new GLib.SubprocessLauncher (flags);
          ProcessImpl.setup_launcher (launcher);

          var subprocess = launcher.spawnv (argv);
          var pipe = subprocess.get_stdout_pipe ();
          var stdout = new GLib.DataInputStream (pipe);
          var address = yield stdout.read_line_async (GLib.Priority.DEFAULT, cancellable);

          if (unlikely (null == address || ! GLib.DBus.is_address (address)))
            throw new GLib.IOError.INVALID_DATA ("got a bad address from DBUS daemon");

          (_tracker = new ProcessWatch (subprocess)).terminated.connect (daemon_terminated_);

        return yield connect_to (_address = address, cancellable);
        }

      public async bool terminate (GLib.Cancellable? cancellable = null) throws GLib.Error
        {
          return null == _tracker ? true : yield _tracker.terminate (cancellable);
        }
    }
}