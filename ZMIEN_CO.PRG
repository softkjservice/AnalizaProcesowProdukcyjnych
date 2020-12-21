*******************************************************************************
* Funkcja umozliwia tworzenie i wydruk zestawienia pozycji przeznaczonych     *
* do zamiany z ukazaniem ich nowej nazwa. Tworzy plik zamian.dbf              *
*******************************************************************************
FUNCTION ZMIEN_CO()
local t[7],q[7]
public znazwa:=space(32),zkod:=space(7),zjm:=space(3)
t[1]:="nazwa_old"
t[2]:="kod_old"
t[3]:="nazwa_new"
t[4]:="kod_new"
t[5]:="jm_old"
t[6]:="jm_new"
t[7]:="sprzedany"
*for i=1 to 6
 * q[i]:=""
*next
if.not.file("zamian.dbf")
  zamian_tworz()
endif
clear
@ 21,0 say "OLD:"
@ 22,0 say "NEW:"
use zamian new
sel_zam=select()
set color to n/w,w/n
@ 0,0 say "                 Ustalanie nowych nazwa w archiwum programu  FIRMA              "
@ 24,0 say "    PgUp - magazyn    Dopisz    Popraw     Kasuj     dRukuj    Esc - rezygnuj   "
set color to
dbedit(1,0,19,78,t,"UF","",,,,chr(205))
clear
close all
RETURN

FUNCTION UF()
local lnazwa_old:=nazwa_old,lkod_old:=kod_old,ljm_old:=jm_old
local lnazwa_new:=nazwa_new,lkod_new:=kod_new,ljm_new:=jm_new
local last:=lastkey(),t[3],ek
lcolor:=setcolor()
t[1]:="mnaz"
t[2]:="mkod"
t[3]:="mjm"
@ 21,7 say lnazwa_old
@ 21,41 say lkod_old
@ 21,50 say ljm_old
@ 22,7 say lnazwa_new
@ 22,41 say lkod_new
@ 22,50 say ljm_new
do case
  case last=27
    return 0
  case last=82.or.last=114
    set device to printer
    w=prow()
	@ w,0 say "ZESTAWIENIE POZYCJI, KTORYCH NAZWY LUB KODY ULEGLY ZMIANIE"
	w=w+1
	@ w,0 say "Wydruk wykonano dnia:"
	@ w,23 say date()
	@ w,33 say "o godzinie:"	
	@ w,45 say time()
    w=w+1
	@ w,0 say "----------------------------------------------------------"
	w=w+3
    go top
	do while.not.eof()
	  @ w,0 say "Dotychczas ......"
	  @ w,19 say nazwa_old
	  @ w,54 say kod_old
      w=w+1
	  @ w,0 say "Po zmianie ......"
	  @ w,19 say nazwa_new
	  @ w,54 say kod_new	  
	  w=w+2
	  skip
	enddo
	eject
	set device to screen
    keyboard chr(205)
	return 2
  case last=68.or.last=100      &&Dopisz
    lnazwa_old=space(32)
	lkod_old=space(7)
	ljm_old=space(3)
	set cursor on
	@ 21,7 get lnazwa_old
	@ 21,41 get lkod_old
	@ 21,50 get ljm_old
	read
    if lastkey()=18
      save screen to ek
	  set default to 1mag
	  if file("mag_sum.dbf")
	    use mag_sum index sum_naz new
	  else
	    use magazyn index mag_naz new
	  endif
	  sel_mag=select()
      set color to n/w,w/n
	  @ 9,29 to 23,79 double
	  dbedit(10,30,22,78,t,"UM","",,,,chr(205))	
	  if lastkey()=13
	    lnazwa_old=znazwa
	    lkod_old=zkod
	    ljm_old=zjm
	  endif
	  select &sel_zam
	  setcolor(lcolor)
	  restore screen from ek
      @ 21,7 say lnazwa_old
      @ 21,41 say lkod_old
      @ 21,50 say ljm_old	  
      if lastkey()#27
	    lnazwa_new=lnazwa_old
	    lkod_new=lkod_old
	    ljm_new=ljm_old
	    @ 21,7 get lnazwa_old
	    @ 21,41 get lkod_old
	    @ 21,50 get ljm_old
	    @ 22,7 get lnazwa_new
	    @ 22,41 get lkod_new
	    @ 22,50 get ljm_new	  
	    read
	  endif	  
	else
      if lastkey()#27
	    lnazwa_new=lnazwa_old
	    lkod_new=lkod_old
	    ljm_new=ljm_old
	    @ 22,7 get lnazwa_new
	    @ 22,41 get lkod_new
	    @ 22,50 get ljm_new	  
	    read
	  endif	
	endif
	if lastkey()#27
	  append blank
	  replace nazwa_old with lnazwa_old,kod_old with lkod_old,jm_old with ljm_old
	  replace nazwa_new with lnazwa_new,kod_new with lkod_new,jm_new with ljm_new	  
	endif
	set cursor off
  case last=80.or.last=112     &&Popraw
	set cursor on
	@ 21,7 get lnazwa_old
	@ 21,41 get lkod_old
	@ 21,50 get ljm_old
    @ 22,7 get lnazwa_new
    @ 22,41 get lkod_new
    @ 22,50 get ljm_new	
	read
	if lastkey()#27
	  replace nazwa_old with lnazwa_old,kod_old with lkod_old,jm_old with ljm_old
	  replace nazwa_new with lnazwa_new,kod_new with lkod_new,jm_new with ljm_new	  
	endif
	set cursor off	
  case last=75.or.last=107     &&Kasuj	
    delete
	pack
	keyboard chr(205)
	return 2
endcase
RETURN 1

FUNCTION UM()
last=lastkey()
znazwa=mnaz
zkod=mkod
zjm=mjm
do case
  case last=27.or.last=13
    return 0
endcase
RETURN 1


FUNCTION ZAMIAN_TWORZ()
create nowa
append blank
replace field_name with "nazwa_old"
replace field_type with "C"
replace field_len with 32
append blank
replace field_name with "kod_old"
replace field_type with "C"
replace field_len with 7
append blank
replace field_name with "jm_old"
replace field_type with "C"
replace field_len with 3
append blank
replace field_name with "nazwa_new"
replace field_type with "C"
replace field_len with 32
append blank
replace field_name with "kod_new"
replace field_type with "C"
replace field_len with 7
append blank
replace field_name with "jm_new"
replace field_type with "C"
replace field_len with 3
append blank
replace field_name with "sprzedany"
replace field_type with "L"
replace field_len with 1
create zamian from nowa
use
erase nowa.dbf
RETURN nil
