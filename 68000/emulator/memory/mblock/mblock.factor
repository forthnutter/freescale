! Copyright (C) 2014 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: 
    accessors arrays kernel math sequences byte-arrays io
    math.parser unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    words quotations math.order 
    freescale.68000.emulator.alu models math.bitwise ;
  

IN: freescale.68000.emulator.memory.mblock



TUPLE: mblock start array ;



: <mblock> ( start array -- mblock )
    mblock boa ;


: mblock-read ( address mblock -- d )
    [ start>> - ] keep array>> nth ;

: mblock-write ( d address mblock -- )
    [ start>> - ] keep array>> set-nth ;

! Get the start address and end addres from the memory block
: mblock-start-end ( mblock -- start end )
    [ start>> dup ] keep array>> length + ;
