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
import { useEffect, useState } from 'react'
import { PiRocketLaunch } from 'react-icons/pi'

export default function Page ()
{
  const [ obj, setObj ] = useState<null | Interface> (null)
  const [ message, setMessage ] = useState ('Querying interface proxy')

  useEffect (() =>
    {
      InterfaceFactory.create ().then (setObj)
                                .catch (e => setMessage (e.toString ()))
    }, [])

  return ! obj

    ? <p>{ message }</p>
    : <Stack>

        <p>Application showcase</p>

        <Group>
          <Button onClick={() => obj.RandomUUID ().then (setMessage)
                                                  .catch (e => setMessage (e.toString ())) }
                  rightSection={ <p>{ message }</p> }
                  variant='outline'>
            <PiRocketLaunch />
          </Button>
        </Group>
      </Stack>
}