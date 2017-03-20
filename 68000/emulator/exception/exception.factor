! Exception routine

USING: kernel ;

IN: freescale.68000.emulator.exception

TUPLE: exception reset address data trap ;



: <exception> ( -- exception )
    exception new ;
