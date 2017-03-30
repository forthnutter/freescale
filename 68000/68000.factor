! Copyright (C) 2016 Joseph Moschini. a.k.a. forthnutter
! See http://factorcode.org/license.txt for BSD license.
!

USING:
   accessors kernel math math.bitwise math.order math.parser
   sequences unicode unicode.case grouping
   freescale.68000.emulator tools.continuations
   freescale.binfile arrays prettyprint
   math.ranges
   models.memory quotations words
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

: string-dr ( d -- str )
    [ >hex-pad8 " " append ] [ >dec-pad9 " " append ] [ >bin-pad32 ] tri
    append append ;


! lets make a string that shows the value of D0 in Hex and Decimal maybe binary
! "D0: $XXXXXXXX DDDDDDD BBBB BBBB BBBB BBBBBBBB"
: string-D0 ( cpu -- s )
    D0> string-dr "D0: " prepend ;

 ! lets make a string that shows the value of D1 in Hex and Decimal maybe binary
! "D1: $XXXXXXXX DDDDDDD"
: string-D1 ( cpu -- s )
    D1> string-dr "D1: " prepend ;

! lets make a string that shows the value of D2 in Hex and Decimal maybe binary
! "D2: $XXXXXXXX DDDDDDD"
: string-D2 ( cpu -- s )
    D2> string-dr "D2: " prepend ;

! lets make a string that shows the value of D3 in Hex and Decimal maybe binary
! "D3: $XXXXXXXX DDDDDDD"
: string-D3 ( cpu -- s )
    D3> string-dr "D3: " prepend ;

! lets make a string that shows the value of D4 in Hex and Decimal maybe binary
! "D4: $XXXXXXXX DDDDDDD"
: string-D4 ( cpu -- s )
    D4> string-dr "D4: " prepend ;

! lets make a string that shows the value of D5 in Hex and Decimal maybe binary
! "D5: $XXXXXXXX DDDDDDD"
: string-D5 ( cpu -- s )
    D5> string-dr "D5: " prepend ;

! lets make a string that shows the value of D6 in Hex and Decimal maybe binary
! "D6: $XXXXXXXX DDDDDDD"
: string-D6 ( cpu -- s )
    D6> string-dr "D6: " prepend ;

! lets make a string that shows the value of D7 in Hex and Decimal maybe binary
! "D7: $XXXXXXXX DDDDDDD"
: string-D7 ( cpu -- s )
    D7> string-dr "D7: " prepend ;

! Build the DX strings into an array
: string-DX ( cpu -- array )
    0 7 [a,b]
    [
        number>string "string-D" prepend
        "freescale.68000" lookup-word
        1quotation [ dup ] dip call( cpu -- str )
    ] map [ drop ] dip ;


! lets make a string that shows the value of D0 in Hex and Decimal maybe binary
! "A0: $XXXXXXXX DDDDDDD"
: string-A0 ( cpu -- s )
    [ A0> >hex-pad8 ] [ A0> >dec-pad9 ] bi
    [ " " append ] dip append "A0: " prepend ;

 ! lets make a string that shows the value of D1 in Hex and Decimal maybe binary
! "A1: $XXXXXXXX DDDDDDD"
: string-A1 ( cpu -- s )
    [ A1> >hex-pad8 ] [ A1> >dec-pad9 ] bi
    [ " " append ] dip append "A1: " prepend ;

! lets make a string that shows the value of D2 in Hex and Decimal maybe binary
! "A2: $XXXXXXXX DDDDDDD"
: string-A2 ( cpu -- s )
    [ A2> >hex-pad8 ] [ A2> >dec-pad9 ] bi
    [ " " append ] dip append "A2: " prepend ;

! lets make a string that shows the value of D3 in Hex and Decimal maybe binary
! "A3: $XXXXXXXX DDDDDDD"
: string-A3 ( cpu -- s )
    [ A3> >hex-pad8 ] [ A3> >dec-pad9 ] bi
    [ " " append ] dip append "A3: " prepend ;

! lets make a string that shows the value of D4 in Hex and Decimal maybe binary
! "D4: $XXXXXXXX DDDDDDD"
: string-A4 ( cpu -- s )
    [ A4> >hex-pad8 ] [ A4> >dec-pad9 ] bi
    [ " " append ] dip append "A4: " prepend ;

! lets make a string that shows the value of D5 in Hex and Decimal maybe binary
! "A5: $XXXXXXXX DDDDDDD"
: string-A5 ( cpu -- s )
    [ A5> >hex-pad8 ] [ A5> >dec-pad9 ] bi
    [ " " append ] dip append "A5: " prepend ;

! lets make a string that shows the value of D6 in Hex and Decimal maybe binary
! "A6: $XXXXXXXX DDDDDDD"
: string-A6 ( cpu -- s )
    [ A6> >hex-pad8 ] [ A6> >dec-pad9 ] bi
    [ " " append ] dip append "A6: " prepend ;


! lets make a string that shows the value of D7 in Hex and Decimal maybe binary
! "A7: $XXXXXXXX DDDDDDD"
: string-A7 ( cpu -- s )
    [ A7> >hex-pad8 ] [ A7> >dec-pad9 ] bi
    [ " " append ] dip append "A7: " prepend ;

! Build the DX strings into an array
: string-AX ( cpu -- array )
    0 7 [a,b]
    [
        number>string "string-A" prepend
        "freescale.68000" lookup-word
        1quotation [ dup ] dip call( cpu -- str )
    ] map [ drop ] dip ;

: string-PC ( cpu -- $ )
  [ PC> >hex-pad8 ] [ PC> >dec-pad9 ] bi
  [ " " append ] dip append "PC: " prepend ;

      
