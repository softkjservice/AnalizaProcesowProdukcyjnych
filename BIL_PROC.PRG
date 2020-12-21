
*******************************************************************************
* Przegladanie BO oraz dokumentow zakupu i srednich cen                       *
*******************************************************************************
FUNCTION BIL_PRZEGLAD()
local lmagnaz,t[1],q[1],ltxt:=""
t[1]:="mnaz"
q[1]:=""
do case 
  case wyrob_mag
    lmagnaz:="     MAGAZYN WYROBOW GOTOWYCH     "
  case polwyrob_mag 
    lmagnaz:="       MAGAZYN POLFABRYKATOW      "
  case surowiec_mag
    lmagnaz:="    MAGAZYN SUROWCOW I TOWAROW    "
  case handel_mag
    lmagnaz:="    MAGAZYN TOWAROW HANDLOWYCH    "				
  otherwise 
    lmagnaz:="    WSZYSTKIE MAGAZYNY LACZNIE    "  	
endcase
do case
  case menu_zak
    ltxt="         WYKAZ DOKUMENTOW ZAKUPU        "
	  case menu_prod
    ltxt="          WYKAZ DOKUMENTOW  P W         "
endcase
kj_okno(0,0,23, "           ANALIZA BILANSU OTWARCIA MIESIACA ORAZ DOKUMENTOW ZAKUPU             ",2)
kj_okno(2,1,20,lmagnaz,5)
kj_okno(2,1,17,lmagnaz,5)
kj_okno(2,39,14,ltxt,5)
kj_okno(2,39,12,ltxt,5)
kj_okno(17,37,5,"          P O D S U M O W A N I E         ",3)
@ 20,3 say "Kod:                     "
@ 21,3 say "Cena magazynowa:"   
select 5
set default to 1dok
use mmdok
select 2
set default to 1dok
use zakup
select 1
set default to 1mag
*use magazyn index mag_naz
bz_use(bil_num_mies)
m_filtr()
do skom with "1-Wyroby, 2-Polwyroby, 3-Surowce, 4-Towary, 0-Wszystkie   Enter-zatw. Esc-rez."
keyboard chr(205)
dbedit(3,2,18,33,t,"B_FU","",q,"ß")
select 1
close all
select 2
close all
select 3
close all
select 4
close all
select 5
close all
RETURN nil


*******************************************************************************
* Obsluguje baze magazynowa - przeglad pozycji, wybor do analizy              *
*******************************************************************************
FUNCTION B_FU(tryb,numer)
local last:=lastkey(),t[5],q[5],i,ek,lcolor:=setcolor(),lprodukt:=.f.
private vmnaz:=mnaz,vmkod:=mkod,vmjm:=mjm
private bil_jm:=mjm
t[1]:="tzewndok"
t[2]:="str(til,8,2)"
t[3]:="str(tcen_m,8,2)"
t[4]:="tjm"
t[5]:="tdat"
q[1]:="Numer dokum."
q[2]:="Ilosc"
q[3]:="Cena"
q[4]:="jm"
q[5]:="Data"
if menu_prod
  t[1]="tndok"
endif

do case

  case last=13
    save screen to ek
    set color to w/n*
	@ row(),col() say mnaz 
	setcolor(lcolor)
    if menu_zak
      lprodukt=czy_produkt(vmnaz,vmkod)
      if lprodukt
        kj_tkom(9," Uwaga ! ",vmnaz,"jest produktem lub polproduktem i nie podlega analizie","w tym raporcie.              Ok!",5)	  	
	    select 1
	    restore screen from ek
	    keyboard chr(205)
	    return 2
	  endif
	endif
    do case
	  case menu_zak
	    select 2
	  case menu_prod
	    select 5	
	endcase
    t_filtr()
	do skom with "Esc - powrot do wyboru pozycji do analizy"
	dbedit(3,40,13,77,t,"B_FU_1_kor","",q,"ß")
	restore screen from ek
	select 1	
  case last=27
    return 0
  case last=48
    bil_mag(0)
    return 0
  case last=49
    bil_mag(1)  
	return 0
  case last=50
    bil_mag(2)
	return 0
  case last=51
    bil_mag(3)
	return 0
  case last=52
    bil_mag(4)
	return 0
endcase
@ 20,8 say mkod
@ 20,17 say mil
@ 20,29 say mjm
@ 21,20 say mcen_m
RETURN 1



*******************************************************************************
* Obsluguje baze ZAKUP.DBF  - umozliwia przeglad dokumentow zakupu zwiazanych *
* z wybrana pozycja magazynowa orza zadeklarowanym okresem rozliczeniowym     *
*   Uwaga!  Funkcja wprowadza korekty jednostek  szt - 100                    *
*******************************************************************************
FUNCTION B_FU_1_KOR(tryb,numer)
local last:=lastkey(),bo_il:=0,bo_cen:=0,lmjm:=""
local ltil_sum:=0,ltwartosc_sum:=0,l_srednia:=0
local lzak_sum:=0,lzak_il_sum:=0,lprod_il:=0,lprod_sum:=0
@ 15,41 say "Z dnia:"
@ 15,49 say tdat
@ 15,62 say tjm
@ 15,66 say round(til*tcen_m,2) picture "9999999.99" 
ltnaz=tnaz
ltkod=tkod
ltjm=tjm
do case
  case last=13
	  select 3
      set default to 1mag
