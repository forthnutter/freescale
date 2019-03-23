! disassembler for the 68000


USING:     accessors arrays kernel math sequences byte-arrays io
    math.parser math.ranges unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    words quotations math.bitwise models models.memory ascii
    freescale.68000.emulator ;

IN: freescale.68000.disassembler

TUPLE: disassembler opcodes ;


: >hex-pad8 ( d -- s )
    [ "$" ] dip >hex 8 CHAR: 0 pad-head >upper append ;

: >hex-pad4 ( d -- $ )
  [ "$" ] dip >hex 4 CHAR: 0 pad-head >upper append ;

: >hex-pad2 ( d -- $ )
  [ "$" ] dip >hex 2 CHAR: 0 pad-head >upper append ;

: opcode$-error ( cpu -- $ )
  drop
  "ILLEGAL-INSTRUCTION" ;



: dregister$ ( d -- $ )
  {
    { 0 [ "D0" ] }
    { 1 [ "D1" ] }
    { 2 [ "D2" ] }
    { 3 [ "D3" ] }
    { 4 [ "D4" ] }
    { 5 [ "D5" ] }
    { 6 [ "D6" ] }
    { 7 [ "D7" ] }
    [ drop f ]
  } case ;



: aregister$ ( d -- $ )
  {
    { 0 [ "A0" ] }
    { 1 [ "A1" ] }
    { 2 [ "A2" ] }
    { 3 [ "A3" ] }
    { 4 [ "A4" ] }
    { 5 [ "A5" ] }
    { 6 [ "A6" ] }
    { 7 [ "A7" ] }
    [ drop f ]
  } case ;



: >long< ( wh wl -- l )
    [ 16 bits 16 shift ] dip 16 bits bitor ;


: op-zero-size ( array -- n )
  first 7 6 bit-range 2 bits ;

: op-zero-reg ( array -- n )
  first 2 0 bit-range 3 bits ;

: op-zero-status ( array -- $ )
  op-zero-size
  {
    { 0 [ "CCR" ] }
    { 1 [ "SR" ] }
    [ drop "BAD SIZE" ]
  } case ;

: op-zero-mode-seven ( array -- $ )
  [ op-zero-reg ] keep swap
  {
    { 0 [ drop "ABS.W" ] }
    { 1 [ drop "ABS.L" ] }
    { 4 [ op-zero-status ] }
    [ drop drop "BAD REG"]
  } case ;




: op-zero-mode ( array -- n )
  first 5 3 bit-range 3 bits ;

: op-zero-reg$ ( array -- $ )
  first 5 0 bit-range 6 bits
  {
    { 0 [ "D0" ] }
    { 1 [ "D1" ] }
    { 2 [ "D2" ] }
    { 3 [ "D3" ] }
    { 4 [ "D4" ] }
    { 5 [ "D5" ] }
    { 6 [ "D6" ] }
    { 7 [ "D7" ] }
    { 16 [ "(A0)" ] }
    { 17 [ "(A1)" ] }
    { 18 [ "(A2)" ] }
    { 19 [ "(A3)" ] }
    { 20 [ "(A4)" ] }
    { 21 [ "(A5)" ] }
    { 22 [ "(A6)" ] }
    { 23 [ "(A7)" ] }
    { 24 [ "(A0)+" ] }
    { 25 [ "(A1)+" ] }
    { 26 [ "(A2)+" ] }
    { 27 [ "(A3)+" ] }
    { 28 [ "(A4)+" ] }
    { 29 [ "(A5)+" ] }
    { 30 [ "(A6)+" ] }
    { 31 [ "(A7)+" ] }
    [ drop "?"]
  } case ;

: op-zero-ea ( array -- $ )
  [ op-zero-mode ] keep
  swap
  {
    { 0 [ op-zero-reg dregister$ ] }
    { 2 [ op-zero-reg aregister$ ] }
    { 7 [ op-zero-mode-seven ] }
    [ drop drop "BAD MODE" ]
  } case ;

: ori-byte ( array -- $ )
  [ "ORI.B #$" ] dip
  [ second 8 bits >hex append "," append ] keep
  [ op-zero-ea append ] keep drop ;

: ori-word ( array -- $ )
  [ "ORI.W #$" ] dip
  [ second >hex append "," append ] keep
  [ op-zero-ea append ] keep drop ;

