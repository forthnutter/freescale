! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: 
    accessors arrays kernel math sequences byte-arrays io
    math.parser unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    words quotations math.bitwise models freescale.68000.emulator.alu ;
  

IN: freescale.68000.emulator.address

TUPLE: usp < model ;

: <usp> ( model -- usp )
    0 usp new-model [ add-dependency ] keep ;

M: usp model-changed
    [ value>> ] dip set-model ;

M: usp model-activated
    drop ;



TUPLE: ssp < model ;

: <ssp> ( model -- ssp )
    0 ssp new-model [ add-dependency ] keep ;

M: ssp model-changed
    break
    [ value>> ] dip set-model ;

M: ssp model-activated
    drop ;



TUPLE: a7 < model ssp usp ;

: <a7> ( -- a7 )
    0 a7 new-model
    dup <ssp> >>ssp dup <usp> >>usp ;

M: a7 model-changed
    break
    [ alu-mode? ] dip swap
    [ dup usp>> deactivate-model ssp>> activate-model ]
    [ dup ssp>> deactivate-model usp>> activate-model ] if ;


TUPLE: ax < model ;

: <ax> ( -- ax )
    0 ax new-model ;

TUPLE: ar array ;

: <ar> ( -- ar )
    ar new 8 0 <array> [ >>array [] map ] keep 
    [ 7 ] dip nth [ >>usp ] keep >>ssp ;


: ar-read ( n ar -- v )
    [ 2 0 bit-range ] dip
    array>> nth ;


: ar-write ( d n ar -- )
    [ 2 0 bit-range ] dip
    array>> set-nth ;