*      if file("bo_m.dbf")
*        use bo_m
      if bo_use(bil_num_mies) 
        seek vmnaz
        if found()
          bo_il=mil
    	  bo_cen=mcen_m
    	  bo_jm=mjm
          if kor1
		    bo_il=kor_jm_il(bil_jm,bo_jm,bo_il)
		    bo_cen=kor_jm_cen(bil_jm,bo_jm,bo_cen)
		  endif 
        endif
        close
      endif
      @ 18,39 say "B O .......               po           "
	  @ 19,39 say "Zakup .....               po           "
      if menu_prod
	    @ 20,39 say "Produkcja..               po           "	  
	  else
	    @ 20,39 say "            ..........................."	  
	  endif	
      @ 21,39 say "Razem .....               po           "
      @ 18,50 say bo_il picture "9999999.99"
      @ 18,61 say bil_jm 
      @ 18,67 say bo_cen picture "999999.99"

	select 2             &&Zakupy
    t_filtr()
	go top
    ltwartosc_sum=0
    ltil_sum=0
	do while.not.eof()
	  ltil=til
	  ltjm=tjm
      ltwartosc_sum=ltwartosc_sum+til*tcen_m
      if kor1
	    ltil=kor_jm_il(bil_jm,ltjm,ltil)      
	  endif	
	  ltil_sum=ltil_sum+ltil
	  skip
	enddo
	go top
    
	if menu_prod       &&Produkcja
	  select 5
      go top
*	  t_filtr()
	  lprod_il=0
	  do while.not.eof()
	    ltil=til
	    ltjm=tjm
        if kor1
	      ltil=kor_jm_il(bil_jm,ltjm,ltil)      
	    endif	
	    lprod_il=lprod_il+ltil
	    skip
	  enddo	  
	  lprod_sum=lprod_il*wyr_cen(vmnaz,vmkod)
	endif
    go top
	if menu_prod        &&dopisz surowce dokupione
	  @ 20,50 say lprod_il picture "9999999.99"            &&Raport produkcyjny
      @ 20,61 say bil_jm 
      @ 20,67 say lprod_sum/lprod_il picture "999999.99"
    endif
	  @ 19,50 say ltil_sum picture "9999999.99"            &&Raport zakupu
      @ 19,61 say bil_jm 
      @ 19,67 say ltwartosc_sum/ltil_sum picture "999999.99"	
	
	@ 21,50 say ltil_sum+bo_il+lprod_il picture "9999999.99"
    @ 21,61 say bil_jm 
    @ 21,67 say (ltwartosc_sum + bo_il*bo_cen+lprod_sum) / (ltil_sum+bo_il+lprod_il) picture "999999.99"	
    
  case last=27
    return 0
endcase	
RETURN 1


*******************************************************************************
* Funkcja zapamietuje w pliku magazyn wartosci srednie zakupu i produkcji (+BO)
* 
*******************************************************************************
FUNCTION BIL_SREDNIA()
local lmnaz,lmkod,bil_jm,lbil_cen,lprodukt:=.f.
local lmjm,lbo_wartosc:=0,lbo_il:=0,ltwartosc_sum:=0,lti_sum:=0
local ltlo:=.f.,ltxt:="",k_last:=0,k_aktual:=0,start_sum,last_sum
select 5
set default to 1dok
use mmdok
select 1
set default to 1mag
*use magazyn index mag_naz
bz_use(bil_num_mies)
select 2
set default to 1dok
use zakup


*******mODYFIKACJA JEDNOSTEK W WYROBACH

  select 4
  set default to 1mag
  use defin
  do while.not.eof()
    lsnazwa=snazwa
	lskod=skod
	ltxt=stuff(space(45),1,len(alltrim(snazwa)),alltrim(snazwa))
	ltxt=stuff(ltxt,len(alltrim(snazwa))+3,7,skod)
	select 1
	seek lsnazwa
	if found()
	  lmcen_m=mcen_m
	  lmjm=mjm
	  select 4
	  do case
	    case lmjm="100".and.sjm#"100"
		  replace silosc with silosc/100
		  replace sjm with lmjm
	    case lmjm#"100".and.sjm="100"
		  replace silosc with silosc*100		  
		  replace sjm with lmjm
	  endcase
	  replace scena with lmcen_m
	endif
    skip
  enddo



select 1
set filter to substr(mster,3,1)#"w"
go top
ltxt="Usrednianie ceny zak."			
k_last=lastrec()
do while.not.eof()       &&  Usrednianie cen zakupu towarow i surowcow
  @ 24,0 say mnaz
  vmnaz=mnaz
  vmkod=mkod
  k_aktual=recno()
  ltlo=kj_pasek(9,15,ltxt,k_last,k_aktual,ltlo)
  lbo_wartosc=0
  lbo_il=0 
  lmnaz=mnaz
  lmkod=mkod
  bil_jm=mjm
    select 3
    set default to 1mag
     if bo_use(bil_num_mies)
	  seek lmnaz
      if found()
        lbo_il=mil
		lbo_jm=mjm
		lbo_wartosc=mcen_m*mil
        if kor1
		  lbo_il=kor_jm_il(bil_jm,lbo_jm,lbo_il)
		endif
      endif
      close
    endif
  
    select 2                  && w zakupach
    t_filtr()
    ltil_sum=0
	ltwartosc_sum=0
	do while.not.eof()
      ltil=til
	  ltjm=tjm
	  ltwartosc_sum=ltwartosc_sum+til*tcen_m
      if kor1
	    ltil=kor_jm_il(bil_jm,ltjm,ltil)
	  endif
	  ltil_sum=ltil_sum+ltil
	  skip
	enddo
	lbil_cen=(lbo_wartosc+ltwartosc_sum)/(lbo_il+ltil_sum)

    select 1
	if.not.czy_produkt(lmnaz,lmkod)
	  replace mcen_m with lbil_cen
	endif  
  skip
enddo  

*********** Wyroby w cenach srednich skladnikow
set filter to substr(mster,3,1)="w"
go top
start_sum=0
last_sum=0
do while.t.
  do while.not.eof()
    @ 24,0 say mnaz
    recno=recno()
    lmnaz=mnaz
    lmkod=mkod
    lwyr_cen=wyr_cen(lmnaz,lmkod)
	go recno
    replace mcen_m with lwyr_cen
   	last_sum=last_sum+mil*mcen_m
    skip
  enddo
  if last_sum=start_sum
    exit
  else
    start_sum=last_sum
    last_sum=0
    go top
  endif
enddo