: andi-long ( array -- $ )
  [ "ANDI.L #$" ] dip
  [ second ] keep [ third ] keep [ >long<  >hex append "," append ] dip
  op-zero-ea append ;

: andi-byte ( array -- $ )
  [ "ANDI.B #$" ] dip
  [ second ] keep [ >hex append "," append ] dip
  op-zero-ea append ;

: (opcode$-0) ( array -- $ )
  [ first 11 6 bit-range 6 bits ] keep swap
  {
    { 0 [ ori-byte ] }  ! ORI
    { 1 [ ori-word ] }  ! ORI
    { 2 [ drop "ANDI.B" ] } ! ANDI
    { 0x06 [ drop "BCLR" ] }
    { 0x08 [ andi-byte ] }
    { 10 [ andi-long ] }
    [ drop opcode$-error ]
  } case ;


: move-mode-seven$ ( reg array -- $ )
  swap ! get reg
  {
    { 0 [ drop "70" ] }
    { 1 [ [ "(" ] dip [ second ] keep third words-long >hex-pad8 append ").L" append ] }
    { 4 [ [ "#" ] dip [ second ] keep third words-long >hex-pad8 append ] }
    [ drop drop "bad" ]
  } case ;



: move-mode-six$ ( reg array -- $ )
  [ second 7 0 bit-range 8 >signed number>string "(" append ] keep
  [ aregister$ ] 2dip [ prepend "," append ] dip
  [ second 15 bit? ] keep swap
  [
    [ second 14 12 bit-range aregister$ append ] keep
  ]
  [
    [ second 14 12 bit-range dregister$ append ] keep
  ] if
  second 15 bit?
  [ ".L)" append ]
  [ ".W)" append ] if ;

: move-ea ( reg mode array -- $ )
  swap ! get mode
  {
    { 0 [ drop dregister$ ] }
    { 1 [ drop aregister$ ] }
    { 6 [ move-mode-six$ ] }
    { 7 [ move-mode-seven$ ] }
    [ drop drop drop "bad" ]
  } case ;


: (opcode$-1) ( array -- $ )
  [ "MOVE.B " ] dip
  [ first move-source-reg ] keep
  [ first move-source-mode ] keep
  [ move-ea ] keep [ append ] dip
  [ "," append ] dip
  [ first move-dest-reg ] keep
  [ first move-dest-mode ] keep
  [ move-ea ] keep [ append ] dip drop ;


: (opcode$-2) ( array -- $ )
  [ "MOVE.L "] dip
  [ first move-source-reg ] keep
  [ first move-source-mode ] keep
  [ move-ea "," append ] keep [ append ] dip
  [ first move-dest-reg ] keep
  [ first move-dest-mode ] keep
  [ move-ea ] keep [ append ] dip drop ;


: (opcode$-3) ( array -- $ )
  break
  opcode$-error ;

: jumps ( array -- $ )
  [ first 5 0 bit-range ] keep swap
  {
    { 0x10 [ drop "JMP (A0)" ] }
    [ drop drop "BAD OPCODE JUMP"]
  } case ;

: clr-byte ( array -- $ )
  [ first 5 0 bit-range ] keep swap
  {
    { 0 [ drop "CLR.B D0"] }
    { 1 [ drop "CLR.B D1"] }
    { 2 [ drop "CLR.B D2"] }
    { 3 [ drop "CLR.B D3"] }
    [ drop drop "BAD OPCODE"]
  } case ;

: (opcode$-4) ( array -- $ )
  [ first 15 6 bit-range ] keep swap
  {
    { 0x108 [ clr-byte ] }
    { 0x139 [ drop "RESET" ] }
    { 0x13B [ jumps ] }
    [ drop drop "BAD OPCODE 4" ]
  } case ;


: (opcode$-5) ( array -- $ )
  break
  opcode$-error ;

: >signed$ ( x n -- $ )
  [ bits ] keep 2dup 1 - bit?
  [ 2^ - number>string ]
  [ drop [ "+" ] dip number>string append ] if ;

: op-branch-displace ( disp array -- $ )
  swap
  {
    { 0 [ [ ".W " ] dip second 16 >signed$ append ] }
    { 0xff [ drop ".L" ] }
    [ drop drop ".B" ]
  } case ;

