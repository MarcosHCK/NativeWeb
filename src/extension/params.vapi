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
  [CCode (cheader_filename = "params.h", cname = "_nw_extension_params_pack", returns_floating_reference = true)]
  internal static extern GLib.Variant? params_pack (GLib.GenericArray<JSC.Value> @params, [CCode (type = "const GVariantType*")] string? variant_type);
  [CCode (cheader_filename = "params.h", cname = "_nw_extension_params_unpack")]
  internal static extern GLib.GenericArray<JSC.Value> params_unpack (GLib.Variant @params, JSC.Context context);
}
