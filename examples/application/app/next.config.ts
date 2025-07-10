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
import { type NextConfig } from 'next'
import path from 'path'

let abs: string | undefined
const distDir = (abs = process.env.BUILD_PATH) === undefined ? undefined : path.relative (__dirname, abs)

const nextConfig: NextConfig =
{
  distDir,
  images: { unoptimized: true },
  output: 'export',
  reactStrictMode: true,
  trailingSlash: true,
};

export default nextConfig
