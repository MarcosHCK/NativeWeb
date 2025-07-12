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

  public interface ISignalable : GLib.Object
    {

      [Compact] class SignalConnector
        {
          public string name;
          public ISignalable proxy;

          public extern void free ();

          public SignalConnector (string name, ISignalable proxy)
            {
              this.name = name;
              this.proxy = proxy;
            }
        }

      private ulong add_signal_handler (string signal_name, JSC.Value func)
        {
          return add_signal_handler_ (this, signal_name, func);
        }

      [CCode (cheader_filename = "isignalable.h", cname = "_nw_isignalable_recv_signal_connect")]
      static extern ulong add_signal_handler_ (GLib.Object? @this, string signal_name, JSC.Value func);

      public void consume (GLib.Variant message)
        {
          GLib.Variant _params;
          string signal_name = Ipc.Call.unpack (message, out _params);

          recv_signal (signal_name, _params);
        }

      static ulong on_signal_connect (GenericArray<JSC.Value> a, SignalConnector connector)
        {
          ulong id = 0;
          if (a.length < 1 || ! a [0].is_function ())

            JSC.Context.get_current ().throw (@"expected callable argument, got $(a.length < 1 ? "nothing" : a [0].to_string ())");
          else
            id = connector.proxy.add_signal_handler (connector.name, a [0]);
        return id;
        }

      protected static void prepare (JSC.Class klass)
        {
          var klass_name = klass.name;

          klass.add_method ("disconnect", (s, a) =>
            {
              if (a.length < 1 || a [0].is_function ())

                JSC.Context.get_current ().throw (@"$(klass_name).disconnect must receive a callable argument");
              else
                ((ISignalable) s).remove_handler ((ulong) a [0].to_double ());
              return null;
            }, Type.NONE);
        }

      [HasEmitter] public signal void recv_signal (string signal_name, GLib.Variant _params);

      protected static void register (JSC.Class klass, string field_name, string signal_name)
        {
          var property_type = typeof (JSC.Value);

          klass.add_property (field_name, property_type, s =>
            {
              var connector = new SignalConnector (signal_name, (ISignalable) s);
              unowned var destroy_notify = (DestroyNotify) SignalConnector.free;
              unowned var user_data = (void*) (owned) connector;

              var context = (JSC.Context) JSC.Context.get_current ();
              var connect = new JSC.Value.function_variadic (context, "connect", (Callback) on_signal_connect, user_data, destroy_notify, Type.ULONG);
              var object = new JSC.Value.object (context, null, null);

                object.object_set_property ("connect", connect);
              return object;
            }, null);
        }

      private void remove_handler (ulong handler_id)
        {
          disconnect (handler_id);
        }
    }
}
