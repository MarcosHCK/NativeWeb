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

  public class Dragger : GLib.Object
    {

      const uint delay = 200;
      const double min_offset = 10;

      public Gtk.GestureDrag controller { get; private set; }
      private Delayed delayed;
      public bool drag { get; set; }

      private Gdk.Toplevel? toplevel { get
        {
          unowned var widget = controller.get_widget ();
          unowned var native = widget?.get_native ();
          unowned var surface = native?.get_surface ();
          return ! (surface is Gdk.Toplevel) ? null : (Gdk.Toplevel) surface; }}

      construct
        {
          controller = new Gtk.GestureDrag ();
          controller.drag_update.connect (on_drag_update);
          controller.propagation_phase = Gtk.PropagationPhase.CAPTURE;
          delayed = new Delayed (delay);
        }

      static double distance (double dx, double dy)
        {
          return Math.sqrt ((dx * dx) + (dy * dy));
        }

      private void on_drag_update (double dx, double dy)
        {

          double x = 0, y = 0;
          if (drag && controller.get_start_point (out x, out y) && distance (dx, dy) >= min_offset)
            {
              unowned var button = (int) controller.get_current_button ();
              unowned var event = controller.get_current_event ();
              unowned var device = controller.get_current_event_device ();

              toplevel?.begin_move (device, button, x, y, event?.get_time () ?? 0);
            } }
    }
}