ltxt="Usrednianie cen prod."			
*set filter to substr(mster,3,1)="w"
go top
k_last=lastrec()
do while.not.eof()       &&  Usrednianie cen wyrobow i surowcow przetwarzanych
    @ 24,0 say mnaz
	lsrednia_skladnikow=mcen_m
	vmnaz=mnaz
    vmkod=mkod
    k_aktual=recno()
    ltlo=kj_pasek(9,15,ltxt,k_last,k_aktual,ltlo)
    lbo_wartosc=0
    lbo_il=0 
    lmnaz=mnaz
    lmkod=mkod
    bil_jm=mjm
    select 3
    set default to 1mag
*    if file("bo_m.dbf")
*      use bo_m
    if bo_use(bil_num_mies)
      seek lmnaz
      if found()
        lbo_il=mil
		lbo_jm=mjm
		lbo_wartosc=mcen_m*mil
        if kor1
		  lbo_il=kor_jm_il(bil_jm,lbo_jm,lbo_il)
		endif
      endif
      close
    endif
  
    select 2                  && w zakupach
    t_filtr()	
    ltil_sum=0
	ltwartosc_sum=0
	do while.not.eof()
      ltil=til
	  ltjm=tjm
	  ltwartosc_sum=ltwartosc_sum+til*tcen_m
      if kor1
	    ltil=kor_jm_il(bil_jm,ltjm,ltil)
	  endif
	  ltil_sum=ltil_sum+ltil
	  skip
	enddo


    select 5
    t_filtr()
	lwyr_il=0
	do while.not.eof()
      ltil=til
	  ltjm=tjm
      if kor1
	    ltil=kor_jm_il(bil_jm,ltjm,ltil)
	  endif
	  lwyr_il=lwyr_il+ltil	  
	  skip
	enddo
	lwyr_wartosc=lwyr_il*lsrednia_skladnikow
	lbil_cen=(lbo_wartosc+ltwartosc_sum+lwyr_wartosc)/(lbo_il+ltil_sum+lwyr_il)
    select 1
	replace mcen_m with lbil_cen
	
  skip 
enddo


set filter to
go top
  select 4
  set default to 1mag
  use defin
  do while.not.eof()
    lsnazwa=snazwa
	lskod=skod
	ltxt=stuff(space(45),1,len(alltrim(snazwa)),alltrim(snazwa))
	ltxt=stuff(ltxt,len(alltrim(snazwa))+3,7,skod)
	select 1
	seek lsnazwa
	if found()
	  lmcen_m=mcen_m
	  lmjm=mjm
	  select 4
	  do case
	    case lmjm="100".and.sjm#"100"
		  replace silosc with silosc/100
		  replace sjm with lmjm
	    case lmjm#"100".and.sjm="100"
		  replace silosc with silosc*100		  
		  replace sjm with lmjm
	  endcase
	  replace scena with lmcen_m
	endif
    skip
  enddo
select 2
close
select 3
close
select 4
close
select 5
close
  
***************************Wpisanie cen srednich do plikow 
* sprzedaz,przes1,przes2,mmdok oraz uaktualnienie jednostek rowniez w pliku
* zakup ( na tym etapie brak jeszcze uzgodnienia jednostek tylko dla bo i bz*)
***************************
select 2
set default to 1dok
lcykl=1
do while .t.
  select 2
  do case
    case lcykl=1
      do skom with "Wpisywanie cen srednich do pliku ze sprzedaza krajowa"
	  use sprzedaz 
      index on tnaz+tkod to tnazkod
      use sprzedaz index tnazkod	  
    case lcykl=2
	  do skom with "Wpisywanie cen srednich do pliku z wyrobami"
      use mmdok 
      index on tnaz+tkod to tnazkod
      use mmdok index tnazkod	  	  
    case lcykl=3
	  do skom with "Wpisywanie cen srednich do zestawienia przetworzonych surowcow"
      use bilp_sur
      index on tnaz+tkod to tnazkod
      use bilp_sur index tnazkod	  	  	  	  
    case lcykl=4
	  do skom with "Wpisywanie cen srednich do pliku ze sprzedaza exportowa"	
      use sp_expo
      index on tnaz+tkod to tnazkod
      use sp_expo index tnazkod	  	  	  
  endcase 	    
  select 1
  go top    
  do while.not.eof()
	@ 24,2 say mnaz
	vmnaz=mnaz
    vmkod=mkod
    vmjm=mjm
    lmcen_m=mcen_m
    lmster=mster
    select 2
	t_filtr()
*	if.not.kj_pusty()
      do while.not.eof()
        if kor1
          do case
            case vmjm="100".and.tjm#"100"
              replace til with til/100
	          replace tjm with vmjm
            case vmjm#"100".and.tjm="100"
		      replace til with til*100
		      replace tjm with vmjm
	      endcase
	    endif	 
        replace tster with lmster
		replace tcen_m with lmcen_m		  	  		  
        skip
      enddo
*	endif	
    select 1
	skip
  enddo	
  lcykl=lcykl+1	
  if lcykl>4.or.(lcykl=4.and..not.file("sp_expo.dbf"))
    exit
  endif
enddo  
select 2
close
select 1
close all

*p_surowce()              

kj_tkom(10,"","Usrednianie cen i korekta jednostek zakonczone","","Nacisnij dowolny klawisz",5)
RETURN NIL


******************************************************************************
* Funkcja sprawdza, czy analizowana pozycja jest wyrobem lub polwyrobem      *
******************************************************************************
FUNCTION CZY_PRODUKT(pmnaz,pmkod)
local select:=select(),lprodukt:=.f.
if file("defin.dbf")            &&jesli produkcja i produkt lub polprodukt
  select 4
  set default to 1mag
  use defin index def_gnaz
  seek pmnaz
  lprodukt=found()
  close
  select &select
endif
RETURN lprodukt


