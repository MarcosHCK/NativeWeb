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

  public errordomain ScriptError
    {
      FAILED;
      public static extern GLib.Quark quark ();
    }

  public class Error : GLib.Object
    {

      public int code { get; construct; }
      public GLib.Quark domain { get; construct; }
      public string message { get; construct; }

      const string KLASS_KEY = "nw-error-jsc-class";

      public Error (GLib.Quark domain, int code, string message)
        {
          Object (code: code, domain: domain, message: message);
        }

      public Error.from_gerror (GLib.Error error)
        {
          Object (code: error.code, domain: error.domain, message: error.message);
        }

      static Error constructor (GenericArray<JSC.Value> values, JSC.Class jsc_class)
        {
          unowned var code = ScriptError.FAILED;
          unowned var domain = ScriptError.quark ();
          string? message = null;

          if (values.length > 0)
            {
              JSC.Value value;

              for (bool retry = true; retry;) if ((value = values [0]).is_string ())

                { message = value.to_string (); break; }
              else
                { retry = false;
                  value = value.object_invoke_methodv ("toString", null); }
            }
          return new Error (domain, code, message ?? "unspecified");
        }

      static JSC.Value query_int (int value)
        {
          unowned var context = JSC.Context.get_current ();
          return new JSC.Value.number (context, (double) value);
        }

      static JSC.Value query_string (string value)
        {
          unowned var context = JSC.Context.get_current ();
          return new JSC.Value.string (context, value);
        }

      public static unowned JSC.Class register (JSC.Context context)
        {
          unowned var destroy_notify = (GLib.DestroyNotify) GLib.Object.unref;
          unowned var name = "GError";
          unowned var parent_class = (JSC.Class?) null;
          unowned var vtable = (JSC.ClassVTable?) null;

          unowned var klass = (JSC.Class) context.register_class (name, parent_class, vtable, destroy_notify);

          klass.add_property ("code", typeof (JSC.Value), 
            s => query_int (((Error) s)._code), null);
          klass.add_property ("domain", typeof (JSC.Value),
            s => query_string (((Error) s)._domain.to_string ()), null);
          klass.add_property ("message", typeof (JSC.Value),
            s => query_string (((Error) s)._message.to_string ()), null);
          klass.add_method ("toString", s => ((Error) s).to_string (), typeof (string));

          var ctor = klass.add_constructor (null, a => constructor (a, klass), typeof (Error));

          context.set_data_full (KLASS_KEY, klass.ref (), destroy_notify);
          context.set_value (klass.get_name (), ctor);
        return klass;
        }

      [CCode (cheader_filename = "jsc/jsc.h", cname = "jsc_context_throw_with_name_printf")]
      [PrintfFormat]
      static extern void _throw_with_name_printf (JSC.Context context, string name, string fmt, ...);

      public static void @throw (JSC.Context context, GLib.Error error, string? name = null)
        {

          if (error.domain == GLib.DBusError.quark () && GLib.DBusError.is_remote_error (error))
            {
              var _name = GLib.DBusError.get_remote_error (error);

              GLib.DBusError.strip_remote_error (error);
              Error.throw (context, error, _name);
            }
          else
            {
              unowned var code = error.code;
              unowned var domain = error.domain.to_string ();
              unowned var message = error.message.to_string ();

              name = name ?? "GError";

              _throw_with_name_printf (context, name, "%s: %u: %s", domain, code, message);
            }
        }

      public string to_string ()
        {
          return "%s: %u: %s".printf (_domain.to_string (), _code, _message);
        }

      public JSC.Value to_value (JSC.Context context)
        {
          unowned JSC.Class? jsc_class;

          if (unlikely ((jsc_class = context.get_data<JSC.Class> (KLASS_KEY)) == null))
            jsc_class = Error.register (context);
        return new JSC.Value.object (context, @ref (), jsc_class);
        }
    }
}