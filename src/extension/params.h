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
#ifndef __NW_EXTENSION_PARAMS__
#define __NW_EXTENSION_PARAMS__ 1
#include <glib.h>
#include <webkit/webkit-web-process-extension.h>

#if __cplusplus
extern "C" {
#endif // __cplusplus

  G_GNUC_INTERNAL GVariant* _nw_extension_param_pack (JSCValue* param, const GVariantType* variant_type);
  G_GNUC_INTERNAL GVariant* _nw_extension_params_pack (GPtrArray* params, const GVariantType* variant_type);
  G_GNUC_INTERNAL JSCValue* _nw_extension_param_unpack (GVariant* param, JSCContext* context);
  G_GNUC_INTERNAL GPtrArray* _nw_extension_params_unpack (GVariant* params, JSCContext* context);

#if __cplusplus
}
#endif // __cplusplus

#endif // __NW_EXTENSION_PARAMS__
