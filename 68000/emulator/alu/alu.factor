! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING:
    accessors arrays kernel math sequences byte-arrays io
    math.parser unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep
    models math.bitwise ;



IN: freescale.68000.emulator.alu


CONSTANT: C-BIT  0
CONSTANT: V-BIT  1
CONSTANT: Z-BIT  2
CONSTANT: N-BIT  3
CONSTANT: X-BIT  4
CONSTANT: I0-BIT 8
CONSTANT: I1-BIT 9
CONSTANT: I2-BIT 10
CONSTANT: S-BIT  13
CONSTANT: T-BIT  15
CONSTANT: IP     0b11100000000

TUPLE: alu < model ;





M: alu model-activated
    break drop ;


! we add a connection
: alu-add-connection ( model alu -- )
    swap add-connection ;


! C flag manipulation
: alu-c-set ( alu -- )
    [ value>> C-BIT set-bit ] keep set-model ;

: alu-c-clr ( alu -- )
    [ value>> C-BIT clear-bit ] keep set-model ;

: alu-c-read ( alu -- b )
    value>> C-BIT dup bit-range ;

: alu-c-write ( b alu -- )
    swap 0 = [ alu-c-clr ] [ alu-c-set ] if ;

: ?alu-c ( ? alu -- )
    swap [ alu-c-set ] [ alu-c-clr ] if ;

: alu-c? ( alu -- ? )
    alu-c-read 0 = not ;

! V flag manipulation
: alu-v-set ( alu -- )
    [ value>> V-BIT set-bit ] keep set-model ;

: alu-v-clr ( alu -- )
    [ value>> V-BIT clear-bit ] keep set-model ;

: alu-v-read ( alu -- b )
    value>> V-BIT dup bit-range ;

: alu-v-write ( b alu -- )
    swap 0 = [ alu-v-clr ] [ alu-v-set ] if ;

: ?alu-v ( ? alu -- )
    swap [ alu-v-set ] [ alu-v-clr ] if ;

: alu-v? ( alu -- ? )
    alu-v-read 0 = not ;

! Z flag manipulation
: alu-z-set ( alu -- )
    [ value>> Z-BIT set-bit ] keep set-model ;

: alu-z-clr ( alu -- )
    [ value>> Z-BIT clear-bit ] keep set-model ;

: alu-z-read ( alu -- b )
    value>> Z-BIT dup bit-range ;

: alu-z-write ( b alu -- )
    swap 0 = [ alu-z-clr ] [ alu-z-set ] if ;

: ?alu-z ( ? alu -- )
    swap [ alu-z-set ] [ alu-z-clr ] if ;

: alu-z? ( alu -- ? )
    alu-z-read 0 = not ;

! N flag manipulation
: alu-n-set ( alu -- )
    [ value>> N-BIT set-bit ] keep set-model ;

: alu-n-clr ( alu -- )
    [ value>> N-BIT clear-bit ] keep set-model ;

: alu-n-read ( alu -- b )
    value>> N-BIT dup bit-range ;

: alu-n-write ( b alu -- )
    swap 0 = [ alu-n-clr ] [ alu-n-set ] if ;

: ?alu-n ( ? alu -- )
    swap [ alu-n-set ] [ alu-n-clr ] if ;

: alu-n? ( alu -- ? )
    alu-n-read 0 = not ;

! X flag manipulation
: alu-x-set ( alu -- )
    [ value>> X-BIT set-bit ] keep set-model ;

: alu-x-clr ( alu -- )
    [ value>> X-BIT clear-bit ] keep set-model ;

: alu-x-read ( alu -- b )
    value>> X-BIT dup bit-range ;

: alu-x-write ( b alu -- )
    swap 0 = [ alu-x-clr ] [ alu-x-set ] if ;

: ?alu-x ( ? alu -- )
    swap [ alu-x-set ] [ alu-x-clr ] if ;

: alu-x? ( alu -- ? )
    alu-x-read 0 = not ;


! I0 flag manipulation
: alu-ip0-set ( alu -- )
    [ value>> I0-BIT set-bit ] keep set-model ;

: alu-ip0-clr ( alu -- )
    [ value>> I0-BIT clear-bit ] keep set-model ;

: alu-ip0-read ( alu -- b )
    value>> I0-BIT dup bit-range ;

