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


IN: freescale.68000.emulator.count

TUPLE: count bytes cycles ;


: (bytes-0) ( opcode -- n )
  ;

: (bytes-1) ( opcode -- n )
  ;

: (bytes-2) ( opcode -- n )
  ;

: (bytes-3) ( opcode -- n )
  ;

: (bytes-4) ( opcode -- n )
  ;

: (bytes-5) ( opcode -- n )
  ;

: (bytes-6) ( opcode -- n )
  ;

: (bytes-7) ( opcode -- n )
  ;

: (bytes-8) ( opcode -- n )
  ;

: (bytes-9) ( opcode -- n )
  ;

: (bytes-A) ( opcode -- n )
  ;

: (bytes-B) ( opcode -- n )
  ;

: (bytes-C) ( opcode -- n )
  ;

: (bytes-D) ( opcode -- n )
  ;

: (bytes-E) ( opcode -- n)
  ;

: (bytes-F) ( -- )
  ;

! generate the opcode array here
: count-bytes-build ( count -- )
  bytes>> dup
  [
    [ drop ] dip
    [
      >hex >upper
      "(bytes-" swap append ")" append
      "freescale.68000.emulator.count" lookup-word 1quotation
    ] keep
    [ swap ] dip swap [ set-nth ] keep
  ] each-index drop ;

! find number of bytes in opcode
: count-bytes ( opcode count -- n )
      [ 6 swap cpu-pc-read-array ] keep [ cashe<< ] keep [ cashe>> first ] keep
      [ extract-opcode ] dip [ opcodes>> nth ] keep swap call( cpu -- )
  ;

: (cycles-0) ( -- )
  ;

: (cycles-1) ( -- )
  ;

: (cycles-2) ( -- )
  ;

: (cycles-3) ( -- )
  ;

: (cycles-4) ( -- )
  ;

: (cycles-5) ( -- )
  ;

: (cycles-6) ( -- )
  ;

: (cycles-7) ( -- )
  ;

: (cycles-8) ( -- )
  ;

: (cycles-9) ( -- )
  ;

: (cycles-A) ( -- )
  ;

: (cycles-B) ( -- )
  ;

: (cycles-C) ( -- )
  ;

: (cycles-D) ( -- )
  ;

: (cycles-E) ( -- )
  ;

: (cycles-F) ( -- )
  ;

! generate the opcode array here
: count-cycles-build ( count -- )
  cycles>> dup
  [
    [ drop ] dip
    [
      >hex >upper
      "(cycles-" swap append ")" append
        "freescale.68000.emulator.count" lookup-word 1quotation
    ] keep
    [ swap ] dip swap [ set-nth ] keep
  ] each-index drop ;

: count-build ( count -- )
  16 0 <array> >>bytes
  16 0 <array> >>cycles
  [ count-bytes-build ] keep
  count-cycles-build ;

: <count-opcode> ( --  count )
  count new [ count-build ] keep ;
