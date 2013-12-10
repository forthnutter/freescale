! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: 
    accessors arrays kernel math sequences byte-arrays io
    math.parser unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    words quotations freescale.68000.emulator.alu ;
  
!    io.encodings.binary
!    io.files
!    io.pathnames
!    peg.ebnf
!    peg.parsers
! ;
IN: freescale.68000.emulator

TUPLE: cpu alu ar dr pc ssp usp rx cycles memory ;



! put value into A7
: >A7 ( d cpu -- )
  [ alu>> alu-mode? ] keep swap
  [ ssp<< ] [ usp<< ] if ;

! get A7
: A7> ( cpu -- d )
  [ alu>> alu-mode? ] keep swap
  [ ssp>> ] [ usp>> ] if ;

! increment A7
: A7+ ( cpu -- )
  [ A7> 1 + ] keep >A7 ;

! decrement A7
: A7- ( cpu -- )
  [ A7> 1 - ] keep >A7 ;




! the opcodes are divide into 16 
! opcode 0
: (opcode-0) ( cpu -- )
  drop ;

: (opcode-1) ( cpu -- )
  drop ;

: (opcode-2) ( cpu -- )
  drop ;

: (opcode-3) ( cpu -- )
  drop ;

: (opcode-4) ( cpu -- )
  drop ;

: (opcode-5) ( cpu -- )
  drop ;

: (opcode-6) ( cpu -- )
  drop ;

: (opcode-7) ( cpu -- )
  drop ;

: (opcode-8) ( cpu -- )
  drop ;

: (opcode-9) ( cpu -- )
  drop ;

: (opcode-A) ( cpu -- )
  drop ;

: (opcode-B) ( cpu -- )
  drop ;

: (opcode-C) ( cpu -- )
  drop ;

: (opcode-D) ( cpu -- )
  drop ;

: (opcode-E) ( cpu -- )
  drop ;

: (opcode-F) ( cpu -- )
  drop ;



: <cpu> ( -- cpu )
  cpu new
  <alu> >>alu
  8 0 <array> >>dr
  8 0 <array> >>ar
  0 >>ssp
  0 >>usp


  [ alu>> 7 swap alu-imask-write ] keep

 ;
                    