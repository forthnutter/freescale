! Copyright (C) 2016 Joseph Moschini.  a.k.a. forthnutter
! See http://factorcode.org/license.txt for BSD license.
!
USING:
    accessors arrays kernel math sequences byte-arrays io
    math.parser math.ranges unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    words quotations math.bitwise freescale.68000.emulator.exception
    freescale.68000.emulator.alu models ascii prettyprint ;


IN: freescale.68000.emulator


CONSTANT: CPU-RESET 0
CONSTANT: CPU-RUNNING 1
CONSTANT: CPU-READY 2
CONSTANT: ACCESS-FAULT 8
CONSTANT: CPU-ADDRESS-ERROR 12
CONSTANT: ILLEGAL-INSTRUCTION 16
CONSTANT: CPU-UNKNOWN 32




! Generic functions read and write memory
GENERIC: read-bytes ( n address cpu -- seq )
GENERIC: write-bytes ( seq address cpu -- )

! cpu name of class
! alu is Arithmatic Logic Unit
! ar is a set of address registers
! dr is a set of data registes
! pc is the program counter
! rx
! cashe instrcution cashe
! opcode array of opcodes call
! state of cpu
! reset is model to run all things that need to reset
! exception
! doublefault
! stop
! trace
! halt
! sync
TUPLE: cpu alu ar dr pc rx cashe opcodes state
    reset exception doublefault stop trace halt sync ;






: cpu-exception ( excep cpu -- )
    drop drop ;

: >PC ( d cpu -- )
    pc<< ;

! test data before putting value into PC
: >PC? ( d cpu -- )
    swap
    dup f = swap dup t = swap [ or ] dip swap
    [
        drop CPU-ADDRESS-ERROR >>state drop
    ] [ swap >PC ] if ;

: PC> ( cpu -- d )
    pc>> ;

! increment PC+2
: PC+ ( cpu -- )
  [ PC> 2 + ] keep >PC ;

! increment PC+4
: PC++ ( cpu -- )
  [ PC+ ] keep PC+ ;

! write to user sp
: >USP ( d cpu -- )
   ar>> 7 swap set-nth ;

! read the user sp
: USP> ( cpu -- d )
  ar>> 7 swap nth ;

! get user sp
! : USR> ( cpu -- d )
!   ar>> 7 swap nth ;

! write to supervisor sp
: >SSP ( d cpu -- )
   ar>> 8 swap set-nth ;

! read supervisor sp
: SSP> ( cpu -- d )
  ar>> 8 swap nth ;

! put value into A7
: >A7 ( d cpu -- )
    [ alu>> alu-mode? ] keep swap
    [ >SSP ] [ >USP ] if ;

! test data before putting value into A7
: >A7? ( d cpu -- )
    swap
    dup f = swap dup t = swap [ or ] dip swap
    [
        drop CPU-ADDRESS-ERROR >>state drop
    ] [ swap >A7 ] if ;


! get A7
: A7> ( cpu -- d )
  [ alu>> alu-mode? ] keep swap
  [ SSP> ] [ USP> ] if ;


! increment A7
: A7+ ( cpu -- )
  [ A7> 1 + ] keep >A7 ;

! decrement A7
: A7- ( cpu -- )
  [ A7> 1 - ] keep >A7 ;



: >A6 ( d cpu -- )
  ar>> 6 swap set-nth ;

: A6> ( cpu -- d )
  ar>> 6 swap nth ;

: >A5 ( d cpu -- )
  ar>> 5 swap set-nth ;

: A5> ( cpu -- d )
  ar>> 5 swap nth ;

: >A4 ( d cpu -- )
  ar>> 4 swap set-nth ;

: A4> ( cpu -- d )
  ar>> 4 swap nth ;

: >A3 ( d cpu -- )
  ar>> 3 swap set-nth ;

: A3> ( cpu -- d )
  ar>> 3 swap nth ;

: >A2 ( d cpu -- )
  ar>> 2 swap set-nth ;

: A2> ( cpu -- d )
  ar>> 2 swap nth ;

: >A1 ( d cpu -- )
  ar>> 1 swap set-nth ;

: A1> ( cpu -- d )
  ar>> 1 swap nth ;

: >A0 ( d cpu -- )
  ar>> 0 swap set-nth ;

: A0> ( cpu -- d )
  ar>> 0 swap nth ;

: >D7 ( d cpu -- )
  dr>> 6 swap set-nth ;

: D7> ( cpu -- d )
  dr>> 6 swap nth ;

: >D6 ( d cpu -- )
  dr>> 6 swap set-nth ;

: D6> ( cpu -- d )
  dr>> 6 swap nth ;

: >D5 ( d cpu -- )
  dr>> 5 swap set-nth ;

: D5> ( cpu -- d )
  dr>> 5 swap nth ;

: >D4 ( d cpu -- )
  dr>> 4 swap set-nth ;

: D4> ( cpu -- d )
  dr>> 4 swap nth ;

: >D3 ( d cpu -- )
  dr>> 3 swap set-nth ;

: D3> ( cpu -- d )
  dr>> 3 swap nth ;

: >D2 ( d cpu -- )
  dr>> 2 swap set-nth ;

: D2> ( cpu -- d )
  dr>> 2 swap nth ;

