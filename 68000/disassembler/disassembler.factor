! disassembler for the 68000


USING:     accessors arrays kernel math sequences byte-arrays io
    math.parser math.ranges unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    words quotations math.bitwise models models.memory ascii
    freescale.68000.emulator ;

IN: freescale.68000.disassembler

TUPLE: disassembler opcodes ;

: opcode$-error ( cpu -- $ )
  drop
  "ILLEGAL-INSTRUCTION" ;

! : extract-opcode ( instruct -- opcode )
!  15 12 bit-range 4 bits ;

: (opcode$-0) ( array -- $ )
  break
  opcode$-error ;


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

: move-mode-seven$ ( reg array -- $ )
  swap ! get reg
  {
    { 0 [ drop "70" ] }
    { 1 [ drop "71" ] }
    [ drop drop "bad" ]
  } case ;

: move-rb-ea ( reg mode array -- $ )
  swap ! get mode
  {
    { 0 [ drop dregister$ ] }
    { 7 [ move-mode-seven$ ] }
    [ drop drop drop "bad" ]
  } case ;


: (opcode$-1) ( array -- $ )
  break
  [ "move.b " ] dip
  [ first move-source-reg ] keep
  [ first move-source-mode ] keep
  [ move-rb-ea ] keep [ append ] dip
  [ "," append ] dip
  [ first move-dest-reg ] keep
  [ first move-dest-mode ] keep
  [ move-rb-ea ] keep [ append ] dip drop ;



: (opcode$-2) ( array -- $ )
  break
  opcode$-error ;


: (opcode$-3) ( array -- $ )
  break
  opcode$-error ;


: (opcode$-4) ( array -- $ )
  break
  opcode$-error ;


: (opcode$-5) ( array -- $ )
  break
  opcode$-error ;


: (opcode$-6) ( array -- $ )
  break
  opcode$-error ;


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
