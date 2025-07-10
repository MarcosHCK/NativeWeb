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
/* eslint-disable @typescript-eslint/no-namespace */
import { SignalSpec } from './signal'

declare global
{

  namespace browser
    {
      function close (): void;
      function disconnect (signal_id: number): void;
      function drag (should: boolean): Promise<void>;
      function maximize (value?: boolean): Promise<void>;
      const maximized: SignalSpec<[ boolean ]>;
      function minimize (value?: boolean): Promise<void>;
      const onClose: SignalSpec<[]>;
      function open (url: string): Promise<void>;
      function resize (h: number, w: number): Promise<void>;
    }
}

export { }
