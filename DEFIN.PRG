clear
@ 1,0 say "Program drukuje efinicje wyrobow gotowych na podstawie pliku defin.dbf"
@ 3,0 say "Obsluguje sciezke 1MAG"
plik:="\b_defin.txt"
tak=.f.
@ 10,0 say "Wykonac ?"
set cursor on
@ 10,12 get tak
read

if.not.tak
  set cursor off
  return
endif
tak=.f.
@ 12,0 say "Do pliku ?"
@ 12,12 get tak
read
set cursor off
set device to printer
set default to 1MAG
if tak
  set printer to &plik
endif
w=prow()
@ w,0 say "W Y R O B Y   G O T O W E  -  W Y K A Z   S K L A D N I K O W"
w=w+1
@ w,0 say "-------------------------------------------------------------"
w=w+3
use defin new
index on gnazwa+gkod to def_gnk
use defin index def_gnk
do while.not.eof()
  lgnazwa=gnazwa
  lgkod=gkod
  @ w,0 say gnazwa
  @ w,34 say gkod
  do while gnazwa=lgnazwa.and.gkod=lgkod
    w=w+1
	@ w,5 say snazwa
	@ w,40 say skod
	@ w,50 say silosc 
	@ w,63 say sjm
	skip
  enddo
  w=w+3
enddo
set device to screen
close
RETURN