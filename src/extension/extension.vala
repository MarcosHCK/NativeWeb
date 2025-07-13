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

  public class Extension : GLib.Object, GLib.Initable
    {

      private string _bus_address;
      private string _uuid;

      public GLib.DBusConnection bus { get; }
      public GLib.Variant? extension_data { get; }
      public GLib.Variant parameters { construct; }
      public WebKit.ScriptWorld script_world { get; private set; }
      public WebKit.WebProcessExtension wk_extension { get; construct; }

      public override void constructed ()
        {
          base.constructed ();
          _parameters.get ("(smsm*)", &_uuid, &_bus_address, &_extension_data);
        }

      public static extern unowned Extension get_default ();

      static void evaluate (JSC.Context context, string path) { try
        {
          var bytes = GLib.resources_lookup_data (path, 0);
          var uri = @"resource://$path";

          unowned var data = (uint8 []) bytes.get_data ();
          unowned var code = (string) data;
          unowned var length = (ssize_t) data.length;

          context.evaluate_with_source_uri (code , length, uri, 1);
          bytes = null;
        }
      catch (GLib.Error e)
        {
          Error.throw (context, e);
        }}

      static void exception_handler (JSC.Context context, JSC.Exception exception)
        {
          var console = (JSC.Value) context.get_value ("console");
          var message = (JSC.Value) new JSC.Value.string (context, exception.to_string ());
          console.object_invoke_methodv ("error", { message });

          warning ("%s", exception.report ());
          context.throw_exception (exception);
        }

      public bool init (GLib.Cancellable? cancellable) throws GLib.Error
        {
          script_world = WebKit.ScriptWorld.get_default ();
          script_world.window_object_cleared.connect (on_window_object_cleared);
          wk_extension.user_message_received.connect (on_user_message_received);

          unowned var address = _bus_address;
          unowned var flags1 = GLib.DBusConnectionFlags.AUTHENTICATION_CLIENT;
          unowned var flags2 = GLib.DBusConnectionFlags.MESSAGE_BUS_CONNECTION;
          unowned var flags = flags1 | flags2;

          _bus = new GLib.DBusConnection.for_address_sync (address, flags, null, null);
          return true;
        }

      public static extern unowned Extension new_default (WebKit.WebProcessExtension wk_extension, [CCode (type = "const GVariant*")] GLib.Variant? parameters);

      public signal void recv_message (string name, GLib.Variant @params);
      public signal void register (JSC.Context context, WebKit.WebPage web_page);

      public async GLib.Variant? send_message (string name, GLib.Variant parameters, GLib.Cancellable? cancellable = null) throws GLib.Error
        {
          var message = new WebKit.UserMessage (name, parameters);
          var response = yield wk_extension.send_message_to_context (message, cancellable);
          var result = response.parameters;
          return Ipc.Reply.unpack (result);
        }

      private void on_user_message_received (WebKit.UserMessage message)
        {
          unowned var name = message.name;
          unowned var params = message.parameters;

          recv_message (name, params);
        }

      private void on_window_object_cleared (WebKit.WebPage web_page, WebKit.Frame frame)
        {
          var context = frame.get_js_context_for_script_world (script_world);

          context.push_exception_handler (exception_handler);

          BrowserNamespace.register (context, web_page);
          Error.register (context);
          LogLib.register (context);
          Utf8Namespace.register (context);

          register (context, web_page);
          evaluate (context, "/org/hck/nativeweb/extension/setup.js");
        }
    }
}
