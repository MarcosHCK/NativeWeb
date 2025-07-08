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

  public enum MessageResponse
    {
      DEFAULT = 0,
      NO = 0,
      YES = 1,
    }

  [GtkTemplate (ui = "/org/hck/nativeweb/gtk/message.ui")]

  public class Message : Gtk.Window
    {
      [GtkChild] private unowned Gtk.Grid? grid1 = null;
      [GtkChild] private unowned Gtk.Image? image1 = null;
      [GtkChild] private unowned Gtk.Label? label1 = null;

      class Quark buttonidq = GLib.Quark.from_string ("hck-button-id-quark");

      [CCode (cname = "add_button")] private void add_buttons (string[] labels)
        {
          for (int i = 0; i < labels.length; ++i)
            {
              var button = new Gtk.Button.with_label (labels [i]);

              button.clicked.connect (on_button_clicked);
              button.set_qdata<int> (buttonidq, i);
              grid1.attach (button, i, 0);
            }
        }

      [CCode (cname = "begin")] [PrintfFormat] private void begin (string format, va_list l)
        {
          label1.use_markup = true;
          label1.label = @"<big>$(GLib.Markup.vprintf_escaped (format, l))</big>";
        }

      [CCode (cname = "finish")] private void finish (string icon_name, string[] labels)
        {
          image1.icon_name = icon_name;
          add_buttons (labels);
        }

      [CCode (cname = "on_button_clicked")] private void on_button_clicked (Gtk.Button button)
        {
          responded (button.get_qdata<int> (buttonidq));
        }

      public signal void responded (int id)
        {
          close ();
        }

      [PrintfFormat] public Message.error (string format, ...)
        {
          Object ();
          begin (format, va_list ());
          finish ("dialog-error-symbolic", { ("Ok") });
        }

      public Message.gerror (GLib.Error e)
        {
          unowned var code = e.code;
          unowned var domain = e.domain.to_string ();
          unowned var message = e.message.to_string ();

          this.error ("%s: %u: %s", domain, code, message);
        }

      [PrintfFormat] public Message.message (string format, ...)
        {
          Object ();
          begin (format, va_list ());
          finish ("dialog-information-symbolic", { ("Ok") });
        }

      [PrintfFormat] public Message.question (string format, ...)
        {
          Object ();
          begin (format, va_list ());
          finish ("dialog-question-symbolic", { ("No"), ("Yes") });
        }

      [PrintfFormat] public Message.warning (string format, ...)
        {
          Object ();
          begin (format, va_list ());
          finish ("dialog-warning-symbolic", { ("Ok") });
        }

      public extern async int choose (Gtk.Window? parent, GLib.Cancellable? cancellable) throws GLib.Error;

      static void _choose_worker (GLib.Task task, Message self, void* task_data, GLib.Cancellable? cancellable = null)
        {
          int _response = -1;
          unowned var response = (int[]) &_response;
          unowned var handler_id = (ulong) self.responded.connect (newval => GLib.AtomicInt.set (ref response [0], newval));

          self.present ();

          while (! cancellable.is_cancelled () && GLib.AtomicInt.get (ref response [0]) < 0)
            GLib.Thread.yield ();

          self.disconnect (handler_id);

          if (cancellable.is_cancelled ())

            task.return_new_error_literal (IOError.quark (), IOError.CANCELLED, "cancelled");
          else
            task.return_int ((ssize_t) _response);
        }

      [CCode (cname = "nw_message_choose")]

      public void choose_async (Gtk.Window? parent, GLib.Cancellable? cancellable, GLib.AsyncReadyCallback callback)
        {
          var task = new GLib.Task (this, cancellable, callback);

          set_transient_for (parent);

          task.set_check_cancellable (false);
          task.set_priority (GLib.Priority.DEFAULT);
          task.set_return_on_cancel (false);
          task.set_source_tag ((void*) choose_async);
          task.set_static_name ("nw_message_choose");
          task.run_in_thread ((TaskThreadFunc) _choose_worker);
        }

      [CCode (cname = "nw_message_choose_finish")]

      public int choose_finish (GLib.AsyncResult result) throws GLib.Error
        {
          return (int) ((GLib.Task) result).propagate_int ();
        }

      public new void show (Gtk.Window? parent)
        {
          set_transient_for (parent);
          present ();
        }

      public void show_orphan (Gtk.Application application)
        {
          Gtk.Window window;

          if ((window = application.get_windows ().nth (0)?.data) == null)

            { this.application = application; this.present (); }
          else
            { show (application.active_window ?? window); }
        }
    }
}
