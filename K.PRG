*******************************************************************************
* Program k.prg                                                               *
* Usuwa bledy i przygotowuje bazy do analizy                                  *
*******************************************************************************
local lpowt:=.f.,ek,lwykonaj:=.f.
kor1:=.t.         &&wlaczona korekta szt - 100
dlugosc_str=58
plikdruk=.t.
plik:="\kjbil.txt"
bil_dat:=date()
set date to german
clear
kj_okno(0,0,24, "  USUWANIE BLEDOW W BAZACH DANYCH                                                ",1)

save screen to ek
lwykonaj=kj_gkom(10," Balagan w kodach !    (redukkod)          Wykonac ? ",;
                      "Usuwanie powtarzajacych sie nazw przy roznych kodach",;
					  "w B O ",lwykonaj,5)
if lwykonaj
  redukkod()
  restore screen from ek
  @ 2,0 say "Redukcja powtarzajacych sie nazw w BO ............................ +"
endif

save screen to ek
lwykonaj=kj_gkom(10," Import pliku sprzedazy exp. (dol_expo)    Wykonac ? ",;
                      "Program importuje z \EXPORT98\1DOK i przelicza sprzedaz exportowa",;
					  "z dol na zl wg kursu sadu",lwykonaj,5)
if lwykonaj
  dol_expo()
  restore screen from ek
  @ 3,0 say "Import i przeliczenie sprzedazy exportowej z dol. na zl .......... +"
endif

save screen to ek
lwykonaj=kj_gkom(10," Zwielokrotnione procedury   (normy)       Wykonac ? ",;
                      "Program redukuje ilosc procedur, bada istnienie procedury dla",;
					  "kazdego wyrobu.",lwykonaj,5)
if lwykonaj
  normy()          &&badanie istnienia definicji, usuwanie podw.
  restore screen from ek
  @ 4,0 say "Kontrola normatyw zakonczona pomyslnie ........................... +"
endif

save screen to ek
lwykonaj=kj_gkom(10," Balagan w kodach - archiwa  (kor_kod)     Wykonac ? ",;
                      "Program koryguje blednie zadeklarowne kody - zanienia 02 na 03",;
					  "kod zasilaczy na 04. Obsluguje magazyn gl.oraz dok.obrotu.",lwykonaj,5)
if lwykonaj
  kor_kod()
  restore screen from ek
  @ 5,0 say "Korekta bledow w kodzie (02/03) oraz zmiana zasilaczy na 04....... +"
endif


save screen to ek
lwykonaj=kj_gkom(10," Analiza pliku defin.dbf oraz mmdok.dbf.   Wykonac ? ",;
                      "Program wykrywa zbedna definicje wyrobow oraz ",;
					  "pokazuje brakujace do uzupelnienia.",lwykonaj,5)
if lwykonaj
  def_analiz()
  restore screen from ek
  @ 6,0 say "Analiza definicji wykonana  ...................................... +"
endif

*save screen to ek
*lwykonaj=kj_gkom(10," Zamiana nazw i kodow    Wykonac ? ",;
*                      "Program zastepuje dotychczasowe nazwy i kody ",;
*					  "nowymi zgodnie z definicja w pliku ZAMIAN.DBF.",lwykonaj,5)
*if lwykonaj
*  zastap()
*  restore screen from ek
*  @ 6,0 say "Analiza definicji wykonana  ...................................... +"
*endif

close all
inkey(3)
RETURN



*******************************************************************************
* Funkcja bada powtarzalnosc pozycji magazynowych                             *
*******************************************************************************
FUNCTION A_POWT_MAG()
local lpusty:=.f.,lwarunek:="mnaz=lmnaz.and.mkod=lmkod                                "
set cursor on
@ 5,0 say "Warunek:"
@ 5,10 get lwarunek
read
set cursor off
lwarunek=alltrim(lwarunek)
select 1
set default to 1mag
use magazyn
index on mnaz+mkod to naz_kod
use magazyn index naz_kod
do while.t.
  @ 24,0 say mnaz
  lmnaz=mnaz
  lmkod=mkod
  skip
  if eof()
    exit
  endif
  if &lwarunek
    replace mindex with -1
  else
    replace mindex with 0
  endif
