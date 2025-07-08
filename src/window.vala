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

  [GtkTemplate (ui = "/org/hck/nativeweb/gtk/window.ui")]

  public class Window : Gtk.ApplicationWindow
    {

      public NativeWeb.Browser browser { get; construct; }
      private Dragger dragger = new Dragger ();
      private HeaderBar? header_bar = null;
      public WebKit.WebView webview { get; private set; }
      public bool with_titlebar { construct; default = true; }

      construct
        {
          webview = browser.create_view ();

          webview.decide_policy.connect (on_decide_policy);
          webview.load_failed.connect (on_load_failed);
          webview.permission_request.connect (on_permission_request);
          webview.visible = webview.vexpand = webview.hexpand = true;
          webview.user_message_received.connect (on_user_message_received);
          webview.web_process_terminated.connect (on_web_process_terminated);
          set_child (webview);

          if (_with_titlebar)

            set_titlebar (header_bar = new HeaderBar ());
          else
            {
              var bar = new Gtk.HeaderBar ();

              bar.visible = (bar.show_title_buttons = false);
              set_titlebar (bar);
            }

          notify ["application"].connect (on_notify_application);
          notify ["maximized"].connect (on_notify_maximized);

          ((Gtk.Widget) this).add_controller (dragger.controller);
        }

      public Window (Gtk.Application application, NativeWeb.Browser browser)
        {
          Object (application: application, browser: browser, with_titlebar: true);
        }

      public Window.without_titlebar (Gtk.Application application, NativeWeb.Browser browser)
        {
          Object (application: application, browser: browser, with_titlebar: false);
        }

      public override bool close_request ()
        {
          if (webview == null) return false;
          var parameters = new GLib.Variant.tuple ({ });
          var message = new WebKit.UserMessage ("OnClose", parameters);

          visible = false;
          webview.send_message_to_page.begin (message, null, (o, res) => {
            notify_finish (o, res); webview = null; close (); });
          return true;
        }

      public bool load_uri (string uri)
        {
          webview.load_uri (uri);
          return true;
        }

      private void notify_page (WebKit.UserMessage message) requires (webview != null)
        {
          webview.send_message_to_page.begin (message, null, notify_finish);
        }

      static void notify_finish (GLib.Object? o, GLib.AsyncResult res)
        {

          try { ((WebKit.WebView) o).send_message_to_page.end (res); } catch (GLib.Error e)
            {
              unowned var code = e.code;
              unowned var domain = e.domain.to_string ();
              unowned var message_ = e.message.to_string ();

              critical ("error sending notification: %s: %u: %s", domain, code, message_);
            }
        }

      private bool on_decide_policy (WebKit.WebView webview, WebKit.PolicyDecision decision_, WebKit.PolicyDecisionType type)
        {
          switch (type)
            {

            case WebKit.PolicyDecisionType.NAVIGATION_ACTION:

              var decision = decision_ as WebKit.NavigationPolicyDecision;
              var action = decision.navigation_action;

              if (! action.is_redirect ())

                decision_.use ();
              else
                {
                  WebKit.URIRequest request;

                  if ((request = action.get_request ()) == null)
                    {
                      /* Weird */
                      decision_.ignore ();
                      break;
                    }

                  (new Message.question (@"$(webview.get_uri ()) wants to redirect to $(request.get_uri ())"))

                    .choose.begin (this, null, (o, res) =>
                      {
                        try { switch (((Message) o).choose.end (res))
                          {
                            case MessageResponse.NO: decision_.ignore (); break;
                            case MessageResponse.YES: decision_.use (); break;
                            default: assert_not_reached ();
                          } }
                        catch (GLib.Error e)
                          {
                            error (@"$(e.domain): $(e.code): $(e.message)");
                          }
                      });
                }
              break;

            case WebKit.PolicyDecisionType.NEW_WINDOW_ACTION:

              decision_.ignore ();
              warning ("pop-up window blocked");
              break;

            case WebKit.PolicyDecisionType.RESPONSE:

              var decision = decision_ as WebKit.ResponsePolicyDecision;

              if (decision.is_mime_type_supported ())
                return false;

              var response = decision.get_response ();
              var request = decision.get_request ();
              var mime_type = response.get_mime_type ();
              var uri = request.get_uri ();

              if (webview.get_main_resource ().get_uri () == uri && mime_type == "application/pdf")
                {
                  webview.load_uri (@"pdf://$uri");
                  return false;
                }

              decision_.download ();
              break;
            }
          return true;
        }

      private bool on_load_failed (WebKit.WebView webview, WebKit.LoadEvent event, string failing_uri, GLib.Error error)
        {
          if (error.code == WebKit.NetworkError.CANCELLED)
            return false;

          (new Message.warning (@"LoadFailed: $(error.domain): $(error.code): $(error.message)")).show (this);
          return true;
        }

      private void on_notify_application ()
        {
          icon_name = application?.application_id;
          if (null != header_bar)
          header_bar.menu_model = application?.menubar;
        }

      private void on_notify_maximized ()
        {
          if (webview == null) return;
          var parameters = new GLib.Variant ("(b)", maximized);
          var message = new WebKit.UserMessage ("Maximized", parameters);
          notify_page (message);
        }

      private bool on_permission_request (WebKit.WebView webview, WebKit.PermissionRequest request)
        {
          request.deny ();
          warning ("request of type %s denied", request.get_type ().name ());
          return true;
        }

      private bool on_user_message_received (WebKit.WebView webview, WebKit.UserMessage message)
        {
          GLib.Variant? result = null;
          string name;

          try { switch ((name = message.name))
            {
            case "close":

              close ();
              break;

            case "drag":

              bool value = false;
              message.parameters.get ("(b)", &value);

              dragger.drag = value;

              result = new GLib.Variant.boolean (true);
              break;

            case "maximize":

              bool abs = false, value = false;
              message.parameters.get ("(mb)", &abs, &value);

              if (abs ? value : !( Gdk.ToplevelState.MAXIMIZED in (get_native ()?.get_surface () as Gdk.Toplevel)?.state))
                maximize (); else unmaximize ();

              result = new GLib.Variant.boolean (true);
              break;

            case "minimize":

              bool abs = false, value = false;
              message.parameters.get ("(mb)", &abs, &value);

              if (abs ? value : !( Gdk.ToplevelState.MINIMIZED in (get_native ()?.get_surface () as Gdk.Toplevel)?.state))
                minimize (); else unminimize ();

              result = new GLib.Variant.boolean (true);
              break;

            case "open":

              unowned string? uri_string = null;

              message.parameters.get ("(&s)", &uri_string);

              var path = Application.get_default ().resource_base_path;
              var base_uri = GLib.Uri.build (0, "app", null, null, 0, path, null, null);
              var uri_object = GLib.Uri.parse_relative (base_uri, uri_string, 0);
              var uri = uri_object.to_string ();

              Application.get_default ().open ({ GLib.File.new_for_uri (uri) }, "");
              result = new GLib.Variant.boolean (true);
              break;

            case "resize":

              int h = default_height;
              int w = default_width;

              message.parameters.get ("(ii)", &h, &w);

              set_default_size (w, h);
              result = new GLib.Variant.boolean (true);
              break;

            default: return false;
            } }
          catch (GLib.Error e)
            {
              var parameters = Ipc.reply_pack (null, e);
              var reply = new WebKit.UserMessage (name, parameters);
              message.send_reply (reply);
            }
          if (unlikely (result != null))
            {
              result = new GLib.Variant.tuple ({ result });

              var parameters = Ipc.reply_pack (result, null);
              var reply = new WebKit.UserMessage (name, parameters);
              message.send_reply (reply);
            }
          return true;
        }

      private void on_web_process_terminated (WebKit.WebView webview, WebKit.WebProcessTerminationReason reason)
        {
          (new Message.error (@"WebProcess crashed: $reason")).show (this);
        }
    }
}
