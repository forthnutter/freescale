! Copyright (C) 2016 Joseph Moschini.  a.k.a. forthnutter
! See http://factorcode.org/license.txt for BSD license.
!
! opterand size routines


USING:
    accessors arrays kernel math sequences byte-arrays io
    math.parser math.ranges unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    words quotations math.bitwise freescale.68000.emulator
    models ascii ;


IN: freescale.68000.count

TUPLE: bc-count bytes cycles ;

! Bit Manipulation
: (bytes-0) ( opcode -- n )
  11 0 bit-range
  {
    { 0 [ 2 ] }
    [ drop ]
  } case ;

: (bytes-1) ( opcode -- n )
  drop 2
  ;

: (bytes-2) ( opcode -- n )
  drop 2
  ;

: (bytes-3) ( opcode -- n )
  drop 2
  ;

: (bytes-4) ( opcode -- n )
  drop 2
  ;

: (bytes-5) ( opcode -- n )
  drop 2
  ;

: (bytes-6) ( opcode -- n )
  drop 2
  ;

: (bytes-7) ( opcode -- n )
  drop 2
  ;

: (bytes-8) ( opcode -- n )
  drop 2
  ;

: (bytes-9) ( opcode -- n )
  drop 2
  ;

: (bytes-A) ( opcode -- n )
  drop 2
  ;

: (bytes-B) ( opcode -- n )
  drop 2
  ;

: (bytes-C) ( opcode -- n )
  drop 2
  ;

: (bytes-D) ( opcode -- n )
  drop 2
  ;

: (bytes-E) ( opcode -- n )
  drop 2
  ;

: (bytes-F) ( opcode -- n )
  drop 2
  ;

! now we return the number of bytes
: count-number-bytes ( array count -- n )
  [ dup first extract-opcode ] dip
  ;

! generate the opcode array here
: count-bytes-build ( count -- )
  bytes>> dup
  [
    [ drop ] dip
    [
      >hex >upper
      "(bytes-" swap append ")" append
      "freescale.68000.count" lookup-word 1quotation
    ] keep
    [ swap ] dip swap [ set-nth ] keep
  ] each-index drop ;

! find number of bytes in opcode
: count-bytes ( opcode count -- n )
      [ 6 swap cpu-pc-read-array ] keep [ cashe<< ] keep [ cashe>> first ] keep
      [ extract-opcode ] dip [ opcodes>> nth ] keep swap call( cpu -- )
  ;

: (cycles-0) ( count -- n )
  ;

: (cycles-1) ( count -- n )
  ;

: (cycles-2) ( count -- n )
  ;

: (cycles-3) ( count -- n )
  ;

: (cycles-4) ( count -- n )
  ;

: (cycles-5) ( count -- n )
  ;

: (cycles-6) ( count -- n )
  ;

: (cycles-7) ( count -- n )
  ;

: (cycles-8) ( count -- n )
  ;

: (cycles-9) ( count -- n )
  ;

: (cycles-A) ( count -- n )
  ;

: (cycles-B) ( count -- n )
  ;

: (cycles-C) ( count -- n )
  ;

: (cycles-D) ( count -- n )
  ;

: (cycles-E) ( count -- n )
  ;

: (cycles-F) ( count -- n )
  ;

! generate the opcode array here
: count-cycles-build ( count -- )
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
  16 0 <array> >>bytes
  16 0 <array> >>cycles
  [ count-bytes-build ] keep
  count-cycles-build ;

: <count-opcode> ( --  count )
  bc-count new [ count-build ] keep ;