: alu-ip0-write ( b alu -- )
    swap 0 = [ alu-ip0-clr ] [ alu-ip0-set ] if ;

: ?alu-ip0 ( ? alu -- )
    swap [ alu-ip0-set ] [ alu-ip0-clr ] if ;

: alu-ip0? ( alu -- ? )
    alu-ip0-read 0 = not ;

! I1 flag manipulation
: alu-ip1-set ( alu -- )
    [ value>> I1-BIT set-bit ] keep set-model ;

: alu-ip1-clr ( alu -- )
    [ value>> I1-BIT clear-bit ] keep set-model ;

: alu-ip1-read ( alu -- b )
    value>> I1-BIT dup bit-range ;

: alu-ip1-write ( b alu -- )
    swap 0 = [ alu-ip1-clr ] [ alu-ip1-set ] if ;

: ?alu-ip1 ( ? alu -- )
    swap [ alu-ip1-set ] [ alu-ip1-clr ] if ;

: alu-ip1? ( alu -- ? )
    alu-ip1-read 0 = not ;

! I2 flag manipulation
: alu-ip2-set ( alu -- )
    [ value>> I2-BIT set-bit ] keep set-model ;

: alu-ip2-clr ( alu -- )
    [ value>> I2-BIT clear-bit ] keep set-model ;

: alu-ip2-read ( alu -- b )
    value>> I2-BIT dup bit-range ;

: alu-ip2-write ( b alu -- )
    swap 0 = [ alu-ip2-clr ] [ alu-ip2-set ] if ;

: ?alu-ip2 ( ? alu -- )
    swap [ alu-ip2-set ] [ alu-ip2-clr ] if ;

: alu-ip2? ( alu -- ? )
    alu-ip0-read 0 = not ;

! read that interrupt mask
: alu-ip ( alu -- n )
  value>> I2-BIT I0-BIT bit-range ;

! interrupt mask
: alu-imask-write ( b alu -- )
    [ 3 bits ] dip
    [ IP bitnot ] dip
    [ value>> ] keep [ bitand ] dip
    [ 8 shift ] 2dip [ bitor ] dip
    set-model ;


! set the supervise mode
: alu-s-set ( alu -- )
    [ value>> S-BIT set-bit ] keep set-model ;

! clear the supervise mode
: alu-s-clr ( alu -- )
    [ value>> S-BIT clear-bit ] keep set-model ;

! read supervise mode value
: alu-s-read ( alu -- b )
  value>> S-BIT dup bit-range ;

! read the supervise mode bit
: alu-mode? ( alu -- ? )
    alu-s-read 0 = not ;

! clear the trace
: alu-t-clr ( alu -- )
    [ value>> T-BIT clear-bit ] keep set-model ;

! trace read
: alu-t> ( alu -- b )
  value>> T-BIT dup bit-range ;

! get staus of trace
: alu-t? ( alu -- ? )
    alu-t> 0 = not ;


! read Status Register
: alu-sr> ( alu -- sr )
    value>> 16 bits ;

! write Status Register
: >alu-sr ( d cpu -- )
    [ 16 bits ] dip set-model ;

! test the byte for zero and set flag
: alu-byte-z ( b alu -- )
  [ 0 = ] dip swap
  [ alu-z-set ] [ alu-z-clr ] if ;

! test the long data for zero
: alu-long-z ( data alu -- )
  [ 0 = ] dip swap
  [ alu-z-set ] [ alu-z-clr ] if ;

: alu-byte-n ( b alu -- )
  [ 7 bit? ] dip swap
  [ alu-n-set ] [ alu-n-clr ] if ;

: alu-long-n ( data alu -- )
  [ 31 bit? ] dip swap
  [ alu-n-set ] [ alu-n-clr ] if ;

: alu-byte-c ( b alu -- )
  [ 8 bit? ] dip swap
  [ alu-c-set ] [ alu-c-clr ] if ;

: alu-lsl-byte ( count d alu -- r )
  [ [ dup 0 = not ] 2dip rot ]
  [
    [ 1 - ] 2dip
    [ dup 7 bit? ] dip
    [ ?alu-c ] keep
    [ dup 7 bit? ] dip
    [ ?alu-x ] keep
    [ 1 8 bitroll 0 clear-bit ] dip
    [ dup 7 bit? ] dip
    [ ?alu-n ] keep
    [ dup 8 bits 0 = ] dip
    [ ?alu-z ] keep
    [ alu-v-clr ] keep
  ] while drop swap drop ;