: >D1 ( d cpu -- )
  dr>> 1 swap set-nth ;

: D1> ( cpu -- d )
  dr>> 1 swap nth ;

: >D0 ( d cpu -- )
  dr>> 0 swap set-nth ;

: D0> ( cpu -- d )
  dr>> 0 swap nth ;

: SR> ( cpu -- d )
    alu>> alu-sr> ;

: >SR ( d cpu -- )
    alu>> >alu-sr ;


! split a word value to bytes
: word-bytes ( w -- a b )
    [ 15 8 bit-range ] keep 7 0 bit-range ;

! join two bytes into word
: bytes-word ( a b -- w )
    [ 8 bits 8 shift ] dip 8 bits bitor ;

! join two words into long
: words-long ( wh wl -- l )
    [ 16 bits 16 shift ] dip 16 bits bitor ;


! split a long into 4 bytes
: long-bytes ( l -- a b c d )
    [ 31 16 bit-range word-bytes ] keep
    15 0 bit-range word-bytes ;

! split long into words
: long-words ( l -- wh wl )
    [ 31 16 bit-range ] keep
    15 0 bit-range ;

: cpu-write-byte ( d address cpu --  )
    [ 1byte-array ] 2dip
    write-bytes ;

! write word to memory
: cpu-write-word ( d address cpu --  )
    [ word-bytes 2byte-array ] 2dip
    write-bytes ;


! write long to memory
: cpu-write-long ( dddd address cpu --  )
    [ long-bytes 4byte-array ] 2dip
    write-bytes ;


: bytes>number ( seq -- number )
    0 [ [ 8 shift ] dip bitor ] reduce ;

: cpu-read-byte ( address cpu -- d )
    [ 1 ] 2dip read-bytes bytes>number ;

: cpu-read-word ( address cpu -- d )
    [ 2 ] 2dip read-bytes bytes>number ;

: cpu-read-long ( address cpu -- d )
    [ 4 ] 2dip read-bytes bytes>number ;

: cpu-pc-read ( cpu -- d )
    [ PC> ] keep cpu-read-word ;

! returns array of words
: cpu-pc-read-array ( n cpu -- array )
    [ 0 swap 2 <range> >array ] dip
    [ [ PC> + ] curry map ] keep
    [ cpu-read-word ] curry map ;

: source-reg ( instruct -- regnum )
  2 0 bit-range 3 bits ;

: source-mode ( instruct -- mode )
  5 3 bit-range 3 bits ;

: dest-mode ( instruct -- mode )
    8 6 bit-range 3 bits ;

: dest-reg ( instruct -- reg )
  11 9 bit-range 3 bits ;

: extract-opcode ( instruct -- opcode )
  15 12 bit-range 4 bits ;

: move-dest-reg ( instruct -- regnum )
    11 9 bit-range 3 bits ;

: move-dest-mode ( instruct -- mode )
    8 6 bit-range 3 bits ;

: move-source-reg ( instruct -- regnum )
    2 0 bit-range 3 bits ;

: move-source-mode ( instruct -- mode )
    5 3 bit-range 3 bits ;

! generates a 6 bit mode value
: move-mode ( instruct -- mode )
  8 3 bit-range 6 bits ;


: cpu-read-dregister ( d cpu -- n )
  swap
  {
    { 0 [ D0> ] }
    { 1 [ D1> ] }
    { 2 [ D2> ] }
    { 3 [ D3> ] }
    { 4 [ D4> ] }
    { 5 [ D5> ] }
    { 6 [ D6> ] }
    { 7 [ D7> ] }
    [ drop drop f ]
  } case ;

: cpu-write-dregister ( d reg cpu -- )
  swap
  {
    { 0 [ >D0 ] }
    { 1 [ >D1 ] }
    { 2 [ >D2 ] }
    { 3 [ >D3 ] }
    { 4 [ >D4 ] }
    { 5 [ >D5 ] }
    { 6 [ >D6 ] }
    { 7 [ >D7 ] }
    [ drop drop drop ]
  } case ;


: cpu-read-aregister ( d cpu -- n )
  swap
  {
    { 0 [ A0> ] }
    { 1 [ A1> ] }
    { 2 [ A2> ] }
    { 3 [ A3> ] }
    { 4 [ A4> ] }
    { 5 [ A5> ] }
    { 6 [ A6> ] }
    { 7 [ A7> ] }
    [ drop drop f ]
  } case ;

: cpu-write-aregister ( d reg cpu -- )
  swap
  {
    { 0 [ >A0 ] }
    { 1 [ >A1 ] }
    { 2 [ >A2 ] }
    { 3 [ >A3 ] }
    { 4 [ >A4 ] }
    { 5 [ >A5 ] }
    { 6 [ >A6 ] }
    { 7 [ >A7 ] }
    [ drop drop drop ]
  } case ;


! get absolute word address read byte
: cpu-rb-aword ( cpu -- w )
  [ PC++ ] keep
  [ cashe>> second ] keep
  cpu-read-byte ;





: cpu-write-mode-one ( d reg cpu -- )
  swap
  {
    { 0 [ >A0 ] }
    { 1 [ >A1 ] }
    { 2 [ >A2 ] }
    { 3 [ >A3 ] }
    { 4 [ >A4 ] }
    { 5 [ >A5 ] }
    { 6 [ >A6 ] }
    { 7 [ >A7 ] }
    [ drop drop drop ]
  } case ;



