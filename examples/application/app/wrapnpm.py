#! /usr/bin/env python3
# Copyright 2025-2026 MarcosHCK
# This file is part of NativeWeb.
#
# NativeWeb is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# NativeWeb is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with NativeWeb. If not, see <http://www.gnu.org/licenses/>.
#
from argparse import ArgumentParser
from pathlib import Path
from subprocess import run
import glob, os

def deplist (basepath: Path):

  source_dirs = \
    [
      'components',
      'hooks',
      'lib',
      'pages',
      'services',
    ]

  source_exts = \
    [
      'css',
      'js', 'jsx',
      'ts', 'tsx',
    ]

  source_patterns = \
    [
      f'{dir}/**/*.{ext}' for dir in source_dirs
                          for ext in source_exts
    ]

  patterns = \
    [
      *source_patterns,
      './eslint.config.mjs',
      './next-env.d.ts',
      './next.config.ts',
      './package-lock.json',
      './package.json',
      './postcss.config.cjs',
      './public/**/*',
      './tsconfig.json',
      'theme.ts',
    ]

  root = str (basepath)
  sources = []

  for pattern in patterns:

    files = glob.glob (pattern, recursive = True, root_dir = root)
    files = [ str (basepath / file) for file in files ]

    sources.extend (files)

  return 'package.json: ' + ' '.join (sources)

if __name__ == '__main__':

  parser = ArgumentParser ()

  parser.add_argument ('-depfile', type = str)
  parser.add_argument ('-place', type = str)
  parser.add_argument ('arguments', nargs = '*')
  args = parser.parse_args ()

  if (builddir := os.environ.get ('BUILD_PATH')) == None:

    raise Exception ('build directory is unspecified')
  else:

    run ([ 'npm', *args.arguments ], cwd = args.place)

    with (Path (builddir) / str (args.depfile)).open ('w') as stream:

      stream.write (deplist (Path (args.place)) + '\n')
      stream.flush ()