******************************************************************************
* Funkcja instaluje filtr w bazie dokumentow ma pozycje i miesiac            *
******************************************************************************
FUNCTION T_FILTR()
	if bil_num_mies=0
	  set filter to tnaz=vmnaz
    else
	  set filter to month(tdat)=bil_num_mies.and.tnaz=vmnaz
	endif
    go top
RETURN


******************************************************************************
* Funkcja instaluje filtr w bazie dokumentow ma pozycje i miesiac            *
******************************************************************************
FUNCTION M_FILTR()
if menu_prod
  mag_prod_war=mag_warunek
  set filter to substr(mster,3,1)="w"
  go top
  mag_prod_war=mag_prod_war+""+".and."+dbfilter()
  set filter to &mag_prod_war
else
  set filter to &mag_warunek
endif  
go top
RETURN 


******************************************************************************
* Funkcja ustala magazyn biezacy. 1-wyroby,2-polwyr,3-surowce, 4-towary 0-all*
******************************************************************************
FUNCTION BIL_MAG(pnum)
do case
  case pnum=0.or.pnum=5
    b_magtyt="WYROBY GOTOWE + POLWYROBY + SUROWCE + TOWARY"
    wyrob_mag=.f.
	polwyrob_mag=.f.
	surowiec_mag=.f.
	handel_mag=.f.
  	mag_warunek:='.t.'
    return 0
  case pnum=1 
    b_magtyt=" W  Y  R  O  B  Y     G  O  T  O  W  E               "
    wyrob_mag=.t.
	polwyrob_mag=.f.
	surowiec_mag=.f.
	handel_mag=.f.
	  mag_warunek:='substr(mkod,1,2)="01"'	    
	return 0
  case pnum=2 
    b_magtyt="       P  O  L  W  Y  R  O  B  Y                     "
    wyrob_mag=.n.
	polwyrob_mag=.t.
	surowiec_mag=.f.
	handel_mag=.f.
	 * mag_warunek:='substr(mkod,1,2)="02"'	    
	  mag_warunek:='substr(mkod,1,2)="03".and.substr(mster,3,1)="w"'	    
	return 0
  case pnum=3 
    b_magtyt=" S U R O W C E   I   M A T E R I A L Y                "
    wyrob_mag=.f.
	polwyrob_mag=.f.
	surowiec_mag=.t.
	handel_mag=.f.
	  mag_warunek:='substr(mkod,1,2)="03"'	    
	return 0
  case pnum=4 
    b_magtyt="    T O W A R Y    H A N D L O W E                      "
    wyrob_mag=.f.
	polwyrob_mag=.f.
	surowiec_mag=.f.
	handel_mag=.t.
	  mag_warunek:='substr(mkod,1,2)="04"'	    
	return 0
endcase
RETURN nil



******************************************************************************
* Funkcja koryguje bledy wynikajace z j.m=100 oraz szt  -  dotyczy ilosci    *
******************************************************************************
FUNCTION KOR_JM_IL(pbil_jm,pmjm,pil)
do case
  case pbil_jm="100".and.pmjm#"100"
    pil=pil/100
  case pbil_jm#"100".and.pmjm="100"
    pil=pil*100	
endcase  
RETURN pil


******************************************************************************
* Funkcja koryguje bledy wynikajace z j.m=100 oraz szt  - dotyczy ceny       *
******************************************************************************
FUNCTION KOR_JM_CEN(pbil_jm,pmjm,pcen)
do case
  case pbil_jm="100".and.pmjm#"100"
    pcen=pcen*100
  case pbil_jm#"100".and.pmjm="100"
    pcen=pcen/100	
endcase
RETURN pcen		


******************************************************************************
* Funkcja wylicza wartosc wyrobu wedlug procedur i aktualnych cen            *
* magazynowych czesci skladowych                                             *
******************************************************************************
FUNCTION WYR_CEN(pnaz,pkod)
local lcen:=0,dbfilter,select:=select(),recno
select 1
dbfilter=dbfilter()
recno:=recno()
set filter to
go top
  select 4
  set default to 1mag
  use defin
  set filter to gnazwa=pnaz
  go top
  do while.not.eof()
    lsnazwa=snazwa
	lskod=skod
	lsilosc=silosc
	lsjm=sjm
	ltxt=stuff(space(50),1,len(alltrim(snazwa)),alltrim(snazwa))
	ltxt=stuff(ltxt,len(alltrim(snazwa))+3,7,skod)
	ltxt=stuff(ltxt,len(alltrim(snazwa))+12,3,sjm)	
	ltxt=alltrim(ltxt)
    select 1
	seek lsnazwa
	if found()
	  lcen=lcen+lsilosc*mcen_m
      if mjm#lsjm
	    kj_tkom(9," Uwaga ! ","W pozycji bedaca skladnikiem wyrobu gotowego",ltxt,"wykryto konflikt jednostek miary. Popraw i ponownie przeprowadz usrednianie.",5) 
	    sukces=.f.
        set filter to &dbfilter
        go top
        go recno
        select &select		
		return lcen
	  endif
	else
	  kj_tkom(9," Uwaga ! ","Pozycja bedaca skladnikiem wyrobu gotowego nie odnaleziona",ltxt,"Uzupelnij baze magazynowa i ponownie przeprowadz usrednianie cen",5) 
      sukces=.f.
      select 1
      set filter to &dbfilter
      go top
      go recno
      select &select
	  return lcen
	endif
    select 4
    skip
  enddo
  
  close
  select 1
  set filter to &dbfilter
  go top
  go recno
  select &select
RETURN lcen




   
FUNCTION BIL_NORMATYW()
local lmagnaz,t[2],q[2],t1[5],q1[5]
t[1]:="mnaz"
t[2]:="mkod"
q[1]:=""
q[2]:=""
t1[1]:="snazwa"
t1[2]:="skod"
t1[3]:="silosc"
t1[4]:="sjm"
t1[5]:="scena"
t1[1]:="Nazwa"
q1[2]:="Kod"
q1[3]:="Ilosc"
q1[4]:="J.m"
q1[5]:="Cena"
kj_okno(0,0,23, "                    NORMATYWY WYROBOW GOTOWYCH I POLWYROBOW                     ",2)
kj_okno(2,1,7,"Nazwa wyrobu gotowego lub polwyrobu   Kod   " ,5)
kj_okno(11,1,11,"                            S K L A D N I K I                                 ",5)
kj_okno(2,47,7,"     P O D S U M O W A N I E    ",3)

