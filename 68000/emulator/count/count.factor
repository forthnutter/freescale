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

TUPLE: count bcount cycle ;


: (bytes-0)
  ;

: (bytes-1)
  ;

: (bytes-2)
  ;

: (bytes-3)
  ;

: (bytes-4)
  ;

: (bytes-5)
  ;

: (bytes-6)
  ;

: (bytes-7)
  ;

: (bytes-8)
  ;

: (bytes-9)
  ;

: (bytes-A)
  ;

: (bytes-B)
  ;

: (bytes-C)
  ;

: (bytes-D)
  ;

: (bytes-E)
  ;

: (bytes-F)
  ;

! generate the opcode array here
: count-bytes ( count -- )
  bcount>> dup
  [
    [ drop ] dip
    [
      >hex >upper
      "(bytes-" swap append ")" append
      "freescale.68000.count" lookup-word 1quotation
    ] keep
    [ swap ] dip swap [ set-nth ] keep
  ] each-index drop ;


: (cycles-0)
  ;

: (cycles-1)
  ;

: (cycles-2)
  ;

: (cycles-3)
  ;

: (cycles-4)
  ;

: (cycles-5)
  ;

: (cycles-6)
  ;

: (cycles-7)
  ;

: (cycles-8)
  ;

: (cycles-9)
  ;

: (cycles-A)
  ;

: (cycles-B)
  ;

: (cycles-C)
  ;

: (cycles-D)
  ;

: (cycles-E)
  ;

: (cycles-F)
  ;

! generate the opcode array here
: count-cycles ( count -- )
  cycles>> dup
  [
    [ drop ] dip
    [
      >hex >upper
      "(cycles-" swap append ")" append
        "freescale.68000.count" lookup-word 1quotation
    ] keep
    [ swap ] dip swap [ set-nth ] keep
  ] each-index drop ;

: count-build ( count -- )
  16 0 <array> >>bcount
  16 0 <array> >>cycle
  [ count-bytes ] keep
  count-cycles ;

: <count-opcode> ( --  count )
  count new ;
