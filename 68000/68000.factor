! Copyright (C) 2014 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!

USING:
   accessors kernel math math.bitwise math.order math.parser
   sequences unicode.case
   freescale.68000.emulator
   freescale.binfile ;


IN: freescale.68000



! rom dump number of bytes
: hexdump ( n address cpu -- str )
  [
      16 bits
      [ dup 16 < ] dip
      [ swap [ + ] [ swap drop 16 + ] if ] keep
      [ 16 bits ] dip
      [ min ] [ max ] 2bi
       2dup
  ] dip 
  memory>> subseq [ drop ] dip
  [ >hex 4 CHAR: 0 pad-head >upper " " append ] dip
  [ >hex 2 CHAR: 0 pad-head >upper " " append ] { } map-as concat append ;





: start-68k ( -- cpu )
    "work/freescale/68000/iplrom.dat" <binfile>
    0 swap <cpu> [ memory>> swap append ] keep memory<< ;