enddo
set filter to mindex=-1
go top
do pusty with lpusty
lpowt=.not.lpusty
if.not.lpusty
  browse()
endif
lpusty=.not.lpusty
RETURN lpusty


*******************************************************************************
* Funkcja bada przypadek wystapienia pozycji w dok. zakupu i sprzedazy        *
* takich ,  ktore nie wystepuja w magazynie                                   *
*******************************************************************************
FUNCTION A_BRAK_MAG()
local lpusty:=.f.
set cursor on
select 1
set default to 1mag
use magazyn index mag_naz
select 2
set default to 1dok
use zakup
index on tnaz to kj_tnaz
use zakup index kj_tnaz
do while .not. eof()
  ltnaz=tnaz
  ltkod=tkod
  select 1
  locate for mnaz=ltnaz .and. substr(mkod,5)=substr(ltkod,5)
  lfound=found()
  select 2
  if.not.lfound.and.til#0
	replace tindex with -1
  else
    replace tindex with 0    	
  endif
  skip
enddo
set filter to tindex=-1
go top
do pusty with lpusty
if.not.lpusty
  @ 0,0 say "Wykaz pozycji zakupionych , ktore nie wystepuja w magazynie."
  browse(2,0,24,79)
  @ 12,0 say "Dopiszc ?"
  set cursor on
  zz=.t.
  @ 12,10 get zz
  read
  set cursor off
  if zz=.t..and..not.lastkey()=27
    a_dopisz()
  else
    close all
    lpusty=.not.lpusty
    RETURN lpusty  
  endif

else
  @ 8,10 say "Zakupy ........... +"
endif

use sprzedaz
index on tnaz to kj_tnaz
use sprzedaz index kj_tnaz
do while .not. eof()
  ltnaz=tnaz
  ltkod=tkod
  select 1
  locate for mnaz=ltnaz .and. substr(mkod,5)=substr(ltkod,5)
  lfound=found()
  select 2
  if.not.lfound.and.til#0
    replace tindex with -1
  else
    replace tindex with 0  
  endif
  skip
enddo
set filter to tindex=-1
go top
do pusty with lpusty
if.not.lpusty
  @ 0,0 say "Wykaz pozycji sprzedanych , ktore nie wystepuja w magazynie."
  browse(2,0,24,79)
  @ 12,0 say "Dopiszc ?"
  set cursor on
  zz=.t.
  @ 12,10 get zz
  read
  set cursor off
  if zz=.t..and..not.lastkey()=27
    a_dopisz()
  else
    close all
    lpusty=.not.lpusty
    RETURN lpusty  
  endif
else
  @ 9,10 say "Sprzedaz.......... +"
endif

if file("przes1.dbf")
  use przes1
  index on tnaz to kj_tnaz
  use przes1 index kj_tnaz
  do while .not. eof()
    ltnaz=tnaz
    ltkod=tkod
    select 1
    locate for mnaz=ltnaz .and. substr(mkod,5)=substr(ltkod,5)
    lfound=found()
    select 2
    if.not.lfound.and.til#0
      replace tindex with -1
    else
      replace tindex with 0  
    endif
    skip
  enddo
  set filter to tindex=-1
  go top
  do pusty with lpusty
  if.not.lpusty
    @ 0,0 say "Wykaz pozycji wydanych z magazyny, ktore nie wystepuja w magazynie."
    browse(2,0,24,79)
    @ 12,0 say "Dopiszc ?"
    set cursor on
    zz=.t.
    @ 12,10 get zz
    read
    set cursor off
    if zz=.t..and..not.lastkey()=27
      a_dopisz()
    else
      close all
      lpusty=.not.lpusty
      RETURN lpusty  
    endif
  else
    @ 10,10 say "Wydano ........... +"
  endif
