! Exception routine


IN: freescale.68000.exception

TUPLE: exception reset address data trap ;



: <exception> ( -- exception )
    exception new ;
    