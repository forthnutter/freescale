! Exception routine

USING: kernel ;

IN: freescale.68000.emulator.exception



TUPLE: exception program read instruction ;



: <exception> ( -- exception )
    exception new ;


! this changeds when reset happlens
: exception model-changed
  f >>program
  t >>read
  t >>instruction drop ;

  