: source-areg ( instruct -- regnum )
    2 0 bit-range 3 bits ;

: source-emode ( instruct -- mode )
    5 3 bit-range 3 bits ;


: absolute-word ( cpu -- w )
  [ cashe>> second ] keep
  cpu-read-long ;

! grabs the second and third word fro cashe to make a long address
: absolute-long ( cpu -- l )
  [ [ PC+ ] keep cashe>> second ] keep
  [ PC+ ] keep cashe>> third words-long ;

: mode-seven ( reg cpu -- data )
  swap
  {
    { 0 [ absolute-word ] }
    { 1 [ absolute-long ] }
    [ drop ]
  } case ;


: source-data ( cpu -- data )
  [ [ cashe>> first source-reg ] [ cashe>> first source-mode ] bi ] keep
  swap
  {
    { 0 [ cpu-read-dregister ] }
    { 7 [ [ mode-seven ] keep cpu-read-long ] }
    [ drop drop ]
  } case ;

! get effective addres register value
: effective-reg ( instruct -- regvlaue )
  2 0 bit-range 3 bits ;

! get effective address mode value
: effective-mode ( instruct -- modeval )
  5 3 bit-range 3 bits ;

! let do effective mode seven
: effective-mode-seven ( reg cpu -- data )
  swap
  {
    { 4 [ SR> ] }
    [ drop drop 0 ]
} case ;


! get effective address value mainly for opcode 0
: ea-read ( cpu -- data )
  [ [ cashe>> first effective-reg ] [ cashe>> first effective-mode ] bi ]  keep
  swap
  {
    { 0 [ cpu-read-dregister ] }
    { 7 [ effective-mode-seven ] }
    [ drop drop ]
  } case ;

! write to the effective address
: ea-write ( data cpu -- )
  [ [ cashe>> first effective-reg ] [ cashe>> first effective-mode ] bi ] keep
  swap
  {
      { 0 [ cpu-write-dregister ] }
      [ drop drop drop drop ]
  } case ;

: cpu-rb-along ( cpu -- b )
  [ PC+ ] keep
  [ cashe>> second ] keep
  [ PC+ ] keep
  [ cashe>> third words-long ] keep
  [ cpu-read-byte ] keep
  PC+ ;

! read byte
: cpu-0-rb-seven ( reg cpu -- d )
    swap
    {
        { 0 [ cpu-rb-aword ] }   ! absolute word
        { 1 [ cpu-rb-along ] }    ! absolute long
        { 4 [ SR> ] }
        [ drop drop f ]
    } case ;


: cpu-0-rb-ea ( reg mode cpu -- d )
  swap
  {
    { 0 [ cpu-read-dregister 8 bits ] }
    { 7 [ cpu-0-rb-seven ] }
    [ drop drop ]
  } case ;

: cpu-0-wb-ea ( data reg mode cpu -- )
  swap
  {
    { 0 [ cpu-write-dregister ] }
    { 1 [ cpu-write-mode-one ] }
    { 7 [ drop drop drop ] } ! cpu-wb-mode-seven ] }
    [ drop drop drop drop ]
  } case ;


: code0-ea-mode ( d -- mode )
  5 3 bit-range 3 bits ;

: code0-ea-reg ( d -- reg )
  2 0 bit-range 3 bits ;



! read byte
: cpu-0-rw-mode-seven ( reg cpu -- d )
    swap
    {
        { 0 [ cpu-rb-aword ] }   ! absolute word
        { 1 [ cpu-rb-along ] }    ! absolute long
        { 4 [ SR> ] }
        [ drop drop f ]
    } case ;

! read word of the effective address
: cpu-0-rw-ea ( reg mode cpu -- d )
  swap
  {
    { 0 [ cpu-read-dregister ] }
    { 7 [ cpu-0-rw-mode-seven ] }
    [ drop drop ]
  } case ;

: cpu-0-ww-mode-seven ( data reg cpu -- )
  swap
  {
    { 0 [ drop drop ] }
    { 1 [ drop drop ] } ! cpu-0-ww-along ] }
    { 4 [ >SR ] }
    [ drop drop drop ]
  } case ;



: cpu-0-ww-ea ( data reg mode cpu -- )
  swap
  {
    { 0 [ cpu-write-dregister ] }
    { 1 [ cpu-write-mode-one ] }
    { 7 [ cpu-0-ww-mode-seven ] }
    [ drop drop drop drop ]
  } case ;

  ! get the size from instruction
: cpu-size ( cpu -- size )
  cashe>> first 7 6 bit-range 2 bits ;


: destination-data ( cpu -- data )
  [ [ cashe>> first dest-reg ] [ cashe>> first dest-mode ] bi ] keep
  swap
  {
    { 0 [ cpu-read-dregister ] }
    { 7 [ mode-seven ] }
    [ drop drop ]
  } case ;

! set the condition code for move.b
: move-byte-condition ( data cpu -- )
  [ [ 7 bit? ] dip alu>> ?alu-n ] 2keep
  [ alu>> alu-v-clr ] keep
  [ alu>> alu-c-clr ] keep
  [ 8 bits 0 = ] dip alu>> ?alu-z ;


