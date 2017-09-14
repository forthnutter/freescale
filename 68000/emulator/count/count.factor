! Copyright (C) 2016 Joseph Moschini.  a.k.a. forthnutter
! See http://factorcode.org/license.txt for BSD license.
!
! opterand size routines


USING:
    accessors arrays kernel math sequences byte-arrays io
    math.parser math.ranges unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    words quotations math.bitwise freescale.68000.emulator.exception
    freescale.68000.emulator.alu models ascii ;


IN: freescale.68000.count

TUPLE: count opcode cycle ;




: <count-opcode> ( --  count )
  count new ;
