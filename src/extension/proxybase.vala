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

  public class Factory : GLib.Object
    {
    }

  public class ProxyBase : GLib.Object, IAttributable, IInvocable, ISignalable
    {

      public GLib.DBusProxy? proxiee { get; construct; }
      public int timeout_msec { get; set; default = -1; }

      public ProxyBase (GLib.DBusProxy? proxiee = null)
        {
          Object (proxiee: proxiee);
        }

      public static JSC.Value add_default_ctor (JSC.Class jsc_klass, JSC.Context context)
        {
          var name = jsc_klass.get_name ();
          var ctor = jsc_klass.add_constructor (name, () => new ProxyBase (), typeof (ProxyBase));
          context.set_value (jsc_klass.get_name (), ctor);
        return ctor;
        }

      public static unowned JSC.Class add_factory (JSC.Class jsc_klass, JSC.Context context, string? name = null)
        {
          unowned var destroy_notify = (GLib.DestroyNotify) Object.unref;
          unowned var parent_class = (JSC.Class?) null;
          unowned var vtable = (JSC.ClassVTable?) null;

          name = name ?? @"$(jsc_klass.get_name ())Factory";

          unowned var klass = (JSC.Class) context.register_class (name, parent_class, vtable, destroy_notify);

          var instance = new Factory ();
          var factory = new JSC.Value.object (context, (owned) instance, klass);

          context.set_value (klass.get_name (), factory);
        return klass;
        }

      static string construct_signature (GLib.DBusArgInfo[] args)
        {
          var builder = new GLib.StringBuilder ("(");

          foreach (unowned var info in args) builder.append (info.signature);
                                             builder.append_c (')');
        return builder.free_and_steal ();
        }

      protected async GLib.Variant? invoke (string method_name, GLib.Variant? parameters) throws GLib.Error
        {
          if (unlikely (proxiee == null))
           throw new GLib.IOError.NOT_CONNECTED ("proxy object is not connected");

          unowned var flags1 = GLib.DBusCallFlags.ALLOW_INTERACTIVE_AUTHORIZATION;
          unowned var flags2 = GLib.DBusCallFlags.NO_AUTO_START;
          unowned var flags = flags1 | flags2;
        return yield proxiee.call (method_name, parameters, flags, timeout_msec);
        }

      protected GLib.Variant read_property (string property_name) throws GLib.Error
        {
          if (unlikely (proxiee == null))
           throw new GLib.IOError.NOT_CONNECTED ("proxy object is not connected");

          GLib.Variant? value;

          if (unlikely ((value = proxiee.get_cached_property (property_name)) == null))
            throw new GLib.IOError.INVALID_DATA ("uncached property");
        return value;
        }

      public static unowned JSC.Class register (JSC.Context context, GLib.DBusInterfaceInfo dbus_info, string? name = null)
        {
          unowned var destroy_notify = (GLib.DestroyNotify) Object.unref;
          unowned var parent_class = (JSC.Class?) null;
          unowned var vtable = (JSC.ClassVTable?) null;

          name = name ?? dbus_info.name;

          unowned var klass = (JSC.Class) context.register_class (name, parent_class, vtable, destroy_notify);

          foreach (unowned var info in dbus_info.methods)
            {
              var signature = construct_signature (info.in_args);
              ((IInvocable)).register (klass, info.name, info.name, signature);
            }

          foreach (unowned var info in dbus_info.properties)
            {
              unowned var signature = info.signature;
              ((IAttributable)).register (klass, info.name, info.name, signature);
            }

          foreach (unowned var info in dbus_info.signals)
            {
              ((ISignalable)).register (klass, info.name, info.name);
            }
        return klass;
        }

      protected bool write_property (string property_name, GLib.Variant value) throws GLib.Error
        {
          if (unlikely (proxiee == null))
           throw new GLib.IOError.NOT_CONNECTED ("proxy object is not connected");

          proxiee.set_cached_property (property_name, value);

          write_property_.begin (property_name, value, (o, res) =>
            {

              try { ((ProxyBase) o).write_property_.end (res); } catch (GLib.Error e)
                {
                  unowned var code = e.code;
                  unowned var domain = e.domain.to_string ();
                  unowned var message = e.message.to_string ();

                  critical ("failed to write property '%s': %s: %u: %s", property_name, domain, code, message);
                }
            });
        return true;
        }

      protected async bool write_property_ (string property_name, GLib.Variant value) throws GLib.Error
        {
          unowned var flags1 = GLib.DBusCallFlags.ALLOW_INTERACTIVE_AUTHORIZATION;
          unowned var flags2 = GLib.DBusCallFlags.NO_AUTO_START;
          unowned var flags = flags1 | flags2;
          unowned var info = proxiee.get_interface_info ();
          unowned var method_name = "org.freedesktop.DBus.Properties.Set";

          if (unlikely (info == null))
            throw new GLib.IOError.INVALID_DATA ("underlying proxy has not info");

          var _interface_name = new GLib.Variant.string (info.name);
          var _property_name = new GLib.Variant.string (property_name);
          var _value = new GLib.Variant.variant (value);
          var parameters = new GLib.Variant.tuple ({ _interface_name, _property_name, _value });

          yield proxiee.call (method_name, parameters, flags, timeout_msec);
        return true;
        }
    }
}