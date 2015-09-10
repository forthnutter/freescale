! Copyright (C) 2014 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!

USING:
   accessors kernel math math.bitwise math.order math.parser
   sequences unicode.case grouping
   freescale.68000.emulator
   freescale.binfile
   freescale.68000.emulator.memory.mblock
   freescale.68000.emulator.memory ;


IN: freescale.68000



! memory display or dump bytes
: mdb ( n address cpu -- str/f )
  [
      32 bits
      [ dup 16 < ] dip
      [ swap [ + ] [ swap drop 16 + ] if ] keep
      [ 16 bits ] dip
      [ min ] [ max ] 2bi
       2dup
  ] dip 
  memory>> memory-subseq dup f =
  [
    [ drop drop ] dip
  ]
  [
    swap drop
    [ >hex 8 CHAR: 0 pad-head >upper ": " append ] dip
    [ >hex 2 CHAR: 0 pad-head >upper " " append ] { } map-as concat append
  ] if ;
    

! need turn a byte array into word array
: >word< ( a b -- ab )
        [ 8 bits 8 shift ] dip 8 bits bitor ;

: >long< ( a b c d -- abcd )
        [ >word< 16 bits 16 shift ] 2dip >word< 16 bits bitor ;


! memory display words
: mdw ( n address cpu -- str/f )
  [
      32 bits
      [ dup 16 < ] dip
      [ swap [ + ] [ swap drop 16 + ] if ] keep
      [ 16 bits ] dip
      [ min ] [ max ] 2bi
       2dup
  ] dip 
  memory>> memory-subseq dup f =
  [
    [ drop drop ] dip
  ]
  [
    2 group [ first2 >word< ] map
    swap drop
    [ >hex 8 CHAR: 0 pad-head >upper ": " append ] dip
    [ >hex 4 CHAR: 0 pad-head >upper " " append ] { } map-as concat append
  ] if ;
    
! memory display long
: mdl ( n address cpu -- str/f )
  [
      32 bits
      [ dup 16 < ] dip
      [ swap [ + ] [ swap drop 16 + ] if ] keep
      [ 16 bits ] dip
      [ min ] [ max ] 2bi
       2dup
  ] dip 
  memory>> memory-subseq dup f =
  [
    [ drop drop ] dip
  ]
  [
    4 group [ first4 >long< ] map
    swap drop
    [ >hex 8 CHAR: 0 pad-head >upper ": " append ] dip
    [ >hex 8 CHAR: 0 pad-head >upper " " append ] { } map-as concat append
  ] if ;


: start-68k ( -- cpu )
    "work/freescale/68000/1616OSV_045.bin" <binfile>
    0 swap <mblock> <cpu> [ memory>> memory-add-block ] keep ;



