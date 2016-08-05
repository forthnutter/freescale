! Copyright (C) 2014 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!

USING:
   accessors kernel math math.bitwise math.order math.parser
   sequences unicode unicode.case grouping
   freescale.68000.emulator
   freescale.binfile
   models.memory
   ;


IN: freescale.68000



! memory display or dump bytes
: mdb ( n address cpu -- str/f )
  [ memory-read ] 2keep drop [ dup f = ] dip swap
  [
    [ drop ] dip 
  ]
  [
    >hex 8 CHAR: 0 pad-head >upper ": " append swap
    [ >hex 2 CHAR: 0 pad-head >upper " " append ] { } map-as concat append
  ] if ;
    

! need turn a byte array into word array
: >word< ( a b -- ab )
        [ 8 bits 8 shift ] dip 8 bits bitor ;

: >long< ( a b c d -- abcd )
        [ >word< 16 bits 16 shift ] 2dip >word< 16 bits bitor ;


! memory display words
: mdw ( n address cpu -- str/f )
    [ >even ] 2dip    ! make sure we have even number of bytes
    [ memory-read ] 2keep drop  [ dup f = ] dip swap
    [
        [ drop ] dip
    ]
    [
        >hex 8 CHAR: 0 pad-head >upper ": " append swap
        2 group [ first2 >word< ] map

        [ >hex 4 CHAR: 0 pad-head >upper " " append ] { } map-as concat append
    ] if ;
    
! memory display long
: mdl ( n address cpu -- str/f )
    [ >even 0b11 unmask ] 2dip
    [ memory-read ] 2keep drop [ dup f = ] dip swap
    [
        [ drop ] dip
    ]
    [
        >hex 8 CHAR: 0 pad-head >upper ": " append swap
        4 group [ first4 >long< ] map
        [ >hex 8 CHAR: 0 pad-head >upper " " append ] { } map-as concat append
  ] if ;




