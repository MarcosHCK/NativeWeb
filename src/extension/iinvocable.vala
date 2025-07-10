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

      public static GLib.Variant? collect_arg (JSC.Value param, [CCode (type = "const GVariantType*")] string? variant_type)
        {
          return param_pack (param, variant_type);
        }

      public static GLib.Variant? collect_args (GLib.GenericArray<JSC.Value> @params, [CCode (type = "const GVariantType*")] string? variant_type)
        {
          return params_pack (@params, variant_type); 
        }

      public static JSC.Value expand_arg (GLib.Variant param, JSC.Context context)
        {
          return param_unpack (param, context);
        }

      public static GenericArray<JSC.Value> expand_args (GLib.Variant @params, JSC.Context context)
        {
          return params_unpack (params, context);
        }

      protected async GLib.Variant? invoke (string method, GLib.Variant? parameters) throws GLib.Error
        {
          var _params = parameters ?? new GLib.Variant.tuple ({ });
          var _message = Ipc.Call.pack (method, _params);
          return yield send (_message);
        }

      public abstract async GLib.Variant? send (GLib.Variant _message) throws GLib.Error;
    }
}