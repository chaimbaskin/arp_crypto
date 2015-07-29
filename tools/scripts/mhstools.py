#
# Copyright (c) 2015 University of Cambridge
# Copyright (c) 2015 David J. Miller
# All rights reserved.
#
# This software was developed by the University of Cambridge Computer Laboratory 
# under EPSRC INTERNET Project EP/H040536/1, National Science Foundation under Grant No. CNS-0855268,
# and Defense Advanced Research Projects Agency (DARPA) and Air Force Research Laboratory (AFRL), 
# under contract FA8750-11-C-0249.
#
# @NETFPGA_LICENSE_HEADER_START@
#
# Licensed to NetFPGA Open Systems C.I.C. (NetFPGA) under one or more contributor
# license agreements.  See the NOTICE file distributed with this work for
# additional information regarding copyright ownership.  NetFPGA licenses this
# file to you under the NetFPGA Hardware-Software License, Version 1.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at:
#
#   http://www.netfpga-cic.org
#
# Unless required by applicable law or agreed to in writing, Work distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations under the License.
#
# @NETFPGA_LICENSE_HEADER_END@
#
################################################################################
#
#  Description:
#         A set of routines for parsing, manipulating, and writing out MHS
#        files.
#

import copy
import itertools
import re


DISABLED_FLAG = '#!'
df_re     = re.compile( '^\s*#\s*!(.*)' ) # disabled flag


class Entity(object):
    """
    Storage class for objects within an MHS file.
    """

    def __init__( self, line ):
        self.disabled_flag = False
        self._kw           = None
        self.args          = []
        self.comment       = None

        # Handle disabled (commented) core instances
        disabled = df_re.match( line )
        if disabled:
            self.disabled_flag = True
            line = disabled.group(1)

        # Handle ordinary comments
        try:
            # Look to see if a comment is present.  If not, index() will throw
            # an exception, and we skip this section.
            hash_index = line.index( '#' )
        except ValueError:
            pass
        else:
            self.comment = line[hash_index + 1:].rstrip('\r\n')
            line = line[:hash_index]

        # Tokenise a keyword line
        kwargs = line.strip().split( None, 1 )
        if len(kwargs) > 0:
            self._kw = kwargs[0]
        if len(kwargs) > 1:
            self.args = [tuple(elt.strip() for elt in av.split('=',1))           # tuples of (a,v)
                                               for av in kwargs[1].split(',')    # list of 'a=v'
                        ]                                                        # [(a,v),...]

    def __str__( self ):
        s = ''
        if self.disabled_flag:
            s += DISABLED_FLAG
        if self._kw is not None:
            args = ', '.join( ' = '.join( av ) for av in self.args )
            s += '%s%s%s' % (self._kw, ' ' if args else '', args)
        if self.comment is not None:
            s += '%s#%s' % ('\t' if s else '', self.comment)
        return s

    def is_begin( self ):
        """
        Check for BEGIN keyword
        """
        return self.kw() == 'BEGIN'

    def is_end( self ):
        """
        Check for END keyword
        """
        return self.kw() == 'END'

    def is_comment( self ):
        """
        Returns True when this object is an ordinary comment
        """
        return self.comment is not None

    def kw( self ):
        """
        Returns keyword (as uppercase) if present, otherwise empty string
        """
        return ('' if self._kw is None else self._kw.upper())

    def core_name( self ):
        """
        Returns the name of the core instance represented by this record, or
        None if not a core instance.
        """
        if self.is_begin():
            return self.args[0][0]

    def copy( self ):
        """
        Returns a deep copy of self.
        """
        return copy.deepcopy(self)


class TooManyError(Exception):
    """
    Exception for signalling the unexpected return of too many objects.
    """
    def __init__( self, what, ents ):
        self.what = what
        self.ents = ents

    def __str__( self ):
        return 'too many %s' % self.what


def parse_mhs( fh, lno_gen = None ):
    """
    Parses an MHS file.  Returns a list of Entity instances representing the
    entities in the MHS file.

    NB: BEGIN Entites include the additional attribute `inst_ents`, which is
        itself a list of Entity objects representing the lines that belong to
        that core instance.
    """
    if type(fh) == str:
        raise Exception('parse_mhs: expected an open file handle, not a string (%s)' % fh)
    if lno_gen is None:
        lno_gen = itertools.count(1)

    ents = []
    for lno, line in itertools.izip(lno_gen, fh):
        ent = Entity( line )
        if ent.is_begin():
            ent.inst_ents = parse_mhs( fh, lno_gen )
        ents.append( ent )
        if ent.is_end():
            return ents
    return ents


def set_disabled_flag( ent, val ):
    """
    Set the entity's disabled flag to the specified value.  If the entity is a
    core instance, set all subordinate entities to the same value.
    """
    ent.disabled_flag = val
    if ent.is_begin():
        for inst_ent in ent.inst_ents:
            set_disabled_flag( inst_ent, val )


def get_ents_by_kw( ents, kw ):
    """
    Return a list of the args for all lines matching keyword `kw` (eg, all PORT
    mappings).  `ents` should either be a list of Entities, or a reference to a
    BEGIN Entity.
    """
    if type(ents) == Entity: ents = ents.inst_ents
    return sum( [x.args for x in filter( lambda x: x.kw() == kw, ents )],
                [] )


def get_parameter( ents, name ):
    """
    Attempt to find the instance PARAMETER by `name`.  Returns None if not
    found.  `ents` should either be a list of Entities, or a reference to a
    BEGIN Entity.
    """
    if type(ents) == Entity and ents.is_begin(): ents = ents.inst_ents
    params = filter( lambda x: x[0].upper() == name.upper(),
                     get_ents_by_kw( ents, 'PARAMETER' ) )
    if len(params) > 1:
        raise TooManyError( 'instances of PARAMETER %s' % name,
                            [x[1] for x in params] )
    return (params[0][1] if params else None)


def instances( mhs ):
    """
    Generator that iterates over all instances in the given MHS file
    """
    return (ent for ent in mhs if ent.is_begin())


def get_other_inst( mhs, inst, net ):
    """
    Returns the other instance connected to `inst` by `net`
    """
    net_kws = ['PORT', 'BUS_INTERFACE']
    others = filter( lambda other: (
                            other is not inst and not other.disabled_flag and
                            filter( lambda x: x[1].upper() == net.upper(),  # matching nets
                                    sum( (get_ents_by_kw( other, kw ) for kw in net_kws),
                                         [] )                               # all instance nets
                                    ) ),
                     instances(mhs) )
    if len(others) > 1:
        raise TooManyError( 'instances on net %s' % net, others )
    return (others[0] if others else None)


def write_mhs( fh, mhs ):
    """
    Write out MHS file (inverse of parse_mhs()).
    """
    if type(fh) == str:
        raise Exception('write_mhs: expected an open file handle, not a string (%s)' % fh)

    for ent in mhs:
        fh.write( '%s\n' % ent )
        if ent.is_begin():
            write_mhs( fh, ent.inst_ents )
