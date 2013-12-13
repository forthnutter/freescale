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
  

IN: freescale.6805.emulator

TUPLE: cpu a x ccr pc sp halted? last-interrupt cycles mlist memory ;




: >word< ( word -- byte byte )
  #! Explode a word into its two 8 bits values.
  #! dup HEX: FF bitand swap -8 shift HEX: FF bitand swap ;
  dup "FF" hex> bitand swap -8 shift "FF" hex> bitand ;



: read-word ( addr cpu -- word )
   drop drop 0
  #! [ read-byte ] 2keep [ 1 + ] dip read-byte swap 8 shift bitor
;

: PC+ ( cpu -- )
   [ pc>> ] keep swap 1 + >>pc drop ;

: PC- ( cpu -- )
   [ pc>> ] keep swap 1 - >>pc drop ;

: not-implemented ( <cpu> -- )
  drop
;

: write-byte ( d a cpu -- )
   memory>> memory-write ;


: read-byte ( a cpu -- d )
   memory>> memory-read ;


! Get PC and Read memory data
: pc-memory-read ( cpu -- d )
  [ pc>> ] keep memory>> memory-read ;



! Branch if Bit 0 is Set
: (opcode-00) ( cpu -- )
   [ PC+ ] keep [ pc-memory-read ] keep drop drop
  ;

: cpu-reset ( cpu -- )
   0xfffe >>pc drop ;

#! Make a CPU here
: <cpu> ( -- cpu )
  cpu new
  [ cpu-reset ] keep
  <memory> >>memory ;