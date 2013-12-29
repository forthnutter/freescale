! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors kernel math models sequences vectors
       freescale.6805.emulator.port arrays ;


IN: freescale.6805.emulator.memory

TUPLE: io-cell < model start size ;

: <io-cell> ( dependant start size -- io-cell )
    0 io-cell new-model [ size<< ] keep [ start<< ] keep
    [ swap add-dependency ] keep ;


TUPLE: ram-cell < model start size array ;

TUPLE: rom-cell < model start size array ;

TUPLE: memory vector ;

: <memory> ( -- memory )
    memory new V{ } clone >>vector ;


: memory-add ( cell memory -- )
    vector>> push ;


! need the cell
: memory-cell ( address memory -- cell/? )
    array>> ?nth ;


! now get the value from cell
: memory-cell-value ( cell -- value/? )
   drop f ;


! read memory
: memory-read ( address memory -- data )
    drop drop 0 ;


! write memory
: memory-write ( d address memory -- )
    drop drop drop ;

! write an array to memory
: memory-array-write ( array address memory -- )
    rot
    [
        -rot
        [ memory-write ] 2keep
        [ 1 + ] dip
    ] each 2drop ;



: <memory-default> ( -- memory )
    <memory>
    <port> swap [ [ data>> ] keep swap ] dip swap
    [  0 1 <io-cell> ] curry keep [ vector>> push ] keep ;