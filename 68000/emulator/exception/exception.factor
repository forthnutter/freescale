! Exception routine

USING: kernel accessors models ;

IN: freescale.68000.emulator.exception


CONSTANT: EXCEPTION-RESET 0
CONSTANT: EXCEPTION-RUNNING 1
CONSTANT: EXCEPTION-READY 2
CONSTANT: EXCEPTION-ACCESS-FAULT 8
CONSTANT: EXCEPTION-ADDRESS-ERROR 12
CONSTANT: EXCEPTION-ILLEGAL-INSTRUCTION 16
CONSTANT: EXCEPTION-UNKNOWN 32

TUPLE: exception model program read instruction ;



: <exception> ( value -- exception )
    exception new-model ;

: exception-set ( value exception -- )
  drop ;
