! Copyright (C) 2013 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!

USING: accessors byte-arrays combinators grouping io
       io.files io.files.info kernel math math.order math.parser sequences
       tools.continuations io.encodings.binary ;

IN: freescale.binfile


: binfile-size ( path -- size )
    file-info size>> ;

! make structure to store the lines of data
: <binfile> ( path -- binarray )
    [ exists? ] keep swap
    [
        [ binfile-size ] keep swap
        [ binary ] dip [ read ] curry with-file-reader
    ]
    [ ] if ;

