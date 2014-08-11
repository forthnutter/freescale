! Copyright (C) 2014 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: 
    accessors arrays kernel math sequences byte-arrays io
    math.parser unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    words quotations math.order 
    freescale.68000.emulator.alu models math.bitwise
    freescale.68000.emulator.memory.mblock ;
  

IN: freescale.68000.emulator.memory


TUPLE: memory vector ;

: <memory> ( -- memory )
    memory new
    V{ } clone >>vector ;


: memory-add-block ( mblock memory -- )
    vector>> push ;



! go find address memory block 
: memory-find ( address memory -- mblock )
    vector>>
    [
        [ mblock-start-end between? ] keep
    ] find
    [ drop ] dip ! remove index
    swap
    [ ] [ drop f ] if
    ;



! test to see if address is available
: memory-test ( address memory -- ? )
    memory-find mblock? ;

: memory-between ( from to memory -- ? )
    [ memory-test ] curry bi@ and ;

! read byte from memory
: memory-read-byte ( address memory -- d/f )
    [ dup ] dip memory-find
    dup mblock?
    [ mblock-read ] [ drop drop f ] if ;


: memory-write-byte ( d address memory -- ? )
    [ dup ] dip memory-find
    dup mblock?
    [ mblock-write t ] [ drop drop drop f ] if ;


: memory-read-word ( address memory -- d )
    [ memory-read-byte ] 2keep [ 1 + ] dip memory-read-byte
    2dup and f = [ drop drop f ] [ [ 8 shift ] dip bitor ] if ;

: memory-write-word ( d address memory -- ? )
    [ [ dup 8 bits swap ] dip [ 7 0 bit-range ] dip ] dip
    [ memory-write-byte swap ] 2keep [ 1 + ] dip memory-write-byte
    and ;

: memory-read-long ( address memory -- d )
    [ memory-read-word ] 2keep [ 2 + ] dip memory-read-word ;

: memory-write-long ( d address memory -- )
    [ dup ] dip memory-find dup
    [ mblock-write ] [ ] if ;

! return a sub array of memory
: memory-subseq ( from to memory -- array/f )
    [ [ memory-find ] curry bi@ 2dup [ mblock? ] bi@ and ] 3keep drop rot
    [
        [ drop ] 2dip rot
        [ [ mblock-address ] curry bi@ ] keep
        mblock-subseq
    ] [ ] if
    
    ;


! create a memory block and add binary array
: memory-create ( address array memory -- )
    [ <mblock> ] dip memory-add-block ;