! Copyright (C) 2011, 2012 Joseph Moschini
! See http://factorcode.org/licence.txt for BSD license.
USING: accessors arrays combinators kernel make math math.bitwise
namespaces sequences words words.symbol parser io.binary bit-arrays ;
IN: 68000.assembler


: insn ( operand opcode -- ) { 26 0 } bitfield 4 >be % ;

: s>u16 ( s -- u ) 0xffff bitand ;

: d-insn ( d a simm opcode -- )
        [ s>u16 { 0 16 21 } bitfield ] dip insn ;

: define-d-insn ( word opcode -- )
        [ d-insn ] curry ( d a simm -- ) define-declared ;

SYNTAX: D: create scan-word define-d-insn ;

CONSTANT: D0 ?{ f f f f }

: abcd ( -- d )
        [ 0x0c 1 { 8 12 } bitfield ] call ;