!
: write-destination-byte ( data cpu -- )
  [ [ cashe>> first dest-reg ] [ cashe>> first dest-mode ] bi ] keep
  swap
  {
    { 0 [ [ [ drop ] dip move-byte-condition ] 3keep cpu-write-dregister ] }
    { 7 [ [ [ drop ] dip move-byte-condition ] 3keep [ mode-seven ] keep cpu-write-byte ] }
    [ drop drop drop drop ]
  } case ;

: ori-ea-reg ( cpu -- data )
  cashe>> first 2 0 bit-range 3 bits ;

: ori-ea-mode ( cpu -- data )
  cashe>> first 5 3 bit-range 3 bits ;

: ori-mode-seven ( reg cpu -- data )
  swap
  {
    { 0 [ absolute-word ] }
    { 1 [ absolute-long ] }
    { 4 [ alu>> alu-sr ]  }
    [ drop ]
  } case ;

: ori-mode-seven-write ( d reg cpu -- )
  swap
  {
    { 4 [
          [ alu>> alu-mode? ] keep swap
          [ alu>> alu-sr-write ]
          [ exception>> 32 swap set-model drop ] if
        ]
    }
    [ drop drop drop ]
  } case ;

: ori-ea ( cpu -- data )
    [ [ ori-ea-reg ] [ ori-ea-mode ] bi ] keep
    swap
    {
      { 0 [ cpu-read-dregister ] }
      { 7 [ ori-mode-seven ] keep }
      [ drop drop ]
    } case ;

: ori-ea-write ( d cpu -- )
  [ [ ori-ea-reg ] [ ori-ea-mode ] bi ] keep
  swap
  {
    { 7 [ ori-mode-seven-write ] }
    [ drop drop drop drop  ]
  } case ;

: ori-source ( cpu -- data )
  [ cashe>> second ] keep cashe>> third words-long ;

: ori-source-word ( cpu -- data )
  cashe>> second ;


  ! get the size from instruction
: ori-source-size ( cpu -- size )
  cashe>> first 7 6 bit-range 2 bits ;


: ori-source-byte ( cpu -- data )
  ori-source-word 8 bits ;


: ori-dest-byte ( s cpu -- data )
  [ ori-ea ] keep
  alu>> alu-or-byte ;

: ori-dest-word ( s cpu -- data )
  [ ori-ea ] keep
  alu>> alu-or-word ;

: ori-dest-word-write ( d cpu -- )
  ori-ea-write ;

: cpu-ori ( cpu -- )
  [ ori-source-size ] keep swap ! size
  {
    { 0 [ [ ori-source-byte ] keep [ ori-dest-byte ] keep 2drop ] }     ! Byte
    { 1 [
          [ ori-source-word ] keep [ PC++ ] keep
          [ ori-dest-word ] keep
          ori-dest-word-write
        ]
    }     ! word
    { 2 [ drop ] }     ! long
    [ drop drop ]
  } case ;

! reset models
: cpu-reset-models ( cpu -- cpu )
    [ f ] dip [ reset>> set-model ] keep
    [ t ] dip [ reset>> set-model ] keep ;

: cpu-add-reset ( obj cpu -- cpu )
  [ reset>> add-connection ] keep ;


: cpu-andi-word-data ( cpu -- )
  [ cashe>> second 16 bits ] keep
  [ cashe>> first code0-ea-reg ] keep
  [ cashe>> first code0-ea-mode ] keep
  [ cpu-0-rw-ea ] keep
  [ bitor ] dip
  [ cashe>> first code0-ea-reg ] keep
  [ cashe>> first code0-ea-mode ] keep
  [ cpu-0-ww-ea ] keep
  PC++ ;

! read word of the effective address
: cpu-0-rl-ea ( reg mode cpu -- d )
  swap
  {
    { 0 [ cpu-read-dregister ] }
    { 7 [ cpu-0-rw-mode-seven ] }
    [ drop drop ]
  } case ;

: cpu-0-wl-ea ( data reg mode cpu -- )
  swap
  {
    { 0 [ cpu-write-dregister ] }
    { 1 [ cpu-write-mode-one ] }
    { 7 [ cpu-0-ww-mode-seven ] }
    [ drop drop drop drop ]
  } case ;



: cpu-andi-long-data ( cpu -- )
  [ PC+ ] keep
  [ cashe>> second 16 bits ] keep
  [ PC+ ] keep
  [ cashe>> third 16 bits ] keep
  [ words-long ] dip
  [ cashe>> first code0-ea-reg ] keep
  [ cashe>> first code0-ea-mode ] keep
  [ cpu-0-rl-ea ] keep
  [ alu>> alu-and-long ] keep
  [ cashe>> first code0-ea-reg ] keep
  [ cashe>> first code0-ea-mode ] keep
  [ cpu-0-wl-ea ] keep
  PC+ ;


: cpu-andi-byte-data ( cpu -- )
  [ PC+ ] keep
  [ cashe>> second 8 bits ] keep
  [ cashe>> first code0-ea-reg ] keep
  [ cashe>> first code0-ea-mode ] keep
  [ cpu-0-rl-ea ] keep
  [ alu>> alu-and-byte ] keep
  [ cashe>> first code0-ea-reg ] keep
  [ cashe>> first code0-ea-mode ] keep
  [ cpu-0-wl-ea ] keep
  PC+ ;