select 4
set default to 1mag
*use defin
USE DEF_SUR INDEX DEF_GSUR,DEF_SSUR
select 1
set default to 1mag
*use magazyn index mag_naz
bz_use(bil_num_mies)
*set filter to substr(mster,3,1)="w"
set filter to MAGAZ=1
go top
keyboard chr(205)
dbedit(3,2,8,43,t,"B_FU_N","",q,"ß")
select 1
close all
select 2
close all
select 3
close all
select 4
close all
select 5
close all
RETURN nil

FUNCTION B_FU_N(tryb,numer)
local last:=lastkey(),t[5],q[5],i,ek,lcolor:=setcolor(),lprodukt:=.f.
private vmnaz:=mnaz,vmkod:=mkod,vmjm:=mjm,vmcen_p:=mcen_p
private bil_jm:=mjm
t[1]:="snazwa"
t[2]:="skod"
t[3]:="silosc"
t[4]:="sjm"
t[5]:="scena"
q[1]:="Nazwa"
q[2]:="Kod"
q[3]:="Ilosc"
q[4]:="J.m"
q[5]:="Cena"

do case

  case last=13
    save screen to ek
    set color to w/n*
	@ row(),col() say mnaz 
	setcolor(lcolor)
	select 4
    set filter to gnazwa=vmnaz.and.gkod=vmkod
    go top
	do skom with "Esc - powrot do wyboru pozycji do analizy"
	dbedit(12,2,21,77,t,"B_FU_S","",q,"ß")
	restore screen from ek
	select 1	
  case last=27
    return 0
endcase
RETURN 1


FUNCTION B_FU_S(tryb,numer)
local last:=lastkey(),recno:=recno(),lsum:=0
do case
  case last=13
    go top
	do while.not.eof()
	  lsum=lsum+silosc*scena
	  skip
	enddo
	go recno
	@ 4,49 say "SKLADNIKI :"
	@ 5,49 say "Laczna wartosc..."
	@ 7,49 say "Placa jednostkowa"    
	@ 5,66 say lsum picture "9999999.99"
	@ 7,66 say vmcen_p picture "9999999.99"
  case last=27
    return 0 
endcase
RETURN 1




**************************************SPRZEDAZ - PRZEGLAD
FUNCTION SPRZED_PRZEG()
local lmagnaz,t[2],q[2],t1[5],q1[5]
t[1]:="mnaz"
t[2]:="mkod"
q[1]:=""
q[2]:=""
t1[1]:="snazwa"
t1[2]:="skod"
t1[3]:="silosc"
t1[4]:="sjm"
t1[5]:="scena"
t1[1]:="Nazwa"
q1[2]:="Kod"
q1[3]:="Ilosc"
q1[4]:="J.m"
q1[5]:="Cena"
kj_okno(0,0,23, "               ANALIZA SPRZEDAZY W CENACH ZAKUPU I SPRZEDAZY                    ",2)
kj_okno(2,1,7,"  Nazwa pozycji magazynowej        Kod      " ,5)
kj_okno(11,1,11,"          W Y K A Z    D O K U M E N T O W    S P R Z E D A Z Y               ",5)
kj_okno(2,47,7,"     P O D S U M O W A N I E    ",3)
select 2
set default to 1dok
do case
  case sp_kraj
    use sprzedaz
  case sp_export
    use sp_expo
endcase

select 1
set default to 1mag
*use magazyn index mag_naz
bz_use(bil_num_mies)
keyboard chr(205)
dbedit(3,2,8,43,t,"B_FU_SPRZED","",q,"ß")
select 1
close all
select 2
close all
RETURN nil

FUNCTION B_FU_SPRZED(tryb,numer)
local last:=lastkey(),t[6],q[6],i,ek,lcolor:=setcolor(),lprodukt:=.f.
private vmnaz:=mnaz,vmkod:=mkod,vmjm:=mjm,vmcen_p:=mcen_p
private bil_jm:=mjm
t[1]:="substr(tndok,3)"
t[2]:="tdat"
t[3]:="til"
t[4]:="tjm"
t[5]:="tcen_m"
t[6]:="tcen"
q[1]:="Numer dokum."
q[2]:="Data"
q[3]:="Ilosc"
q[4]:="J.m"
q[5]:="Cen.zakupu"
q[6]:="Cen. sprzed."
do case

  case last=13
    save screen to ek
    set color to w/n*
	@ row(),col() say mnaz 
	setcolor(lcolor)
	select 2
    t_filtr()
	do skom with "Esc - powrot do wyboru pozycji do analizy"
	dbedit(12,2,21,77,t,"B_FU_SP","",q,"ß")
	restore screen from ek
	select 1	
  case last=27
    return 0
endcase
RETURN 1


FUNCTION B_FU_SP(tryb,numer)
local last:=lastkey(),recno:=recno(),lsum:=0,lzak_sum:=0,lsprzed_sum:=0
do case
  case last=13
    go top
    do while.not.eof()
      lzak_sum=lzak_sum+til*tcen_m
	  lsprzed_sum=lsprzed_sum+til*tcen	
      skip
 	enddo
	go recno
	@ 4,49 say "R A Z E M :"
	@ 5,49 say "W cenach sprzed. "
	@ 6,49 say "W cenach zekupu  "    
	@ 5,66 say lsprzed_sum picture "9999999.99"
	@ 6,66 say lzak_sum picture "9999999.99"
	@ 7,66 say "----------"
	@ 8,49 say "R O Z N I C A :"
	@ 8,66 say lsprzed_sum - lzak_sum picture "9999999.99"
  case last=27
    return 0 