endif


if file("przes2.dbf")
  use przes2
  index on tnaz to kj_tnaz
  use przes2 index kj_tnaz
  do while .not. eof()
    ltnaz=tnaz
    ltkod=tkod
    select 1
    locate for mnaz=ltnaz .and. substr(mkod,5)=substr(ltkod,5)
    lfound=found()
    select 2
    if.not.lfound.and.til#0
      replace tindex with -1
    else
      replace tindex with 0  
    endif
    skip
  enddo
  set filter to tindex=-1
  go top
  do pusty with lpusty
  if.not.lpusty
    @ 0,0 say "Wykaz pozycji przyjetych do magazyny, ktore nie wystepuja w magazynie."
    browse(2,0,24,79)
    @ 12,0 say "Dopiszc ?"
    set cursor on
    zz=.t.
    @ 12,10 get zz
    read
    set cursor off
    if zz=.t..and..not.lastkey()=27
      a_dopisz()
    else
      close all
      lpusty=.not.lpusty
      RETURN lpusty  
    endif
  else
    @ 11,10 say "Przyjeto ......... +"
  endif
endif



if file("mmdok.dbf")
  use mmdok 
  index on tnaz to kj_tnaz
  use mmdok index kj_tnaz
  do while .not. eof()
    ltnaz=tnaz
    ltkod=tkod
    select 1
    locate for mnaz=ltnaz .and. substr(mkod,5)=substr(ltkod,5)
    lfound=found()
    select 2
    if.not.lfound.and.til#0
      replace tindex with -1
    else
      replace tindex with 0  
    endif
    skip
  enddo
  set filter to tindex=-1
  go top
  do pusty with lpusty
  if.not.lpusty
    @ 0,0 say "Wykaz pozycji wytworzonych, ktore nie wystepuja w magazynie."
    browse(2,0,24,79)
    @ 12,0 say "Dopiszc ?"
    set cursor on
    zz=.t.
    @ 12,10 get zz
    read
    set cursor off
    if zz=.t..and..not.lastkey()=27
      a_dopisz()
      return .f.
    else
      close all
      lpusty=.not.lpusty
      RETURN lpusty  
    endif
  else
    @ 12,10 say "Wyprodukowano .... +"
  endif
endif

close all
lpusty=.not.lpusty
RETURN lpusty

FUNCTION A_DOPISZ()
	go top
	do while.not.eof()
	  ltnaz=tnaz
	  ltkod=tkod
	  ltjm=tjm
	  do case
	    case substr(tkod,1,2)="01"
		  ltmagaz=1
	    case substr(tkod,1,2)="03"
		  ltmagaz=3
	    case substr(tkod,1,2)="04"
		  ltmagaz=4		  		  
	  endcase
	  select 1
	  locate for mnaz=ltnaz.and.mkod=ltkod
	  if.not.found()
	    append blank
	    replace mnaz with ltnaz,mkod with ltkod,mjm with ltjm,magaz with ltmagaz
	  endif
	  select 2
	  skip
	enddo
RETURN nil




*******************************************************************************
* Procedura bada istnienie rekordu po zafiltrowaniu                           *
*******************************************************************************
PROCEDURE PUSTY
parameters ppusty
local recno:=recno(),lile:=0
go top
do while.not.eof()
  lile=lile+1
  skip
enddo
if lile>0
  ppusty=.f.
else
  ppusty=.t.
endif
go recno
RETURN


