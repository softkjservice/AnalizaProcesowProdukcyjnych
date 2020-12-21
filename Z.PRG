*******************************************************************************
* Program do korekty istniejacych baz                                         *
*******************************************************************************
local lbelka,tnaz[12],tlit[12],topis[12],lpoz:=1
lbelka:=" W Y B I E R Z "
for i=1 to 12
  tnaz[i]:=""
  tlit[i]:=""
  topis[i]:=""
next
tnaz[1]="Brak w magazynie        "
tnaz[2]="Usuniecie zwiel.normatyw"
tnaz[3]="Analiza normatyw        "
tnaz[4]="Definiowanie zastepnikow"
tnaz[5]="Zastepowanie            "
tnaz[6]="Sumowanie pozycji ident."
tnaz[7]="Magazyny na podst. kodu "
tnaz[8]="Korekra jednostek       "
tnaz[9]="Ceny BZ do magazynow    "
tnaz[10]="Wydruk dokumentow PZ    "
tnaz[11]="Wydruk dokumentow RW    "
tnaz[12]="Usuniecie zbednych defin"
topis[1]:="Dopisuje pozycje zarejestrowane w bo lub dokumentach i usuniete z magazynu"
topis[2]:="Usuwa definicje tego samego wyrobu rozniace sie kodem"
topis[3]:="Usuwa zbedne definicje"
topis[4]:="Edycja pliku ZAMIAN.DBF. Mozliwosc wydruku zastepnikow"
topis[5]:="Zastepowanie w bo, magazynach oraz dokumentach nazw, kodow i jednostek"
topis[6]:="Sumowanie pozycji o tej samej nazwie, kodzie i jednostce"
topis[7]:="Zdefiniowanie odpowiedniego magazynu (magaz) zgodnie z kodem"
topis[8]:="Korekta jednostek: SZT oraz 100 "
topis[10]:="Seryjny wydruk dok. PZ za miesiac bilansowany"
topis[11]:="Seryjny wydruk dok. RW za miesiac bilansowany"
topis[12]:="Program usuwa definicje wyrobow, ktorych nie odnajduje w magazynie"
  clear
  lpoz=men_pion(5,30,12,lbelka,tnaz,tlit,topis,lpoz)
if lastkey()=27
  return
endif
  do case
    case lpoz=1
      mag_brak()
    case lpoz=2	    
      normy()			  	  
    case lpoz=3	    
      def_analiz()	  	  
    case lpoz=4	    
      zmien_co()
    case lpoz=5
      zastap()	  
    case lpoz=6	    
      mag_sum()		
    case lpoz=7	    
      kod_mag()		
    case lpoz=8	    
      jednostki()		  	  
    case lpoz=9	    
      cen_bz_mag()		  	  	  
    case lpoz=10
	  pz_druk()
    case lpoz=11
	  rw_druk()	  
    case lpoz=12
	  def_czysc() 	  
  endcase
  close all
RETURN


*******************************************************************************
* Funkcja wyszukuje pozycje okreslone poprzez pola: nazwa_old oraz kod_old    *
* i zastepuje je zgodnie z opisem w polu nazwa_new oraz kod_new w pliku       *
* zamian.dbf. Obsluguje pliki: bo.dbf i magazyn.dbf dla magazynu glownego     *
* oraz wszystkich dostepnych podmagazynow, zakup.dbf, mmdok.dbf, przes1.dbf   *
* przes2.dbf. Kontroluje istnienie przeznaczonej do zmiany pozycji w plikach: *
* sprzedaz.dbf oraz ,jesli istnieje, w pliku \export98\1dok\sprzedaz.dbf.     *
*******************************************************************************
FUNCTION ZASTAP()
local sel_dok,sel_mag,sel_zam,lcykl:=1,lmag:=1
local ek,lbo:=.f.
use zamian new
sel_zam=select()
clear
@ 0,0 say "ZAMIANA NAZW W MAGAZYNACH I ARCHIWACH"
@ 2,0 say "Sprawdzanie mozliwosci dokonania zamiany ..............."
do while.t.
  do case
    case lcykl=1
	  set default to 1dok
      use sprzedaz new
      index on tnaz+tkod+tjm to t_naz3
      use sprzedaz index t_naz3	  
    case lcykl=2
      set default to \export98\1dok
      if file("sprzdaz.dbf")
	    use sprzedaz new
        index on tnaz+tkod+tjm to t_naz3
        use sprzedaz index t_naz_e	  		
	  endif  
  endcase
  sel_dok=select()
  select &sel_zam
  go top
  do while.not.eof()

    lnazwa_old=nazwa_old
    lkod_old=kod_old
    select &sel_dok
	if kj_nk_tseek(lnazwa_old,lkod_old)
      if.not.kj_gkom(8," Uwaga!  Pozycja zarejestrowana w dokumentach sprzedazy",;
	              lnazwa_old+lkod_old,"Dokonac zamiany",.t.,5)
	    select &sel_zam			  
	    replace sprzedany with .t.
      endif				    
    endif
	select &sel_zam
    skip 
  enddo
  select &sel_dok
  use
  lcykl=lcykl+1
  if lcykl>2
    exit
  endif
enddo
if.not.kj_gkom(8,"","Sprawdzenie wystepowania zdefiniowanych pozycji w dokumentach","sprzedazy zakonczone. Kontynuowac ?",.t.,5)
              
  close all
  return	 		  
endif			  
@ 2,58 say "+"
@ 3,0 say "Zamiana w magazynie glownym i podmagazynach ............"
lmag=1
do while.t.
  pmagdefault(lmag)
  if file("magazyn.dbf")
    use magazyn index mag_naz,mag_kod new
    sel_mag=select()
    if file("bo.dbf")
	  lbo=.t.
	  use bo index bo_naz,bo_kod new
	  sel_bo=select()
	else
	  lbo=.f.
	endif
  else
    save screen to ek
	kj_tkom(8,"","Dokonano zamiany nazw w",str(lmag-1,3),"magazynach.  Nacisnij dowolny klawisz",5) 
    restore screen from ek
	exit
  endif	
  select &sel_zam
  go top
  do while.not.eof()
    lnazwa_old=nazwa_old
	lkod_old=kod_old
	lnazwa_new=nazwa_new
	lkod_new=kod_new
	ljm_old=jm_old
	ljm_new=jm_new
@ 22,0 say "Magazyny "
@ 23,0 SAY LMAG
@ 24,0 say lnazwa_old+lkod_old+ljm_old
	select &sel_mag
	do while.t.
	  if kj_mseek(lnazwa_old,lkod_old,ljm_old)
	    replace mnaz with lnazwa_new,mkod with lkod_new,mjm with ljm_new
	  else
	    exit
	  endif
	enddo  
	if lbo
	  select &sel_bo
	  do while.t.
	    if kj_mseek(lnazwa_old,lkod_old,ljm_old)
	      replace mnaz with lnazwa_new,mkod with lkod_new,mjm with ljm_new
	    else
		  exit
		endif	
	  enddo
	endif
	select &sel_zam
    skip
  enddo
  select &sel_bo
  use
  select &sel_mag
  use
  lmag=lmag+1