: cpu-andi ( cpu -- )
  [ cpu-size ] keep swap
  {
    { 0 [ cpu-andi-byte-data ] }  ! byte
    { 1 [ drop ] }  ! word
    { 2 [ cpu-andi-long-data ] }  ! long
    [ drop drop ]
  } case ;

: cpu-eori-byte-data ( cpu -- )
  [ PC+ ] keep
  [ cashe>> second 8 bits ] keep
  [ cashe>> first code0-ea-reg ] keep
  [ cashe>> first code0-ea-mode ] keep
  [ cpu-0-rl-ea ] keep
  [ alu>> alu-or-byte ] keep
  [ cashe>> first code0-ea-reg ] keep
  [ cashe>> first code0-ea-mode ] keep
  [ cpu-0-wl-ea ] keep
  PC+ ;

: cpu-eori ( cpu -- )
  [ cpu-size ] keep swap
  {
    { 0 [ cpu-eori-byte-data ] }
    [ drop drop ]
  } case ;


! the opcodes are divide into 16
! opcode 0 Bit Manipulation MOVEP Immediate
! ADDI ANDI
! BCHG BCLR BSET BTST
! CALLM CAS CAS2 CHK2 CMPI CMP2
! EORI
! MOVEP
! ORI
! RTM
! SUBI
: (opcode-0) ( cpu -- )
  break
  [ cashe>> first 11 8 bit-range 4 bits ] keep swap
  {
    { 0 [ cpu-ori ] }  ! ORI
    { 2 [ cpu-andi ] } ! ANDI
    { 10 [ cpu-eori ] } ! EORI

    [ drop drop ]
  } case ;



: cpu-move-rb-mode-seven ( reg cpu -- d )
  swap
  {
    { 0 [ drop f ] }
    { 1 [ cpu-rb-along ] }
    [ drop drop f ]
  } case ;

: cpu-move-rb-ea ( reg mode cpu -- d )
  swap
  {
    { 0 [ cpu-read-dregister 8 bits ] }
    { 7 [ cpu-move-rb-mode-seven ] }
    [ drop drop ]
  } case ;


: cpu-move-wb-along ( data cpu -- )
  [ PC+ ] keep
  [ cashe>> second ] keep
  [ PC+ ] keep
  [ cashe>> third words-long ] keep
  [ cpu-write-byte ] keep
  PC+ ;

: cpu-move-wb-mode-seven ( data reg cpu -- )
  swap
  {
    { 0 [ drop drop ] }
    { 1 [ cpu-move-wb-along ] }
    { 4 [ >SR ] }
    [ drop drop drop ]
  } case ;



: cpu-move-wb-ea ( data reg mode cpu -- )
  [ [ 2drop ] dip alu>> alu-byte-z ] 4keep
  [ [ 2drop ] dip alu>> alu-byte-n ] 4keep
  [ alu>> alu-v-clr ] keep
  [ alu>> alu-c-clr ] keep
  swap
  {
    { 0 [ cpu-write-dregister ] }
    { 1 [ cpu-write-mode-one ] }
    { 7 [ cpu-move-wb-mode-seven ] }
    [ drop drop drop drop ]
  } case ;




! Move Byte
: (opcode-1) ( cpu -- )
  [ source-data ] keep
  [ write-destination-byte ] keep  PC+ ;

: cpu-read-imm ( cpu -- l )
  [ PC+ ] keep
  [ cashe>> second ] keep
  [ PC+ ] keep
  [ cashe>> third words-long ] keep PC+ ;

: cpu-read-along ( cpu -- l )
  [ cpu-read-imm ] keep
  cpu-read-long ;

: cpu-move-rl-mode-seven ( reg cpu -- d )
  swap
  {
    { 0 [ drop f ] }
    { 1 [ cpu-read-along ] }
    { 4 [ cpu-read-imm ] }
    [ drop drop f ]
  } case ;

! get the 8 bit signed displacement
: move-displacement ( data -- d )
  7 0 bit-range 8 >signed ;

! get the word or long signed index value
: move-index ( cpu -- d )
  [
    [ cashe>> second ] keep swap
    [ 15 bit? ] keep swap ! test for address or data registers
    [
      ! true its address
      14 12 bit-range swap
      cpu-read-aregister
    ]
    [
      14 12 bit-range swap
      cpu-read-dregister
    ] if
  ] keep
  cashe>> second
  [ 11 bit? ] dip swap
  [ 32 >signed ]
  [ 16 >signed ] if ;


: move-disp-index ( reg cpu -- d )
  [ PC+ ] keep
  [ cpu-read-aregister ] keep
  [ cashe>> second move-displacement + ] keep
  [ move-index + ] keep [ PC+ ] keep cpu-read-long ;


: cpu-move-rl-ea ( reg mode cpu -- d )
  swap
  {
    { 0 [ cpu-read-dregister ] }
    { 6 [ move-disp-index ] }
    { 7 [ cpu-move-rl-mode-seven ] }
    [ drop drop drop f ]
  } case ;

