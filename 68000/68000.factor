! Copyright (C) 2014 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!

USING:
   accessors kernel math.bits math.bitwise
   freescale.68000.emulator freescale.68000.emulator.memory
   freescale.binfile ;


IN: freescale.68000


: start-68k ( -- cpu )
    "work/freescale/68000/iplrom.dat" <binfile>
    0 swap <cpu> [ memory>> memory-create ] keep ;