endcase
RETURN 1


FUNCTION O_BIL_NORM_DRUK()
local lmnaz,lmkod,bil_jm,lbil_cen,lnum:=0,lstrona:=1,lwyrob:=.f.,ek
local lmjm,lbo_wartosc:=0,lbo_il:=0,ltwartosc_sum:=0,lti_sum:=0
local ltlo:=.f.,ltxt:="",k_last:=0,k_aktual:=0
local ltxt1:=""
local ltx0:="|                                                                                                                               |"
local ltyt:=""
ltyt="   N O R M A Y W Y    ZUZYCIA  SUROWCOW  I  MATERIALOW"
do startdruk
set device to printer
@ prow(),pcol() say chr(18)
w=prow()
@ w,11 say ltyt
w=w+1
@ w,10 say "========================================================="
w=w+3
@ w,0 say "OKRES ROZLICZENIOWY   Rok:           Miesiac:"
@ w,26 say year(bil_dat) 
@ w,46 say bil_miesiac
w=w+3
@ prow(),pcol() say chr(15)
norm_tyt(lstrona)
***select 3 - BO  4-defin.dbf
CLOSE ALL
set default to 1mag
select 1
use magazyn index mag_naz
select 4
use defin index def_gnaz
*USE DEF_SUR INDEX DEF_GSUR,DEF_SSUR
do while.not.eof()
    w=w+1
      if w>dlugosc_str
	    eject
        w=prow()
		lstrona=lstrona+1
		norm_tyt(lstrona)
		w=prow()
	  endif	
    lwartosc_sum=0
	lnazwa=gnazwa
	lkod=gkod
    @ w,0 say ltx0
    w=w+1	
    @ w,0 say ltx0
    w=w+1					  
    lnum=lnum+1
    @ w,0 say "|"
    @ w,1 say lnum picture "9999"
    @ w,7 say gnazwa
    @ w,41 say gkod
    
	do while gnazwa=lnazwa.and.gkod=lkod.and..not.eof()
      lsnazwa=snazwa
	  bil_jm=sjm
	  lscena=0
	  select 1
	  seek lsnazwa
	  if found()
	    lmjm=mjm
	    lscena=mcen_m
		lscena=kor_jm_cen(bil_jm,lmjm,lscena)
	  else
	    set device to screen
		kj_tkom(10," Uwaga ! ","Skladnik nie odnaleziony w wyrobie",lnazwa,lsnazwa,5)
	    set device to printer
	  endif
	  select 4
	  lwartosc_sum=lwartosc_sum+silosc*lscena
	  @ w,49 say snazwa
	  @ w,84 say skod
	  @ w,92 say silosc
	  @ w,103 say sjm
	  @ w,107 say lscena picture "9999999.99"
      @ w,118 say lscena*silosc picture "9999999.99"
      @ w,129 say "|"
	  skip
	  w=w+1
      if w>dlugosc_str
	    eject
        w=prow()
		lstrona=lstrona+1
        norm_tyt(lstrona)
		w=prow()
        w=w+1
        @ w,0 say ltx0
        w=w+1	
        @ w,0 say ltx0
        w=w+1					  		
	  endif
	  @ w,0 say "|"
	enddo
    @ w,117 say "----------- |"
	w=w+1
	@ w,0 say "|"
	@ w,105 say "R a z e m :" 
	@ w,118 say lwartosc_sum picture "9999999.99"
	@ w,129 say "|"
    w=w+1
	@ w,0 say ltx0
	w=w+1
	@ w,0 say "|"
	@ w,1 say replicate(chr(196),127)
	@ w,129 say "|"
enddo
eject
close all
set device to screen
lcolor=setcolor()
if plikdruk
  zz=.t.
  do gkom with "Edycja na ekranie ? [T/N]  ",zz
  if lastkey()#27.and.zz
    run ne &plik
  endif
endif
kj_tkom(8,"","Drukowanie zakonczone","","Nacisnij dowolny klawisz.  Ok!",5)		  		  
setcolor(lcolor)
RETURN nil


FUNCTION OLD_NORM_TYT(pstrona)
local ltx1:="=================================================================================================================================="
local ltx2:="| Nr  | Nazwa wyrobu lub polwyrobu      |  Kod  |  Skladniki:  Nazwa               | Kod   | Ilosc    |J.m| Cena     | Wartosc   |"
local ltx3:="|=====|=================================|=======|==================================|=======|==========|===|==========|===========|"
local ltx4:="|                                                                                                                                |"
local ltx5:="|                                                                                                                                |"
@ w,0 say "Normatywy wyrobow gotowych i polwyrobow.                                                                Strona:"        
@ w,110 say pstrona picture "99999"
w=w+1
@ w,0 say ltx1
w=w+1
@ w,0 say ltx2
w=w+1
@ w,0 say ltx3
*w=w+1
*@ w,0 say ltx4
*w=w+1
*@ w,0 say ltx5
*w=w+1
RETURN nil


FUNCTION BIL_ZAMK_OLD()
local ek,lcolor:=setcolor(),lmag:=1,lwmagil
local lmagtxt,lmiesiac:=bil_num_mies,lcykl:=1
save screen to ek
select 1
pmagdefault(1)
use magazyn index mag_naz    &&potrzebny do porownania mjm
*do while .t.
*  select 2
*  pmagdefault(lmag)
*  if.not.file("magazyn.dbf")
*    lwmagil=lmag-1
*    lmagtxt=str(lwmagil)
*	kj_tkom(8," Operacja zakonczona ",;
*	         "Program przeanalizowal magazyny w ilosci",;
*			 lmagtxt,;
*			 "Nacisnij dowolny klawisz",5)
*	exit
*  endif
*  lmag=lmag+1
*enddo

  if.not.bom(lmiesiac)   &&Kopiowanie bom do bzm z uwzglednieniem ew. zmian mjm
    kj_tkom(8," Uwaga ! ","Blad w bazach magazynowych","Prawdopodobnie brak zamkniecia miesiaca poprzedniego",;
            "Popraw i ponow probe.  Nacisnij dowolny klawisz.",5)
    return
  endif    
