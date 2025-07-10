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
import '@mantine/core/styles.css'
import '@mantine/notifications/styles.css'
import { AppShell, Button, Grid, Group, MantineProvider, rem, ScrollArea, Stack } from '@mantine/core'
import { FiMaximize2, FiMinimize2, FiMinus, FiX } from 'react-icons/fi'
import { theme } from '../theme'
import css from './_app.module.css'
import Head from 'next/head'
import React, { type ReactNode, useEffect, useState } from 'react'

const headerHeightPx = 40

const columns = 32 as const
const spaceSizes = { base: 0, sm: 1 } as const
const centerSizeTuples = Object.entries (spaceSizes).map (([b, s]) => [ b, columns - s * 2 ]) as readonly [string,number][]
const centerSizes = Object.fromEntries (centerSizeTuples)

function ControlButton ({ children, onClick, size = 33 }: { children?: ReactNode, onClick: () => void, size?: number })
{

  return <Stack className={css.controlButtonStack} style={{ '--button-size': rem (size) }}>

    <Button className={css.controlButton} onClick={onClick} radius={rem (size)} variant='subtle'>{ children }</Button>
  </Stack>
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const App = ({ Component, pageProps }: any) =>
{
  const [ maximized, setMaximized ] = useState (false)

  useEffect (() =>
    {
      const id = browser.maximized.connect (setMaximized)
      return () => browser.disconnect (id)
    }, [])

  return <MantineProvider defaultColorScheme='auto' theme={theme}>

    <Head>

      <title>Historical maps</title>

      <meta content='minimum-scale=1, initial-scale=1, width=device-width, user-scalable=no' name='viewport' />
      <link rel='shortcut icon' href='/favicon.ico' />
    </Head>

    <AppShell header={{ height: headerHeightPx }}
              padding='md'>

      <AppShell.Header onMouseEnter={() => browser.drag (true)}
                       onMouseLeave={() => browser.drag (false)}
                       withBorder={false}>

        <Grid columns={9} p={rem (5)}>

          <Grid.Col span={{ base: 1, xs: 2 }}>
            { /* icon here */ }
          </Grid.Col>

          <Grid.Col span={{ base: 0, xs: 5 }} visibleFrom='xs'>
            { /* contents here */ }
          </Grid.Col>

          <Grid.Col span={{ base: 8, xs: 2 }}>

            { /* Controls here */ }
            <Group gap={3} justify='end'>
              <ControlButton onClick={() => browser.minimize ()} size={headerHeightPx - 5}> <FiMinus /> </ControlButton>
              <ControlButton onClick={() => browser.maximize ()} size={headerHeightPx - 5}>{ ! maximized ? <FiMaximize2 /> : <FiMinimize2 /> }</ControlButton>
              <ControlButton onClick={() => browser.close ()} size={headerHeightPx - 5}> <FiX /> </ControlButton>
            </Group>
          </Grid.Col>
        </Grid>
      </AppShell.Header>

      <AppShell.Main className={css.appShellMain}>

        <ScrollArea.Autosize mah='var(--app-shell-main-height)'>

          <Grid columns={columns} gutter={0} style={{ maxWidth: 'var(--app-shell-main-width)' }}>

            <Grid.Col className={css.appShellMainCol} offset={spaceSizes} span={centerSizes}>

              <ScrollArea> <Component {...pageProps} /> </ScrollArea>
            </Grid.Col>
          </Grid>
        </ScrollArea.Autosize>
      </AppShell.Main>
    </AppShell>
  </MantineProvider>
}

export default App