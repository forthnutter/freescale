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

TUPLE: bc-count bytes cycles array ;

! Bit Manipulation
: (bytes-0) ( bc-count -- n )
  [ array>> first ] keep
  [ 7 0 bit-range ] dip
  [
    {
      { 0x34 [ 4 ] }
      { 0x35 [ 8 ] }
      [ drop 4 ]
    } case
  ] dip drop ;

: (bytes-1) ( bc-count -- n )
  [ array>> first ] keep
  [ 11 0 bit-range ] dip
  [
    {
      { 0x34 [ 4 ] }
      { 1 [ 4 ] }
      { 2 [ 8 ] }
      { 0x039 [ 6 ] }
      { 0x3c0 [ 6 ] }
      { 0xe79 [ 6 ] }
      [ drop 2 ]
    } case
  ] dip drop ;

: (bytes-2) ( bc-count -- n )
  [ array>> first ] keep
  [ 11 0 bit-range ] dip
  [
    {
      { 0x34 [ 4 ] }
      { 1 [ 4 ] }
      { 2 [ 8 ] }
      { 0x3c0 [ 6 ] }
      { 0xe79 [ 6 ] }
      [ drop 2 ]
    } case
  ] dip drop ;

: (bytes-3) ( bc-count -- n )
  drop 2
  ;

: (bytes-4) ( bc-count -- n )
  drop 2
  ;

: (bytes-5) ( bc-count -- n )
  drop 2
  ;

: (bytes-6) ( bc-count -- n )
  drop 2
  ;

: (bytes-7) ( bc-count -- n )
  drop 2
  ;

: (bytes-8) ( bc-count -- n )
  drop 2
  ;

: (bytes-9) ( bc-count -- n )
  drop 2
  ;

: (bytes-A) ( bc-count -- n )
  drop 2
  ;

: (bytes-B) ( bc-count -- n )
  drop 2
  ;

: (bytes-C) ( bc-count -- n )
  drop 2
  ;

: (bytes-D) ( bc-count -- n )
  drop 2
  ;

: (bytes-E) ( bc-count -- n )
  drop 2
  ;

: (bytes-F) ( bc-count -- n )
  drop 2
  ;

! now we return the number of bytes
: count-number-bytes ( array count -- n )
  [ swap >>array array>> ] keep
  [ first extract-opcode ] dip
  [ bytes>> nth ] keep swap call( bc-count -- n )
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