*******************************************************************************
* Program zamienia kod 02 na 03 w pliku zakup, sprzedaz, przes1, przes2, mmdok*
* sp_expo. Zamienia kod 03 zasilaczy na 04, pusty na 03 z wyjatkiem poz:      *
* "ANTENA DEXTA NOWA i ANTENA DEXTA POKOJOWA" , ktore zmienia na 04           *
* Usuwa znaki kodu od 3 do 7 rowniez w pliku defin.dbf.                       *
*******************************************************************************
FUNCTION KOR_KOD()
local lcykl:=1,ek
save screen to ek
select 2
set default to 1mag
do while.t.
  do case
    case lcykl=1
      use magazyn index mag_naz,mag_kod
    case lcykl=2
      use bo index bo_naz,bo_kod	  
  endcase	  
  do while.not.eof()
    replace mkod with stuff(space(7),1,2,substr(mkod,1,2))
	if substr(mkod,1,2)="02"
      replace mkod with stuff(mkod,1,2,"03")
	  replace magaz with 3
    endif
    if substr(mnaz,1,8)="ZASILACZ"
      replace mkod with stuff(mkod,1,2,"04")
	  replace magaz with 4
    endif
    if mkod=space(7)
      do case
        case mnaz="ANTENA DEXTA NOWA".or.mnaz="ANTENA DEXTA POKOJOWA"	
	      replace mkod with "04     "
          replace magaz with 4
	    otherwise
	      replace mkod with "03     "
		  replace magaz with 3
	  endcase
    endif
    skip
  enddo
  do case
    case lcykl=1
      @ 7,10 say "Magazyn........  +"
    case lcykl=2
      @ 7,10 say "Magazyn/BO .... ++"	
  endcase
  lcykl=lcykl+1
  if lcykl>2
    exit
  endif
  close
enddo
close all

select 1
set default to 1dok
lcykl=1
do while.t.
  do case
    case lcykl=1
      use zakup 
    case lcykl=2
      use sprzedaz
    case lcykl=3
      use przes1
    case lcykl=4
      use przes2  
    case lcykl=5
      use mmdok   
    case lcykl=6
      use sp_expo 	  	  	  
  endcase	  
  do while.not.eof()
    replace tkod with stuff(space(7),1,2,substr(tkod,1,2))    
	if substr(tkod,1,2)="02"
      replace tkod with stuff(tkod,1,2,"03")
    endif
    if substr(tnaz,1,8)="ZASILACZ"
      replace tkod with stuff(tkod,1,2,"04")
    endif
    if tkod=space(7).and..not.tnaz=space(32)
      do case
        case tnaz="ANTENA DEXTA NOWA".or.tnaz="ANTENA DEXTA POKOJOWA"	
	      replace tkod with "04     "
	    otherwise
	      replace tkod with "03     "
	  endcase
    endif  
    skip
  enddo
  do case
    case lcykl=1
      @ 8,10 say "Zakupy           +"
    case lcykl=2
      @ 9,10 say "Sprzedaz kraj    +"
    case lcykl=3
      @ 10,10 say "Przesun. wydano  +"
    case lcykl=4
      @ 11,10 say "Przesun.przyjeto +"
    case lcykl=5
      @ 12,10 say "Wyprodukowano    +"
    case lcykl=6
      @ 13,10 say "Sprzedaz export  +"	  	  	  	  	  
  endcase
  lcykl=lcykl+1
  if lcykl>6
    exit
  endif
  close
enddo
close all

set default to 1mag
if file("defin.dbf")
  use defin 
  do while.not.eof()
    replace gkod with stuff(space(7),1,2,substr(gkod,1,2))    
    replace skod with stuff(space(7),1,2,substr(skod,1,2))	
    if substr(gkod,1,2)="02"
      replace gkod with stuff(gkod,1,2,"03")
    endif
    if substr(skod,1,2)="02"
      replace skod with stuff(skod,1,2,"03")
    endif	
    if substr(snazwa,1,8)="ZASILACZ"
      replace skod with stuff(skod,1,2,"04")
    endif
    if skod=space(7).and..not.snazwa=space(32)
      do case
        case snazwa="ANTENA DEXTA NOWA".or.snazwa="ANTENA DEXTA POKOJOWA"	
	      replace skod with "04     "
	    otherwise
	      replace skod with "03     "
	  endcase
    endif  
    skip
  enddo
  @ 14,10 say "Normatywy ..... +"
else
  kj_tkom(8," Uwaga! ","Brak definicji wyrobow gotowych","","Nacisnij dowolny klawisz.",5)