enddo
@ 3,58 say "+"
@ 4,0 say "Zamiana w archiwach dokumentow ........................."
lcykl=1
do while.t.
@ 5,0 say lcykl
  do case
    case lcykl=1
	  if file("1dok\zakup.dbf")
	    set default to 1dok
		use zakup new
		index on tnaz+tkod to b_t_naz1
		use zakup index b_t_naz1
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [zakup.dbf] nie odnaleziony","Pomijam cykl nr 1","Nacisnij dowolny klawisz.",5)
	  endif
    case lcykl=2
	  if file("1dok\sprzedaz.dbf")
	    set default to 1dok
		use sprzedaz new
		index on tnaz+tkod to b_t_naz2
		use sprzedaz index b_t_naz2
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [sprzedaz.dbf] nie odnaleziony","Pomijam cykl nr 2","Nacisnij dowolny klawisz.",5)
	  endif
    case lcykl=3
	  if file("1dok\przes1.dbf")
	    set default to 1dok
		use przes1 new
		index on tnaz+tkod to b_t_naz3
		use przes1 index b_t_naz3
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [przes1.dbf] nie odnaleziony","Pomijam cykl nr 3","Nacisnij dowolny klawisz.",5)
	  endif	  
    case lcykl=4
	  if file("1dok\przes2.dbf")
	    set default to 1dok
		use przes2 new
		index on tnaz+tkod to b_t_naz4
		use przes2 index b_t_naz4
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [przes2.dbf] nie odnaleziony","Pomijam cykl nr 4","Nacisnij dowolny klawisz.",5)
	  endif
    case lcykl=5
	  if file("1dok\mmdok.dbf")
	    set default to 1dok
		use mmdok new
		index on tnaz+tkod to b_t_naz5
		use mmdok index b_t_naz5
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [mmdok.dbf] nie odnaleziony","Pomijam cykl nr 5","Nacisnij dowolny klawisz.",5)
	  endif	  
    case lcykl=6
	  if file("1dok\wz_tow.dbf")
	    set default to 1dok
		use wz_tow new
		index on tnaz+tkod to b_t_naz6
		use wz_tow index b_t_naz6
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [wz_tow.dbf] nie odnaleziony","Pomijam cykl nr 6","Nacisnij dowolny klawisz.",5)
	  endif
    case lcykl=7
	  if file("1dok\pz_tow.dbf")
	    set default to 1dok
		use pz_tow new
		index on tnaz+tkod to b_t_naz7
		use pz_tow index b_t_naz7
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [pz_tow.dbf] nie odnaleziony","Pomijam cykl nr 7","Nacisnij dowolny klawisz.",5)
	  endif	  
    case lcykl=8
	  if file("1dok\rwdok.dbf")
	    set default to 1dok
		use rwdok new
		index on tnaz+tkod to b_t_naz8
		use rwdok index b_t_naz8
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [rwdok.dbf] nie odnaleziony","Pomijam cykl nr 8","Nacisnij dowolny klawisz.",5)
	  endif	  
    case lcykl=9
	  if file("\export98\1dok\sprzedaz.dbf")
	    set default to \export98\1dok
		use sprzedaz new
		index on tnaz+tkod to b_t_naz9
		use sprzedaz index b_t_naz9
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [sprzedaz.dbf] nie odnaleziony","Pomijam cykl nr 2","Nacisnij dowolny klawisz.",5)
	  endif
  endcase
  select &sel_zam
  go top
  do while.not.eof()
    if.not.sprzedany
	  lnazwa_old=nazwa_old
	  lkod_old=kod_old
	  lnazwa_new=nazwa_new
	  lkod_new=kod_new
	  ljm_old=jm_old
	  ljm_new=jm_new
@ 22,0 say "Dokumenty"
@ 23,0 SAY LCYKL
@ 24,0 say lnazwa_old+lkod_old+ljm_old
	  select &sel_dok
	  do while.t.
	    if kj_tseek(lnazwa_old,lkod_old,ljm_old)
		  replace tnaz with lnazwa_new,tkod with lkod_new,tjm with ljm_new
        else
		  exit
		endif
	  enddo	
	  select &sel_zam
	  skip
	else
	  skip
	endif  
  enddo
  select &sel_dok
  use
  lcykl=lcykl+1
  if lcykl>9
    exit
  endif
enddo
@ 4,58 say "+"
@ 5,0 say "Zamiana w definicjach wyrobow .........................."
lcykl=1
do while.t.
  do case
    case lcykl=1
	  if file("1mag\defin.dbf")
	    set default to 1mag
		use defin new
		index on gnazwa+gkod to b_t_naz10
		use defin index b_t_naz10
		sel_def=select()
	  else
	    kj_tkom(8,"","Plik [defin.dbf] nie odnaleziony","Pomijam cykl nr 2","Nacisnij dowolny klawisz.",5)
	  endif
    case lcykl=2
	  if file("1mag\defin.dbf")
	    set default to 1mag
		use defin new
		index on snazwa+skod to b_t_naz11
		use defin index b_t_naz11
		sel_def=select()
	  else
	    kj_tkom(8,"","Plik [defin.dbf] nie odnaleziony","Pomijam cykl nr 2","Nacisnij dowolny klawisz.",5)
	  endif	  
  endcase

  select &sel_zam
  go top
  do while.not.eof()
    if.not.sprzedany
	  lnazwa_old=nazwa_old
	  lkod_old=kod_old
	  lnazwa_new=nazwa_new
	  lkod_new=kod_new
	  ljm_old=jm_old
	  ljm_new=jm_new
@ 22,0 say "Definicje"
@ 23,0 SAY LCYKL
@ 24,0 say lnazwa_old+lkod_old+ljm_old
	  select &sel_def
	  do case
	    case lcykl=1
	      do while.t.
	        if kj_dseek(lnazwa_old,lkod_old)
		      if lnazwa_old=lnazwa_new.and.lkod_old=lkod_new
			    exit
			  else
			    replace gnazwa with lnazwa_new,gkod with lkod_new
			  endif	
            else
		      exit
		    endif
	      enddo	
	    case lcykl=2
	      do while.t.
	        if kj_s_dseek(lnazwa_old,lkod_old,ljm_old)
		      replace snazwa with lnazwa_new,skod with lkod_new,sjm with ljm_new
            else
		      exit
		    endif
	      enddo			  
	  endcase
	  select &sel_zam
	  skip
	else
	  skip
	endif  
  enddo
  select &sel_def
  use
  lcykl=lcykl+1
  if lcykl>2
    exit
  endif
