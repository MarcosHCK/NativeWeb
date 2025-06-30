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

  [Compact (opaque = true)]

  public class Delayed
    {

      private GLib.MainContext context;
      private uint delay;
      private GLib.Source? trigger;

      public Delayed (uint delay)
        {
          this.context = GLib.MainContext.ref_thread_default ();
          this.delay = delay;
          this.trigger = null;
        }

      static GLib.Source create (uint interval, GLib.SourceOnceFunc func)
        {
          var source = new GLib.TimeoutSource (interval);

          source.set_callback (() => { func (); return GLib.Source.REMOVE; });
          source.set_priority (GLib.Priority.DEFAULT);
          source.set_static_name ("NativeWeb.Delayed.trigger");
        return source;
        }

      public void cancel ()
        {
          trigger?.destroy ();
          trigger = null;
        }

      public void launch (owned GLib.SourceOnceFunc func)
        {
          trigger?.destroy ();
          (trigger = create (delay, (owned) func)).attach (context);
        }
    }
}