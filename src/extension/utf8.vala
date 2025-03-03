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

  public class Utf8Namespace : GLib.Object
    {

      static GLib.Bytes? prelude (JSC.Context context, GenericArray<JSC.Value> args)
        {
          JSC.Value arg;

          if (unlikely ((arg = prelude_args (context, args)) == null))
            return null;

          if (arg.is_string ())

            return arg.to_string_as_bytes ();
          else
            {
              unowned size_t size;
              unowned void* data = arg.typed_array_get_data (out size);

              return _g_bytes_new_static (data, size);
            }
        }

      static JSC.Value? prelude_args (JSC.Context context, GenericArray<JSC.Value> args)
        {

          if (unlikely (args.length < 1))
            {
              context.throw ("string or bytearray expected");
              return null;
            }

          unowned var arg = args [0];

          if (unlikely ((arg.is_string () || (arg.is_typed_array () && arg.typed_array_get_type () == JSC.TypedArrayType.UINT8)) == false))
            {
              context.throw (@"string or bytearray expected, got $(arg.to_string ())");
              return null;
            }

          return arg;
        }

      [CCode (cheader_filename = "glib.h", cname = "g_bytes_new")]
      static extern GLib.Bytes _g_bytes_new (void* data, size_t size);

      [CCode (cheader_filename = "glib.h", cname = "g_bytes_new_static")]
      static extern GLib.Bytes _g_bytes_new_static (void* data, size_t size);

      [CCode (cheader_filename = "glib.h", cname = "g_utf8_make_valid")]
      static extern string _g_utf8_make_valid ([CCode (array_length_type = "gssize", type = "const gchar*")] uint8[] data);

      [CCode (cheader_filename = "glib.h", cname = "g_utf8_validate_len")]
      static extern bool _g_utf8_validate_len ([CCode (array_length_pos = 1.1, array_length_type = "gsize", type = "const gchar*")] uint8[] data, out string? end = null);

      private JSC.Value? assume_valid (GenericArray<JSC.Value> args)
        {
          JSC.Context context = JSC.Context.get_current ();
          JSC.Value arg;

          if (unlikely ((arg = prelude_args (context, args)) == null))
            return null;

          if (arg.is_string ())

            return arg;
          else
            {
              unowned size_t size;
              unowned void* data = arg.typed_array_get_data (out size);

              return new JSC.Value.string_from_bytes (context, _g_bytes_new (data, size));
            }
        }

      private JSC.Value? make_valid (GenericArray<JSC.Value> args)
        {
          GLib.Bytes bytes;
          JSC.Context context = JSC.Context.get_current ();

          if (unlikely ((bytes = prelude (context, args)) == null))

            return null;
          else
            return new JSC.Value.string (context, _g_utf8_make_valid (bytes.get_data ()));
        }

      private JSC.Value? validate (GenericArray<JSC.Value> args)
        {
          GLib.Bytes bytes;
          JSC.Context context = JSC.Context.get_current ();

          if ((bytes = prelude (context, args)) == null)

            return null;
          else
            return new JSC.Value.boolean (context, _g_utf8_validate_len (bytes.get_data ()));
        }

      public static JSC.Class register (JSC.Context context)
        {
          unowned var destroy_notify = (GLib.DestroyNotify) Object.unref;
          unowned var parent_class = (JSC.Class?) null;
          unowned var vtable = (JSC.ClassVTable?) null;

          var klass = (JSC.Class) context.register_class ("Utf8Namespace", parent_class, vtable, destroy_notify);

          klass.add_method ("assume_valid", (s, a) => ((Utf8Namespace) s).assume_valid (a), typeof (JSC.Value));
          klass.add_method ("make_valid", (s, a) => ((Utf8Namespace) s).make_valid (a), typeof (JSC.Value));
          klass.add_method ("validate", (s, a) => ((Utf8Namespace) s).validate (a), typeof (JSC.Value));

          var instance = new Utf8Namespace ();

          context.set_value ("utf8", new JSC.Value.object (context, (void*) (owned) instance, klass));
        return (owned) klass;
        }
    }
}