enddo
@ 5,58 say "+"
close all
RETURN .t.


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
index on nazwa_old to zamian
use zamian index zamian
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
    if.not.last=82
	  @ prow(),pcol() say chr(15)
	endif
	go top
	do while.not.eof()
	  if last=82
	    @ w,0 say "Dotychczas ......"
	    @ w,19 say nazwa_old
	    @ w,54 say kod_old
        w=w+1
	    @ w,0 say "Po zmianie ......"
	    @ w,19 say nazwa_new
	    @ w,54 say kod_new	  
	    w=w+2
	  else
	    @ w,0 say nazwa_old+"  "+kod_old+"  "+jm_old+"    "+nazwa_new+"  "+kod_new+"  "+jm_new
	    w=w+1
	  endif
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
	  seek alltrim(lnazwa_old)
      set color to n/w,w/n
	  @ 9,29 to 23,79 double
	  dbedit(10,30,22,78,t,"UM","",,,,chr(205))	
	  use
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
@ 23,40 say "Ilosc:"
@ 23,47 say mil picture "9999999.99"
@ 23,60 say "Cena:"
@ 23,67 say mcen_m picture "9999999.99"
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

*******************************************************************************
* Funkcja wyszukuje pozycje wystepujace w bo lub zarejestrowane w dokumentach *
* (procedurach), a nie wystepujace w magazynie zbiorczym (mag_sum.dbf         * 
*******************************************************************************
FUNCTION MAG_BRAK()
local sel_dok,sel_mag,sel_sum,lcykl:=1,lmag:=1
local ek,lbo:=.f.
pmagdefault(1)
use magazyn index mag_naz,mag_kod new
sel_mag=select()
use mag_sum index sum_naz,sum_kod new
sel_sum=select()
clear
@ 0,0 say "WYSZUKIWANIE POZYCJI USUNIETYCH Z MAGAZYNU"
@ 2,0 say "B O  ..................................................."
if file("bo.dbf")
  use bo new
  sel_bo=select()
  do while.not.eof()
    lmnaz=mnaz
	lmkod=mkod
	lmjm=mjm
	select &sel_sum
	if.not.kj_mseek(lmnaz,lmkod,lmjm)
	  if kj_gkom(8," Uwaga!  Pozycja nie odnalezona w magazynie",lmnaz+lmkod+lmjm,"BO, Wydrukowac ?",.t.,5)
	    set device to printer
		@ prow()+1,0 say "B O  .............."+lmnaz+"  "+lmkod+"  "+lmjm
		set device to screen 
	  endif
	  append blank
	  replace mnaz with lmnaz,mkod with lmkod,mjm with lmjm,magaz with 5	  
	  select &sel_mag
	  append blank
	  replace mnaz with lmnaz,mkod with lmkod,mjm with lmjm,magaz with 5
	endif
	select &sel_bo
    skip
  enddo
endif
@ 2,58 say "+"

@ 3,0 say "Przeszukiwanie archiwow dokumentow zarejestrowanych ...."
lcykl=1
do while.t.
@ 5,0 say lcykl
  do case
    case lcykl=1
	  if file("1dok\sprzedaz.dbf")
	    set default to 1dok
		use sprzedaz new
		index on tnaz+tkod+tjm to b_t_naz 
		use sprzedaz index b_t_naz 
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [sprzedaz.dbf] nie odnaleziony","Pomijam cykl nr 2","Nacisnij dowolny klawisz.",5)
	  endif  
    case lcykl=2
	  if file("\export98\1dok\sprzedaz.dbf")
	    set default to \export98\1dok
		use sprzedaz new
		index on tnaz+tkod+tjm to b_t_naz 
		use sprzedaz index b_t_naz 
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [sprzedaz.dbf] nie odnaleziony","Pomijam cykl nr 2","Nacisnij dowolny klawisz.",5)
	  endif
    case lcykl=3
	  if file("1dok\zakup.dbf")
	    set default to 1dok
		use zakup new
		index on tnaz+tkod+tkod+tjm to b_t_naz 
		use zakup index b_t_naz 
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [zakup.dbf] nie odnaleziony","Pomijam cykl nr 1","Nacisnij dowolny klawisz.",5)
	  endif

    case lcykl=4
	  if file("1dok\przes1.dbf")
	    set default to 1dok
		use przes1 new
		index on tnaz+tkod+tjm to b_t_naz 
		use przes1 index b_t_naz 
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [przes1.dbf] nie odnaleziony","Pomijam cykl nr 3","Nacisnij dowolny klawisz.",5)
	  endif	  
    case lcykl=5
	  if file("1dok\przes2.dbf")
	    set default to 1dok
		use przes2 new
		index on tnaz+tkod+tjm to b_t_naz 
		use przes2 index b_t_naz 
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [przes2.dbf] nie odnaleziony","Pomijam cykl nr 4","Nacisnij dowolny klawisz.",5)
	  endif
    case lcykl=6
	  if file("1dok\mmdok.dbf")
	    set default to 1dok
		use mmdok new
		index on tnaz+tkod+tjm to b_t_naz6
		use mmdok index b_t_naz6
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [mmdok.dbf] nie odnaleziony","Pomijam cykl nr 5","Nacisnij dowolny klawisz.",5)
	  endif	  
    case lcykl=7
	  if file("1dok\wz_tow.dbf")
	    set default to 1dok
		use wz_tow new
		index on tnaz+tkod+tjm to b_t_naz7
		use wz_tow index b_t_naz7
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [wz_tow.dbf] nie odnaleziony","Pomijam cykl nr 6","Nacisnij dowolny klawisz.",5)
	  endif
    case lcykl=8
	  if file("1dok\pz_tow.dbf")
	    set default to 1dok
		use pz_tow new
		index on tnaz+tkod+tjm to b_t_naz8
		use pz_tow index b_t_naz8
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [pz_tow.dbf] nie odnaleziony","Pomijam cykl nr 7","Nacisnij dowolny klawisz.",5)
	  endif	  
    case lcykl=9
	  if file("1dok\rwdok.dbf")
	    set default to 1dok
		use rwdok new
		index on tnaz+tkod+tjm to b_t_naz9
		use rwdok index b_t_naz9
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [rwdok.dbf] nie odnaleziony","Pomijam cykl nr 8","Nacisnij dowolny klawisz.",5)
	  endif	  
  endcase
  do while.not.eof()
    ltnaz=tnaz
	ltkod=tkod
	ltjm=tjm
	select &sel_sum
	if.not.kj_mseek(ltnaz,ltkod,ltjm)
	  if kj_gkom(8," Uwaga!  Pozycja nie odnalezona w magazynie",ltnaz+ltkod+ltjm,"Wydrukowac ?",.t.,5)
	    set device to printer
		do case
		  case lcykl=1
		    @ prow()+1,0 say "Sprzedaz - kraj ..."+ltnaz+"  "+ltkod+"  "+ltjm
		  case lcykl=2
		    @ prow()+1,0 say "Sprzedaz - export ."+ltnaz+"  "+ltkod+"  "+ltjm			
		  case lcykl=3
		    @ prow()+1,0 say "Zakupy ............"+ltnaz+"  "+ltkod+"  "+ltjm
		  case lcykl=4
		    @ prow()+1,0 say "Przes. - wydano ..."+ltnaz+"  "+ltkod+"  "+ltjm
		  case lcykl=5
		    @ prow()+1,0 say "Przes.-przyjeto ..."+ltnaz+"  "+ltkod+"  "+ltjm			
		  case lcykl=6
		    @ prow()+1,0 say "Produkcja ........."+ltnaz+"  "+ltkod+"  "+ltjm
		  case lcykl=7
		    @ prow()+1,0 say "W Z ..............."+ltnaz+"  "+ltkod+"  "+ltjm
		  case lcykl=8
		    @ prow()+1,0 say "P Z ..............."+ltnaz+"  "+ltkod+"  "+ltjm			
		  case lcykl=9
		    @ prow()+1,0 say "R W ..............."+ltnaz+"  "+ltkod+"  "+ltjm						
		endcase
		set device to screen 
	  endif
	  append blank
	  replace mnaz with ltnaz,mkod with ltkod,mjm with ltjm,magaz with 5	  
	  select &sel_mag
	  append blank
	  replace mnaz with ltnaz,mkod with ltkod,mjm with ltjm,magaz with 5
	endif
	select &sel_dok
	skip
  enddo
  select &sel_dok
  use
  lcykl=lcykl+1
  if lcykl>9
    exit
  endif
enddo
@ 3,58 say "+"
@ 4,0 say "Analiza pliku defin.dbf: wyroby i skladniki ............"
lcykl=1
do while.t.
  do case
    case lcykl=1
	  if file("1mag\defin.dbf")
	    set default to 1mag
		use defin new
		index on gnazwa+gkod to b_t_naz
		use defin index b_t_naz
		sel_def=select()
	    do while.not.eof()
          lgnazwa=gnazwa
		  lgkod=gkod
	      select &sel_sum
		  if.not.kj_nk_mseek(lgnazwa,lgkod)
	        if kj_gkom(8," Uwaga!  Pozycja nie odnalezona w magazynie",lgnazwa+lgkod," Wydrukowac ?",.t.,5)
	          set device to printer
		      @ prow()+1,0 say "Wyrob gotowy ......"+lgnazwa+"  "+lgkod
		      set device to screen 
	        endif
	        append blank
	        replace mnaz with lgnazwa,mkod with lgkod, magaz with 5			
	        select &sel_mag
	        append blank
	        replace mnaz with lgnazwa,mkod with lgkod, magaz with 5
	      endif
          select &sel_def
          skip
        enddo
	  else
	    kj_tkom(8,"","Plik [defin.dbf] nie odnaleziony","Pomijam cykl nr 2","Nacisnij dowolny klawisz.",5)
	  endif
    case lcykl=2
	  if file("1mag\defin.dbf")
	    set default to 1mag
		use defin new
		index on snazwa+skod to b_t_naz
		use defin index b_t_naz
		sel_def=select()
	    do while.not.eof()
          lsnazwa=snazwa
		  lskod=skod
		  lsjm=sjm
	      select &sel_sum
		  if.not.kj_mseek(lsnazwa,lskod,lsjm)
	        if kj_gkom(8," Uwaga!  Pozycja nie odnalezona w magazynie",lsnazwa+lskod+lsjm," Wydrukowac ?",.t.,5)
	          set device to printer
		      @ prow()+1,0 say "Skladnik .........."+lsnazwa+"  "+lskod+"  "+lsjm
		      set device to screen 
	        endif
	        append blank
	        replace mnaz with lsnazwa,mkod with lskod,mjm with lsjm, magaz with 5			
	        select &sel_mag
	        append blank
	        replace mnaz with lsnazwa,mkod with lskod,mjm with lsjm, magaz with 5
	      endif
          select &sel_def
          skip
        enddo

	  else
	    kj_tkom(8,"","Plik [defin.dbf] nie odnaleziony","Pomijam cykl nr 2","Nacisnij dowolny klawisz.",5)
	  endif	  
  endcase
  select &sel_def
  use
  lcykl=lcykl+1
  if lcykl>2
    exit
  endif
enddo
@ 4,58 say "+"
close all
RETURN NIL

FUNCTION POLWYR_DRUK()
set default to 1dok
use mmdok new
index on tnaz+tkod+tjm to b_tnaz
use mmdok index b_tnaz
set device to printer
w=prow()
@ w,0 say "Polwyroby:"
w=w+1
do while.not.eof()
  if .not. substr(tkod,1,2)="01"
    ltnaz=tnaz
    ltkod=tkod
    ltjm=tjm
	@ w,0 say ltnaz+"  "+ltkod+"  "+ltjm
	w=w+1
	do while tnaz=ltnaz.and.tkod=ltkod.and.tjm=ltjm
	  skip
	enddo
  else
    skip
  endif	
enddo
set device to screen 
RETURN nil

*******************************************************************************
* Funkcja sumuje identyczne pozycje w magazynach oraz bo                      *
*******************************************************************************
FUNCTION MAG_SUM()
local lnum:=1,sel_mag,sel_bo,lil_sum:=0,m_przed:=0,m_po:=0,b_przed:=0,b_po:=0
local m_przed_all:=0,m_po_all:=0,b_przed_all:=0,b_po_all:=0,lmag:=1
do while.t.
  pmagdefault(lmag)
  if file("magazyn.dbf")
    use magazyn new
	index on mnaz+mkod+mjm to b_nkj
	use magazyn index b_nkj,mag_naz,mag_kod
    sel_mag=select()
    if file("bo.dbf")
	  lbo=.t.
	  use bo new
	  index on mnaz+mkod+mjm to b_bo 
	  use bo index b_bo,bo_naz,bo_kod
	  sel_bo=select()
	else
	  lbo=.f.
	endif
  else
    save screen to ek
	kj_tkom(8,"","Dokonano zamiany nazw w",str(lmag-1,3),"magazynach.  Nacisnij dowolny klawisz",5) 
    restore screen from ek
	exit
  endif	
  select &sel_mag
  sum mil*mcen_m to m_przed
  go top
  do while.not.eof()
    @ 23,0 say lmag
    @ 24,0 say mnaz+mkod+mjm
    lmnaz=mnaz
	lmkod=mkod
	lmjm=mjm
	recno=recno()
	lil_sum=0
	lwar_sum=0
	do while mnaz=lmnaz.and.mkod=lmkod.and.mjm=lmjm
	  lil_sum=lil_sum+mil
	  lwar_sum=lwar_sum+mil*mcen_m
	  skip
	enddo
	go recno
	replace mil with lil_sum,mcen_m with lwar_sum/lil_sum
	skip
	do while mnaz=lmnaz.and.mkod=lmkod.and.mjm=lmjm
	  delete
	  skip
	enddo
  enddo
  pack
  sum mil*mcen_m to m_po
  if lbo
    select &sel_bo
    sum mil*mcen_m to b_przed
	do while.not.eof()
	  @ 24,0 say mnaz+mkod+mjm
      lmnaz=mnaz
	  lmkod=mkod
	  lmjm=mjm
	  recno=recno()
	  lil_sum=0
	  lwar_sum=0
	  do while mnaz=lmnaz.and.mkod=lmkod.and.mjm=lmjm
	    lil_sum=lil_sum+mil
		lwar_sum=lwar_sum+mil*mcen_m
	    skip
	  enddo
	  go recno
	  replace mil with lil_sum,mcen_m with lwar_sum/lil_sum
	  skip
	  do while mnaz=lmnaz.and.mkod=lmkod.and.mjm=lmjm
	    delete
	    skip
	  enddo
    enddo
	sum mil*mcen_m to b_po   
    pack	
	use
    b_przed_all=b_przed_all+b_przed
    b_po_all=b_po_all+b_po  	
  endif
  select &sel_mag
  use
  lmag=lmag+1
  m_przed_all=m_przed_all+m_przed
  m_po_all=m_po_all+m_po
enddo

clear
@ 10,0 say "                  Magazyny              BO"    
@ 11,0 say "Przed operacja:                           "    
@ 12,0 say "Po operacji   :                           "
@ 13,0 say "                ---------------------   --------------------"
@ 14,0 say " Roznica                                  "        
@ 11,18 say m_przed_all picture "9999999999.999"
@ 11,40 say b_przed_all picture "9999999999.999"
@ 12,18 say m_po_all picture "9999999999.999"
@ 12,40 say b_po_all picture "9999999999.999"
@ 14,18 say m_przed_all-m_po_all picture "9999999999.999"
@ 14,40 say b_przed_all-b_po_all picture "9999999999.999"
inkey(0)
RETURN nil


*******************************************************************************
* Funkcja ustala numer magazynu na podstawie kodu                             *
*******************************************************************************
FUNCTION KOD_MAG()
local lmag:=1
do while.t.
  pmagdefault(lmag)
  if file("magazyn.dbf")
    use magazyn new
    sel_mag=select()
    if file("bo.dbf")
	  lbo=.t.
	  use bo new
	  sel_bo=select()
	else
	  lbo=.f.
	endif
  else
    save screen to ek
	kj_tkom(8,"","Dokonano zamiany nazw w",str(lmag-1,3),"magazynach.  Nacisnij dowolny klawisz",5) 
    restore screen from ek
	exit
  endif	
  select &sel_mag
  do while.not.eof()
    do case 
	  case substr(mkod,1,2)="01"
	    replace magaz with 1
	  case substr(mkod,1,2)="02"
	    replace magaz with 2
	  case substr(mkod,1,2)="03"
	    replace magaz with 3
	  case substr(mkod,1,2)="04"
	    replace magaz with 4						
	  otherwise
	    kj_tkom(8," Uwaga! ","Brak zdefiniowanego kodu w pozycji",mnaz+mkod+mjm,"Uzupelnij i ponow probe",5)
    endcase
	skip
  enddo
  if lbo
    select &sel_bo
    do while.not.eof()
      do case 
	    case substr(mkod,1,2)="01"
	      replace magaz with 1
	    case substr(mkod,1,2)="02"
	      replace magaz with 2
	    case substr(mkod,1,2)="03"
	      replace magaz with 3
	    case substr(mkod,1,2)="04"
	      replace magaz with 4						
	    otherwise
	      kj_tkom(8," Uwaga! ","Brak zdefiniowanego kodu w pozycji",mnaz+mkod+mjm,"Uzupelnij i ponow probe",5)
      endcase
	  skip
    enddo  
	use
  endif
  select &sel_mag
  use
  lmag=lmag+1
enddo
RETURN nil


*******************************************************************************
* Funkcja zamienia jednostki zgodnie z zapamietanymi w pliku magazyn.dbf      *
* Koryguje ceny oraz ilosci                                                   *
* Obsluguje pliki: bo.dbf i magazyn.dbf dla magazynu glownego oraz wszystkich *
* dostepnych podmagazynow, zakup.dbf, mmdok.dbf, przes1.dbf, przes2.dbf       *
*******************************************************************************
FUNCTION JEDNOSTKI()
local sel_dok,sel_mag,sel_zam,lcykl:=1,lmag:=1
local ek,lbo:=.f.
local mag_przed:=0,mag_po:=0,sp_przed:=0,sp_po:=0,spe_przed:=0,spe_po:=0
local zak_przed:=0,zak_po:=0,przes1_przed:=0,przes1_po:=0,przes2_przed:=0
local przes2_po:=0,mm_przed:=0,mm_po:=0,wz_przed:=0,wz_po:=0,pz_przed:=0
local pz_po:=0,rw_przed:=0,rw_po:=0,bo_przed:=0,bo_po:=0
local smag_przed:=0,smag_po:=0,ssp_przed:=0,ssp_po:=0,sbo_przed:=0
local sbo_po:=0,def_przed:=0,def_po:=0

pmagdefault(1)
use magazyn index mag_naz new
sel_wzor=select()

if file("bo.dbf")    &&Zamiana jednostek w BO magazynu glownego
  use bo new  
  sel_bo=select()
    sum mil*mcen_m to bo_przed
    sbo_przed=sbo_przed+bo_przed	
	go top
    do while.not.eof()
      lmnaz=mnaz
	  lmkod=mkod
	  lmjm=mjm
      @ 22,0 say "B O"
      @ 24,0 say lmnaz+lmkod+lmjm
	  select &sel_wzor
      if kj_nk_mseek(lmnaz,lmkod)
	    bil_jm=mjm
	    select &sel_bo
        do case
	      case mjm="SZT".and.bil_jm="100"
		    replace mjm with bil_jm, mil with mil/100,mcen_m with mcen_m*100
		    replace mcen_d with mcen_d*100,mcen_h with mcen_h*100
	      case mjm="100".and.bil_jm="SZT"
		    replace mjm with bil_jm, mil with mil*100,mcen_m with mcen_m/100
		    replace mcen_d with mcen_d/100,mcen_h with mcen_h/100
	    endcase
	  else
	    if kj_gkom(8," Uwaga! Pozycja nie odnaleziona (er001)",lmnaz+lmkod+lmjm,"Wydrukowac ?",.t.,5)
          set device to printer
		  @ prow()+1,0 say lmnaz+lmkod+lmjm
		  set device to screen
        endif
	  endif
	  select &sel_bo
      skip
    enddo
    sum mil*mcen_m to bo_po
    sbo_po=sbo_po+bo_po	
    use
  endif

@ 3,0 say "Zamiana w magazynie glownym i podmagazynach ............"
lmag=2
do while.t.
  pmagdefault(lmag)
  if file("magazyn.dbf")
    use magazyn index mag_naz,mag_kod new
    sel_mag=select()
    if file("bo.dbf")
	  lbo=.t.
	  use bo index bo_naz,bo_kod new
	  sel_bo=select()
	else
	  lbo=.f.
	endif
  else
    save screen to ek
	kj_tkom(8,"","Dokonano zamiany nazw w",str(lmag-1,3),"magazynach.  Nacisnij dowolny klawisz",5) 
    restore screen from ek
	exit
  endif	
  select &sel_mag
  sum mil*mcen_m to mag_przed
  smag_przed=smag_przed+mag_przed
  go top
  do while.not.eof()
    lmnaz=mnaz
	lmkod=mkod
	lmjm=mjm
    @ 22,0 say "Magazyny "
    @ 23,0 SAY LMAG
    @ 24,0 say lmnaz+lmkod+lmjm
	select &sel_wzor
    if kj_nk_mseek(lmnaz,lmkod)
	  bil_jm=mjm
	  select &sel_mag
      do case
	    case mjm="SZT".and.bil_jm="100"
		  replace mjm with bil_jm, mil with mil/100,mcen_m with mcen_m*100
		  replace mcen_d with mcen_d*100,mcen_h with mcen_h*100
	    case mjm="100".and.bil_jm="SZT"
		  replace mjm with bil_jm, mil with mil*100,mcen_m with mcen_m/100
		  replace mcen_d with mcen_d/100,mcen_h with mcen_h/100
	  endcase
	else
	  if kj_gkom(8," Uwaga! Pozycja nie odnaleziona (er001)",lmnaz+lmkod+lmjm,"Wydrukowac ?",.t.,5)
        set device to printer
		@ prow()+1,0 say lmnaz+lmkod+lmjm
		set device to screen
      endif
	endif
	select &sel_mag
    skip
  enddo
  sum mil*mcen_m to mag_po
  smag_po=smag_po+mag_po
  use
  if lbo
    select &sel_bo
    sum mil*mcen_m to bo_przed
    sbo_przed=sbo_przed+bo_przed	
	go top
    do while.not.eof()
      lmnaz=mnaz
	  lmkod=mkod
	  lmjm=mjm
      @ 22,0 say "Magazyny "
      @ 23,0 SAY LMAG
      @ 24,0 say lmnaz+lmkod+lmjm
	  select &sel_wzor
      if kj_nk_mseek(lmnaz,lmkod)
	    bil_jm=mjm
	    select &sel_bo
        do case
	      case mjm="SZT".and.bil_jm="100"
		    replace mjm with bil_jm, mil with mil/100,mcen_m with mcen_m*100
		    replace mcen_d with mcen_d*100,mcen_h with mcen_h*100
	      case mjm="100".and.bil_jm="SZT"
		    replace mjm with bil_jm, mil with mil*100,mcen_m with mcen_m/100
		    replace mcen_d with mcen_d/100,mcen_h with mcen_h/100
	    endcase
	  else
	    if kj_gkom(8," Uwaga! Pozycja nie odnaleziona (er001)",lmnaz+lmkod+lmjm,"Wydrukowac ?",.t.,5)
          set device to printer
		  @ prow()+1,0 say lmnaz+lmkod+lmjm
		  set device to screen
        endif
	  endif
	  select &sel_bo
      skip
    enddo
    sum mil*mcen_m to bo_po
    sbo_po=sbo_po+bo_po	
    use
  endif
  lmag=lmag+1
enddo
@ 3,58 say "+"


@ 4,0 say "Zamiana w archiwach dokumentow ........................."
lcykl=1
do while.t.
@ 5,0 say lcykl
  do case
    case lcykl=1
	  if file("1dok\zakup.dbf")
	    set default to 1dok
		use zakup new
	    sum til*tcen_m to zak_przed
		index on tnaz+tkod to b_t_naz1
		use zakup index b_t_naz1
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [zakup.dbf] nie odnaleziony","Pomijam cykl nr 1","Nacisnij dowolny klawisz.",5)
	  endif
    case lcykl=2
	  if file("1dok\sprzedaz.dbf")
	    set default to 1dok
		use sprzedaz new
		sum til*tcen_m to sp_przed
		index on tnaz+tkod to b_t_naz2
		use sprzedaz index b_t_naz2
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [sprzedaz.dbf] nie odnaleziony","Pomijam cykl nr 2","Nacisnij dowolny klawisz.",5)
	  endif
    case lcykl=3
	  if file("1dok\przes1.dbf")
	    set default to 1dok
		use przes1 new
        sum til*tcen_m to przes1_przed
		index on tnaz+tkod to b_t_naz3
		use przes1 index b_t_naz3
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [przes1.dbf] nie odnaleziony","Pomijam cykl nr 3","Nacisnij dowolny klawisz.",5)
	  endif	  
    case lcykl=4
	  if file("1dok\przes2.dbf")
	    set default to 1dok
		use przes2 new
		sum til*tcen_m to przes2_przed
		index on tnaz+tkod to b_t_naz4
		use przes2 index b_t_naz4
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [przes2.dbf] nie odnaleziony","Pomijam cykl nr 4","Nacisnij dowolny klawisz.",5)
	  endif
    case lcykl=5
	  if file("1dok\mmdok.dbf")
	    set default to 1dok
		use mmdok new
		sum til*tcen_m to mm_przed
		index on tnaz+tkod to b_t_naz5
		use mmdok index b_t_naz5
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [mmdok.dbf] nie odnaleziony","Pomijam cykl nr 5","Nacisnij dowolny klawisz.",5)
	  endif	  
    case lcykl=6
	  if file("1dok\wz_tow.dbf")
	    set default to 1dok
		use wz_tow new
		sum til*tcen_m to wz_przed
		index on tnaz+tkod to b_t_naz6
		use wz_tow index b_t_naz6
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [wz_tow.dbf] nie odnaleziony","Pomijam cykl nr 6","Nacisnij dowolny klawisz.",5)
	  endif
    case lcykl=7
	  if file("1dok\pz_tow.dbf")
	    set default to 1dok
		use pz_tow new
		sum til*tcen_m to pz_przed
		index on tnaz+tkod to b_t_naz7
		use pz_tow index b_t_naz7
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [pz_tow.dbf] nie odnaleziony","Pomijam cykl nr 7","Nacisnij dowolny klawisz.",5)
	  endif	  
    case lcykl=8
	  if file("1dok\rwdok.dbf")
	    set default to 1dok
		use rwdok new
		sum til*tcen_m to rw_przed
		index on tnaz+tkod to b_t_naz8
		use rwdok index b_t_naz8
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [rwdok.dbf] nie odnaleziony","Pomijam cykl nr 8","Nacisnij dowolny klawisz.",5)
	  endif	  
    case lcykl=9
	  if file("\export98\1dok\sprzedaz.dbf")
	    set default to \export98\1dok
		use sprzedaz new
		sum til*tcen_m to spe_przed
		index on tnaz+tkod to b_t_naz9
		use sprzedaz index b_t_naz9
		sel_dok=select()
	  else
	    kj_tkom(8,"","Plik [sprzedaz.dbf] nie odnaleziony","Pomijam cykl nr 2","Nacisnij dowolny klawisz.",5)
	  endif
  endcase
  go top
  do while.not.eof()
    ltnaz=tnaz
	ltkod=tkod
	ltjm=tjm
    @ 22,0 say "Dokumenty"
    @ 23,0 SAY LCYKL
    @ 24,0 say ltnaz+ltkod+ltjm
	select &sel_wzor
    if kj_nk_mseek(ltnaz,ltkod)
	  bil_jm=mjm
	  select &sel_dok
	  do while tnaz=ltnaz.and.tkod=ltkod
        do case
	      case tjm="SZT".and.bil_jm="100"
		    replace tjm with bil_jm, til with til/100,tcen_m with tcen_m*100
		    replace tcen with tcen*100
	      case tjm="100".and.bil_jm="SZT"
		    replace tjm with bil_jm, til with til*100,tcen_m with tcen_m/100
		    replace tcen with tcen/100
	    endcase
	    skip
	  enddo
	else
	  if kj_gkom(8," Uwaga! Pozycja nie odnaleziona (er002)",ltnaz+ltkod+ltjm,"Wydrukowac ?",.t.,5)
        set device to printer
		@ prow()+1,0 say ltnaz+ltkod+ltjm
		set device to screen
      endif
	  select &sel_dok
	  skip
	endif
  enddo
  do case
    case lcykl=1
	  sum til*tcen_m to zak_po
    case lcykl=2
	  sum til*tcen_m to sp_po
    case lcykl=3
	  sum til*tcen_m to przes1_po
    case lcykl=4
	  sum til*tcen_m to przes2_po
    case lcykl=5
	  sum til*tcen_m to mm_po
    case lcykl=6
	  sum til*tcen_m to wz_po
    case lcykl=7
	  sum til*tcen_m to pz_po
    case lcykl=8
	  sum til*tcen_m to rw_po
    case lcykl=9
	  sum til*tcen_m to spe_po	  	  	  	  	  	  	  	  
  endcase
  use
  lcykl=lcykl+1
  if lcykl>9
    exit
  endif
enddo
@ 4,58 say "+"


@ 5,0 say "Zamiana w definicjach wyrobow .........................."
if file("1mag\defin.dbf")
  set default to 1mag
  use defin new
  sum silosc*scena to def_przed
  index on snazwa+skod to b_t_naz10
  use defin index b_t_naz10
  sel_def=select()
  do while.not.eof()
    lsnazwa=snazwa
    lskod=skod
	lsjm=sjm
	select &sel_wzor
    if kj_nk_mseek(lsnazwa,lskod)
	  bil_jm=mjm
	  select &sel_def
        do case
	      case sjm="SZT".and.bil_jm="100"
		    replace sjm with bil_jm, silosc with silosc/100,scena with scena*100
	      case sjm="100".and.bil_jm="SZT"
            replace sjm with bil_jm, silosc with silosc*100,scena with scena/100
	    endcase
	else
	  if kj_gkom(8," Uwaga! Pozycja nie odnaleziona (er002)",ltnaz+ltkod+ltjm,"Wydrukowac ?",.t.,5)
        set device to printer
		@ prow()+1,0 say ltnaz+ltkod+ltjm
		set device to screen
      endif
	endif	
    skip
  enddo
  sum silosc*scena to def_po
  @ 5,58 say "+"
else
	    kj_tkom(8,"","Plik [defin.dbf] nie odnaleziony","Pomijam cykl ","Nacisnij dowolny klawisz.",5)
endif

clear
@ 0,10 say "BO"
@ 0,20 say "Magazyny"
@ 0,30 say "Zakupy"
@ 0,40 say "Sprzedaz"
@ 0,50 say "Przes1"
@ 0,60 say "Przes2"
@ 10,10 say "Produkcja"
@ 10,20 say "WZ"
@ 10,30 say "PZ"
@ 10,40 say "RW"
@ 10,50 say "Sprzed_e"
@ 10,60 say "Definicje"
@ 1,0 say "Przed:"
@ 2,0 say "Po:"
@ 3,0 say "Roznica:"
@ 11,0 say "Przed:"
@ 12,0 say "Po:"
@ 13,0 say "Roznica:"
@ 1,10 say bo_przed picture "9999999999"
@ 1,20 say mag_przed picture "9999999999"
@ 1,30 say zak_przed picture "9999999999"
@ 1,40 say sp_przed picture "9999999999"
@ 1,50 say przes1_przed picture "9999999999"
@ 1,60 say przes2_przed picture "9999999999"
@ 11,10 say mm_przed picture "9999999999"
@ 11,20 say wz_przed picture "9999999999"
@ 11,30 say pz_przed picture "9999999999"
@ 11,40 say rw_przed picture "9999999999"
@ 11,50 say spe_przed picture "9999999999"
@ 11,60 say def_przed picture "9999999999"
@ 2,10 say bo_po picture "9999999999"
@ 2,20 say mag_po picture "9999999999"
@ 2,30 say zak_po picture "9999999999"
@ 2,40 say sp_po picture "9999999999"
@ 2,50 say przes1_po picture "9999999999"
@ 2,60 say przes2_po picture "9999999999"
@ 12,10 say mm_po picture "9999999999"
@ 12,20 say wz_po picture "9999999999"
@ 12,30 say pz_po picture "9999999999"
@ 12,40 say rw_po picture "9999999999"
@ 12,50 say spe_po picture "9999999999"
@ 12,60 say def_po picture "9999999999"
@ 3,10 say bo_przed - bo_po picture "9999999999"
@ 3,20 say mag_przed-mag_po picture "9999999999"
@ 3,30 say zak_przed-zak_po picture "9999999999"
@ 3,40 say sp_przed-sp_po picture "9999999999"
@ 3,50 say przes1_przed-przes1_po picture "9999999999"
@ 3,60 say przes2_przed-przes2_po picture "9999999999"
@ 13,10 say mm_przed-mm_po picture "9999999999"
@ 13,20 say wz_przed-wz_po picture "9999999999"
@ 13,30 say pz_przed-pz_po picture "9999999999"
@ 13,40 say rw_przed-rw_po picture "9999999999"
@ 13,50 say spe_przed-spe_po picture "9999999999"
@ 13,60 say def_przed-def_po picture "9999999999"
close all
RETURN .t.



*******************************************************************************
* Funkcja wprowadza  ceny z bz4 do magazynu i podmagazynow                    *
*******************************************************************************
FUNCTION CEN_BZ_MAG()
local lmag:=1,sel_mag,sel_bz
pmagdefault(1)
use bz4 index bz4_naz new
sel_bz=select()
do while.t.
  pmagdefault(lmag)
  if file("magazyn.dbf")
    use magazyn new
    sel_mag=select()
    if file("bo.dbf")
	  lbo=.t.
	  use bo new
	  sel_bo=select()
	else
	  lbo=.f.
	endif
  else
    save screen to ek
	kj_tkom(8,"","Dokonano zamiany nazw w",str(lmag-1,3),"magazynach.  Nacisnij dowolny klawisz",5) 
    restore screen from ek
	exit
  endif	
  select &sel_mag
  do while.not.eof()
    lmnaz=mnaz
	lmkod=mkod
	lmjm=mjm
	select &sel_bz
      if kj_mseek(lmnaz,lmkod,lmjm)
	    lmcen_m=mcen_m
		select &sel_mag
		replace mcen_m with lmcen_m,mcen_d with lmcen_m*1.2,mcen_h with lmcen_m*1.1
	  else
        kj_tkom(8," Uwaga! ","Brak pozycji w BZ*.dbf",mnaz+mkod+mjm,"",5)
	  endif
	select &sel_mag
	skip
  enddo
  if lbo
    select &sel_bo
    do while.not.eof()
      lmnaz=mnaz
	  lmkod=mkod
	  lmjm=mjm
	  select &sel_bz
        if kj_mseek(lmnaz,lmkod,lmjm)
	      lmcen_m=mcen_m
		  select &sel_bo
		  replace mcen_m with lmcen_m,mcen_d with lmcen_m*1.2,mcen_h with lmcen_m*1.1
	    else
          kj_tkom(8," Uwaga! ","Brak pozycji w BZ*.dbf",mnaz+mkod+mjm,"",5)
	    endif
	  select &sel_bo
	  skip
    enddo
  use
  endif
  select &sel_mag
  use
  lmag=lmag+1
enddo
RETURN nil
 
 
FUNCTION RW_DRUK()
local sel_sur,sel_magdef,ek,lmiesiac:=0
set default to 1dok
save screen to ek
@ 22,20 say "Za miesic:"
set cursor on
@ 22,32 get lmiesiac picture "999" range 0,12
read
if lastkey()=27
  restore screen from ek
  return
endif
set cursor off
use magdef new
sel_magdef=select()
use bilp_sur index bilp_sur new
sel_sur=select()
if lmiesiac#0
  set filter to month(tdat)=lmiesiac
  go top
endif
set device to printer
do while.not.eof()
  w=prow()
  lnum=0
  ltndok=tndok
  ltnkon=tnkon
  select &sel_magdef
  locate for mag_nr=ltnkon
  if found()
    lmag_nazwa=mag_nazwa
	lmag_miasto=mag_miasto
	lmag_ulica=mag_ulica
  else
    lmag_nazwa=space(15)
	lmag_miasto=space(15)
	lmag_ulica=space(15)
  endif
  select &sel_sur
  @ w,30 say "R  W     nr "+stuff(ltndok,11,2,"")
  w=w+1
  @ w,29 say replicate(chr(205),27)
  w=w+2
  @ w,5 say "Dotyczy dokumentu przerobu NR "+ltndok+"  "+"z dnia "
  @ w,61 say tdat 
  w=w+2
  @ w,5 say "Zwrot z magazynu nr "
* @ w,25 say ltnkon picture "999"
  @ w,30 say lmag_nazwa+"  "+lmag_miasto+"  "+lmag_ulica
  w=w+1
  @ w,5 say "surowcow i polwyrobow w postaci przetworzonej."
  w=w+3
  @ w,5 say "===================================================================="
  w=w+1
  @ w,5 say "| Lp.| Nazwa                           | Kod     | Ilosc     | Jm. |"
  w=w+1
  @ w,5 say "|====|=================================|=========|===========|=====|"
  w=w+1
  @ w,5 say "|                                                                  |"         
  w=w+1
  do while tndok=ltndok
    lnum=lnum+1
	@ w,5 say "|"
	@ w,6 say lnum picture "999"
	@ w,12 say tnaz
	@ w,46 say tkod
	@ w,55 say til picture "9999999.99"
	@ w,67 say tjm
	@ w,72 say "|"
	w=w+1
    skip
  enddo
  @ w,5 say "|                                                                  |"  
  w=w+1
  @ w,5 say "===================================================================="
  w=w+6
  @ w,5 say "     ....................                 ....................      "
  w=w+1
  @ w,5 say "        Wyroby przyjal                         Wyroby zdal"
  eject 
enddo
set device to screen
RETURN nil 



FUNCTION PZ_DRUK()
local sel_zak,sel_kon,sel_trah,ek,lmiesiac:=0
save screen to ek
@ 22,10 say "Za miesic:"
set cursor on
@ 22,22 get lmiesiac picture "999" range 0,12
read
if lastkey()=27
  restore screen from ek
  return
endif
set cursor off
set default to kontrah
use kontrah index kont_nr new
sel_kon=select()
use trah index trah_nr new
sel_trah=select()
set default to 1dok
use zakup index zakup new
sel_zak=select()
if lmiesiac#0
  set filter to month(tdat)=lmiesiac
  go top
endif
set device to printer
do while.not.eof()
  w=prow()
  lnum=0
  ltndok=tndok
  ltzewndok=tzewndok
  ltnkon=tnkon
  select &sel_kon
  seek ltnkon
  lfound=.f.
  if found()
    lfound=.t.
  else
    select &sel_trah
	seek ltkon
	if found()
	  lfound=.f.
	endif   
  endif
  if lfound
    lnaz1=naz1
	lnaz2=naz2
	lmiasto=miasto
	lulica=ulica
	lnip=nip
  else
    lnaz1=""
	lnaz2=""
	lmiasto=""
	lulica=""
    lnip=""  
  endif
  select &sel_zak
  @ w,30 say "P  Z     nr "+stuff(ltndok,11,2,"")
  w=w+1
  @ w,29 say replicate(chr(205),27)
  w=w+2
  @ w,5 say "Dotyczy dokumentu zakupu nr "+ltzewndok+ "  z dnia "
  @ w,58 say tdat
  w=w+2
  @ w,5 say "Kontrahent: "
  @ w,17 say alltrim(lnaz1)+"  "+alltrim(lnaz2)
  w=w+1 
  @ w,17 say alltrim(lmiasto)+"  "+alltrim(lulica)
  w=w+1
  @ w,17 say "NIP "+lnip
  w=w+3
  @ w,5 say "===================================================================="
  w=w+1
  @ w,5 say "| Lp.| Nazwa                           | Kod     | Ilosc     | Jm. |"
  w=w+1
  @ w,5 say "|====|=================================|=========|===========|=====|"
  w=w+1
  @ w,5 say "|                                                                  |"         
  w=w+1
  do while tndok=ltndok
    lnum=lnum+1
	@ w,5 say "|"
	@ w,6 say lnum picture "999"
	@ w,12 say tnaz
	@ w,46 say tkod
	@ w,55 say til picture "9999999.99"
	@ w,67 say tjm
	@ w,72 say "|"
	w=w+1
    skip
  enddo
  @ w,5 say "|                                                                  |"  
  w=w+1
  @ w,5 say "===================================================================="
  w=w+6
  @ w,5 say "     .................... "
  w=w+1
  @ w,5 say "      Podpis magazyniera"
  eject 
enddo
set device to screen
RETURN nil 

FUNCTION FIRMA_SET()

RETURN NIL

FUNCTION DEF_CZYSC()
local mag_sel,def_sel,lgnazwa,lgkod,lfound:=.t.
close all
select 0
set default to 1mag
use magazyn index mag_naz
mag_sel=select()
select 0
use defin index def_gnaz
def_sel=select()
do while.not.eof()
  lgnazwa=gnazwa
  lgkod=gkod
  select &mag_sel
  lfound=kj_nk_mseek(lgnazwa,lgkod)
  select &def_sel
  if.not.lfound
    delete
  endif
  skip
enddo
pack
RETURN nil