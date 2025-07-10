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
from typing import Generator, TypeVar
from xml.etree.ElementTree import fromstring as xmlparse, tostring as xmlprint, Element
import re

subpat = r'@([^@\s]*)@'

T = TypeVar ('T')

def flatten (a: list[T], b: T | list[T]) -> list[T]:

  if not isinstance (b, list):

    a.append (b)
  else:
    a.extend (b)

  return a

def walkdir (basepath: Path) -> Generator[Path, None, None]:

  for path in basepath.iterdir ():

    if path.is_dir ():

      for path in walkdir (path):

        yield path
    else:

      if path.name [0] != '.':

        yield path

class Generator_:

  def __init__ (self, basepath: str):

    self.basepath = Path (basepath)

  def process (self, input_file: Path, output_file: Path):

    with input_file.open ('r') as stream:

      xml = stream.read ()
      gresources = xmlparse (xml)

    if gresources.tag != 'gresources':

      raise Exception (f'Unexpected tag {gresources.tag} at document root')
    else:

      result = self.process_gresources (gresources)

      with output_file.open ('wb') as stream:

        stream.write (xmlprint (result))

  def process_basepath (self, tag: Element) -> Element:

    basepath = str (self.basepath)
    basepath = basepath if '/' != basepath [-1] else basepath [:-1]

    tag.text = re.sub (r'@BASEPATH@', basepath, tag.text)

    return tag

  def process_file (self, tag: Element) -> Element | list[Element]:

    tag = self.process_basepath (tag)

    if not bool (match := re.search (subpat, tag.text)):

      return tag
    else:

      match (match := match.group (1)):

        case _:

          raise Exception (f'Unknown match {match}')

  def process_files (self, tag: Element) -> Element | list[Element]:

    tag = self.process_basepath (tag)
    newtags = []

    for path in walkdir (basepath := Path (tag.text)):

      newtag = Element ('file', tag.attrib or {})

      newtag.attrib ['alias'] = str (path.relative_to (basepath))

      newtag.tail = tag.tail or ''
      newtag.text = str (path.relative_to (self.basepath))

      newtags.append (newtag)

    return newtags

  def process_gresource (self, tag: Element) -> Element | list[Element]:

    (newtag := Element (tag.tag, tag.attrib)).tail = tag.tail or ''

    for child in tag:

      match child.tag:

        case 'file':

          newtag = flatten (newtag, self.process_file (child))

        case 'files':

          newtag = flatten (newtag, self.process_files (child))

        case _:

          raise Exception (f'Unexpected tag {child.tag} under <{tag.tag}>')

    return newtag

  def process_gresources (self, tag: Element) -> Element | list[Element]:

    (newtag := Element (tag.tag, tag.attrib)).tail = tag.tail or ''

    for child in tag:

      if child.tag != 'gresource':

        raise Exception (f'Unexpected tag {child.tag} under <{tag.tag}>')

      if not isinstance (result := self.process_gresource (child), list):

        newtag.append (result)
      else:
        newtag.extend (result)

    return newtag

if __name__ == '__main__':

  parser = ArgumentParser ()

  parser.add_argument ('input', type = str)
  parser.add_argument ('output', type = str)

  args = parser.parse_args ()

  Generator_ (Path (args.output).parent).process (Path (args.input), Path (args.output))
