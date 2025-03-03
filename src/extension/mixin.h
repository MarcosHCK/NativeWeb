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
#ifndef __NW_MIXIN__
#define __NW_MIXIN__
#include <glib.h>

#define MIXIN(type,name,statn) \
  ; \
    type* name = NULL; \
    type* __dyn_##name = NULL; \
    type __stat_##name [(statn)];

#define MIXIN_NEW(type,name,length) (G_GNUC_EXTENSION ({ \
  ; \
    gsize __length = (length); \
    name = G_N_ELEMENTS (__stat_##name ) < __length ? & __stat_##name [0] : (__dyn_##name = g_new (type, __length)); \
  }))

#define MIXIN_CREATE(type,name,statn,length) \
  ; \
    MIXIN (type, name, (statn)); \
    MIXIN_NEW (type, name, (length));

#define MIXIN_DELETE(type,name) (G_GNUC_EXTENSION ({ \
  ; \
    g_free (__dyn_##name ); \
  }))

#endif // __NW_MIXIN__
