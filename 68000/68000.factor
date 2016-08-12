! Copyright (C) 2014 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!

USING:
   accessors kernel math math.bitwise math.order math.parser
   sequences unicode unicode.case grouping
   freescale.68000.emulator
   freescale.binfile
   math.ranges
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

: >hex-pad8 ( d -- s )
    [ "$" ] dip >hex 8 CHAR: 0 pad-head append ;

: >dec-pad9 ( d -- s )
    number>string 9 32 pad-head ;
: >bin-pad32 ( d -- s )
    >bin 32 CHAR: 0 pad-head ;
    
  
! lets make a string that shows the value of D0 in Hex and Decimal maybe binary
! "D0: $XXXXXXXX DDDDDDD"
: String-D0 ( cpu -- s )
    [ D0> >hex-pad8 ] [ D0> >dec-pad9 ] bi
    [ " " append ] dip append "D0: " prepend ;
 
 ! lets make a string that shows the value of D1 in Hex and Decimal maybe binary
! "D1: $XXXXXXXX DDDDDDD"
: String-D1 ( cpu -- s )
    [ D1> >hex-pad8 ] [ D1> >dec-pad9 ] bi
    [ " " append ] dip append "D1: " prepend ;

! lets make a string that shows the value of D2 in Hex and Decimal maybe binary
! "D2: $XXXXXXXX DDDDDDD"
: String-D2 ( cpu -- s )
    [ D2> >hex-pad8 ] [ D2> >dec-pad9 ] bi
    [ " " append ] dip append "D2: " prepend ;
    
! lets make a string that shows the value of D3 in Hex and Decimal maybe binary
! "D3: $XXXXXXXX DDDDDDD"
: String-D3 ( cpu -- s )
    [ D3> >hex-pad8 ] [ D3> >dec-pad9 ] bi
    [ " " append ] dip append "D3: " prepend ;

! lets make a string that shows the value of D4 in Hex and Decimal maybe binary
! "D4: $XXXXXXXX DDDDDDD"
: String-D4 ( cpu -- s )
    [ D4> >hex-pad8 ] [ D4> >dec-pad9 ] bi
    [ " " append ] dip append "D4: " prepend ;

! lets make a string that shows the value of D5 in Hex and Decimal maybe binary
! "D5: $XXXXXXXX DDDDDDD"
: String-D5 ( cpu -- s )
    [ D5> >hex-pad8 ] [ D5> >dec-pad9 ] bi
    [ " " append ] dip append "D5: " prepend ;

! lets make a string that shows the value of D6 in Hex and Decimal maybe binary
! "D6: $XXXXXXXX DDDDDDD"
: String-D6 ( cpu -- s )
    [ D6> >hex-pad8 ] [ D6> >dec-pad9 ] bi
    [ " " append ] dip append "D6: " prepend ;    

    
! lets make a string that shows the value of D7 in Hex and Decimal maybe binary
! "D7: $XXXXXXXX DDDDDDD"
: String-D7 ( cpu -- s )
    [ D7> >hex-pad8 ] [ D7> >dec-pad9 ] bi
    [ " " append ] dip append "D7: " prepend ;

! Build the DX strings into an array
: DX-String ( cpu -- array )
    0 7 [a,b] [ ] { } map ;
    
    
    