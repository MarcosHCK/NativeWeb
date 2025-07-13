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
import { Button, Group, Stack } from '@mantine/core'
import { PiExport, PiFloppyDisk, PiRocketLaunch } from 'react-icons/pi'
import { useEffect, useState } from 'react'

export default function Page ()
{
  const [ obj, setObj ] = useState<null | Interface> (null)
  const [ notice, setNotice ] = useState<string> ('Querying interface proxy')
  const [ value1, setValue1 ] = useState<string> ('query random uuid')
  const [ value2, setValue2 ] = useState<string> ('query stored string')

  useEffect (() =>
    {
      Interface.create ().then (v => setObj (v))
                         .catch (e => setNotice (e.toString ()))
    }, [])

  return ! obj

    ? <p>{ notice }</p>
    : <Stack>

        <p>Application showcase</p>

        <Group>
          <Button onClick={() => obj.RandomUUID ().then (v => setValue1 (v))
                                                  .catch (e => setValue1 (e.toString ())) }
                  rightSection={ <p>{ value1 }</p> }
                  variant='outline'>
            <PiRocketLaunch />
          </Button>
        </Group>

        <Group>
          <Button onClick={() => obj.Store = value1}
                  variant='outline'>
            <PiFloppyDisk />
          </Button>
          <Button onClick={() => setValue2 (obj.Store)}
                  rightSection={ <p>{ value2 }</p> }
                  variant='outline'>
            <PiExport />
          </Button>
        </Group>
      </Stack>
}