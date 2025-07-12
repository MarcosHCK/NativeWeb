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

  public interface IInvocable : GLib.Object
    {

      [CCode (scope = "notify")]
      public delegate JSC.Value ResultCollector (GLib.Variant result, JSC.Context context);

      public static GLib.Variant? collect_arg (JSC.Value param, [CCode (type = "const GVariantType*")] string? variant_type)
        {
          return param_pack (param, variant_type);
        }

      public static GLib.Variant? collect_args (GLib.GenericArray<JSC.Value> @params, [CCode (type = "const GVariantType*")] string? variant_type)
        {
          return params_pack (@params, variant_type); 
        }

      static JSC.Value collect_result (GLib.Variant result, JSC.Context context)
        {

          if (result.n_children () == 1)

            return param_unpack (result.get_child_value (0), context);
          else
            return new JSC.Value.array_from_garray (context, params_unpack (result, context));
        }

      public static JSC.Value expand_arg (GLib.Variant param, JSC.Context context)
        {
          return param_unpack (param, context);
        }

      public static GenericArray<JSC.Value> expand_args (GLib.Variant @params, JSC.Context context)
        {
          return params_unpack (params, context);
        }

      public abstract async GLib.Variant? invoke (string method, GLib.Variant? parameters) throws GLib.Error;

      public static void register (JSC.Class klass, string field_name, string method_name, string signature, owned ResultCollector? collector = null)
        {
          if (null == collector) collector = collect_result;

          klass.add_method (field_name, (s, @params) =>

            Promise.create (JSC.Context.get_current (), p =>

            ((IInvocable) s).invoke.begin (method_name, collect_args (params, signature), (o, res) =>
              {
                GLib.Variant result;
                try { result = ((IInvocable) o).invoke.end (res); } catch (GLib.Error e)
                  { p.reject_gerror (e); return; }
                    p.resolve (collector (result, p.context));
              })), typeof (JSC.Value));
        }
    }
}