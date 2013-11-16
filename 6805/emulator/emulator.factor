! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: 
    accessors arrays
    kernel
    locals
    math sequences byte-arrays io
    math.parser unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    vectors
    words quotations deques dlists
    freescale.6805.emulator.memory
    freescale.6805.emulator.alu ;
  
!    io.encodings.binary
!    io.files
!    io.pathnames
!    peg.ebnf
!    peg.parsers
! ;
IN: freescale.6805.emulator

TUPLE: cpu a x ccr pc sp halted? last-interrupt cycles mlist memory ;

GENERIC: reset ( cpu -- )
GENERIC: addmemory ( obj cpu -- )
GENERIC: byte-read ( address cpu -- byte )




#! do a cpu Reset
M: cpu reset ( cpu -- )
   0               >>a          ! reset reg A
   0               >>x          ! reset reg X
   "11100000" bin> >>ccr        ! reset CCR
   "FFFE" hex>     >>pc         ! reset PC this needs a relook
   "00FF" hex>     >>sp         ! reset SP
   f >>halted?
   0 >>cycles
   drop
;





: >word< ( word -- byte byte )
  #! Explode a word into its two 8 bits values.
  #! dup HEX: FF bitand swap -8 shift HEX: FF bitand swap ;
  dup "FF" hex> bitand swap -8 shift "FF" hex> bitand ;




: write-byte ( value addr cpu -- )
  #! Write a byte to the specified memory address.
#!  over dup 0 < swap HEX: FFFF > or
 #! [ 3drop ]
 #! [ ram>> set-nth ] if
;

: read-word ( addr cpu -- word )
  #! [ read-byte ] 2keep [ 1 + ] dip read-byte swap 8 shift bitor
;

: write-word ( value addr cpu -- )
  [ >word< ] 2dip [ write-byte ] 2keep [ 1 + ] dip write-byte ;

: inc-pc ( cpu -- )
  [ pc>> ] keep
  swap
  1 + >>pc
  drop
 ;


: not-implemented ( <cpu> -- )
  drop
;

 


! Get PC and Read memory data
: pc-memory-read ( cpu -- d )
  [ pc>> ] keep [ memory>> ] keep
  memory-read ;


! Branch if Bit 0 is Set
: (opcode-00) ( cpu -- )
  [ pc-memory-read ] keep 
  ;

#! Make a CPU here
: <cpu> ( -- cpu )
  cpu new
  <memory> >>memory ;