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

  public class BrowserNamespace : GLib.Object, ISignalable
    {

      private WeakRef _web_page;
      public WebKit.WebPage web_page { owned get { return (WebKit.WebPage) _web_page.get (); } construct { _web_page.set (value); } }

      construct
        {
          web_page.user_message_received.connect (on_user_message_received);
        }

      public BrowserNamespace (WebKit.WebPage web_page)
        {
          Object (web_page: web_page);
        }

      private async GLib.Variant? invoke (string method, GLib.Variant? parameters) throws GLib.Error
        {
          var message = new WebKit.UserMessage (method, parameters);
          var response = yield web_page.send_message_to_view (message, null);
          var result = response.parameters;
          return Ipc.reply_unpack (result);
        }

      private bool on_user_message_received (WebKit.UserMessage user_message)
        {
          recv_signal (user_message.name, user_message.parameters);
          return on_user_message_received_reply (user_message, true);
        }

      static bool on_user_message_received_reply (WebKit.UserMessage user_massage, bool result)
        {
          var parameters = new GLib.Variant.boolean (result);
          var reply = new WebKit.UserMessage (user_massage.name, parameters);
          user_massage.send_reply (reply);
          return result;
        }

      public static JSC.Class register (JSC.Context context, WebKit.WebPage web_page)
        {
          unowned var destroy_notify = (GLib.DestroyNotify) Object.unref;
          unowned var parent_class = (JSC.Class?) null;
          unowned var vtable = (JSC.ClassVTable?) null;

          var instance = new BrowserNamespace (web_page);
          var klass = (JSC.Class) context.register_class ("BrowserNamespace", parent_class, vtable, destroy_notify);

          klass.add_method ("close", (s, a) =>

            Promise.create (JSC.Context.get_current (), p =>

              ((BrowserNamespace) s).invoke.begin ("close", params_pack (a, null), (o, res) =>
                {
                  GLib.Variant v;
                  try { v = ((BrowserNamespace) o).invoke.end (res); } catch (GLib.Error e)
                    { p.reject_gerror ((owned) e); return; }
                      p.resolve (new JSC.Value.boolean (p.context, v.get_child_value (0).get_boolean ()));
                })), typeof (JSC.Value));

          klass.add_method ("drag", (s, a) =>
          
            Promise.create (JSC.Context.get_current (), p =>

              ((BrowserNamespace) s).invoke.begin ("drag", params_pack (a, "(b)"), (o, res) =>
                {
                  GLib.Variant v;
                  try { v = ((BrowserNamespace) o).invoke.end (res); } catch (GLib.Error e)
                    { p.reject_gerror ((owned) e); return; }
                      p.resolve (new JSC.Value.boolean (p.context, v.get_child_value (0).get_boolean ()));
                })), typeof (JSC.Value));

          klass.add_method ("maximize", (s, a) =>
          
            Promise.create (JSC.Context.get_current (), p =>

              ((BrowserNamespace) s).invoke.begin ("maximize", params_pack (a, "(mb)"), (o, res) =>
                {
                  GLib.Variant v;
                  try { v = ((BrowserNamespace) o).invoke.end (res); } catch (GLib.Error e)
                    { p.reject_gerror ((owned) e); return; }
                      p.resolve (new JSC.Value.boolean (p.context, v.get_child_value (0).get_boolean ()));
                })), typeof (JSC.Value));

          klass.add_method ("minimize", (s, a) =>
          
            Promise.create (JSC.Context.get_current (), p =>

              ((BrowserNamespace) s).invoke.begin ("minimize", params_pack (a, "(mb)"), (o, res) =>
                {
                  GLib.Variant v;
                  try { v = ((BrowserNamespace) o).invoke.end (res); } catch (GLib.Error e)
                    { p.reject_gerror ((owned) e); return; }
                      p.resolve (new JSC.Value.boolean (p.context, v.get_child_value (0).get_boolean ()));
                })), typeof (JSC.Value));

          klass.add_method ("open", (s, a) =>
          
            Promise.create (JSC.Context.get_current (), p =>

              ((BrowserNamespace) s).invoke.begin ("open", params_pack (a, "(s)"), (o, res) =>
                {
                  GLib.Variant v;
                  try { v = ((BrowserNamespace) o).invoke.end (res); } catch (GLib.Error e)
                    { p.reject_gerror ((owned) e); return; }
                      p.resolve (new JSC.Value.boolean (p.context, v.get_child_value (0).get_boolean ()));
                })), typeof (JSC.Value));

          klass.add_method ("resize", (s, a) =>
          
            Promise.create (JSC.Context.get_current (), p =>

              ((BrowserNamespace) s).invoke.begin ("resize", params_pack (a, "(ii)"), (o, res) =>
                {
                  GLib.Variant v;
                  try { v = ((BrowserNamespace) o).invoke.end (res); } catch (GLib.Error e)
                    { p.reject_gerror ((owned) e); return; }
                      p.resolve (new JSC.Value.boolean (p.context, v.get_child_value (0).get_boolean ()));
                })), typeof (JSC.Value));

          (ISignalable).prepare (klass);
          (ISignalable).register (klass, "onClose", "OnClose");
          (ISignalable).register (klass, "maximized", "Maximized");

          context.set_value ("browser", new JSC.Value.object (context, (void*) (owned) instance, klass));
        return (owned) klass;
        }
    }
}
