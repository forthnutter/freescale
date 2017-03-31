! disassembler for the 68000


USING:     accessors arrays kernel math sequences byte-arrays io
    math.parser math.ranges unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    words quotations math.bitwise models models.memory ascii ;

IN: freescale.68000.disassembler

TUPLE: disassembler opcodes ;

: opcode$-error ( cpu -- $ )
  drop
  "ILLEGAL-INSTRUCTION" ;

: extract-opcode ( instruct -- opcode )
  15 12 bit-range 4 bits ;

: (opcode$-0) ( array -- $ )
  opcode$-error ;


: (opcode$-1) ( array -- $ )
  opcode$-error ;


: (opcode$-2) ( array -- $ )
  opcode$-error ;


: (opcode$-3) ( array -- $ )
  opcode$-error ;


: (opcode$-4) ( array -- $ )
  opcode$-error ;


: (opcode$-5) ( array -- $ )
  opcode$-error ;


: (opcode$-6) ( array -- $ )
  opcode$-error ;


: (opcode$-7) ( array -- $ )
  opcode$-error ;


: (opcode$-8) ( cpu -- $ )
  opcode$-error ;


: (opcode$-9) ( cpu -- $ )
  opcode$-error ;


: (opcode$-A) ( cpu -- $ )
  opcode$-error ;


: (opcode$-B) ( cpu -- $ )
  opcode$-error ;


: (opcode$-C) ( cpu -- $ )
  opcode$-error ;


: (opcode$-D) ( cpu -- $ )
  opcode$-error ;


: (opcode$-E) ( cpu -- $ )
  opcode$-error ;


: (opcode$-F) ( cpu -- $ )
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
