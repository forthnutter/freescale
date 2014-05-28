! Copyright (C) 2014 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: 
    accessors arrays kernel math sequences byte-arrays io
    math.parser unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    words quotations math.order
    freescale.68000.emulator.alu models ;
  

IN: freescale.68000.emulator.memory



TUPLE: mblock start array ;



: <mblock> ( start array -- mblock )
    mblock boa ;


: mblock-read ( address mblock -- d )
    [ start>> - ] keep array>> nth ;

: mblock-write ( d address mblock -- )
    [ start>> - ] keep array>> set-nth ;


TUPLE: memory vector ;

: <memory> ( -- memory )
    memory new
    V{ } clone >>vector ;


: memory-add-block ( mblock memory -- )
    vector>> push ;



: memory-test ( address memory -- ? )
    f -rot
    vector>>
    [
        [ dup ] dip [ start>> ] keep
        [ between? ] dip drop swap [ or ] dip
    ] each drop
 ;


: memory-find ( address memory -- mblock )
    vector>>
    [
        [ dup ] dip [ start>> ] keep
        [ between? ] dip drop
    ] find [ drop drop ] dip ;



: memory-read-byte ( address memory -- d )
    [ dup ] dip memory-find dup
    [ mblock-read ] [ ] if ;


: memory-write-byte ( d address memory -- )
    [ dup ] dip memory-find dup
    [ mblock-write ] [ ] if ;


: memory-read-word ( address memory -- d )
    [ memory-read-byte ] 2keep
    memory-read-byte ;

: memory-write-word ( d address memory -- )
    [ dup ] dip memory-find dup
    [ mblock-write ] [ ] if ;

: memory-read-long ( address memory -- d )
    [ memory-read-word ] 2keep memory-read-word ;

: memory-write-long ( d address memory -- )
    [ dup ] dip memory-find dup
    [ mblock-write ] [ ] if ;

! create a memory block and add binary array
: memory-create ( address array memory -- )
    [ <mblock> ] dip memory-add-block ;