select 1
close all
pmagdefault(1)
use magazyn index mag_naz
select 2
pmagdefault(1)
bz_use(bil_num_mies)
do skom with "Dostosowuje jedn. miary w BZ do istniejacych w magazynie. Przelicza il. i ceny" 
do while.not.eof()
  @ 24,2 say mnaz
  lmnaz=mnaz
  bil_jm=mjm
  select 1
  seek lmnaz
  if found()
    bil_jm=mjm
  endif
  select 2
  if mjm#bil_jm
    lmil=mil
	lmjm=mjm
	lmcen_m=mcen_m
	replace mjm with bil_jm
	replace mil with kor_jm_il(bil_jm,lmjm,lmil)
	replace mcen_m with kor_jm_cen(bil_jm,lmjm,lmcen_m)    
  endif
  skip
enddo


select 3
pelny=.f.
do while.t.
  set default to 1dok
  close 
  do case
    case lcykl=1
      do skom with "Dodaje do BZ zakupy"
	  use zakup
      index on tnaz to t_naz
      use zakup index t_naz	  
    case lcykl=2
	  do skom with "Dodaje do BZ produkcje"
      use mmdok
      index on tnaz to t_naz
      use mmdok index t_naz	  	  
    case lcykl=3
	  do skom with "Odejmuje od BZ sprzedaz krajowa"
      use sprzedaz	  	  
      index on tnaz to t_naz
      use sprzedaz index t_naz	  	  	  
    case lcykl=4
	  do skom with "Odejmuje od BZ sprzedaz exportowa"
      use sp_expo	  	  
      index on tnaz to t_naz
      use sp_expo index t_naz	  	  	  	  
  endcase

  set filter to month(tdat)=bil_num_mies
  go top
  do while.not.eof()
    @ 24,2 say tnaz
	ltnaz=tnaz
	bil_jm=tjm
	lil_sum=0
	do while tnaz=ltnaz
	  ltjm=tjm
	  ltil=til
	  lil_sum=lil_sum+kor_jm_il(bil_jm,ltjm,ltil)
	  skip
	enddo
	 	
	select 2
	seek ltnaz
	if found()
	  bil_jm1=mjm
	  if lcykl<3
	    replace mil with mil+kor_jm_il(bil_jm1,bil_jm,lil_sum)
	  else	
	    replace mil with mil-kor_jm_il(bil_jm1,bil_jm,lil_sum)
	  endif
	else
	  select 3
	  ltkod=tkod
      ltjm=bil_jm   &&jednostka w ktorej nastepowalo zliczanie
	  ltstawka=tstawka
	  ltnmag=tnmag
	  ltsymbol=tsymbol
	  ltster=tster
	  select 1
	  seek ltnaz
	  if found()
	    bil_jm=mjm
	  endif
	  select 2
	  if ltjm#bil_jm
	    lil_sum=kor_jm_il(bil_jm,ltjm,lil_sum)
		ltjm=bil_jm 
	  endif
	  if lcykl>=3
	    lil_sum=-1*lil_sum
	  endif
	  append blank
	  replace mnaz with ltnaz,mkod with ltkod,mil with lil_sum
	  replace mjm with ltjm,mstawka with ltstawka,nmag with ltnmag
	  replace msymbol with ltsymbol,mster with ltster
      do case
	    case substr(ltkod,1,2)="01"
		  replace magaz with 1
	    case substr(ltkod,1,2)="03"
		  replace magaz with 3
	    case substr(ltkod,1,2)="04"
		  replace magaz with 4		  		  
	  endcase
	endif
	select 3
  enddo
  lcykl=lcykl+1
  if lcykl>4.or.lcykl=4.and..not.file("sp_expo.dbf")
    exit
  endif
enddo
select 1
close
select 3
close
select 4
close
set default to 1mag
use defin
do skom with "Korekta jednostek i ilosci w definicjach wyrobow"
do while .not.eof()
  @ 24,2 say snazwa
  lsnazwa=snazwa
  select 2
  seek lsnazwa
  lfound=found()
  if lfound
    bil_jm=mjm
  endif
  select 4
  if lfound
    if bil_jm#sjm
	  lsilosc=silosc
	  lsjm=sjm
	  replace silosc with kor_jm_il(bil_jm,lsjm,lsilosc)
	  replace sjm with bil_jm
	endif
  else
    if kj_gkom(8," Skladnik wyrobu gotowego nie odnaleziony.",lsnazwa,"Wydrukowac ?",.t.,5)
      set device to printer
	  w=prow()
	  @ w,0 say "Wyrob:"
	  @ w,15 say gnazwa
	  @ w,50 say gkod
	  w=w+1
	  @ w,0 say "Skladnik:"
	  @ w,15 say snazwa
	  @ w,50 say skod
	  w=w+2
	  @ w,0 say " "
	  set device to screen
	endif
  endif  
  skip
enddo
select 2
close
select 4
close
restore screen from ek
close all
RETURN nil


FUNCTION WYR_IL(pmnaz,pmkod)
local select:=select()
set default to 1mag
*use bo_m new
if bo_use(bil_num_mies)
  seek pmnaz
  if.not.found()
    kj_tkom(8," Uwaga ! ","Pozycja w BO nie odnaleziona",pmnaz,"Popraw i ponow probe",5)
  else
    pil=mil
  endif
  close
endif
set default to 1dok
use zakup
t_filtr()
do while.not.eof()
  pil=pil+til
  skip
enddo
RETURN pil


