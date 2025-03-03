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

  [CCode (cheader_filename = "promise.h", ref_function = "nw_promise_ref", unref_function = "nw_promise_unref")]
  [Compact (opaque = true)]

  public class Promise
    {
      public JSC.Context context { get; }
      private Promise (JSC.Value resolve, JSC.Value reject);
      public static JSC.Value create (JSC.Context context, owned PromiseCallback target);
      public void reject (JSC.Value value);
      public void reject_string (string value);
      public void reject_gerror (GLib.Error e);
      public void resolve (JSC.Value value);
    }

  [CCode (cheader_filename = "promise.h", scope = "notify")]

  public delegate void PromiseCallback (Promise promise);
}
