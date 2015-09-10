! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: 
    accessors arrays kernel math sequences byte-arrays io
    math.parser unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    words quotations math.bitwise
    freescale.68000.emulator.alu
    models freescale.68000.emulator.memory ;
  

IN: freescale.68000.emulator

CONSTANT: ACCESS-FAULT 8
CONSTANT: ADDRESS-ERROR 12
CONSTANT: ILLEGAL-INSTRUCTION 16


TUPLE: cpu alu ar dr pc rx cycles memory opcodes state ;

: cpu-exception ( excep cpu -- )
    state<< ;

! write to user sp
: >USP ( d cpu -- )
   ar>> 7 swap set-nth ;

! get user sp
: USR> ( cpu -- d )
   ar>> 7 swap nth ;

! write to supervisor sp
: >SSP ( d cpu -- )
   ar>> 7 swap set-nth ;

! read supervisor sp
: SSP> ( cpu -- d )
  ar>> 8 swap nth ;

! put value into A7
: >A7 ( d cpu -- )
    [ alu>> alu-mode? ] keep swap
    [ >SSP ] [ >USP ] if ;

! get A7
: A7> ( cpu -- d )
  [ alu>> alu-mode? ] keep swap
  [ SSP> ] [ USP> ] if ;


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
  dr>> 6 swap set-nth ;

: D7> ( cpu -- d )
  dr>> 6 swap nth ;

: >D6 ( d cpu -- )
  dr>> 6 swap set-nth ;

: D6> ( cpu -- d )
  dr>> 6 swap nth ;

: >D5 ( d cpu -- )
  dr>> 5 swap set-nth ;

: D5> ( cpu -- d )
  dr>> 5 swap nth ;

: >D4 ( d cpu -- )
  dr>> 4 swap set-nth ;

: D4> ( cpu -- d )
  dr>> 4 swap nth ;

: >D3 ( d cpu -- )
  dr>> 3 swap set-nth ;

: D3> ( cpu -- d )
  dr>> 3 swap nth ;

: >D2 ( d cpu -- )
  dr>> 2 swap set-nth ;

: D2> ( cpu -- d )
  dr>> 2 swap nth ;

: >D1 ( d cpu -- )
  dr>> 1 swap set-nth ;

: D1> ( cpu -- d )
  dr>> 1 swap nth ;

: >D0 ( d cpu -- )
  dr>> 0 swap set-nth ;

: D0> ( cpu -- d )
  dr>> 0 swap nth ;

! split a word value to bytes 
: word-bytes ( w -- a b )
    [ 15 8 bit-range ] keep 7 0 bit-range ;

! join two bytes into word
: bytes-word ( a b -- w )
    [ 8 bits 8 shift ] dip 8 bits bitor ;

! join two words into long
: words-long ( wh wl -- l )
    [ 16 bits 16 shift ] dip 16 bits bitor ;


! split a long into 4 bytes
: long-bytes ( l -- a b c d )
    [ 31 16 bit-range word-bytes ] keep
    15 0 bit-range word-bytes ;

! split long into words
: long-words ( l -- wh wl )
    [ 31 16 bit-range ] keep
    15 0 bit-range ;



! read byte from memory
: cpu-read-byte ( address cpu -- d )
  [ memory>> memory? ] keep swap
  [
      [ memory>> memory-read-byte dup f = ] keep swap
      [ ADDRESS-ERROR swap cpu-exception ] [ drop ] if
  ]
  [ drop ADDRESS-ERROR swap cpu-exception 0 ] if ;

: cpu-write-byte ( d address cpu -- )
  [ memory>> memory? ] keep swap
  [
      [ memory>> memory-write-byte f = ] keep swap
      [ ADDRESS-ERROR swap cpu-exception ] [ drop ] if
  ]
  [ drop drop ADDRESS-ERROR swap cpu-exception ] if ;


! read word from memory
: cpu-read-word ( address cpu -- dd )
    [ cpu-read-byte ] 2keep
    [ 1 + ] dip cpu-read-byte bytes-word ;

! write word to memory
: cpu-write-word ( d address cpu -- )
    [ word-bytes swap ] 2dip 
    [ cpu-write-byte ] 2keep
    [ 1 + ] dip cpu-write-byte ;


! read long from memory
: cpu-read-long ( address cpu -- dddd )
    [ cpu-read-word ] 2keep
    [ 2 + ] dip cpu-read-word words-long ;

! write long to memory
: cpu-write-long ( dddd address cpu -- )
    [ long-words swap ] 2dip
    [ cpu-write-word ] 2keep
    [ 2 + ] dip cpu-write-word ;



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
        drop
;

! execute one instruction
: execute-pc-opcode ( cpu -- )
!    [ rom-pc-read ] keep [ opcodes>> nth ] keep swap call( cpu -- )
        drop
;

! Execute to an address
: execute-address ( addr cpu -- )
!    [
 !       [ pc>> = ] 2keep rot ]
!        [ [ execute-pc-opcode ] keep
!    ] until 
    2drop
;


! Reset Process
: power ( reset -- )
    reg_usp = 0;
    for(int i = 0; i < 8; i++) {
        reg_d[i] = reg_a[i] = 0;
    }
    if(processWithReset) reset();
}  

: <cpu> ( -- cpu )
  cpu new
  <alu> >>alu
  8 0 <array> >>dr
  9 0 <array> >>ar
  <memory> >>memory
  [ alu>> 7 swap alu-imask-write ] keep
  [ alu>> alu-s-set ] keep
  
;
                    