: cpu-move-status ( data cpu -- )
  [ alu>> alu-long-z ] 2keep
  [ alu>> alu-long-n ] 2keep
  [ drop ] dip  ! don't data
  [ alu>> alu-v-clr ] keep
  alu>> alu-c-clr ;

: cpu-move-stat ( data reg cpu -- data reg cpu )
  [ [ drop ] dip cpu-move-status ] 3keep ;

: cpu-move-wl-ea ( data reg mode cpu -- )
  swap
  {
    { 0 [ cpu-move-stat cpu-write-dregister ] }
    { 1 [ cpu-write-mode-one ] }
    { 7 [ drop drop drop ] } ! cpu-wl-mode-seven ] }
    [ drop drop drop drop ]
  } case ;


! Move Long MOVE MOVEA
: (opcode-2) ( cpu -- )
    [ cashe>> first move-source-reg ] keep
    [ cashe>> first move-source-mode ] keep
    [ cpu-move-rl-ea ] keep
    [ cashe>> first move-dest-reg ] keep
    [ cashe>> first move-dest-mode ] keep
    [ cpu-move-wl-ea ] keep drop ;


! Move word MOVE MOVEA
: (opcode-3) ( cpu -- )
  break
  drop ;


: get-jmp-address ( mode reg cpu -- address )
  [ swap ] dip swap ! mode on top
  {
    { 2 [ cpu-read-aregister ] }
  } case ;


: clr-byte-ea ( mode reg cpu -- )
  [ swap ] dip swap ! mode on top
  {
    { 0 [ [ 0 ] 2dip cpu-write-dregister ] }
  } case ;

! Miscellaneous
! CHK
! CLR
: cpu-clr-byte ( cpu -- )
  [ cashe>> first source-emode ] keep
  [ cashe>> first source-areg ] keep
  [ clr-byte-ea ] keep PC+ ;

! EXT EXTB
! ILLEGAL
! JMP JSR
: cpu-jmp ( cpu -- )
  [ cashe>> first source-emode ] keep
  [ cashe>> first source-areg ] keep
  [ get-jmp-address ] keep
  >PC ;
! LEA LINK
! MOVEM
! NBCD NEG NEGX NOP NOT
! PACK PEA
! RESET RTD RTR RTS
! SWAP
! TAS TRAP TRAPV TST
! UNLK
: (opcode-4) ( cpu -- )
  [ cashe>> first 15 6 bit-range ] keep swap
  {
    { 0x108 [ cpu-clr-byte ] }
    { 0x139 [
              [ alu>> alu-mode? ] keep swap
              [ cpu-reset-models PC+ ]
              [ exception>> 32 swap set-model ] if
            ]
    }
    { 0x13B [ cpu-jmp ] }

    [ drop drop ]
  } case ;




: op-5-data ( cpu -- d )
  [ cashe>> first 11 9 bit-range ] keep
  cpu-read-dregister ;

: op-5-sub ( cpu -- )
  [ cashe>> first 7 6 bit-range ] keep swap
  {
    { 0 [ drop ] }
    { 1 [ drop ] }
    { 2 [
          [ op-5-data 32 bits ] keep
          [ ea-read ] keep
          [ alu>> alu-sub-long ] keep
          [ PC+ ] keep ea-write
        ]
    }
    [ drop drop ]
  } case ;


: op-5-add ( cpu -- )
  [ cashe>> first 7 6 bit-range ] keep swap
  {
    { 0 [
          [ op-5-data 8 bits ] keep
          [ ea-read ] keep
          [ alu>> alu-add-byte ] keep
          [ PC+ ] keep ea-write
        ] }
    { 1 [ drop ] }
    { 2 [ drop ] }
    [ drop drop ]
  } case ;


: op-5-00 ( cpu -- )
  [ cashe>> first 8 bit? ] keep swap
  [ op-5-sub ] [ op-5-add ] if ;


! ADDQ
! DBcc
! SUBQ SUBX Scc
! TRAPcc
: (opcode-5) ( cpu -- )
  [ cashe>> first 7 6 bit-range ] keep swap
  {
    { 3 [ drop ] }
    [ drop op-5-00 ]
  } case ;

! get branch condition
: branch-condition ( op -- con )
    11 8 bit-range 4 bits ;

: branch-displacement ( op -- disp )
    7 0 bit-range 8 bits ;

: cpu-word-displacement ( cpu -- )
  [ PC+ ] keep
  [ cashe>> second 16 >signed ] keep
  [ PC+ ] keep
  [ PC> + ] keep >PC ;

: cpu-byte-displacement ( cpu -- )
  [ PC+ ] keep
  [ cashe>> first 8 >signed ] keep
  [ PC> + ] keep >PC ;


: cpu-bmi ( cpu -- )
  [ cashe>> first branch-displacement ] keep swap
  {
    { 0
      [
        [ alu>> alu-n? ] keep swap not
        [ [ PC+ ] keep PC+  ] [ break cpu-word-displacement ] if
      ]
    }  ! 16 bit displacement
    [ drop drop ]   ! default is 8 bit displacement
  } case ;

