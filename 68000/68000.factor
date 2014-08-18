! Copyright (C) 2014 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!

USING:
   accessors kernel math math.bitwise math.order math.parser
   sequences unicode.case
   freescale.68000.emulator
   freescale.binfile
   freescale.68000.emulator.memory.mblock
   freescale.68000.emulator.memory ;


IN: freescale.68000



! memory display or dump bytes
: mdb ( n address cpu -- str/f )
  [
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
    [ >hex 8 CHAR: 0 pad-head >upper " " append ] dip
    [ >hex 2 CHAR: 0 pad-head >upper " " append ] { } map-as concat append
  ] if ;
    

! memory display words
! : mdw ( n address cpu -- str/f )
  




: start-68k ( -- cpu )
    "work/freescale/68000/iplrom.dat" <binfile>
    0 swap <mblock> <cpu> [ memory>> memory-add-block ] keep ;
