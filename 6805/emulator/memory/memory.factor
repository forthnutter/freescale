! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors kernel math models sequences vectors
       freescale.6805.emulator.ports arrays ;


IN: freescale.6805.emulator.memory



CONSTANT: MEMSTART 0
CONSTANT: MEMSIZE 0xFFFF

TUPLE: cell < model ;

! make one cell or one memory location
: <cell> ( n -- cell )
    cell new-model ;

GENERIC: read ( object -- n )
GENERIC: write ( n object -- )

M: cell read value>> ;

M: cell write set-model ;

TUPLE: memory array ;


! PORTA  $0000 Port A
! PORTB  $0001 Port B
! PORTC  $0002 Port C
! PORTD  $0003 Port D
! DDRA   $0004 Data Direction Register A
! DDRB   $0005 Data Direction Register B
! DDRC   $0006 Data Direction Register C
! DDRD   $0007 Data Direction Register D
!        $0008
!        $0009
! SPCR   $000A SPI Control Register
! SPSR   $000B SPI Status Register
! SPDR   $000C SPI Data Register
! BAUD   $000D SCI Baud Rate Register
! SCCR1  $000E SCI Control Register 1
! SCCR2  $000F SCI Control Register 2
! SCSR   $0010 SCI Status Register
! SCDR   $0011 SCI Data Register
! TCR    $0012 Timer Control Register
! TSR    $0013 Timer Status Register
! ICRH   $0014 Input Capture Register High
! ICRL   $0015 Input Capture Register Low
! OCRH   $0016 Output Compare Register High
! OCRL   $0017 Output Compare Register Low
! TRH    $0018 Timer Register High
! TRL    $0019 Timer Register Low
! ATRH   $001A Alternate Timer Register High
! ATRL   $001B Alternate Timer Register Low
! EPR    $001C EPROM Porgramming
! COPRST $001D COP Reset Register
! COPCR  $001E COP Control Register


! need the cell
: memory-cell ( address memory -- cell/? )
    array>> ?nth ;


! now get the value from cell
: memory-cell-value ( cell -- value/? )
    dup cell? [ value>> ] [ drop f ] if ;


! read memory
: memory-read ( address memory -- data )
    memory-cell read ;


! write memory
: memory-write ( d address memory -- )
    memory-cell write ;

! write an array to memory
: memory-array-write ( array address memory -- )
    rot
    [
        -rot
        [ memory-write ] 2keep
        [ 1 + ] dip
    ] each 2drop ;

: <memory> ( -- memory )
    memory new
    0x10000 0 <array> [ <cell> ] map >>array ;

