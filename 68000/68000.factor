! Copyright (C) 2014 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!

USING:
   kernel freescale.68000.emulator freescale.binfile ;


IN: freescale.68000


: start-68k ( -- cpu )
    "work/freescale/68000/iplrom.dat" <binfile> <cpu> ;
