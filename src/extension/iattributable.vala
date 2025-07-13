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

  public interface IAttributable : GLib.Object
    {

      private JSC.Value? getter (string property_name)
        {
          var context = JSC.Context.get_current ();
          GLib.Variant param;

          try { param = read_property (property_name); } catch (GLib.Error e)
            { Error.throw (context, e); return null; }
        return param_unpack (param, context);
        }

      private void setter (string property_name, JSC.Value param, string signature)
        {
          var context = JSC.Context.get_current ();
          var value = param_pack (param, signature);

          try { write_property (property_name, value); } catch (GLib.Error e)
            { Error.throw (context, e); }
        }

      public abstract GLib.Variant read_property (string name) throws GLib.Error;
      public abstract bool write_property (string name, GLib.Variant value) throws GLib.Error;

      protected static void register (JSC.Class klass, string field_name, string property_name, string signature)
        {

          klass.add_property (field_name, typeof (JSC.Value),
            (s) => ((IAttributable) s).getter (property_name),
            (s, v) => ((IAttributable) s).setter (property_name, (JSC.Value) v, signature));
        }
    }
}