: op-6-bne ( cpu -- )
  [ cashe>> first branch-displacement ] keep swap
  {
    { 0
      [
        [ alu>> alu-z? ] keep swap
        [ PC+ ] [ cpu-word-displacement ] if
      ]
    }  ! 16 bit displacement
    [
      drop
      [ alu>> alu-z? ] keep swap
      [ PC+ ] [ cpu-byte-displacement ] if
    ]   ! default is 8 bit displacement
  } case ;

: op-6-bra ( cpu -- )
  break
  [ cashe>> first branch-displacement ] keep swap
  {
    { 0 [ cpu-word-displacement ] }
    [ drop cpu-byte-displacement ]
  } case ;

! Bcc BSR BRA
: (opcode-6) ( cpu -- )
  [ cashe>> first branch-condition ] keep swap
  {
    { 0 [ op-6-bra ] }  ! BRA
    { 1 [ drop ] }  ! BSR
    { 2 [ drop ] }  ! BHI
    { 3 [ drop ] }  ! BLS
    { 4 [ drop ] }  ! BCC
    { 5 [ drop ] }  ! BCS
    { 6 [ op-6-bne ] }  ! BNE
    { 7 [ drop ] }  ! BEQ
    { 8 [ drop ] }  ! BVC
    { 9 [ drop ] }  ! BVS
    { 10 [ drop ] } ! BPL
    { 11 [ cpu-bmi ] } ! BMI
    { 12 [ drop ] } ! BGE
    { 13 [ drop ] } ! BLT
    { 14 [ drop ] } ! BGT
    { 15 [ drop ] } ! BLE
    [ drop drop ]
} case ;

! MOVEQ
: (opcode-7) ( cpu -- )
  break
  drop ;



: op-8-or-dr ( cpu -- dr )
  [ cashe>> first 11 9 bit-range 3 bits ] keep
  cpu-read-dregister ;

: op-8-write ( d cpu -- )
  [ cashe>> first 11 9 bit-range 3 bits ] keep
  cpu-write-dregister ;

: op-8-or ( cpu -- )
  [ cashe>> first 8 6 bit-range 3 bits ] keep swap
  {
    { 0 [ [ ea-read ]
          [ op-8-or-dr ]
          [ [ alu>> alu-or-byte ] keep ] tri
          [ ea-write ] keep PC+
        ]
    }
    { 1 [ drop ] }
    { 2 [ drop ] }
    { 4 [ drop ] }
    { 5 [ drop ] }
    { 6 [ drop ] }
    [ drop drop ]
  } case ;


! DIV DIVS DIVL DIVU DIVUL
! OR
! SBCD
! UNPK
: (opcode-8) ( cpu -- )
  break
  [ cashe>> first 8 4 bit-range 5 bits ] keep swap
  {
    { 12 [ drop ] }
    [ drop op-8-or ]
  } case ;

! SUB SUBA SUBX
: (opcode-9) ( cpu -- )
  break

  drop ;

! Reserved
: (opcode-A) ( cpu -- )
  break
  drop ;

! CMP CMPA CMPM
! EOR
: (opcode-B) ( cpu -- )
  break
  drop ;

! AND ABCD EXG MUL MULS MULU
: (opcode-C) ( cpu -- )
  break
  drop ;

! ADD ADDA ADDX
: (opcode-D) ( cpu -- )
  break
  drop ;

: cpu-shift-ir ( cpu -- ? )
  cashe>> first 5 bit? ;

: cpu-shift-rcount ( cpu -- reg )
  cashe>> first 11 9 bit-range 3 bits ;

: cpu-shift-dir ( cpu -- ? )
  cashe>> first 8 bit? ;

: cpu-shift-register ( cpu -- reg )
  cashe>> first 2 0 bit-range ;

: cpu-shift-type ( cpu -- type )
  cashe>> first 4 3 bit-range ;

: cpu-ls-byte ( cpu -- )
  [ PC+ ] keep
  [ cpu-shift-ir ] keep swap
  [
    [ cpu-shift-rcount ] keep
    [ cpu-read-dregister ] keep
    [ cpu-shift-register ] keep
    [
      [ alu>> ] keep
      cpu-shift-dir
      [ alu>> alu-lsl-byte ] [ alu>> alu-lsr-byte ] if
    ] keep
    [ cpu-shift-register ] keep
    cpu-write-dregister
  ]
  [
    [ cpu-shift-rcount ] keep
    [ cpu-shift-register ] keep
    [
      [ alu>> ] keep
      cpu-shift-dir
      [ alu-lsl-byte ] [ alu-lsr-byte ] if
    ] keep
    [ cpu-shift-register ] keep
    cpu-write-dregister
  ] if ;

: cpu-shift-byte ( cpu -- )
  [ cpu-shift-type ] keep swap ! what function
  {
    { 0 [ drop ] }  ! Arithmatic shift
    { 1 [ cpu-ls-byte ] }  ! Logical shift
    { 2 [ drop ] }  ! Rotate with extend
    [ drop  drop ]  ! Rotate
  } case ;

: cpu-ls-long ( cpu -- )
  drop ;