: alu-lsr-byte ( count d alu -- r )
  [ [ dup 0 = not ] 2dip rot ]
  [
    [ 1 - ] 2dip
    [ dup 7 bit? ] dip
    [ ?alu-c ] keep
    [ dup 7 bit? ] dip
    [ ?alu-x ] keep
    [ -1 8 bitroll 0 clear-bit ] dip
    [ dup 7 bit? ] dip
    [ ?alu-n ] keep
    [ dup 8 bits 0 = ] dip
    [ ?alu-z ] keep
    [ alu-v-clr ] keep
  ] while drop swap drop ;

: alu-asl-long ( count d alu -- r )
  [ [ dup 0 = not ] 2dip rot ]
  [
    [ 1 - ] 2dip
    [ dup 31 bit? ] dip
    [ ?alu-c ] keep
    [ dup 31 bit? ] dip
    [ ?alu-x ] keep
    [ 1 bitroll-32 0 clear-bit ] dip
    [ dup 31 bit? ] dip
    [ ?alu-n ] keep
    [ dup 32 bits 0 = ] dip
    [ ?alu-z ] keep
    [ dup 31 bit? ] dip
    [ alu-x? xor ] keep
    [ ?alu-v ] keep
  ] while drop swap drop ;

: alu-asr-long ( count d alu -- r )
  [ [ dup 0 = not ] 2dip rot ]
  [
    [ 1 - ] 2dip
    [ dup 0 bit? ] dip
    [ ?alu-c ] keep
    [ dup 0 bit? ] dip
    [ ?alu-x ] keep
    [ dup 31 bit? ] dip
    [ -1 bitroll-32 ] 2dip
    [ [ 31 set-bit ] [ 31 clear-bit ] if ] dip
    [ dup 31 bit? ] dip
    [ ?alu-n ] keep
    [ dup 32 bits 0 = ] dip
    [ ?alu-z ] keep
    [ alu-v-clr ] keep
  ] while drop swap drop ;

: alu-and-byte ( a b alu -- r )
  [ bitand ] dip
  [ dup 7 bit? ] dip
  [ ?alu-n ] keep
  [ dup 8 bits 0 = ] dip
  [ ?alu-z ] keep
  [ alu-v-clr ] keep
  [ alu-c-clr ] keep drop ;

: alu-and-long ( a b alu -- r )
  [ bitand ] dip
  [ dup 31 bit? ] dip
  [ ?alu-n ] keep
  [ dup 32 bits 0 = ] dip
  [ ?alu-z ] keep
  [ alu-v-clr ] keep
  [ alu-c-clr ] keep drop ;



: alu-or-word ( a b alu -- r )
  [ bitor ] dip
  [ dup 15 bit? ] dip
  [ ?alu-n ] keep
  [ dup 16 bits 0 = ] dip
  [ ?alu-z ] keep
  [ alu-v-clr ] keep
  alu-c-clr ;

: alu-or-byte ( a b alu -- r )
  [ bitor ] dip
  [ dup 7 bit? ] dip
  [ ?alu-n ] keep
  [ dup 8 bits 0 = ] dip
  [ ?alu-z ] keep
  [ alu-v-clr ] keep
  alu-c-clr ;

: alu-sr ( alu -- sr )
  value>> 16 bits ;

: alu-sr-write ( d alu -- )
  [ value>> 16 mask-bit bitor ] keep set-model ;

: alu-ccr ( alu -- ccr )
  value>> 8 bits ;

: alu-ccr-write ( d alu -- )
  [ value>> 8 mask-bit bitor ] keep set-model ;

: alu-add-byte ( a b alu -- r )
  break
  [ + ] dip
  [ alu-byte-n ] 2keep
  [ [ 8 bits ] dip alu-byte-z ] 2keep
  [ alu-byte-c ] 2keep
  [ [ alu-c? ] [ ?alu-x ] bi ] 2keep
  
;

! make a alu
: <alu> ( -- alu )
  0 alu new-model
  [ 7 swap alu-imask-write ] keep
  [ alu-s-set ] keep ;