: op-branch ( disp cond array -- $ )
  swap
  {
    { 0 [ drop drop "0" ] }
    { 1 [ drop drop "1" ] }
    { 2 [ drop drop "BHI" ] }
    { 3 [ drop drop "BLS" ] }
    { 4 [ drop drop "BCC" ] }
    { 5 [ drop drop "BCS" ] }
    { 6 [ drop drop "BNE" ] }
    { 7 [ drop drop "BEQ" ] }
    { 8 [ drop drop "BVC" ] }
    { 9 [ drop drop "BVS" ] }
    { 10 [ [ "BPL" ] 2dip op-branch-displace append ] }
    { 11 [ [ "BMI" ] 2dip op-branch-displace append ] }
    { 12 [ drop drop "BGE" ] }
    { 13 [ drop drop "BLT" ] }
    { 14 [ drop drop "BGT" ] }
    { 15 [ drop drop "BLE" ] }
    [ drop drop drop "BAD COND" ]
  } case ;


: (opcode$-6) ( array -- $ )
  [ first 7 0 bit-range 8 bits ] keep
  [ first 11 8 bit-range 4 bits ] keep
  [ op-branch ] keep drop ;


: (opcode$-7) ( array -- $ )
  break
  opcode$-error ;


: op-8-or ( array -- $ )
  [ first ]


: (opcode$-8) ( array -- $ )
  break
  [ first 8 4 bit-range 3 bits ] keep swap
  {
    { 12 [ drop "DIVU" ] }
    { 16 [ drop "SBCD" ] }
    { 20 [ drop "PACK" ] }
    { 24 [ drop "UNPK" ] }
    { 28 [ drop "DIVS" ] }
    [ drop drop "OR" ]
  } case ;


: (opcode$-9) ( cpu -- $ )
  break
  opcode$-error ;


: (opcode$-A) ( cpu -- $ )
  break
  opcode$-error ;


: (opcode$-B) ( cpu -- $ )
  break
  opcode$-error ;


: (opcode$-C) ( cpu -- $ )
  break
  opcode$-error ;


: (opcode$-D) ( cpu -- $ )
  break
  opcode$-error ;

: ope-count ( cnt -- $ )
  [ 0 = ] keep swap
  [ drop 8 number>string ]
  [ number>string "#" prepend ] if ;

: ope-ir ( array -- $ )
  [ first 11 9 bit-range 3 bits ] keep
  first 5 bit?
  [ dregister$ ] [ ope-count ] if ;

: ope-dir ( array -- $ )
  first 8 bit?
  [ "L" ] [ "R" ] if ;

: ope-type ( array -- $ )
  [ first 4 3 bit-range 2 bits ] keep swap
  {
    { 0 [ [ "AS" ] dip ope-dir append ] }
    { 1 [ [ "LS" ] dip ope-dir append ] }
    { 2 [ drop "rote" ] }
    { 3 [ drop "rot" ] }
    [ drop drop "BAD TYPE" ]
  } case ;

: (opcode$-E) ( array -- $ )
  [ first 7 6 bit-range 2 bits ] keep swap ! get size to find the mode
  {
    {
      0 [
          [ ope-type ".B " append ] keep
          [ ope-ir append "," append ] keep
          first 2 0 bit-range 3 bits dregister$ append
        ]
    }
    { 1 [ drop "W" ] }
    {
      2 [
          [ ope-type ".L " append ] keep
          [ ope-ir append "," append ] keep
          first 2 0 bit-range 3 bits dregister$ append
        ]
    }
    [ drop drop "M" ]   ! memory mode
  } case ;


: (opcode$-F) ( cpu -- $ )
  break
  opcode$-error ;


! generate the string opcode array here
: opcode$-build ( dis -- )
    opcodes>> dup
    [
        [ drop ] dip
        [
            >hex >upper
            "(opcode$-" swap append ")" append
            "freescale.68000.disassembler" lookup-word 1quotation
        ] keep
        [ swap ] dip swap [ set-nth ] keep
    ] each-index drop ;

! disassemble an array of data
: disassemble-array ( array disasm -- $ )
    [ dup first ] dip
    [ extract-opcode ] dip opcodes>> nth call( array -- $ ) ;


: <disassembler> ( -- dasm )
  disassembler new
  16 [ opcode$-error ] <array> >>opcodes
  [ opcode$-build ] keep ;