: cpu-as-long ( cpu -- )
  [ PC+ ] keep
  [ cpu-shift-ir ] keep swap
  [
    [ cpu-shift-rcount ] keep
    [ cpu-read-dregister ] keep
  ]
  [
    [ cpu-shift-rcount ] keep
  ] if
  [ cpu-shift-register ] keep
  [
    [ alu>> ] keep
    cpu-shift-dir
    [ alu-asl-long ] [ alu-asr-long ] if
  ] keep
  [ cpu-shift-register ] keep
  cpu-write-dregister ;

: cpu-shift-long ( cpu -- )
  [ cpu-shift-type ] keep swap
  {
    { 0 [ cpu-as-long ] }  ! Arithmatic Shift
    { 1 [ cpu-ls-long ] }  ! Logical Shift
    { 2 [ drop ] }  ! Rotate with extend
    [ drop drop ]   ! Rotate
  } case ;

! Shift Rotate Bit Field
! ASR
! LSL LSR
! ROL ROR ROXL ROXR
: (opcode-E) ( cpu -- )
  [ cpu-size ] keep swap
  {
    { 0 [ cpu-shift-byte ] }  ! byte
    { 1 [ drop ] }  ! word
    { 2 [ cpu-shift-long ] }  ! long
    [ drop drop ]   ! memory shift
  } case ;


! Coprocessor Interface
! cpBcc cpDBcc cpGEN cpScc cpTRAPcc
! MOVE16
: (opcode-F) ( cpu -- )
  break
  drop ;

! temp opcode
: not-implemented ( cpu -- )
  break
  drop ;

! generate the opcode array here
: opcode-build ( cpu -- )
    opcodes>> dup
    [
        [ drop ] dip
        [
            >hex >upper
            "(opcode-" swap append ")" append
            "freescale.68000.emulator" lookup-word 1quotation
        ] keep
        [ swap ] dip swap [ set-nth ] keep
    ] each-index drop ;




: reset-exception ( cpu -- )
    [ alu>> alu-s-set ] keep
    [ alu>> alu-t-clr ] keep
    [ alu>> 7 swap alu-imask-write ] keep
    [ 0 ] dip [ cpu-read-long ] keep [ >A7? ] keep
    [ 4 ] dip [ cpu-read-long ] keep [ >PC? ] keep
    cpu-reset-models
    CPU-RUNNING >>state drop ;

: reset ( cpu -- )
    CPU-RESET >>state drop ;

! execute one instruction
: execute-pc-opcodes ( cpu -- )
!    [ rom-pc-read ] keep
!    [ opcodes>> nth [ break ] prepose ] keep swap call( cpu -- )
        drop
;


! execute one instruction
: execute-pc-opcode ( cpu -- )
    [ 6 swap cpu-pc-read-array ] keep [ cashe<< ] keep [ cashe>> first ] keep
    [ extract-opcode ] dip [ opcodes>> nth ] keep swap call( cpu -- )
;


! Get the cpu state
: cpu-state ( cpu -- state )
    state>> ;

! I want to know if we are in Ready to execute state
: cpu-ready? ( cpu -- ? )
    cpu-state CPU-READY = ;

: cpu-running? ( cpu -- ? )
  cpu-state CPU-RUNNING = ;


! here we process exception
: cpu-exception-execute ( cpu -- )
    dup exception>> drop drop ;





! : cpu-address-exception ( cpu -- )
!  [ exception>> ] keep swap
!  [  ]
!  [
!    [ t >>exception drop ] keep
!
!    [ f >>exception drop ] keep
!  ] if ;


! Execute one cycles
: execute-cycle ( cpu -- )
    [ dup cpu-running? ]
    [
        dup cpu-state
        {
            { CPU-RESET [ dup reset-exception ] }   ! do reset cycle
            { CPU-ADDRESS-ERROR [ dup execute-pc-opcode ] }
            { CPU-UNKNOWN [ dup reset ] }
            { CPU-RUNNING [ dup execute-pc-opcode ] }
            [ drop CPU-UNKNOWN >>state ]
        } case
    ] do until drop ;

! Reset Process
: cpu-power ( reset cpu -- )
    [ 0 swap >USP ] keep
    [ dr>> [ drop 0 ] map ] keep swap >>dr
    [ ar>> [ drop 0 ] map ] keep swap >>ar
    swap [ reset ] [ drop ] if ;

: cpu-halted ( cpu -- ? )
  doublefault>> ;

! : process ( cpu -- )
!  [ cpu-halted ] keep swap
!  [
!    [ halt>> 0 set-model ] keep
!    [ sync>> 4 set-model ] keep
!  ]
!  [
!    [ 1 swap exception ] keep
!    [
!      [ stop>> ] keep swap
!      [
!        [ irq-sample ] keep
!        [ sync>> 2 set-model ] keep
!      ]
!      [
!        [ alu>> t? ] keep swap >>trace
!        execute-pc-opcode
!      ] if
!    ] keep
!  ] if ;


: new-cpu ( cpu -- cpu' )
  new
  <alu> >>alu
  8 f <array> >>dr
  9 f <array> >>ar
  [ f swap cpu-power ] keep
  16 [ not-implemented ] <array> >>opcodes
  [ opcode-build ] keep
  f <model> >>reset
  f <exception> >>exception
  f >>doublefault
  f >>stop
  f >>trace
  f <model> >>halt
  f <model> >>sync ;

: <cpu> ( -- cpu )
  cpu new-cpu ;
