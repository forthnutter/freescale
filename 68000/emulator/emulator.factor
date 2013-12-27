! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: 
    accessors arrays kernel math sequences byte-arrays io
    math.parser unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    words quotations
    freescale.68000.emulator.alu
    freescale.68000.emulator.memory models ;
  

IN: freescale.68000.emulator

TUPLE: cpu alu ar dr pc rx cycles memory opcodes ;

: cpu-exception ( cpu -- )
  drop ;


! put value into A7
: >A7 ( d cpu -- )
    [ alu>> alu-mode? ] keep swap
    [ ar>> 8 swap set-nth ] [ ar>> 7 swap set-nth ] if ;

! get A7
: A7> ( cpu -- d )
  [ alu>> alu-mode? ] keep swap
  [ ar>> 8 swap nth ] [ ar>> 7 swap nth ] if ;


! increment A7
: A7+ ( cpu -- )
  [ A7> 1 + ] keep >A7 ;

! decrement A7
: A7- ( cpu -- )
  [ A7> 1 - ] keep >A7 ;

: >A6 ( d cpu -- )
  ar>> 6 swap set-nth ;

: A6> ( cpu -- d )
  ar>> 6 swap nth ;

: >A5 ( d cpu -- )
  ar>> 5 swap set-nth ;

: A5> ( cpu -- d )
  ar>> 5 swap nth ;

: >A4 ( d cpu -- )
  ar>> 4 swap set-nth ;

: A4> ( cpu -- d )
  ar>> 4 swap nth ;

: >A3 ( d cpu -- )
  ar>> 3 swap set-nth ;

: A3> ( cpu -- d )
  ar>> 3 swap nth ;

: >A2 ( d cpu -- )
  ar>> 2 swap set-nth ;

: A2> ( cpu -- d )
  ar>> 2 swap nth ;

: >A1 ( d cpu -- )
  ar>> 1 swap set-nth ;

: A1> ( cpu -- d )
  ar>> 1 swap nth ;

: >A0 ( d cpu -- )
  ar>> 0 swap set-nth ;

: A0> ( cpu -- d )
  ar>> 0 swap nth ;

: >D7 ( d cpu -- )
  ar>> 6 swap set-nth ;

: D7> ( cpu -- d )
  ar>> 6 swap nth ;

: >D6 ( d cpu -- )
  ar>> 6 swap set-nth ;

: D6> ( cpu -- d )
  ar>> 6 swap nth ;

: >D5 ( d cpu -- )
  ar>> 5 swap set-nth ;

: D5> ( cpu -- d )
  ar>> 5 swap nth ;

: >D4 ( d cpu -- )
  ar>> 4 swap set-nth ;

: D4> ( cpu -- d )
  ar>> 4 swap nth ;

: >D3 ( d cpu -- )
  ar>> 3 swap set-nth ;

: D3> ( cpu -- d )
  ar>> 3 swap nth ;

: >D2 ( d cpu -- )
  ar>> 2 swap set-nth ;

: D2> ( cpu -- d )
  ar>> 2 swap nth ;

: >D1 ( d cpu -- )
  ar>> 1 swap set-nth ;

: D1> ( cpu -- d )
  ar>> 1 swap nth ;

: >D0 ( d cpu -- )
  ar>> 0 swap set-nth ;

: D0> ( cpu -- d )
  ar>> 0 swap nth ;

! read byte from memory
: cpu-read-byte ( address cpu -- d )
  [ memory>> memory-test ] 2keep rot
  [ memory>> memory-read-byte ] [ cpu-exception 0 ] if
  ;

: cpu-write-byte ( d address cpu -- )
  [ memory>> memory-test ] 2keep rot
  [ memory>> memory-write-byte ] [ cpu-exception ] if ;


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


! execute one instruction
: execute-pc-opcodes ( cpu -- )
!    [ rom-pc-read ] keep
!    [ opcodes>> nth [ break ] prepose ] keep swap call( cpu -- )
;

! execute one instruction
: execute-pc-opcode ( cpu -- )
!    [ rom-pc-read ] keep [ opcodes>> nth ] keep swap call( cpu -- )
;

! Execute to an address
: execute-address ( addr cpu -- )
!    [
 !       [ pc>> = ] 2keep rot ]
!        [ [ execute-pc-opcode ] keep
!    ] until 
!    2drop
;

  

: <cpu> ( -- cpu )
  cpu new
  <alu> >>alu
  8 0 <array> >>dr
  9 0 <array> >>ar
  <memory> >>memory
  [ alu>> 7 swap alu-imask-write ] keep
  [ alu>> alu-s-set ] keep
  
;
                    