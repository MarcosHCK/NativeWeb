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
[CCode (cprefix = "NWA", lower_case_cprefix = "nwa_")]

namespace NativeWebApp
{

  public class InterfaceFacade : NativeWeb.ProxyBase
    {

      public InterfaceFacade (Interface proxiee)
        {
          Object (proxiee: (GLib.DBusProxy) proxiee);
        }

      static JSC.Value constructor (JSC.Class jsc_class)
        {

          unowned var extension = NativeWeb.Extension.get_default ();
          unowned var connection = extension.bus;
          unowned var context = JSC.Context.get_current ();
          unowned var flags = GLib.DBusProxyFlags.NONE;
          unowned var name = "org.hck.nativeweb.app";
          unowned var object_path = "/org/hck/nativeweb/app";

          return NativeWeb.Promise.create (context, p =>

            Interface.get_proxy.begin (connection, name, object_path, flags, null, (o, res) =>
              {
                Interface proxiee;
                try { proxiee = Interface.get_proxy.end (res); } catch (GLib.Error e)
                  { p.reject_gerror (e); return; }
                var instance = new InterfaceFacade (proxiee);
                    p.resolve (new JSC.Value.object (p.context, (owned) instance, jsc_class));
              }));
        }

      public new static unowned JSC.Class register (JSC.Context context)
        {

          unowned var info = Interface.get_interface_info ();
          unowned var klass = NativeWeb.ProxyBase.register (context, info, "Interface");
          unowned var factory_klass = add_factory (klass, context);
          add_default_ctor (klass, context);
          factory_klass.add_method ("create", (s, a) => constructor (klass), typeof (JSC.Value));
        return klass;
        }
    }
}