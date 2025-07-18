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
[CCode (cheader_filename = "config.h", cprefix = "", lower_case_cprefix = "")]

namespace Config
{
  public const bool DEBUG;
  public const bool DEVELOPER;
  public const string G_LOG_DOMAIN;
  public const int G_LOG_USE_STRUCTURED;
  public const string PACKAGE_BUGREPORT;
  public const string PACKAGE_NAME;
  public const string PACKAGE_STRING;
  public const string PACKAGE_TARNAME;
  public const string PACKAGE_URL;
  public const string PACKAGE_VERSION;
  public const uint PACKAGE_VERSION_MAJOR;
  public const uint PACKAGE_VERSION_MINOR;
  public const uint PACKAGE_VERSION_MICRO;
  public const uint PACKAGE_VERSION_STAGE;
}