endif
close all
kj_tkom(8,"","Korekta kodow zakonczona","","Nacisnij dowolny klawisz.",5)
RETURN nil



*******************************************************************************
* Program eliminuje rozne kody zwiazane z cena (A,B,C...), zachowuje jadna    *
* nazwe. Sumuje ilosci i usrednia cene pozycji o tej samej nazwie             *
* Obsluguje sciezke 1MAG"                                                     *
*****************
FUNCTION REDUKKOD()
local lcolor:=setcolor()
set color to n/w,w/n
z_mag_def()
przed=0
po=0
set default to 1mag
select 1
use bo 
index on mnaz+mkod to bnaz_kod
use bo index bnaz_kod
sum mil*mcen_m to przed

go top
if.not.file("mag_pom.dbf")
  copy structure to mag_pom
  select 2
  use mag_pom
else
  select 2
  use mag_pom
  zap
endif  
koniec=.f.
select 1
do while.not.eof()
@ 0,0 say mnaz
  lwartosc=mil*mcen_m
  mag_lad()
  bil_jm=mjm
  do while.t.
    skip
	if eof()
	  koniec=.t.
	  exit
	endif
	if mnaz=zmnaz
	  lmjm=mjm
	  lmil=mil
	  zmil=zmil+kor_jm_il(bil_jm,lmjm,lmil)
	  lwartosc=lwartosc+mil*mcen_m
	else
	  exit
	endif
  enddo
  zmcen_m=lwartosc/zmil
  select 2
  append blank
  mag_replac()
  if koniec
    select 1
    exit
  endif
  select 1
enddo  
close
select 2
go top
sum mil*mcen_m to po
close
@ 10,10 say "Wartosc  przed operacja :"
@ 11,10 say "Wartosc po    operacji : "
@ 10,36 say przed
@ 11,36 say po
@ 12,0 say "Roznica ="
@ 12,36 say przed-po
copy file mag_pom.dbf to bo.dbf
select 1
use bo
index on mnaz to bo_naz
index on nmag to bo_num
index on mkod to bo_kod
close
select 2
close all
setcolor(lcolor)
inkey(0)
RETURN


*******************************************************************************
* Funkcja usuwa powtarzajace sie definicje wyrobow rozrozniane kodem          *
* Analizuje istnienie procedury w zbiorze defin.dbf dla kazdego zarejestrowa- *
* nego wyrobu.                                                                *
*******************************************************************************

FUNCTION NORMY()
local ek
save screen to ek
select 4
close
set default to 1mag
use defin index def_gnaz,def_snaz
do while.not.eof()         &&eliminacja dublowanych definicji
  lgnaz=gnazwa
  lgkod=gkod
  do while gnazwa=lgnaz
    if gkod#lgkod
      delete	
	endif   
	skip 
  enddo
enddo
pack
select 1
set default to 1dok
use mmdok
do while.not.eof()
  ltnaz=tnaz
  select 4
  seek ltnaz
  lfound=found()
  select 1
  if .not. lfound
    kj_tkom(8,"Uwaga ! "," Definicja nie odnaleziona  ",ltnaz,"Nacisnij dowolny klawisz",5)
    replace tindex with -1
  else
    replace tindex with 0
  endif
  skip
enddo
set filter to tindex=-1
go top
clear
@ 0,0 say "Wykaz wyrobow dla ktorych nie odnaleziono procedury przerobu."
browse(2,1,24,78)
close
select 4
close
RETURN nil


********Export - przeliczenie sprzedazy z cen dolarowych na zlotowkowe
FUNCTION DOL_EXPO()
local plik:="\export98\1dok\sprzedaz.dbf                             ",ek
local przed:=0,po:=0,lcolor:=setcolor()
set color to n/w,w/n
save screen to ek
@ 15,0 say "Zatwierdz plik:"  
set cursor on
@ 15,17 get plik
read
set cursor off
if lastkey()=27
  restore screen from ek
  return 
