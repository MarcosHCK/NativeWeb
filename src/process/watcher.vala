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

  public class ProcessWatch : GLib.Object
    {

      private GLib.Cancellable _cancellable;
      private bool _died = false;
      public GLib.Subprocess subprocess { get; construct; }

      construct
        {
          _cancellable = new GLib.Cancellable ();
        }

      public ProcessWatch (GLib.Subprocess subprocess)
        {
          Object (subprocess: subprocess);
        }

      public override void constructed ()
        {
          unowned var cancellable = _cancellable;
          _subprocess.wait_check_async.begin (cancellable, on_complete);
        }

      private void on_complete (GLib.Object? s, GLib.AsyncResult result)
        {

          try { ((GLib.Subprocess) s).wait_check_async.end (result);
                terminated (null); }
          catch (GLib.Error _error) { if (! (_error is IOError.CANCELLED))
              { terminated (_error); }}
          _died = true;
        }

      public async bool terminate (GLib.Cancellable? cancellable = null) throws GLib.Error
        {
          _cancellable.cancel ();

          if (! _died)
            {
              var source = new GLib.TimeoutSource (1000);

              source.set_callback (terminate_anyway);
              source.set_priority (GLib.Priority.HIGH);

              ProcessImpl.terminate_gracefully (_subprocess);
              source.attach ();

              yield _subprocess.wait_async (cancellable);
              source.destroy ();
            }
        return true;
        }

      public bool terminate_anyway ()
        {
          _subprocess.force_exit ();
        return GLib.Source.REMOVE;
        }

      public signal void terminated (GLib.Error? error)
        {

          if (unlikely (null != error))
            {
              unowned var code = error.code;
              unowned var domain = error.domain.to_string ();
              unowned var message = error.message.to_string ();

              critical ("process crashed: %s: %u: %s", domain, code, message);
            }
        }
    }
}