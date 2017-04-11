! disassembler for the 68000


USING:     accessors arrays kernel math sequences byte-arrays io
    math.parser math.ranges unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    words quotations math.bitwise models models.memory ascii
    freescale.68000.emulator ;

IN: freescale.68000.disassembler

TUPLE: disassembler opcodes ;


: >hex-pad8 ( d -- s )
    [ "$" ] dip >hex 8 CHAR: 0 pad-head append ;

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


: op-zero-status ( size array -- $ )
  swap
  {
    { 0 [ drop "CCR" ] }
    { 1 [ drop "SR" ] }
    [ drop drop "BAD SIZE"]
  } case ;

: op-zero-mode-seven ( size reg array -- $ )
  swap
  {
    { 4 [ op-zero-status ] }
    [ drop drop drop "BAD REG"]
  } case ;


: op-zero-ea ( size reg mode array -- $ )
  swap
  {
    { 0 [ drop [ drop ] dip  dregister$ ] }
    { 2 [ drop drop drop "2" ] }
    { 7 [ op-zero-mode-seven ] }
    [ drop drop drop drop "BAD MODE" ]
  } case ;

: ori-byte ( array -- $ )
  [ "ORI.B #$" ] dip
  [ second 8 bits >hex append "," append ] keep
  [ first 7 6 bit-range 2 bits ] keep
  [ first 2 0 bit-range 3 bits ] keep ! resister first
  [ first 5 3 bit-range 3 bits ] keep ! get mode
  [ op-zero-ea append ] keep drop ;

: ori-word ( array -- $ )
  [ "ORI.W #$" ] dip
  [ second >hex append "," append ] keep
  [ first 7 6 bit-range 2 bits ] keep
  [ first 2 0 bit-range 3 bits ] keep
  [ first 5 3 bit-range 3 bits ] keep
  [ op-zero-ea append ] keep drop ;

: (opcode$-0) ( array -- $ )
  break
  [ first 11 6 bit-range 6 bits ] keep swap
  {
    { 0 [ ori-byte ] }  ! ORI
    { 1 [ ori-word ] }  ! ORI
    { 2 [ drop "ANDI" ] } ! ANDI
    [ drop opcode$-error ]
  } case ;


: move-mode-seven$ ( reg array -- $ )
  swap ! get reg
  {
    { 0 [ drop "70" ] }
    { 1 [ [ "(" ] dip [ second ] keep third words-long >hex-pad8 append ").L" append ] }
    [ drop drop "bad" ]
  } case ;

: move-ea ( reg mode array -- $ )
  swap ! get mode
  {
    { 0 [ drop dregister$ ] }
    { 1 [ drop aregister$ ] }
    { 7 [ move-mode-seven$ ] }
    [ drop drop drop "bad" ]
  } case ;


: (opcode$-1) ( array -- $ )
  break
  [ "MOVE.B " ] dip
  [ first move-source-reg ] keep
  [ first move-source-mode ] keep
  [ move-ea ] keep [ append ] dip
  [ "," append ] dip
  [ first move-dest-reg ] keep
  [ first move-dest-mode ] keep
  [ move-ea ] keep [ append ] dip drop ;


: (opcode$-2) ( array -- $ )
  break
  [ "MOVE.L "] dip
  [ first move-source-reg ] keep
  [ first move-source-mode ] keep
  [ move-ea ] keep [ append ] dip
  [ first move-dest-reg ] keep
  [ first move-dest-mode ] keep
  [ move-ea ] keep [ append ] dip drop ;


: (opcode$-3) ( array -- $ )
  break
  opcode$-error ;


: (opcode$-4) ( array -- $ )
  break
  [ first ] keep swap
  {
    { 0x4E70 [ drop "RESET" ] }
    [ drop drop "BAD OPCODE 4" ]
  } case ;


: (opcode$-5) ( array -- $ )
  break
  opcode$-error ;


: op-branch ( disp cond array -- $ )
  swap
  {
    { 0 [ drop drop "0" ] }
    { 1 [ drop drop "1" ] }
    { 2 [ drop drop "2" ] }
    { 3 [ drop drop "3" ] }
    { 4 [ drop drop "4" ] }
    { 5 [ drop drop "5" ] }
    { 6 [ drop drop "6" ] }
    { 7 [ drop drop "7" ] }
    [ drop drop drop "BAD COND"]
  } case ;


: (opcode$-6) ( array -- $ )
  break
  [ first 7 0 bit-range 8 bits ] keep
  [ first 11 8 bit-range 4 bits ] keep
  [ op-branch ] keep drop ;


: (opcode$-7) ( array -- $ )
  break
  opcode$-error ;


: (opcode$-8) ( cpu -- $ )
  break
  opcode$-error ;


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


: (opcode$-E) ( cpu -- $ )
  break
  opcode$-error ;


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