FUNCTION WYR_ZNAK()
local ek
save screen to ek
do skom with "Kodowanie wyrobow i polwyrobow"
  set default to 1mag
  if file("defin.dbf")
    select 1
	close
    bz_use(bil_num_mies)
	select 2
    close
    use defin index def_gnaz
	select 1
	do while.not.eof()
	  lmnaz=mnaz
	  lmkod=mkod
	  select 2
	  seek lmnaz
	  lfound=found()
	  select 1
	  if lfound
	    replace mster with stuff(mster,3,1,"w")
      else
        replace mster with stuff(mster,3,1," ")
	  endif
	  skip
	enddo 
  else
    @ 10,10 say "Brak definicji wyrobow gotowych. Ok!"
	inkey(5)
  endif
  restore screen from ek
select 1
close
select 2
close
RETURN nil

FUNCTION SUR_SUM()
local ek, sur_all:=0,prod_all:=0,tow_all:=0,nic_all:=0,w
save screen to ek
select 1
set default to 1dok
close all
use bilp_sur
do while.not.eof()
  do case
    case substr(tkod,1,2)="01"
	  prod_all=prod_all+til*tcen
    case substr(tkod,1,2)="03"
	  sur_all=sur_all+til*tcen	  
    case substr(tkod,1,2)="04"
	  tow_all=tow_all+til*tcen	  
	otherwise
	  nic_all=nic_all+til*tcen	  
	  
  endcase
  skip
enddo
do startdruk
set device to printer
w=prow()
@ w,0 say "A N A L I Z A    P R O D U K C J I   -   Z U Z Y C I E    M A T E R I L O W"
w=w+1
@ w,0 say "==========================================================================="
w=w+3
@ w,0 say "Za miesiac:"
@ w,15 say bil_miesiac
w=w+10
@ w,0 say "Wartosc przetworzonych surowcow ............................"
@ w,61 say sur_all picture "9999999.99"
w=w+2
@ w,0 say "Wartosc wykorzystanych w zestawach towarow handlowych ......."
@ w,61 say tow_all picture "9999999.99"
w=w+2
@ w,0 say "Wartosc wykorzystanych w zestawach produktow ................"
@ w,61 say prod_all picture "9999999.99"
w=w+2
@ w,61 say "----------"
w=w+2
@ w,0 say "                                          R A Z E M :        "
@ w,61 say tow_all+sur_all+prod_all picture "9999999.99"
set device to screen
@ prow(),pcol() say chr(18)
eject
close all
lcolor=setcolor()
if plikdruk
  zz=.t.
  do gkom with "Edycja na ekranie ? [T/N]  ",zz
  if lastkey()#27.and.zz
    run ne &plik
  endif
endif
RETURN nil

FUNCTION KK_PUSTY()
local lil
sum til to lil
go top
if lil=0
  return .t.
else
  return .f.
endif    
RETURN NIL


*******************************************************************************
* Funkcja przetwarza proceduty zlozone na proste tz. WYROB - SUROWCE          *
* Plik wynikowy DEF_SUR.DBF ma zadeklarowana ilosc z dokladnoscia do 4 miejsc *
*******************************************************************************
FUNCTION DEFIN_S()
local start,last,recno,recno1
local lgnazwa,lgkod,lsnazwa,lskod,lsilosc,lsjm,lscena
local asnazwa,askod,asilosc,asjm,ascena
pmagdefault(1)
if.not.file("def_sur.dbf")
  def_sur_tworz()
else
  use def_sur index def_gsur,def_ssur new
  zap
  use
endif
use def_sur new
index on gnazwa+gkod to def_gsur
index on snazwa+skod to def_ssur
use
use def_sur index def_gsur,def_ssur new
sel_sur=select()
use defin new
sel_def=select()
do while.not.eof()  &&przepisuje defin.dbf do def_sur.dbf
  lgnazwa=gnazwa
  lgkod=gkod
  lsnazwa=snazwa
  lskod=skod
  lsilosc=silosc
  lsjm=sjm
  lscena=scena
  select &sel_sur
  append blank
  replace gnazwa with lgnazwa,gkod with lgkod,snazwa with lsnazwa
  replace skod with lskod,silosc with lsilosc,sjm with lsjm,scena with lscena 
  select &sel_def
  skip
enddo
use
select &sel_sur
last=lastrec()
start=last
clear
do while.t.            &&Usuwanie ze skladnikow pozycji zlozonych (polwyrobow)
  do while.not.eof()
	lgnazwa=gnazwa
	lgkod=gkod
    do while gnazwa=lgnazwa.and.gkod=lgkod
	  recno=recno()
	  lsnazwa=snazwa
	  lskod=skod
	  lsilosc=silosc
      if kj_dseek(lsnazwa,lskod)
	    do while gnazwa=lsnazwa.and.gkod=lskod
		  recno1=recno()
		  asnazwa=snazwa
		  askod=skod
		  asilosc=silosc
		  asjm=sjm
		  ascena=scena
		  append blank
		  replace gnazwa with lgnazwa,gkod with lgkod,snazwa with asnazwa
		  replace skod with askod,silosc with lsilosc*asilosc,sjm with asjm
		  replace scena with ascena
		  go recno1
		  skip
		enddo
	    go recno
	    delete		
      else
        go recno	  
	  endif
	  skip
	enddo	
  enddo
  pack
  last=lastrec()
  if last=start
    exit
  else
    start=last
  endif
enddo
********** Porzadkowanie: podsumowanie skladnikow jednakowych 
index on gnazwa+gkod+snazwa+skod+sjm to def_gs
use
use def_sur index def_gs,def_gsur,def_ssur
do while.not.eof()
  recno=recno()
  lgnazwa=gnazwa
  lgkod=gkod
  lsnazwa=snazwa
  lskod=skod
  lsjm=sjm
  lsilosc=0
  do while gnazwa=lgnazwa.and.gkod=lgkod.and.snazwa=lsnazwa.and.skod=lskod.and.sjm=lsjm
    lsilosc=lsilosc+silosc
    skip
  enddo	
  go recno
  replace silosc with lsilosc
  skip
  do while gnazwa=lgnazwa.and.gkod=lgkod.and.snazwa=lsnazwa.and.skod=lskod.and.sjm=lsjm
    delete
    skip
  enddo	
enddo
pack
use
RETURN nil