endif
plik=alltrim(plik)
copy file &plik to 1dok\sp_expo.dbf
set default to 1dok
select 1
use sp_expo
do while.not.eof()
  przed=przed+til*tcen
  lnum=val(substr(tndok,9,2))
  do case
    case lnum<=6
	  lkurs=3.53
    case lnum>6.and.lnum<=18
	  lkurs=3.55	  
    case lnum>18.and.lnum<=25
	  lkurs=3.528
    case lnum>25.and.lnum<=29
	  lkurs=3.555	  	  	  	  
    case lnum>29.and.lnum<=33
	  lkurs=3.501
    case lnum>33.and.lnum<=35
	  lkurs=3.44 	  	  	  	  	  	  	  	  	  
    case lnum>35.and.lnum<=100
	  lkurs=3.44 	  	  	  	  	  	  	  	  	  	  
  endcase
  replace tcen with tcen*lkurs
  skip
enddo
sum til*tcen to po
close all
@ 18,10 say "W dolarach:"
@ 19,10 say "W zlotowkach:"
@ 18,22 say przed
@ 19,22 say po
@ 21,10 say "Sredni kurs za miesiac:"
@ 21,35 say po/przed
kj_tkom(10,"","Przeliczanie zakonczone.","","Nacisnij dowolny klawisz",5)
restore screen from ek
setcolor(lcolor)
RETURN nil

PROCEDURE BILANS

RETURN
*******************************************************************************
* Funkcja pokazuje i umozliwia wykasowanie procedur nie wykorzystywanych      *
* w wybranym okresie i umozliwia ich usuniecie. Pokazuje rowniez wyroby       *
* zarejestrowane nie posiadajace definicji.                                   *
*******************************************************************************

PROCEDURE DEF_ANALIZ()
local sel_def,sel_mm,sel_pom,ek
local lwarunek:=".t.                                                      "
save screen to ek
clear
@ 10,0 say "Filtr:"
set cursor on
@ 10,10 get lwarunek
read
set cursor off
lwarunek=alltrim(lwarunek)
restore screen from ek
set default to 1dok
use mmdok new
copy structure to mm_pom
index on tnaz+tkod to b_tnk
use mmdok index b_tnk
set filter to &lwarunek
go top
sel_mm=select()
use mm_pom new
sel_pom=select()
set default to 1mag
use defin index def_gnaz new
sel_def=select()
do while.not.eof()
  lgnazwa=gnazwa
  lgkod=gkod
  select &sel_mm
  if.not.kj_nk_tseek(lgnazwa,lgkod)
    select &sel_def
    if kj_gkom(8,"Definicja nie wykorzystywana.",lgnazwa+lgkod,"Usunac ?",.t.,5)
	  do while gnazwa=lgnazwa.and.gkod=lgkod
	    delete
	    skip
	  enddo
	  pack
	else
	  do while gnazwa=lgnazwa.and.gkod=lgkod
	    skip
      enddo		
	endif
  endif
  select &sel_def
  skip
enddo
select &sel_mm
go top
do while.not.eof()
  ltnaz=tnaz
  ltkod=tkod
  ltjm=tjm
  select &sel_def
  if.not.kj_dseek(ltnaz,ltkod)
    select &sel_pom
	append blank
    replace tnaz with ltnaz,tkod with ltkod,tjm with ltjm
  endif
  select &sel_mm
  do while tnaz=ltnaz.and.tkod=ltkod
    skip
  enddo
enddo
select &sel_pom
browse()
if kj_gkom(8,"","Wydrukowac?","",.t.,5)
  set device to printer
* do startdruk
  go top
  w=prow()
  @ w,0 say "Wyroby zarejestrowane nie posiadajace normatyw ! (Do uzupelnienia)"
  w=w+2
  do while.not.eof()
    @ w,0 say tnaz
	@ w,35 say tkod
	@ w,44 say tjm
	w=w+1
    skip
  enddo
  set device to screen
endif
close all
RETURN nil


