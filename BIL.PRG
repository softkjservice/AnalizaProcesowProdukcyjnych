local ek,ek1,ek2,ltnaz,ltkod,ltil,lfound:=.f.,lcolor,lzak_menu:=0
local lbelka:="°  Zakupy  °  Produkcja  °  Sprzedaz  °  Magazyn  °  Inne  °  Koniec °"
local lliter:="   Z          P             S            M           I        K       "
local lmies:=month(date()),lbil_miesiac:="",ltak:=.f.
local lpoz:=1,topis[20], i:=0
public zsred_plac:=0
public z_eksport,z_eksp_plik,z_ue_plik,plikdruk
public baz_all:=.t.
private v_bom:=.f.,v_marza:=.f.
dlugosc_str=58
*plikdruk=.t.
plik:="\kjbil.txt"
bil_dat:=date()
*set fixed on
*set decimals to 8
set delete on
set date to german
public bil_miesiac:=" Pelna dostepna baza",bil_num_mies:=0
public wyrob_mag:=.f.,polwyrob_mag:=.f.,surowiec_mag:=.f.,handel_mag:=.f.
public mag_warunek:=".t.",dok_warunek:=".t.",mag_prod_war:=".t.",bil_upraw:=0
public sukces:=.t.,b_magtyt:="WYROBY GOTOWE + POLWYROBY + SUROWCE + TOWARY"
for i=1 to 20
  topis[i]=space(80)
next
topis[1]="Wydruk bilansu otwarcia miesiaca dla wybranego magazynu"
topis[2]="Analiza BO oraz dokumentow zakupu"
topis[3]="Analiza produkcji - ceny srednie wyrobow, normatywy"
topis[4]="Import bazy sprzedazy eksportowej oraz przeliczenia zgodne z kursem dnia"
topis[5]="Sprzedaz krajowa i eksportowa w cenach magazynowych, placa w sprzedanych wyrob."
topis[6]="Wybor magazynu, wydruk bilansu zamkniecia miesiaca"
topis[7]="Ustalenie :  wydruk na drukarke  lub do pliku"
topis[8]="Koniec pracy w programie BILANS"
topis[9]="Koniec pracy w programie BILANS"
druk_public()
set default to leg01
if file("drukarki.dbf")
  if kj_use("drukarki",.f.,3)
    locate for dr="*"
	if.not.found()
	  go top
	endif
    druk_lad()	
    use
  endif
endif

**
set default to kas_baz
if.not.file("b_setup.dbf")
  b_setup_tworz()
  use b_setup new
  append blank
else
  use b_setup new
endif
z_eksport=eksport
z_eksp_plik=eksp_plik
z_ue_plik=ue_plik
plikdruk=plik
use
setcolor("n/n+")
kas_setup()
clear
bil_tlo()
kj_okno(0,0,10, "  USREDNIENIE CEN    ANALIZA MIESIACA                                           ",1)
kj_okno(18,0,5, "         A K T U A L N E      P A R A M E T R Y      P R O G R A M U            ",2)

lcolor=setcolor()
do skom with "Wpisz haslo i zatwierdz klawiszem [Enter]"
set color to
bil_upraw=kj_haslo(0,46,bil_upraw)
if bil_upraw=0
  clear
  return
endif
setcolor(lcolor)
save screen to ek
*restore screen from ek
set color to "n/w,w/n"
@ 2,27 say "Wybierz miesiac do analizy"
      do miesiac with 4,32,lmies,lbil_miesiac
	  if lastkey()=27
	    bil_num_mies=1
		bil_miesiac="Pelna dostepna baza"
        if .not.kj_gkom(10," Uwaga!!","Analiza obejmie cala dostepna baze bez podzialu","na miesiace.  Wykonac ?",.t.,5)
          return
		endif
      else
	    bil_miesiac=lbil_miesiac
        bil_num_mies=lmies        
        baz_all=.f.
	  endif
restore screen from ek
bil_paramsay()
save screen to ek
lsrednia=kj_gkom(9,"","Aktualizowac ceny srednie oraz ilosci ","zgodnie z dokumentami ?",.f.,5)
restore screen from ek
            if lsrednia
              imp_expo()
			  close all 
			  if bil_zamk()
			    kj_tkom(9,"","Analiza ilosciowa oraz","usrednianie cen zakonczone pomyslnie","Nacisnij dowolny klawisz.  Ok!",5)		  		    
			  else
			    kj_tkom(9,"","Wykryto bledy. Poprawne usrednienie cen nie bylo mozliwe","Popraw i ponow probe.","Nacisnij dowolny klawisz.  Ok!",5)		  		    
			  endif
			endif  
restore screen from ek
ek1=ek
do while .t.                 &&"° Start ° Parametry ° kopiA ° pOmoc ° Koniec °"
  lpoz=menu_poziom(1,0,8,lbelka,lliter,topis,lpoz,.f.,.f.)   &&Menu glowne
  if lastkey()=27
    exit
  endif
  do case
	case lpoz=1                   &&Zakupy 
      close all
	  save screen to ek
	  lzak_menu=1
	  do while.t.
	    lzak_menu=b_zak_menu(lzak_menu)
        do case
	      case lastkey()=27
		    exit
	      case lzak_menu=1
		    plik="\b_zakdok.txt"
	        zakup_druk()
		  case lzak_menu=2
            plik="\b_zakup.txt"
            zakup_bo()
	    endcase	
	  restore screen from ek
	  enddo	
	  close all

	case lpoz=2                    &&Produkcja
	  close all
	  lprod_menu=1
  	  save screen to ek
	  do while.t.
	    lprod_menu=b_prod_menu(lprod_menu)
        do case
	      case lastkey()=27
		    exit
	      case lprod_menu=1
		    plik="\b_mmdok.txt"        
		    mm_druk()
	      case lprod_menu=2
		    plik="\b_norm.txt"        
            bil_norm_druk()		  		  
	    endcase	
	  restore screen from ek
	  enddo	
      close all

    case lpoz=3                &&Sprzedaz
	  close all
	  save screen to ek
	  lsp_menu=1
	  do while.t.
	    lsp_menu=b_sp_menu(lsp_menu)
        do case
	      case lastkey()=27
		    exit
	      case lsp_menu=1
            lsp1_menu=1
			save screen to ek1
			do while.t.
			  lsp1_menu=b_sp1_menu(lsp1_menu)
			  do case
			    case lastkey()=27
				  exit
				case lsp1_menu=1
		          plik="\b_sprz_k.txt"
                  if.not.sprzedaz_druk(lsp_menu)
			        return
			      endif			
			    case lsp1_menu=2
		          plik="\b_sp_szk.txt"
		  	      sp_kraj=.t.
			      sp_export=.f.
			      v_marza=kj_gkom(8,"","Wydrukowac marze ?","",v_marza,5)
                  sprzed_druk(lsp_menu)			
			      v_marza=.f.		  				  	
			  endcase
			  restore screen from ek1
			enddo  
			

	      case lsp_menu=2
            save screen to ek1
			if kj_gkom(8,"","Przeliczyc baze sprzedazy exportowej na zlotowki ?","",.t.,5)
	          close all
              imp_expo()
	          close all			  
			endif
			lsp1_menu=1
			do while .t.
			  lsp1_menu=b_sp1_menu(lsp1_menu)
			  do case
			    case lastkey()=27
				  exit
			    case lsp1_menu=1
		          plik="\b_sprz_e.txt"
                  if.not.sprzedaz_druk(lsp_menu)
			        return
			      endif			
			    case lsp1_menu=2
		          plik="\b_sp_sze.txt"
		  	      sp_kraj=.f.
			      sp_export=.t.
			      v_marza=kj_gkom(8,"","Wydrukowac marze ?","",v_marza,5)
                  sprzed_druk(lsp_menu)			
			      v_marza=.f.		  				  	
			  endcase
			  restore screen from ek1			  
			enddo


*217
	      case lsp_menu=3
            save screen to ek1
			if kj_gkom(8,"","Przeliczyc baze sprzedazy UE na zlotowki ?","",.t.,5)
	          close all
              imp_expo()
	          close all			  
			endif
			lsp1_menu=1
			do while .t.
			  lsp1_menu=b_sp1_menu(lsp1_menu)
			  do case
			    case lastkey()=27
				  exit
			    case lsp1_menu=1
		          plik="\b_sprz_u.txt"
                  if.not.sprzedaz_druk(lsp_menu)
			        return
			      endif			
			    case lsp1_menu=2
		          plik="\b_sp_szu.txt"
		  	      sp_kraj=.f.
			      sp_export=.t.
			      v_marza=kj_gkom(8,"","Wydrukowac marze ?","",v_marza,5)
                  sprzed_druk(lsp_menu)			
			      v_marza=.f.		  				  	
			  endcase
			  restore screen from ek1			  
			enddo			
	    endcase	
	  restore screen from ek
	  enddo	
	  close all

	case lpoz=4                    &&Magazyn	  
	  lmag_menu=1
  	  save screen to ek
	  do while.t.
	    lmag_menu=b_mag_menu(lmag_menu)
        do case
	      case lastkey()=27
		    exit
	      case lmag_menu=1
		   lmag1=1
		   do while.t.
		     lmag1=b_mag1_menu(lmag1)   &&lma1=1 - bo_m  lmag1=2 - bz_m
             if lastkey()=27
			   exit
			 endif			 
			 save screen to ek2
			 do while.t.
			   wybor_mag()               &&wyroby,surowce,polwyroby czy towary ?
               if lastkey()=27
			     restore screen from ek2
				 exit
			   endif
			   pmagdefault(1)
			   select 1
			   close all
			   do case
			     case lmag1=1
			       bo_use(bil_num_mies)
				   plik="\b_bomag.txt"
			       v_bom=.t.
				 case lmag1=2
			       bz_use(bil_num_mies)
				   plik="\b_bzmag.txt"
				   v_bom=.f.				 
			   endcase
               set filter to &mag_warunek
			   go top
               do magazdruk
	           use
			 enddo  
		   enddo	 

		  case lmag_menu=2
            ceny_bz_mag()
			
		  case lmag_menu=3
            stany_mag()			
	    endcase	
	  restore screen from ek
      bil_paramsay()
	  enddo	      
	  close all


    case lpoz=5
	  lb_inne=1
	  do while.t.
	    lb_inne=b_inne_menu(lb_inne)
	    if lastkey()=27
		  exit
		endif		
		do case
		  case lb_inne=1
		    has_new(6,20,12)
		  case lb_inne=2
		    setup()
          case lb_inne=3
		    druk_wybor(6,25)
		endcase
	  enddo
    case lpoz=6
	  close all
      set color to
	  clear
	  return
	case lpoz=7                    &&Koniec menu glownego
	  plikdruk=kj_gkom(8,"","Drukowac do pliku ?","",plikdruk,5)
    case lpoz=8

  endcase
restore screen from ek
bil_paramsay()
enddo
set color to
clear
RETURN

******************************************************************************
******************************************************************************
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





FUNCTION BIL_PARAMSAY()
setcolor("n/w,w/n")
@ 19,2 say " Za miesiac..........."

@ 19,50 say " DATA ......."        
@ 19,25 say space(20)
@ 19,25 say bil_miesiac
*@ 21,26 say curdir()
@ 19,64 say date()
if plikdruk
  @ 20,2 say " Wydruk skierowany do pliku   "
else
  @ 20,2 say " Wydruk skierowany na drukarke"
endif
if z_eksport
  @ 21,2 say " Plik sprzedazy w UE       "
  @ 22,2 say " Plik sprzedazy exportowej:"
  @ 21,30 say z_ue_plik
  @ 22,30 say z_eksp_plik
else
  @ 22,2 say space(77)
endif
setcolor("w/b/b/w")
@ 3,58 to 5,76
@ 4,60 say "Soft-KJ-Service"
RETURN (NIL)


FUNCTION KAS_SETUP
use setup new
zdok_baz=dok_baz
zkon_baz=kon_baz
zarch_baz=arch_baz
zkod_kas=kod_kas
zkonto=konto
zobca_walut=obca_walut
zfis_kas=fis_kas
close
RETURN (NIL)




FUNCTION BIL_POMOC()
local ltytul:="          T D _ F I R M A      TRANSMISJA DOKUMENTOW OBROTU TOWAROWEGO          "   
local ek
save screen to ek
kj_okno(0,0,24,ltytul,1)
@ 2,1 say "     Program SH_FIRMA umozliwia transmisje dokumentow zarejestrowanych        "
@ 3,1 say " z wykorzystaniem programow SH_FIRMA oraz M_FIRMA w katalogu zdefiniowanym    "
@ 4,1 say " jako zrodlowy do katalogu zdefiniowanego jako docelowy. W wyniku dzialania   "
@ 5,1 say " programu w bazie docelowej pojawia sie dokumenty (lub wybrana ich grupa)     "
@ 6,1 say " z bazy zrodlowej oraz uzupelniona zostanie kartoteka kontrahentow i magazy-  "
@ 7,1 say " nowa o te pozycje, ktore w bazie docelowej nie wystepowaly. Stany magazynowe "
@ 8,1 say " pozycji wczesniej wystepujacych sa korygowane.                               "
@ 9,1 say "    OPIS MENU GLOWNEGO :                                                      "
@ 10,1 say " 1: Start - rozpoczecie transmisji poprzedzone wykonaniem kopii bezpieczenstwa"
@ 11,1 say "    bazy danych z katalogu docelowego.                                        "
@ 12,1 say " 2: Parametry - mozliwosc zdefiniowania katalogu zrodlowego, docelowego       "
@ 13,1 say "    oraz przeznaczonego do przechowywania kopii zapasowej bazy docelowej.     "
@ 14,1 say "    - wybor rodzaju dokumentow oraz wyznaczenie okresu objetego transmisja.   "
@ 15,1 say " 3: Kopia - mozliwosc wykonania kopii zapasowej bazy danych z katalogu        "
@ 16,1 say "    docelowego oraz rekonstrukcji bazy docelowej.                             "
@ 17,1 say " 5: Zakonczenie programu i powrot do systemu operacyjnego.                    "
@ 18,1 say " MENU moze byc obslugiwane z wykorzystaniem myszki, strzalek oraz             "
@ 19,1 say " wyroznionych klawiszy skrotow.                                               "  
@ 20,1 say replicate("Ä",78)
@ 21,1 say " Producent : Soft-KJ-Service  05-120 Legionowo ul. Hetmanska 63               "
@ 22,1 say " Informacje techniczne - mgr inz. Krzysztof Jaworski    Tel: 090 21 26 40     "
@ 24,30 say "  Nacisnij dowolny klawisz  "
inkey(0)
restore screen from ek
RETURN nil

FUNCTION BIL_TLO()
local lcolor:=setcolor()
set color to "gr+/n,n/gr+"
@ 11,0 say "°     ÍË ÉÍ   ÉÍÍÍ»                                                            °"
@ 12,0 say "°      ºÉ¼        º                                                            °"
@ 13,0 SAY "°      ÌÊ»        º   ÍÍÍ    R O Z L I C Z E N I E      M I E S I A C A        °"
@ 14,0 say "°     ÍÊ ÈÍ       º                                                            °"
@ 15,0 say "°             ÉÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ     °"
@ 16,0 say "°             ÈÍÍÍ¼                                                            °"
@ 17,0 SAY "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
setcolor(lcolor)	
RETURN NIL

FUNCTION BIL_PARAM()
local lcolor:=setcolor(),ek,ltyp,lpoz1:=1
local ltnaz[2],ltlit[2],ltopis[2],lpoz:=1,lbelka:=""
local lmies:=month(date()),lbil_miesiac:=bil_miesiac
ltnaz[1]:=" Miesiac "
ltnaz[2]:=" mAgazyn "
ltlit[1]:=" M              "
ltlit[2]:="  A             "
ltopis[1]:=" Wybor miesiaca do analizy "
ltopis[2]:=" Wybor magazynu do analizy "

do while.t.
  save screen to ek
  lpoz=men_pion(2,1,2,lbelka,ltnaz,ltlit,ltopis,lpoz)
  do case
    case lastkey()=27
      exit
    case lpoz=1
      do miesiac with 4,10,lmies,lbil_miesiac
	  if lastkey()=27
	    bil_num_mies=0
		bil_miesiac="Pelna dostepna baza"
      else
	    bil_miesiac=lbil_miesiac
        bil_num_mies=lmies        
	  endif
  	case lpoz=2
      wybor_mag()
  endcase
  restore screen from ek
  bil_paramsay()
enddo  
setcolor(lcolor)
RETURN NIL

*******************************************************************************
* Wybor obslugiwanego magazynu                                                *
*******************************************************************************
FUNCTION WYBOR_MAG()
local lcolor:=setcolor(),ek,ltyp,lpoz1:=1
local ltnaz[5],ltlit[5],ltopis[5],lpoz:=0,lbelka:=""
ltnaz[1]:=" Wyroby gotowe       "
ltnaz[2]:=" Polfabrykaty        "
ltnaz[3]:=" Surowce i materialy "
ltnaz[4]:=" Towary handlowe     "
ltnaz[5]:=" Razem polaczone    "
ltlit[1]:=" W                   "
ltlit[2]:=" P                   "
ltlit[3]:=" S                   "
ltlit[4]:=" T                   "
ltlit[5]:=" R                   "
ltopis[1]:=" Magazyn wyrobow gotowych  "
ltopis[2]:=" Magazyn polfabrykatow     "
ltopis[3]:=" Magazun surowcow i materialow"
ltopis[4]:=" Magazyn towarow handlowych"
ltopis[5]:=" Wszystkie magazyny lacznie"
save screen to ek
  lpoz=men_pion(4,52,5,lbelka,ltnaz,ltlit,ltopis,lpoz)
  bil_mag(lpoz)
*  restore screen from ek
  bil_paramsay()
setcolor(lcolor)
RETURN NIL

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
	  mag_warunek:='substr(mkod,1,2)="02"'	    
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


FUNCTION B_ZAK_MENU(ppoz)
local ltnaz[2],ltlit[2],ltopis[2],lbelka:="",lpoz:=ppoz
ltnaz[1]:="Dokumenty          "
ltnaz[2]:="Usrednianie cen    "
ltlit[1]:="D                  "
ltlit[2]:="U                  "
ltopis[1]:="Wydruk dokumentow z wyszczegolnieniem zakupow z poszczegolnych grup towarowych"
ltopis[2]:="Wydruk BO oraz doknmentow zakupu dla wszystkich poz. magazynowych "
save screen to ek
  lpoz=men_pion(2,1,2,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz

FUNCTION B_SP_MENU(ppoz)
local ltnaz[3],ltlit[3],ltopis[4],lbelka:="",lpoz:=ppoz
ltnaz[1]:=" Krajowa    "
ltnaz[2]:=" Eksportowa "
ltnaz[3]:=" Eksport UE "
ltlit[1]:=" K          "
ltlit[2]:=" E          "
ltlit[3]:="         U  "
ltopis[1]:="Analiza sprzedazy krajowej z podzialem na grupy towarowe "
ltopis[2]:="Analiza sprzedazy eksportowej z podzialem na grupy towarowe "
ltopis[3]:="Analiza sprzedazy eksportowej UE z podzialem na grupy towarowe "
save screen to ek
  lpoz=men_pion(2,26,3,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz

FUNCTION B_SP1_MENU(ppoz)
local ltnaz[2],ltlit[2],ltopis[4],lbelka:="",lpoz:=ppoz
ltnaz[1]:=" Dokumenty "
ltnaz[2]:=" Towary    "
ltlit[1]:=" D         "
ltlit[2]:=" T         "
ltopis[1]:="Wydruk dokumentow sprzedazy z podzialem na grupy towarowe "
ltopis[2]:="Wydruk towarow sprzedanych oraz dokumentow z nimi zwiazanych"
save screen to ek
  lpoz=men_pion(4,38,2,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz

FUNCTION B_MAG_MENU(ppoz)
local ltnaz[3],ltlit[3],ltopis[3],lbelka:="",lpoz:=ppoz
ltnaz[1]:=" W y d r u k  "
ltnaz[2]:=" Ceny srednie "
ltnaz[3]:=" Podmagazyny  "
ltlit[1]:=" W           "
ltlit[2]:=" C           "
ltlit[3]:=" P           "
ltopis[1]:="Wybor wybranego magazynu "
ltopis[2]:="Uaktualnienie cen srednich we wszystkich magazynach"
ltopis[3]:="Analiza stanow w magazynie glownym i podmagazynach"
save screen to ek
  lpoz=men_pion(2,39,3,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz

FUNCTION B_MAG1_MENU(ppoz)
local ltnaz[2],ltlit[2],ltopis[2],lbelka:="",lpoz:=ppoz
ltnaz[1]:=" Otwarcie miesiaca  "
ltnaz[2]:=" Zamkniecie miesiaca"
ltlit[1]:=" O           "
ltlit[2]:=" Z           "
ltopis[1]:="Wydruk stanow magazynowych na poczatku miesiaca rozliczeniowego"
ltopis[2]:="Wydruk stanow magazynowych na koncu miesiaca rozliczeniowego"
save screen to ek
  lpoz=men_pion(3,46,2,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz


FUNCTION B_PROD_MENU(ppoz)
local ltnaz[2],ltlit[2],ltopis[2],lbelka:="",lpoz:=ppoz
ltnaz[1]:="Dokumenty przerobu"
ltnaz[2]:="Normatywy         "
ltlit[1]:="D                       "
ltlit[2]:="N                       "
ltopis[1]:="Wydruk dokumentow przerobu: zuzycie surowcow i polwyrobow w cenach srednich"
ltopis[2]:="Wydruk normatyw wyrobow gotowych i polwyrobow"
save screen to ek
  lpoz=men_pion(2,12,2,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz

FUNCTION B_INNE_MENU(ppoz)
local ltnaz[3],ltlit[3],ltopis[3],lbelka:="",lpoz:=ppoz
ltnaz[1]:=" Zmiana hasla  "
ltnaz[2]:=" Parametry     "
ltnaz[3]:=" Drukarki      "
ltlit[1]:=" Z             "
ltlit[2]:=" P             "
ltlit[3]:=" D             "
ltopis[1]:="Zmiana obowiazujacego hasla"
ltopis[2]:="Modyfikacja i zatwierdzanie parametrow programu"
ltopis[3]:="Wybor drukarki"
save screen to ek
  lpoz=men_pion(2,50,3,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz





*******************************************************************************
* Funkcja drukuje raport usredniania cen zakupu                                         *
*******************************************************************************

FUNCTION ZAKUP_BO()
local lmnaz,lmkod,bil_jm,lbil_cen,lnum:=0,lstrona:=1,lwyrob:=.f.
local lmjm,lbo_wartosc:=0,lbo_il:=0,ltwartosc_sum:=0,lti_sum:=0
local ltlo:=.f.,ltxt:="",k_last:=0,k_aktual:=0
local sel_bz,sel_zak,lsred_cen
local ltxt1:=""
local ltx0:="|                                                                                                                 |"
local ltyt:=""
ltyt=" C E N Y   S R E D N I E :  ANALIZA  B O  oraz DOKUMENTOW ZAKUPU"
do startdruk
set device to printer
@ prow(),pcol() say &zdr_kkond
w=prow()
@ w,7 say ltyt
w=w+1
@ w,6 say "================================================================="
w=w+3
@ w,0 say "OKRES ROZLICZENIOWY   Rok:"
@ w,26 say year(bil_dat) 
@ W,37 say "Miesiac:"
@ w,46 say bil_miesiac
w=w+3
@ prow(),pcol() say &zdr_kond
usred_tyt(lstrona)
***select 3 - BO  4-defin.dbf
set default to 1mag
bz_use(bil_num_mies)
sel_bz=select()
set filter to &mag_warunek
go top
set default to 1dok
use zakup new
sel_zak=select()
index on tnaz+tkod+tjm to tnaz1
use zakup index tnaz1
if.not.baz_all
  set filter to month(tdat)=bil_num_mies
  go top
endif  
do while.not.eof()
  ltnaz=tnaz
  ltkod=tkod
  ltjm=tjm  
  @ w,0 say ltx0
  w=w+1	
  @ w,0 say ltx0
  w=w+1					  
  lnum=lnum+1
  @ w,0 say "|"
  @ w,1 say lnum picture "9999"
  @ w,7 say ltnaz
  @ w,41 say ltkod
  select &sel_bz
  if kj_mseek(ltnaz,ltkod,ltjm)
    lbo_il=bo_il
	lbo_cen=bo_cen
      @ w,60 say "B O "
	  if bo_il>0
	    @ w,74 say bo_il picture "9999999.99"
	  else
	    @ w,74 say "     -0"
	  endif	
	  @ w,85 say ltjm
	  if bo_cen>0
	    @ w,90 say bo_cen picture "9999999.99"
	  else
	    @ w,90 say "     -0"
	  endif	
	  if bo_il>0.and.bo_cen>0
	    @ w,102 say bo_cen*bo_il picture "9999999.99"
	  else
	    @ w,102 say "     -0"
	  endif	
	  @ w,114 say"|"
  endif
  select &sel_zak
  ltil_sum=0
  ltwartosc_sum=0
  do while tnaz=ltnaz.and.tkod=ltkod.and.tjm=ltjm
	  w=w+1  
      if w>dlugosc_str
	    eject
        w=prow()
		lstrona=lstrona+1
		usred_tyt(lstrona)
		w=prow()+1
	  endif
	  ltil_sum=ltil_sum+til
	  ltwartosc_sum=ltwartosc_sum+til*tcen_m
      @ w,0 say "|"
      @ w,49 say tzewndok 
	  @ w,65 say tdat
	  @ w,74 say til picture "9999999.99"
	  @ w,85 say tjm
	  @ w,90 say tcen picture "9999999.99"
	  @ w,102 say tcen*til picture "9999999.99"
	  @ w,114 say"|"
    skip
  enddo
  if lbo_il>0.and.lbo_cen>0
    lsred_cen=(lbo_il*lbo_cen+ltwartosc_sum)/(lbo_il+ltil_sum)
  else
    lsred_cen=(ltwartosc_sum)/(ltil_sum)
  endif	
  w=w+1
  @ w,0 say "|                                                                       ----------------------------------------- |"
  w=w+1
  @ w,0 say "|"
  @ w,62 say "Razem:"
  if lbo_il>0
    @ w,74 say ltil_sum+lbo_il picture "9999999.99"	
  else
    @ w,74 say ltil_sum picture "9999999.99"	
  endif	
  @ w,85 say ltjm
  @ w,90 say lsred_cen picture "9999999.99"	
  if lbo_il>0.and.lbo_cen>0
    @ w,102 say ltwartosc_sum+lbo_il*lbo_cen picture "9999999.99"	
  else
    @ w,102 say ltwartosc_sum picture "9999999.99"	
  endif	
  @ w,114 say "|" 
  w=w+1	
  @ w,0 say ltx0
  w=w+1	
      if w>dlugosc_str
	    eject
		w=prow()
		lstrona=lstrona+1
		usred_tyt(lstrona)
		w=prow()
	  else
	    @ w,1 say replicate(chr(196),113)	
	  endif
enddo  
set device to screen
@ prow(),pcol() say &zdr_kkond
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

kj_tkom(8,"","Drukowanie zakonczone","","Nacisnij dowolny klawisz.  Ok!",5)		  		  
setcolor(lcolor)
RETURN nil


FUNCTION USRED_TYT(pstrona)
local ltx1:="==================================================================================================================="
local ltx2:="| Nr  |                                 |  Kod  | Numer dokum.  |  Data  | ILosc    |J.m.| Cena      | Wartosc    |"
local ltx3:="|=====|=================================|=======|===============|========|==========|====|===========|============|"
local ltx4:="|                                                                                                                 |"
local ltx5:="|                                                                                                                 |"
do case
  case wyrob_mag
	ltxt1="Nazwa wyrobu gotowego"
  case polwyrob_mag
	ltxt1="Nazwa polwyrobu"
    
  case surowiec_mag
	ltxt1="Nazwa surowca lub materialu"
  case handel_mag
	ltxt1="Nazwa towaru handlowego"
  otherwise
	ltxt1="Nazwa pozycji magazynowej"
endcase
ltx2=stuff(ltx2,9,len(ltxt1),ltxt1)
    @ w,0 say "Analiza BO oraz dokumentow zakupu.  Usrednianie cen zakupu.                                             Strona:"        
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




*******************************************************************************
* Funkcja drukuje normatywy wyrobow z pliku defi_new.dbf                      *
* Oblicza wartosc wyrobu w oparciu o ceny srednie z konca miesiaca (z bz*.dbf)*
*******************************************************************************
FUNCTION BIL_NORM_DRUK()
local lgnazwa,lgkod,lnum:=0,lstrona:=1,ek,lsnazwa,lscena,lsjm,lsilosc
local sel_bz,sel_def,lwartosc_sum:=0,ltxt1:="",ltyt:="",lbz:=.t.,lgnum:=0
local ltx0:="|                                                                                                                                |"
ltyt="   N O R M A Y W Y    ZUZYCIA  SUROWCOW  I  MATERIALOW"
set device to printer
do startdruk
@ prow(),pcol() say &zdr_kkond
w=prow()
@ w,11 say ltyt
w=w+1
@ w,10 say "========================================================="
w=w+3
@ w,0 say "OKRES ROZLICZENIOWY   Rok:           Miesiac:"
@ w,26 say year(bil_dat) 
@ w,46 say bil_miesiac
w=w+3
@ prow(),pcol() say &zdr_kond
norm_tyt(lstrona)
set default to 1mag
if.not.bz_use(bil_num_mies)
  lbz=.f.
else
  sel_bz=select()
endif  
use defi_new new
index on gnazwa+gkod to def_gnaz
use defi_new index def_gnaz 
sel_def=select()
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
	lgnazwa=gnazwa
	lgkod=gkod
	lnum=lnum+1
    @ w,0 say ltx0
    w=w+1	
    @ w,0 say ltx0
    w=w+1					  
    @ w,0 say "|"
    @ w,1 say lnum picture "9999"
    @ w,7 say gnazwa
	do while gnazwa=lgnazwa.and.gkod=lgkod.and..not.eof()
      lsnazwa=snazwa
	  lskod=skod
	  lsjm=sjm
	  lscena=scena
	  if lbz              &&Jesli istnieje bilans zamkniecia akt.miesiaca
	    select &sel_bz
	    if kj_mseek(lsnazwa,lskod,lsjm)
	      lscena=mcen_m
	    else
	      lscena=0
	      set device to screen
		  kj_tkom(10," Uwaga ! ","Skladnik nie odnaleziony w wyrobie",lgnazwa+lgkod,lsnazwa+lskod,5)
	      set device to printer
	    endif
	    select &sel_def
	    replace scena with lscena
	  endif
	  lwartosc_sum=lwartosc_sum+silosc*scena
	  @ w,41 say snazwa
	  @ w,76 say skod
	  @ w,84 say silosc picture "9999999.9999"
	  @ w,97 say sjm
	  @ w,101 say lscena picture "9999999.99"
      @ w,114 say lscena*silosc picture "9999999.9999"
      @ w,129 say "|"
	  lgnum=gnum
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
    @ w,7 say lgkod
	@ w,20 say "Grupa:"
	@ w,27 say lgnum
	@ w,114 say "-------------  |"
	w=w+1
	@ w,0 say "|"
	@ w,105 say "R a z e m :" 
	@ w,114 say lwartosc_sum picture "9999999.9999"
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


FUNCTION NORM_TYT(pstrona)
local ltx1:="=================================================================================================================================="
local ltx2:="| Nr  | Nazwa wyrobu lub polwyrobu      |  Skladniki:  Nazwa               | Kod   | Ilosc      |J.m| Cena       |   Wartosc     |"
local ltx3:="|=====|=================================|==================================|=======|============|===|============|===============|"
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



******************************************************************************
* Wydruk spisu magazynowego                                                  *
******************************************************************************
PROCEDURE MAGAZDRUK
local ilosc:=1
local em:=savescreen(0,0,24,79)
local drukuj:=.t.
grafik=.t.
vvt=.t.
dlugosc=57
odstep=.f.
strona=1
save screen to em
do startdruk with ilosc,drukuj
if.not.drukuj
  restore screen from em
  return
endif  
set device to printer
@ prow(),pcol() say &zdr_kond
for i=1 to ilosc
    do spdruk
next
set device to screen
if plikdruk
  zz=.t.
  do gkom with "Edycja na ekranie ? [T/N]  ",zz
  if lastkey()#27.and.zz
    run ne &plik
  endif
endif
restore screen from em
set cursor off  
RETURN

*******************************************************************************
* Procedura drukuje wszystkie widoczne pozycje z pliku magazyn                *
*******************************************************************************
PROCEDURE SPDRUK
local lp:=1
local lt1:="|... ................................                                          |" 
local lt2:="|                                                                              |"   
local lt3:="--------------------------------------------------------------------------------"
local ks22:=0
local ks07:=0
local ks00:=0
local kszw:=0
local kv22:=0
local kv07:=0
local kv00:=0
local kvzw:=0
local lpiec:=0
local ltcen:=0
local lbp:=0
local lv:=0
local lbr:=0
local canabrutto:=0
local ltxcen:=space(15)
local ltxbp:=space(11)
local ltxv:=space(11)
local ltxbr:=space(11)
local cenabrtxt:=space(15)
local cenanettxt:=space(10)
local numdok:=space(15)
local data:=space(10)
local liltxt:=space(10)
w=prow()
do spglow
do sptyt						
go top
do while.not.eof()
 if .not. mil=0
  ltcen=mcen_m                &&cena zaokraglona do jednosci
  lbp=mil*ltcen                      && wartosc bez podatku
  lv=lbp*(mstawka/100)               && vat
  lbr=lbp+lv                         && brutto 
  cenabrutto=round(ltcen*(1+(mstawka/100)),2)
  if substr(mster,1,1)="z"
    kszw=kszw+lbp
	kvzw=kvzw+lv
  else
    do case
	  case mstawka=22
	    ks22=ks22+lbp
		kv22=kv22+lv
	  case mstawka=7
	    ks07=ks07+lbp
		kv07=kv07+lv
	  case mstawka=0
	    ks00=ks00+lbp
		kv00=kv00+lv				
	endcase
  endif

  ltxbp=stuff("            ",13-len(alltrim(str(lbp,12,2))),len(alltrim(str(lbp,12,2))),alltrim(str(lbp,12,2))) 
  ltxv=stuff("...........",12-len(alltrim(str(lv,11,2))),len(alltrim(str(lv,11,2))),alltrim(str(lv,11,2))) 
  ltxbr=stuff("...........",12-len(alltrim(str(lbr,11,2))),len(alltrim(str(lbr,11,2))),alltrim(str(lbr,11,2))) 
*  cenanettxt=stuff("...............",16-len(alltrim(strj(ltcen))),len(alltrim(strj(ltcen))),alltrim(strj(ltcen))) 
  cenanettxt=stuff("            ",13-len(alltrim(str(ltcen,12,2))),len(alltrim(str(ltcen,12,2))),alltrim(str(ltcen,12,2))) 
  cenabrtxt=stuff("...........",12-len(alltrim(str(cenabrutto,11,2))),len(alltrim(str(cenabrutto,11,2))),alltrim(str(cenabrutto,11,2))) 
  numdok=stuff("...............",16-len(alltrim(mdokzak)),len(alltrim(mdokzak)),alltrim(mdokzak))
  data=stuff(data,2,8,dtoc(mdata))
  liltxt=stuff("          ",11-len(alltrim(str(mil,10,2))),len(alltrim(str(mil,10,2))),alltrim(str(mil,10,2))) 
   
  if lp>999
    lt1=stuff(lt1,1,4,str(lp,4))
  else
    lt1=stuff(lt1,2,3,str(lp,3))
  endif
  lt1=stuff(lt1,6,len(alltrim(mnaz)),alltrim(mnaz))
  lt1=stuff(lt1,39,10,liltxt)
  lt1=stuff(lt1,50,3,mjm)
  lt1=stuff(lt1,54,12,cenanettxt)
  lt1=stuff(lt1,68,12,ltxbp)  
  @ w,0 say lt1
  w=w+1
  lt1="|... ................................                                          |" 
  lpiec=lpiec+1
  if lpiec=5.and.odstep
    @ w,0 say lt2
	lpiec=0
	w=w+1
  endif
 endif                &&koniec warunku mil#0
  skip
  if w>dlugosc-6.and..not.eof()
    stro=.t.
    @ w,0 say lt3
	lpiec=0
	strona=strona+1
 *  @ w+3,7 say "Koniec strony :"
*@ w+3,23 say strona-1
*@ w+4,7 say "Ciag dalszy spisu  -  PATRZ STRONA :"
 *  @ w+4,pcol() say strona picture "999"
    eject
	w=prow()
    do spglow
	do sptyt
  endif
  lp=lp+1
enddo
@ w,0 say lt3+&zdr_kond
w=w+2
do anstopa with ks22,ks07,ks00,kszw,kv22,kv07
eject
RETURN



PROCEDUR SPTYT

local lt1:="================================================================================"
local lt2:="|Lp.|          N A Z W A             |  Ilosc   |J. |CENA ZAKUPU |   WARTOSC   |"
local lt3:="|   |         T O W A R U            |          | m.|bez podatku |    NETTO    |"
local lt4:="|===|================================|==========|===|============|=============|"
local lt5:="|                                                                              |"
*@ prow(),pcol() say &zdr_kond
@ w,0 say lt1
w=w+1
@ w,0 say lt2
w=w+1
@ w,0 say lt3
w=w+1
@ w,0 say lt4
w=w+1
@ w,0 say lt5
w=w+1
RETURN



PROCEDURE SPGLOW
local ld1:="               S P I S    P O Z Y C J I    M A G A Z Y N O W Y C H              "
local ld2:="              ----------------------------------------------------              "

if grafik
  @ prow(),pcol() say &zdr_grubo+&zdr_kkond
else
  @ prow(),pcol() say &zdr_kkond
endif
@ w,0 say ld1
w=w+1
@ w,0 say ld2

if grafik
  @ prow(),pcol() say &zdr_kgrubo
endif  
w=w+2
@ w,20 say b_magtyt
w=w+2
if v_bom
  @ w,0 say "BILANS OTWARCIA MIESIACA :"
else
  @ w,0 say "BILANS ZAMKNIECIA MIESIACA :"
endif  
do case
  case bil_num_mies=1
    @ w,36 say "S T Y C Z N I A"
  case bil_num_mies=2
    @ w,36 say "L U T E G O"
  case bil_num_mies=3
    @ w,36 say "M A R C A"
  case bil_num_mies=4
    @ w,36 say "K W I E T N I A"
  case bil_num_mies=5
    @ w,36 say "M A J A"
  case bil_num_mies=6
    @ w,36 say "C Z E R W C A"
  case bil_num_mies=7
    @ w,36 say "L I P C A"
  case bil_num_mies=8
    @ w,36 say "S I E R P N I A"
  case bil_num_mies=9
    @ w,36 say "W R Z E S N I A"
  case bil_num_mies=10
    @ w,36 say "P A Z D Z I E R N I K A"
  case bil_num_mies=11
    @ w,36 say "L I S T O P A D A"								
  case bil_num_mies=12
    @ w,36 say "G R U D N I A"	
  case bil_num_mies=0
    @ w,36 say " Nie zdefiniowany !"
endcase
w=w+2
RETURN

PROCEDURE ANSTOPA
parameters p22,p07,p00,pzw,pv22,pv07
local lt1:="Razem NETTO.                  w tym ze st_22%                  7%                  0%                  zw               "
local lt2:="Razem VAT...                  w tym ze st_22%                  7%                  0%                  zw               "
local lt3:="Razem BRUTTO                  w tym ze st_22%                  7%                  0%                  zw               "
local licz:=0
local licztxt:=space(15)

licz=p22+p07+p00+pzw
licz=round(licz,2)
licztxt=stuff("...............",16-len(alltrim(strj(licz))),len(alltrim(strj(licz))),alltrim(strj(licz))) 
lt1=stuff(lt1,13,15,licztxt)
licz=pv22+pv07
licz=round(licz,2)
licztxt=stuff("...............",16-len(alltrim(strj(licz))),len(alltrim(strj(licz))),alltrim(strj(licz))) 
lt2=stuff(lt2,13,15,licztxt)
licz=p22+p07+p00+pzw+pv22+pv07
licz=round(licz,2)
licztxt=stuff("...............",16-len(alltrim(strj(licz))),len(alltrim(strj(licz))),alltrim(strj(licz))) 
lt3=stuff(lt3,13,15,licztxt)

licz=p22
licz=round(licz,2)
licztxt=stuff("...............",16-len(alltrim(strj(licz))),len(alltrim(strj(licz))),alltrim(strj(licz))) 
lt1=stuff(lt1,46,15,licztxt)
licz=pv22
licz=round(licz,2)
licztxt=stuff("...............",16-len(alltrim(strj(licz))),len(alltrim(strj(licz))),alltrim(strj(licz))) 
lt2=stuff(lt2,46,15,licztxt)
licz=p22+pv22
licz=round(licz,2)
licztxt=stuff("...............",16-len(alltrim(strj(licz))),len(alltrim(strj(licz))),alltrim(strj(licz))) 
lt3=stuff(lt3,46,15,licztxt)

licz=p07
licz=round(licz,2)
licztxt=stuff("...............",16-len(alltrim(strj(licz))),len(alltrim(strj(licz))),alltrim(strj(licz))) 
lt1=stuff(lt1,66,15,licztxt)
licz=pv07
licz=round(licz,2)
licztxt=stuff("...............",16-len(alltrim(strj(licz))),len(alltrim(strj(licz))),alltrim(strj(licz))) 
lt2=stuff(lt2,66,15,licztxt)
licz=p07+pv07
licz=round(licz,2)
licztxt=stuff("...............",16-len(alltrim(strj(licz))),len(alltrim(strj(licz))),alltrim(strj(licz))) 
lt3=stuff(lt3,66,15,licztxt)

licz=p00
licz=round(licz,2)
licztxt=stuff("...............",16-len(alltrim(strj(licz))),len(alltrim(strj(licz))),alltrim(strj(licz))) 
lt1=stuff(lt1,86,15,licztxt)
licz=0
licz=round(licz,2)
licztxt=stuff("...............",16-len(alltrim(strj(licz))),len(alltrim(strj(licz))),alltrim(strj(licz))) 
lt2=stuff(lt2,86,15,licztxt)
licz=p00
licz=round(licz,2)
licztxt=stuff("...............",16-len(alltrim(strj(licz))),len(alltrim(strj(licz))),alltrim(strj(licz))) 
lt3=stuff(lt3,86,15,licztxt)

licz=pzw
licz=round(licz,2)
licztxt=stuff("...............",16-len(alltrim(strj(licz))),len(alltrim(strj(licz))),alltrim(strj(licz))) 
lt1=stuff(lt1,106,15,licztxt)
licz=0
licz=round(licz,2)
licztxt=stuff("...............",16-len(alltrim(strj(licz))),len(alltrim(strj(licz))),alltrim(strj(licz))) 
lt2=stuff(lt2,106,15,licztxt)
licz=pzw
licz=round(licz,2)
licztxt=stuff("...............",16-len(alltrim(strj(licz))),len(alltrim(strj(licz))),alltrim(strj(licz))) 
lt3=stuff(lt3,106,15,licztxt)

@ w,0 say lt1
if vvt
  w=w+1
  @ w,0 say lt2
  w=w+1
  @ w,0 say lt3
  w=w+1
endif  
RETURN

*******************************************************************************
* Funkcja zamienia zmienna numeryczna (do 12 zn.) na tekst                    *
* w formacie "999 999 999 999"   wart. zerowa = space(15)                     *
*******************************************************************************
FUNCTION STRJ
parameters plicz
plicz=ROUND(plicz,2)
tx=space(15)
if plicz#0
  tx1=alltrim(str(plicz))
  tx1=stuff(space(12),13-len(tx1),len(tx1),tx1)
  tx=stuff(tx,2,3,substr(tx1,1,3))
  tx=stuff(tx,5,1," ")
  tx=stuff(tx,6,3,substr(tx1,4,3))
  tx=stuff(tx,9,1," ")
  tx=stuff(tx,10,3,substr(tx1,7,3))
 *tx=stuff(tx,12,1," ")
 *tx=stuff(tx,13,3,substr(tx1,10,3))
 tx=stuff(tx,13,3,substr(tx1,10,3))
endif
RETURN tx



*******************************************************************************
* Funkcja drukuje raport usredniania                                          *
*******************************************************************************

FUNCTION SPRZED_DRUK(pbaza)
local lmnaz,lmkod,bil_jm,lbil_cen,lnum:=0,lstrona:=1,lwyrob:=.f.,lpusty:=.f.
local lmjm,lbo_wartosc:=0,lbo_il:=0,ltwartosc_sum:=0,lti_sum:=0
local ltlo:=.f.,ltxt:="",k_last:=0,k_aktual:=0
local ltxt1:=""
local ltx0:="|                                                                                                                              |"
local ltyt:="          ANALIZA SPRZEDAZY W CENACH ZAKUPU I SPRZEDAZY         "
do startdruk
set device to printer
@ prow(),pcol() say &zdr_kkond
w=prow()
@ w,7 say ltyt
w=w+1
@ w,6 say "================================================================="
w=w+1
do case
  case sp_kraj
    @ w,6 say "                S P R Z E D A Z     K R A J O W A                "
  case sp_export
    @ w,6 say "                       E  K  S  P  O  R  T                       "	
endcase
w=w+2
@ w,0 say "OKRES ROZLICZENIOWY   Rok:"
@ w,26 say year(bil_dat) 
@ W,37 say "Miesiac:"
@ w,46 say bil_miesiac
w=w+3
@ prow(),pcol() say &zdr_kond
sprzed_tyt(lstrona)
close all
pmagdefault(1)
bz_use(bil_num_mies)
sel_bz=select()
set default to 1dok
do case
  case pbaza=1            &&sp_kraj
    use sprzedaz new
	index on tnaz+tkod+tjm to t_nazkj
	use sprzedaz index t_nazkj
  case pbaza=2           &&sp_export
    use sp_expo new
	index on tnaz+tkod+tjm to t_nazkj
	use sp_expo index t_nazkj
  case pbaza=3           &&sp_ue
    use sp_ue new
	index on tnaz+tkod+tjm to t_nazkj
	use sp_ue index t_nazkj	
endcase
set filter to month(tdat)=bil_num_mies
go top
sel_dok=select()
lzak_all=0
lsprzed_all=0
do while.not.eof()
  ltnaz=tnaz
  ltkod=tkod
  ltjm=tjm
  select &sel_bz
  if kj_mseek(ltnaz,ltkod,ltjm)
    ltcen_m=mcen_m
  else
    ltcen_m=0
  endif  
  select &sel_dok
  @ w,0 say ltx0
  w=w+1	
  @ w,0 say ltx0
  w=w+1					  
  lnum=lnum+1
  @ w,0 say "|"
  @ w,1 say lnum picture "9999"
  @ w,7 say ltnaz	
  @ w,127 say"|"
  w=w+1
  ltil_sum=0
  lzak_sum=0
  lsprzed_sum=0
  do while tnaz=ltnaz.and.tkod=ltkod.and.tjm=ltjm
    ltil_sum=ltil_sum+til
	lzak_sum=lzak_sum+til*ltcen_m
	lsprzed_sum=lsprzed_sum+til*tcen	  
   	@ w,0 say"|"
	if v_marza
      @ w,6 say ((tcen-ltcen_m)/tcen) * 100 picture "999999.99"		 
	  @ w,16 say "%"
	endif
	@ w,40 say tndok 
	@ w,56 say til picture "9999999.99"
	@ w,67 say tjm
	@ w,72 say ltcen_m picture "9999999.99"
	@ w,86 say ltcen_m*til picture "9999999.999"
	@ w,100 say tcen picture "9999999.99"
	@ w,114 say tcen*til picture "9999999.999"
	@ w,127 say"|"
	w=w+1
        if w>dlugosc_str
	      eject
          w=prow()
		  lstrona=lstrona+1
          sprzed_tyt(lstrona)
		  w=prow()+1
	    endif	 
	    skip
  enddo
  lzak_all=lzak_all+lzak_sum
  lsprzed_all=lsprzed_all+lsprzed_sum
  @ w,0 say "|                                                       ---------------------------------------------------------------------- |"
  w=w+1
  @ w,0 say "|       Kod: "
  @ w,14 say ltkod		
  @ w,44 say "Razem:"
  @ w,56 say ltil_sum picture "9999999.99"	
  @ w,67 say ltjm
  @ w,72 say lzak_sum/ltil_sum picture "9999999.99"	
  @ w,86 say lzak_sum picture "9999999.99"	
  @ w,100 say lsprzed_sum/ltil_sum picture "9999999.99"	
  @ w,114 say lsprzed_sum picture "9999999.99"	
  @ w,127 say"|"
  w=w+1	
  @ w,0 say ltx0
  w=w+1	
  @ w,1 say replicate(chr(196),126)
      if w>dlugosc_str
	    eject
		w=prow()
		lstrona=lstrona+1
        sprzed_tyt(lstrona)
		w=prow()
	  endif
enddo  
w=w+1
      if w>dlugosc_str
	    eject
		w=prow()
		lstrona=lstrona+1
        sprzed_tyt(lstrona)
		w=prow()
	  endif

@ w,72 say "|"
if v_marza
  @ w,6 say ((lsprzed_all-lzak_all)/lzak_all) * 100 picture "999999.99"
  @ w,16 say "%"
endif
@ w,127 say"|"
w=w+1
@ w,0 say "Roznica: [ sprzedaz - zakup ]  ="
@ w,32 say lsprzed_all-lzak_all picture "9999999.99"	
@ w,72 say "|  R A Z E M :"
@ w,86 say lzak_all picture "9999999.99"	
@ w,114 say lsprzed_all picture "9999999.99"	
@ w,127 say"|"
w=w+1
@ w,72 say replicate(chr(196),55)
@ prow(),pcol() say &zdr_kkond
eject
close all
lcolor=setcolor()
set device to screen
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


FUNCTION SPRZED_TYT(pstrona)
local ltx1:="================================================================================================================================"
local ltx2:="| Nr  |                                | Numer dokum.  | ILosc    |J.m.| Cena zakupu | Wart.zakupu | Cena sprzed.| Wart.sprzed.|"
local ltx3:="|=====|================================|===============|==========|====|=============|=============|=============|=============|"
local ltx4:="|                                                                                                                              |"
local ltx5:="|                                                                                                                              |"
do case
  case wyrob_mag
	ltxt1="Nazwa wyrobu gotowego"
  case polwyrob_mag
	ltxt1="Nazwa polwyrobu"
  case surowiec_mag
	ltxt1="Nazwa surowca lub materialu"
  case handel_mag
	ltxt1="Nazwa towaru handlowego"
  otherwise
	ltxt1="Nazwa pozycji magazynowej"
endcase
ltx2=stuff(ltx2,9,len(ltxt1),ltxt1)
@ w,0 say "Analiza sprzedazy w cenach zakupu i sprzedazy.                                                          Strona:"        
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



*******************************************************************************
* Otwarcie odpowiedniego dla miesiaca bilansowego pliku bo_miesiaca (tzn.     *
* bilansu zamkniecia miesiaca poprzedniego                                    *
*******************************************************************************
FUNCTION BO_USE(pmiesiac)
do case
  case pmiesiac=1
    if.not.file("bo.dbf")
	  return .f.
	endif
    use bo index bo_naz,bo_kod new
  case pmiesiac=2
    if.not.file("bz1.dbf")
	  return .f.
	endif
    use bz1 index bz1_naz,bz1_kod new
  case pmiesiac=3
    if.not.file("bz2.dbf")
	  return .f.
	endif
    use bz2 index bz2_naz,bz2_kod new
  case pmiesiac=4
    if.not.file("bz3.dbf")
	  return .f.
	endif
    use bz3 index bz3_naz,bz3_kod new
  case pmiesiac=5
    if.not.file("bz4.dbf")
	  return .f.
	endif
    use bz4 index bz4_naz,bz4_kod new
  case pmiesiac=6
    if.not.file("bz5.dbf")
	  return .f.
	endif
    use bz5 index bz5_naz,bz5_kod new
  case pmiesiac=7
    if.not.file("bz6.dbf")
	  return .f.
	endif
    use bz6 index bz6_naz,bz6_kod new
  case pmiesiac=8
    if.not.file("bz7.dbf")
	  return .f.
	endif
    use bz7 index bz7_naz,bz7_kod new
  case pmiesiac=9
    if.not.file("bz8.dbf")
	  return .f.
	endif
    use bz8 index bz8_naz,bz8_kod new
  case pmiesiac=10
    if.not.file("bz9.dbf")
	  return .f.
	endif
    use bz9 index bz9_naz,bz9_kod new
  case pmiesiac=11
    if.not.file("bz10.dbf")
	  return .f.
	endif
    use bz10 index bz10_naz,bz10_kod new
  case pmiesiac=12
    if.not.file("bz11.dbf")
	  return .f.
	endif
    use bz11 index bz11_naz,bz11_kod new
endcase
RETURN .T.




*******************************************************************************
* Otwarcie odpowiedniego dla miesiaca bilansowego pliku                       *
* bilansu zamkniecia miesiaca                                                 *
*******************************************************************************
FUNCTION BZ_USE(pmiesiac)
do case
  case pmiesiac=1
    if.not.file("bz1.dbf")
	  return .f.
	endif
    use bz1 index bz1_naz,bz1_kod new
  case pmiesiac=2
    if.not.file("bz2.dbf")
	  return .f.
	endif
    use bz2 index bz2_naz,bz2_kod new
  case pmiesiac=3
    if.not.file("bz3.dbf")
	  return .f.
	endif
    use bz3 index bz3_naz,bz3_kod new
  case pmiesiac=4
    if.not.file("bz4.dbf")
	  return .f.
	endif
    use bz4 index bz4_naz,bz4_kod new
  case pmiesiac=5
    if.not.file("bz5.dbf")
	  return .f.
	endif
    use bz5 index bz5_naz,bz5_kod new
  case pmiesiac=6
    if.not.file("bz6.dbf")
	  return .f.
	endif
    use bz6 index bz6_naz,bz6_kod new
  case pmiesiac=7
    if.not.file("bz7.dbf")
	  return .f.
	endif
    use bz7 index bz7_naz,bz7_kod new
  case pmiesiac=8
    if.not.file("bz8.dbf")
	  return .f.
	endif
    use bz8 index bz8_naz,bz8_kod new
  case pmiesiac=9
    if.not.file("bz9.dbf")
	  return .f.
	endif
    use bz9 index bz9_naz,bz9_kod new
  case pmiesiac=10
    if.not.file("bz10.dbf")
	  return .f.
	endif
    use bz10 index bz10_naz,bz10_kod new
  case pmiesiac=11
    if.not.file("bz11.dbf")
	  return .f.
	endif
    use bz11 index bz11_naz,bz11_kod new
  case pmiesiac=12
    if.not.file("bz12.dbf")
	  return .f.
	endif
    use bz12 index bz12_naz,bz12_kod new
endcase
RETURN .t.



*******************************************************************************
* Kopiowanie pliku zamkniecia miesiaca poprzedniego do tworzonego pliku       *
* aktualnie pliku zamkniecia miesiaca biezacego                               *
* Dodatkowe pola: bi_il,bo_cen,zak_il,zak_cen,prod_il,prod_cen                *
*******************************************************************************
FUNCTION BOM(pmiesiac)
local sel_bo,sel_bz1,lmnaz,lmkod,lmjm
do case
  case pmiesiac=1
    if file("bo_bz12.dbf")  && plik zawiera uzgodniony BO w formacie bz_12
	  z_mag_def()
	  if file("bz1.dbf")
	    use bz1 new
		zap
	  else
	    select 0
		bz1_tworz()
		use bz1 
	  endif	
	  sel_bz1=select()	
	  use bo_bz12 new
	  sel_bo=select()
      do while.not.eof()
        mag_lad()
		zsred_plac=sred_plac
		select &sel_bz1
		append blank
		mag_replac()
        replace bo_plac with zsred_plac,bo_il with zmil
		replace bo_cen with zmcen_m
		select &sel_bo		
			    
        skip 
	  enddo
	  use
      select &sel_bz1
      index on mnaz to bz1_naz
	  index on mkod to bz1_kod
	  
	else
	  clear 
	  @ 10,10 say "Brak pliku bo_bz12.dbf"
	   
	endif  
  
  case pmiesiac=101
	  if file("bz12.dbf")
	    use bz12 index bz12_naz,bz12_kod  new
		bz12_sel=select()
	  else
	  	return .f.
	  endif  
    if.not.file("bo.dbf")
	  return .f.
	endif
	if file("bo_uzgod.dbf")   &&plik zawiera ilosci,ceny srednie magazynowe oraz 
	                         *place za wyroby i polwyroby - po zsumowaniu operacji czastkowych
	  z_mag_def()
	  if file("bz1.dbf")
	    use bz1 new
		zap
	  else
	    select 0
		bz1_tworz()
		use bz1 
	  endif	
	  sel_bz1=select()	
	  use bo_uzgod new
	  sel_bo=select()
      do while.not.eof()
	    mag_lad()
		lmnaz=mnaz
		lmkod=mkod
		lmjm=mjm
		select &sel_bz1
		append blank
		mag_replac()
        replace bo_plac with zmcen_p,bo_il with zmil,sred_plac with zmcen_p
		replace bo_cem with mcen_m
		select &sel_bo
	    skip
	  enddo
	  use
      select &sel_bz1
      index on mnaz to bz1_naz
	  index on mkod to bz1_kod
	else
	  z_mag_def()
	  if file("bz1.dbf")
	    use bz1 new
		zap
	  else
	    select 0
		bz1_tworz()
		use bz1 
	  endif	
	  sel_bz1=select()	
	  use bo new
	  sel_bo=select()
      do while.not.eof()
	    mag_lad()
		lmnaz=mnaz
		lmkod=mkod
		lmjm=mjm
		select &bz12_sel
        if kj_mseek(lmnaz,lmkod,lmjm)		
		  zbo_plac=sred_plac
		  zbo_il=zmil
		else
		  zbo_plac=0
		  zbo_il=0
		  if substr(zmkod,1,2)="01".or.substr(zmkod,1,2)="02"
		    kj_tkom(12," Uwaga! ","Brak  mozliwosci okreslenia sredniej placy z BO","dla wyrobu",zmnaz+" "+zmkod+" "+zmjm,5)
		  endif
		endif		
		select &sel_bz1
		append blank
		mag_replac()
        replace bo_plac with zbo_plac,bo_il with zbo_il,sred_plac with zbo_plac
		select &sel_bo
	    skip
	  enddo
	  use
	  select &sel_bz1
	endif  

    index on mnaz to bz1_naz
	index on mkod to bz1_kod
  case pmiesiac=2
    if.not.file("bz1.dbf")
	  return .f.
	endif
    copy file bz1.dbf to bz2.dbf
	use bz2 new
    index on mnaz to bz2_naz
	index on mkod to bz2_kod	
  case pmiesiac=3
    if.not.file("bz2.dbf")
	  return .f.
	endif
    copy file bz2.dbf to bz3.dbf
	use bz3 new
    index on mnaz to bz3_naz
	index on mkod to bz3_kod
  case pmiesiac=4
    if.not.file("bz3.dbf")
	  return .f.
	endif
    copy file bz3.dbf to bz4.dbf
	use bz4 new
    index on mnaz to bz4_naz
	index on mkod to bz4_kod				
  case pmiesiac=5
    if.not.file("bz4.dbf")
	  return .f.
	endif
    copy file bz4.dbf to bz5.dbf
	use bz5 new
    index on mnaz to bz5_naz
	index on mkod to bz5_kod
  case pmiesiac=6
    if.not.file("bz5.dbf")
	  return .f.
	endif
    copy file bz5.dbf to bz6.dbf
	use bz6 new
    index on mnaz to bz6_naz
	index on mkod to bz6_kod				
  case pmiesiac=7
    if.not.file("bz6.dbf")
	  return .f.
	endif
    copy file bz6.dbf to bz7.dbf
	use bz7 new
    index on mnaz to bz7_naz
	index on mkod to bz7_kod		
  case pmiesiac=8
    if.not.file("bz7.dbf")
	  return .f.
	endif
    copy file bz7.dbf to bz8.dbf
	use bz8 new
    index on mnaz to bz8_naz
	index on mkod to bz8_kod		
  case pmiesiac=9
    if.not.file("bz8.dbf")
	  return .f.
	endif
    copy file bz8.dbf to bz9.dbf
	use bz9 new
    index on mnaz to bz9_naz
	index on mkod to bz9_kod		
  case pmiesiac=10
    if.not.file("bz9.dbf")
	  return .f.
	endif
    copy file bz9.dbf to bz10.dbf
	use bz10 new
    index on mnaz to bz10_naz
	index on mkod to bz10_kod		
  case pmiesiac=11
    if.not.file("bz10.dbf")
	  return .f.
	endif
    copy file bz10.dbf to bz11.dbf
	use bz11 new
    index on mnaz to bz11_naz
	index on mkod to bz11_kod			
  case pmiesiac=12
    if.not.file("bz11.dbf")
	  return .f.
	endif
    copy file bz11.dbf to bz12.dbf
	use bz12 new
    index on mnaz to bz12_naz
	index on mkod to bz12_kod				
endcase
if pmiesiac>1
  go top
  do while.not.eof()
    replace bo_il with mil,bo_cen with mcen_m
    replace zak_il with 0,zak_cen with 0,prod_il with 0,prod_cen with 0
    replace bo_plac with sred_plac,sred_plac with 0,aktual_plac with 0
    skip
  enddo
endif
*close all
use
RETURN .t.


******************************************************************************
* Funkcja odtwarza zuzycie surowcow w produkcji w miesiacu bilansowym        *
* psel: selekt z otwartym plikiem bz*.dbf                                    *
******************************************************************************
FUNCTION P_SUROWCE()
local ek,sel_def,sel_sur,sel_mm
save screen to ek
set default to 1dok
if file("bilp_sur.dbf")
  use bilp_sur new
  zap  
else
*  use mmdok new
*  copy structure to bilp_sur
  p_sur_tworz()
  use bilp_sur
endif
sel_sur=select()

use mmdok new
sel_mm=select()

set default to 1mag
use defin new
index on gnazwa+gkod to defin
use defin index defin
sel_def=select()

select &sel_mm
if.not.baz_all
  set filter to month(tdat)=bil_num_mies
  go top
endif  
do while.not.eof()
 if.not.empty(tnaz).and..not.empty(tkod)
  ltnaz=tnaz
  ltkod=tkod
  ltjm=tjm
  ltil=til
  ltndok=tndok
  ltnkon=tnkon
  ltdat=tdat
  ltcen=tcen
  select &sel_def
  if kj_dseek(ltnaz,ltkod) 
    do while gnazwa=ltnaz.and.gkod=ltkod
	  lsnazwa=snazwa
	  lskod=skod
	  lsilosc=silosc
	  lsjm=sjm
      lscena=scena
      select &sel_sur
	  append blank
*	  replace tnaz with lsnazwa,tkod with lskod,til with ltil*lsilosc
*	  replace tjm with lsjm,tndok with ltndok,tnkon with ltnkon,tdat with ltdat
      replace tndok with ltndok,tdat with ltdat,gnaz with ltnaz,gkod with ltkod
	  replace gjm with ltjm,gil with ltil,tnkon with ltnkon
	  replace tnaz with lsnazwa,tkod with lskod,tjm with lsjm 
	  replace til with lsilosc*ltil
      select &sel_def
	  skip
	enddo  
  else
    if kj_gkom(9," Uwaga! Brak definicji wyrobu gotowego",ltnaz+ltkod,"Wystapil grozny blad. Kontynuowac?",.t.,5)
      close all
 	  return .f.
	endif			  
  endif
  select &sel_mm
 endif
 skip
enddo
use
select &sel_def
use
select &sel_sur
use
restore screen from ek
RETURN .t.


*******************************************************************************
* Funkcja tworzy plik bz*, okresla ilosci wynikajace z bo, zakupow, produkcji *
* oraz zuzycia w wyrobach gotowych. Okreska cena srednia oraz place srednia   *
* wyrobow i polwyrobow z uwzglednieniem odpowiednij kolejnosci usredniania    *
*******************************************************************************
FUNCTION BIL_ZAMK()
local ek,lcolor:=setcolor(),lmag:=1,ltnaz,ltkod,ltjm,lil_sum,lwart_sum
local lmagtxt,lmiesiac:=bil_num_mies,lcykl:=1,lplac_sum,lsred_plac
local sel_bz,sel_dok,lcena_mag
save screen to ek
pmagdefault(1)
if.not.bom(lmiesiac)   &&Kopiowanie bom do bzm
  kj_tkom(8," Uwaga ! ","Blad w bazach magazynowych","Prawdopodobnie brak zamkniecia miesiaca poprzedniego",;
            "Popraw i ponow probe.  Nacisnij dowolny klawisz.",5)
  return .f.
endif    
bz_use(bil_num_mies)
sel_bz=select()
pelny=.f.
do while.t.
  set default to 1dok
  do case
    case lcykl=1
      do skom with "Dodaje do BZ_M zakupy"
	  use zakup new
      index on tnaz+tkod+tjm to t_naz1
      use zakup index t_naz1	  
	case lcykl=2
	  do skom with "Dodaje do BZ_M produkcje"
      use mmdok new
      index on tnaz+tkod+tjm to t_naz2
      use mmdok index t_naz2
    case lcykl=3
	  do skom with "Odejmuje od BZ_M sprzedaz krajowa"
      use sprzedaz new	  	  
      index on tnaz+tkod+tjm to t_naz3
      use sprzedaz index t_naz3
    case lcykl=4
	  do skom with "Odejmuje od BZ_M przetworzone surowce"
      use bilp_sur new	  	  
      index on tnaz+tkod+tjm to t_naz4
      use bilp_sur index t_naz4
    case lcykl=5
	  do skom with "Odejmuje od BZ_M sprzedaz exportowa"
      use sp_expo new	  	  
      index on tnaz+tkod+tjm to t_naz5
      use sp_expo index t_naz5
    case lcykl=6
	  do skom with "Odejmuje od BZ_M sprzedaz ue"
      use sp_ue new	  	  
      index on tnaz+tkod+tjm to t_naz6
      use sp_ue index t_naz6	  
  endcase
  sel_dok=select()
  if.not.baz_all
    set filter to month(tdat)=bil_num_mies
    go top
  endif	
  do while.not.eof()
    @ 24,2 say tnaz
	ltnaz=tnaz
	ltkod=tkod
	ltjm=tjm
	lil_sum=0
    lwart_sum=0
	lplac_sum=0
	ltstawka=tstawka
	ltnmag=tnmag
	ltsymbol=tsymbol
	ltster=tster
	do while tnaz=ltnaz.and.tkod=ltkod.and.tjm=ltjm
	  lil_sum=lil_sum+til
**10.03.2004
	  lcena_mag=tcen_m
	  if lcykl=1
        lcena_mag=round(tcen,2)	    
	  else
	    
		select &sel_bz
	    if kj_mseek(ltnaz,ltkod,ltjm)
		  lcena_mag=mcen_m
		endif
		select &sel_dok
	  endif
      lwart_sum=lwart_sum+til*lcena_mag
**	  
	 * lwart_sum=lwart_sum+til*tcen_m
	  if lcykl=2       &&tylko dla wyrobow
	    lplac_sum=lplac_sum+til*tcen
	  endif
	  skip
	enddo
	ltcen_m=lwart_sum/lil_sum
    lsred_plac=lplac_sum/lil_sum
	select &sel_bz	 	
	if lil_sum#0    
	  if lcykl>=3
	    lil_sum=-1*lil_sum
	  endif	
	  if kj_mseek(ltnaz,ltkod,ltjm)
        do case
		  case lcykl=1
		    if mil>0.and.mcen_m>0
			  *replace mcen_m with (mil*mcen_m+ltcen_m*lil_sum)/(mil+lil_sum)
			  replace mcen_m with (mil*mcen_m+lwart_sum)/(mil+lil_sum)
			else
			  replace mcen_m with (ltcen_m*lil_sum)/(lil_sum)
			endif  
			replace zak_cen with ltcen_m,zak_il with lil_sum
			replace mil with mil+lil_sum
		  case lcykl=2
		    if bo_il>0.and.bo_plac>0
			  replace sred_plac  with (bo_il*bo_plac+lsred_plac*lil_sum)/(bo_il+lil_sum+zak_il)
			else
			  replace sred_plac  with (lsred_plac*lil_sum)/(lil_sum+zak_il)
			endif  
		  	replace aktual_plac with lsred_plac
			replace prod_il with lil_sum
*			replace mil with mil+prod_il
          otherwise
		    replace mil with mil+lil_sum
		endcase
	  else
	    append blank
	    replace mnaz with ltnaz,mkod with ltkod
	    replace mjm with ltjm,mstawka with ltstawka,nmag with ltnmag
	    replace msymbol with ltsymbol,mster with ltster
        if lcykl=1
		  replace mcen_m with ltcen_m
		endif
		do case
	      case substr(ltkod,1,2)="01"
		    replace magaz with 1
	      case substr(ltkod,1,2)="02"
		    replace magaz with 2
	      case substr(ltkod,1,2)="03"
		    replace magaz with 3		  		  
	      case substr(ltkod,1,2)="04"
		    replace magaz with 4		  		  
	    endcase
        do case
		  case lcykl=1
			replace zak_cen with ltcen_m,zak_il with lil_sum
			replace mil with lil_sum
		  case lcykl=2
		  	replace prod_il with lil_sum,sred_plac with lsred_plac
			replace aktual_plac with lsred_plac
		  otherwise
		    replace mil with lil_sum	
		endcase
	  endif
	endif
	select &sel_dok
  enddo
  use
  if lcykl=2
*  if lcykl=1
    if.not.wyr_cena(sel_bz) 
      close all
      return .f.
    endif
*  endif
*  if lcykl=2
    select &sel_bz
    if kj_gkom(8,"","Wydrukowac zbiorczy raport usredniania","cen surowcow i wyrobow ?",.t.,5) 
      plikdruk=kj_gkom(8,"","Drukowac do pliku ?","",plikdruk,5)
      plik="\b_sred_c.txt"
	  ceny_druk(sel_bz)      
    endif
  endif
  lcykl=lcykl+1
  if lcykl=3        &&Jesli obsluga surowcow przetworzonych
*    if kj_gkom(8,"","Odtworzyc zbior surowcow przetworzonych ?","",.t.,5)
	  if.not.p_surowce(sel_bz)
	    return .f.
	  endif
*	endif
  endif
  *if lcykl>5.or.lcykl=5.and..not.file("sp_expo.dbf")
  if lcykl>6
    exit
  endif
  select &sel_dok
  use
enddo
close all
RETURN .t.





FUNCTION BZ1_TWORZ()
create nowa
append blank
replace field_name with "nmag"
replace field_type with "N"
replace field_len with 6
replace field_dec with 0
append blank
replace field_name with "mnaz"
replace field_type with "C"
replace field_len with 32
append blank
replace field_name with "mkod"
replace field_type with "C"
replace field_len with 7
append blank
replace field_name with "mil"
replace field_type with "N"
replace field_len with 10
replace field_dec with 2
append blank
replace field_name with "mjm"
replace field_type with "C"
replace field_len with 3
append blank
replace field_name with "mcen_d"
replace field_type with "N"
replace field_len with 14
replace field_dec with 4
append blank
replace field_name with "mcen_h"
replace field_type with "N"
replace field_len with 14
replace field_dec with 4
append blank
replace field_name with "mcen_m"
replace field_type with "N"
replace field_len with 19
replace field_dec with 14
append blank
replace field_name with "mcen_p"
replace field_type with "N"
replace field_len with 19
replace field_dec with 14
append blank
replace field_name with "mstawka"
replace field_type with "N"
replace field_len with 3
replace field_dec with 0
append blank
replace field_name with "msymbol"
replace field_type with "C"
replace field_len with 10
append blank
replace field_name with "mwaluta"
replace field_type with "C"
replace field_len with 5
append blank
replace field_name with "magaz"
replace field_type with "N"
replace field_len with 3
replace field_dec with 0
append blank
replace field_name with "mrez"
replace field_type with "N"
replace field_len with 10
replace field_dec with 2
append blank
replace field_name with "mdata"
replace field_type with "D"
replace field_len with 8
append blank
replace field_name with "mdokzak"
replace field_type with "C"
replace field_len with 15
append blank
replace field_name with "mster"
replace field_type with "C"
replace field_len with 3
append blank
replace field_name with "mntrah"
replace field_type with "N"
replace field_len with 6
replace field_dec with 0
append blank
replace field_name with "mindex"
replace field_type with "N"
replace field_len with 6
replace field_dec with 0
append blank
replace field_name with "magnum"
replace field_type with "N"
replace field_len with 3
replace field_dec with 0
append blank
replace field_name with "bo_il"
replace field_type with "N"
replace field_len with 10
replace field_dec with 2
append blank
replace field_name with "bo_cen"
replace field_type with "N"
replace field_len with 19
replace field_dec with 14
append blank
replace field_name with "zak_il"
replace field_type with "N"
replace field_len with 10
replace field_dec with 2
append blank
replace field_name with "zak_cen"
replace field_type with "N"
replace field_len with 19
replace field_dec with 14
append blank
replace field_name with "prod_il"
replace field_type with "N"
replace field_len with 10
replace field_dec with 2
append blank
replace field_name with "prod_cen"
replace field_type with "N"
replace field_len with 19
replace field_dec with 14
append blank
replace field_name with "bo_plac"
replace field_type with "N"
replace field_len with 19
replace field_dec with 14
append blank
replace field_name with "sred_plac"
replace field_type with "N"
replace field_len with 19
replace field_dec with 14
append blank
replace field_name with "aktual_plac"
replace field_type with "N"
replace field_len with 19
replace field_dec with 14
create bz1 from nowa
use
erase nowa.dbf
RETURN nil

*******************************************************************************
*Funkcja tworzy plik o nazwie BILP_SUR.DBF do rejestracji szczegolowej przerobu
*******************************************************************************
FUNCTION P_SUR_TWORZ()
create nowa
append blank
replace field_name with "tndok"
replace field_type with "C"
replace field_len with 15
append blank
replace field_name with "tdat"
replace field_type with "D"
replace field_len with 8
append blank
replace field_name with "gnaz"
replace field_type with "C"
replace field_len with 32
append blank
replace field_name with "gkod"
replace field_type with "C"
replace field_len with 7
append blank
replace field_name with "gjm"
replace field_type with "C"
replace field_len with 3
append blank
replace field_name with "gil"
replace field_type with "N"
replace field_len with 10
replace field_dec with 2
append blank
replace field_name with "tnaz"
replace field_type with "C"
replace field_len with 32
append blank
replace field_name with "tkod"
replace field_type with "C"
replace field_len with 7
append blank
replace field_name with "tjm"
replace field_type with "C"
replace field_len with 3
append blank
replace field_name with "til"
replace field_type with "N"
replace field_len with 10
replace field_dec with 2
append blank
replace field_name with "tcen"
replace field_type with "N"
replace field_len with 19
replace field_dec with 14
append blank
replace field_name with "tcen_m"
replace field_type with "N"
replace field_len with 19
replace field_dec with 14
append blank
replace field_name with "splac"
replace field_type with "N"
replace field_len with 14
replace field_dec with 4
append blank
replace field_name with "tnkon"
replace field_type with "N"
replace field_len with 6
replace field_dec with 0
append blank
replace field_name with "tster"
replace field_type with "C"
replace field_len with 3
append blank
replace field_name with "tstawka"
replace field_type with "N"
replace field_len with 2
replace field_dec with 0
append blank
replace field_name with "tnmag"
replace field_type with "N"
replace field_len with 6
replace field_dec with 0
append blank
replace field_name with "tsymbol"
replace field_type with "C"
replace field_len with 15

create bilp_sur from nowa
use
erase nowa.dbf
RETURN nil


FUNCTION DEF_SUR_TWORZ()
create nowa
append blank
replace field_name with "gnazwa"
replace field_type with "C"
replace field_len with 32
append blank
replace field_name with "gkod"
replace field_type with "C"
replace field_len with 7
append blank
replace field_name with "snazwa"
replace field_type with "C"
replace field_len with 32
append blank
replace field_name with "skod"
replace field_type with "C"
replace field_len with 7
append blank
replace field_name with "silosc"
replace field_type with "N"
replace field_len with 14
replace field_dec with 4
append blank
replace field_name with "sjm"
replace field_type with "C"
replace field_len with 3
append blank
replace field_name with "scena"
replace field_type with "N"
replace field_len with 19
replace field_dec with 14
create def_sur from nowa
use
erase nowa.dbf
RETURN nil


FUNCTION DEFI_NEW_TWORZ()
create nowa
append blank
replace field_name with "gnazwa"
replace field_type with "C"
replace field_len with 32
append blank
replace field_name with "gkod"
replace field_type with "C"
replace field_len with 7
append blank
replace field_name with "snazwa"
replace field_type with "C"
replace field_len with 32
append blank
replace field_name with "skod"
replace field_type with "C"
replace field_len with 7
append blank
replace field_name with "silosc"
replace field_type with "N"
replace field_len with 14
replace field_dec with 4
append blank
replace field_name with "sjm"
replace field_type with "C"
replace field_len with 3
append blank
replace field_name with "scena"
replace field_type with "N"
replace field_len with 19
replace field_dec with 14
append blank
replace field_name with "gnum"
replace field_type with "N"
replace field_len with 3
replace field_dec with 0
append blank
replace field_name with "wyceniony"
replace field_type with "L"
replace field_len with 1
create defi_new from nowa
use
erase nowa.dbf
RETURN nil


FUNCTION B_SETUP_TWORZ()
create nowa
append blank
replace field_name with "eksport"
replace field_type with "l"
replace field_len with 1
append blank
replace field_name with "eksp_plik"
replace field_type with "C"
replace field_len with 45
append blank
replace field_name with "ue_plik"
replace field_type with "C"
replace field_len with 45
append blank
replace field_name with "plik"
replace field_type with "l"
replace field_len with 1
create b_setup from nowa
use
erase nowa.dbf
RETURN nil






*******************************************************************************
* Funkcja wycenia wyroby w cenie sredniej ich czesci skladowych.              * 
* Ustala kolejnosc usredniania i wpisuje ceny srednie wyrobow do rubryki      * 
* wyr_cen oraz cene srednia uwzgledniajaca bo i ewentualne zakupy do          * 
* rubryki mcen_m. Psel: selekt z otwartym plikiem bz_miesiaca.                * 
* Wylicza place zawarta w wyrobie oraz wszystkich wykorzystanych polwyrobach  *
*******************************************************************************

FUNCTION WYR_CENA(psel)
local sel_bildef,sel_def,lnum:=0,end_all:=.t.,end_poz:=.t.
local g_recno,s_recno,lwyceniony:=.f.,lstopien:=0,lcen_sum:=0,lmcen_m:=0
local ls_plac_sum
pmagdefault(1)
if.not.file("defi_new.dbf")
  defi_new_tworz()
  use defi_new new
  index on gnazwa+gkod to b_gnazk
else
  use defi_new index b_gnazk new
  zap
endif
use
use defi_new index b_gnazk new
sel_bildef=select()
use defin index def_gnaz new
sel_def=select()
do while.not.eof()   &&Przepisanie defin.dbf do defi_new.dbf
  lgnazwa=gnazwa
  lgkod=gkod
  lsnazwa=snazwa
  lskod=skod
  lsjm=sjm
  lscena=scena
  lsilosc=silosc
  select &sel_bildef
  append blank
  replace gnazwa with lgnazwa,gkod with lgkod,snazwa with lsnazwa
  replace skod with lskod,sjm with lsjm,scena with lscena,silosc with lsilosc
  select &sel_def
  skip
enddo
use
*******************************Ustalanie kolejnosci wyceny
select &sel_bildef
go top
do while.t.
  lnum=lnum+1
  end_all=.t.
  do while.not.eof()   &&dla kazdego wyrobu
    lgnazwa=gnazwa
	lgkod=gkod
    g_recno=recno()
	g_wycena=.t.
	do while gnazwa=lgnazwa.and.gkod=lgkod
	  lsnazwa=snazwa
	  lskod=skod
      s_recno=recno()	  
      if kj_dseek(lsnazwa,lskod)
	    if.not.wyceniony
		  g_wycena=.f.
		  end_all=.f.		  
		endif
	  endif
	  go s_recno	  
      skip
	enddo  
	if g_wycena
	  go g_recno
	  do while gnazwa=lgnazwa.and.gkod=lgkod
	   replace wyceniony with .t.
		if gnum=0
		  replace gnum with lnum
		endif
		skip
	  enddo
	endif
  enddo  
  if end_all
    exit
  endif
  go top
  if lnum>100
    kj_tkom(8," Uwaga! ","Wykryto bledy w definicjach wyrobow","i polwyrobow","Popraw i ponow probe.",5)
    return .f.
  endif
enddo
******************************
for i=1 to lnum             &&Usrednianie wedlug poprawnej kolejnosci
  set filter to gnum=i
  go top
  do while.not.eof()
    lgnazwa=gnazwa 
	lgkod=gkod
	lcen_sum=0
	ls_plac_sum=0
	do while gnazwa=lgnazwa.and.gkod=lgkod
      lsnazwa=snazwa
	  lskod=skod
	  lsjm=sjm
	  lsilosc=silosc
	  select &psel
	  if kj_mseek(lsnazwa,lskod,lsjm)
	    lmcen_m=mcen_m
		*lcen_sum=lcen_sum+ROUND(lsilosc*mcen_m,4)
		lcen_sum=lcen_sum+lsilosc*mcen_m
		ls_plac_sum=ls_plac_sum+lsilosc*sred_plac
*	  else
*	    lmcen_m=0
*		if.not.kj_gkom(8," Uwaga! Skladnik wyrobu gotowego nie odnaleziony. Kontynuowac?";
*		           ,lsnazwa+lskod,lgnazwa+lgkod,.t.,5)
 *         select &sel_bildef
*		  use
*		  select &psel
*		  return .f.        
*		endif
*        select &sel_bildef
*		replace silosc with -1						   
	  endif      	  
	  select &sel_bildef
	  replace scena with lmcen_m
	  skip
	enddo
	select &psel
	if kj_nk_mseek(lgnazwa,lgkod)
      replace prod_cen with lcen_sum
	  if mil>0.and.mcen_m>0
	    replace mcen_m with (mil*mcen_m+prod_il*prod_cen)/(mil+prod_il)
	  else
	    replace mcen_m with (prod_il*prod_cen)/(prod_il)
	  endif	
  replace mil with mil+prod_il
	  if bo_il>0.and.bo_plac>0
	    replace sred_plac with (bo_il*bo_plac+prod_il*(ls_plac_sum+aktual_plac))/(bo_il+prod_il)
	  else
	    replace sred_plac with prod_il*(ls_plac_sum+aktual_plac)/prod_il
	  endif
	else
	  
*	  kj_tkom(9," !! ","wyrob nie odnaleziony",lgnazwa+lgkod,"",5)
	endif
	select &sel_bildef
  enddo
next
use
RETURN .t.



*******************************************************************************
* Funkcja drukuje raport zbiorczy procesu usredniania                         *
* Otwarty plik bz*.dbf                                                        *
*******************************************************************************
FUNCTION CENY_DRUK()
local lgnazwa,lgkod,lnum:=0,lstrona:=1,ek,lsnazwa,lscena,lsjm,lsilosc
local sel_bz,sel_def,lwartosc_sum:=0,ltxt1:="",ltyt:=""
local ltx0:="|                                                                                                        |"
plik:="\b_sred_c.txt"
ltyt="USREDNIANIE CEN - WYROBY I POLWYROBY WYTWARZANE W BIEZACYM MIESIACU"
set device to printer
do startdruk
@ prow(),pcol() say &zdr_kkond
w=prow()
@ w,11 say ltyt
w=w+1
@ w,8 say "==================================================================="
w=w+3
@ w,6 say "OKRES ROZLICZENIOWY   Rok:           Miesiac:"
@ w,32 say year(bil_dat) 
@ w,52 say bil_miesiac
w=w+3
@ prow(),pcol() say &zdr_kond
cena_tyt(lstrona)
*set default to 1mag
*bz_use(bil_num_mies)
*sel_bz=select()
go top
do while.not.eof()
 if prod_il>0 
   w=w+1
      if w>dlugosc_str
	    eject
        w=prow()
		lstrona=lstrona+1
		cena_tyt(lstrona)
		w=prow()
		@ w,10 say ltx0
		w=w+1
		@ w,10 say ltx0
		w=w+1
	  endif	
	lnum=lnum+1
    @ w,10 say ltx0
    @ w,10 say "|"
    @ w,11 say lnum picture "9999"
    @ w,17 say mnaz
    @ w,51 say mkod
	@ w,61 say mjm
	@ w,70 say "B O"
	if bo_il>0
	  @ w,87 say bo_il picture "9999999.99"
	else
	  @ w,87 say "     -0"
	endif  
	if bo_cen>0
	  @ w,102 say bo_cen picture "9999999.99" 
	else
	  @ w,102 say "     -0"
	endif  
	@ w,115 say "|"
	w=w+1
    @ w,10 say "|"
	@ w,70 say "Zakup"
	@ w,87 say zak_il picture "9999999.99"
	@ w,102 say zak_cen picture "9999999.99" 
	@ w,115 say "|"	
	w=w+1
    @ w,10 say "|"
	@ w,70 say "Produkcja"
	@ w,87 say prod_il picture "9999999.99"
	@ w,102 say prod_cen picture "9999999.99" 
	@ w,115 say "|"	
    w=w+1
	@ w,10 say "|"
	@ w,87 say "----------"
	@ w,102 say "----------"
	@ w,115 say "|"	
    w=w+1
	@ w,10 say "|"
	@ w,70 say "R a z e m :" 
	@ w,87 say mil picture "9999999.99" 
	@ w,102 say mcen_m picture "9999999.99" 
	@ w,115 say "|"	
    w=w+1
	@ w,10 say ltx0
	w=w+1
	@ w,10 say "|"
	@ w,11 say replicate(chr(196),104)
	@ w,115 say "|"
 endif
 skip
enddo
eject
*close all
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


FUNCTION CENA_TYT(pstrona)
local ltx1:="=========================================================================================================="
local ltx2:="| Nr  | Nazwa pozycji magazynowej       |  Kod  | J.m | Zrodlo pochodzenia |   Ilosc      | Cena srednia |"
local ltx3:="|=====|=================================|=======|=====|====================|==============|==============|"
local ltx4:="|                                                                                                        |"
local ltx5:="|                                                                                                        |"
@ w,10 say "Usrednianie cen                                                                      Strona:                "
@ w,102 say pstrona picture "99999"
w=w+1
@ w,10 say ltx1
w=w+1
@ w,10 say ltx2
w=w+1
@ w,10 say ltx3
RETURN nil


*******************************************************************************
* Funkcja drukuje zestawienie dokumentow  sprzedazy w cenach zakupu i         *
* sprzedazy z rozdzieleniem na sprzedaz wyrobow, polwyrobow, surowcow i       *
* towarow. Podlicza place zawarta w sprzedanych wyrobach z uwzglednieniem     *
* placy zawartej w polwyrobach wchodzacych w sklad sprzedawanych pozycji.     *
*******************************************************************************
FUNCTION SPRZEDAZ_DRUK(pbaza)
local lcykl:=1,lstrona:=1,lp:=0
local sel_bz,sel_sp
local ltxt1:="",ltxt2
local ltx0:="|                                                                                                                 |"
local ltyt:=""
local zak_all:=0,sprzed_all:=0,sur_all:=0,polwyr_all:=0,wyr_all:=0
local tow_all:=0,inne_all:=0,plac_all:=0
local zak_sum,sprzed_sum,sur_sum,polwyr_sum,wyr_sum,tow_sum,inne_sum,plac_sum
local zak_dok,sprzed_dok,sur_dok,polwyr_dok,wyr_dok,tow_dok,inne_dok,plac_dok
ltyt="       ZESTAWIENIE SPRZEDAZY W CENACH ZAKUPU I SPRZEDAZY        "
  pmagdefault(1)
  bz_use(bil_num_mies)
  sel_bz=select()
  set default to 1dok
  do case
    case pbaza=1
	  use sprzedaz index sprzedaz new
	  ltxt2="SPRZEDAZ KRAJOWA"
    case pbaza=2
      use sp_expo new
	  index on tndok to sp_expo
      use sp_expo index sp_expo
	  ltxt2="SPRZEDAZ EKSPORTOWA"
    case pbaza=3
      use sp_ue new
	  index on tndok to sp_ue
      use sp_ue index sp_ue
	  ltxt2="SPRZEDAZ W RAMACH UE"  
  endcase
  sel_sp=select()
do startdruk
set device to printer

do while.t.
  @ prow(),pcol() say &zdr_kkond
  w=prow()
  @ w,7 say ltyt
  w=w+1
  @ w,6 say "================================================================="
  w=w+2
  @ w,0 say ltxt2
  w=w+2
  @ w,0 say "OKRES ROZLICZENIOWY   Rok:"
  @ w,26 say year(bil_dat) 
  @ W,37 say "Miesiac:"
  @ w,46 say bil_miesiac
  w=w+2
  do case
    case lcykl=1
      ltxt1="FAKTURY"	
	  set filter to month(tdat)=bil_num_mies.and.substr(tndok,12,1)$"FURN"
    case lcykl=2
      ltxt1="RACHUNKI"
	  set filter to month(tdat)=bil_num_mies.and.substr(tndok,12,1)$"**"
    case lcykl=3
      ltxt1="PARAGONY"	  	  
	  set filter to month(tdat)=bil_num_mies.and.substr(tndok,12,1)$"PT"
    case lcykl=4
      ltxt1="RAZEM:    FAKTURY + RACHUNKI + PARAGONY"	  	  
  endcase
  go top
  @ w,0 say ltxt1
  w=w+3
  if lcykl=4
    w=w+5
    @ w,0 say "Laczna wartosc dokumentow w cenach zakupu:"
	w=w+2
	@ w,15 say "S U R O W C E ...................."
    @ w,50 say sur_all picture "99999999.99"
	w=w+2
	@ w,15 say "P O L W Y R O B Y ................"
    @ w,50 say polwyr_all picture "99999999.99"	
	w=w+2
	@ w,15 say "W Y R O B Y ......................"
    @ w,50 say wyr_all picture "99999999.99"	
	w=w+2
	@ w,15 say "T O W A R Y   H A N D L O W E ...."
    @ w,50 say tow_all picture "99999999.99"	
	w=w+2
	@ w,15 say "I N N E  ........................."
    @ w,50 say inne_all picture "99999999.99"
	w=w+2
    @ w,50 say "-----------"			
	w=w+2
    @ w,40 say "Razem:  "				
    zak_all=sur_all+polwyr_all+wyr_all+tow_all+inne_all
	@ w,50 say zak_all picture "99999999.99"	  
	w=w+4
    @ w,0 say "Laczna wartosc dokumentow w cenach sprzedazy:"
	@ w,50 say sprzed_all picture "99999999.99"
	w=w+4
    @ w,0 say "Wartosc sprzedazy - Wartosc zakupu  ............."
	@ w,50 say sprzed_all-zak_all picture "99999999.99"		
	w=w+6
    @ w,0 say "Laczna wartosc wynagrodzenia zawarta             "
	w=w+1
    @ w,0 say "w sprzedanych wyrobach i polwyrobach ............"
	@ w,50 say plac_all picture "99999999.99"			
	eject
	exit
  endif
  @ prow(),pcol() say &zdr_kond  
  sprzedaz_tyt(lstrona)
  ***************************koniec naglowka
  zak_sum=0
  sprzed_sum=0
  sur_sum=0
  polwyr_sum=0
  wyr_sum=0
  tow_sum=0
  inne_sum=0
  plac_sum=0
  lp=0
  do while.not.eof()
      w=w+1
      if w>dlugosc_str
	    eject
        w=prow()
		lstrona=lstrona+1
		sprzedaz_tyt(lstrona)
		w=prow()+1
	  endif	    
    lp=lp+1
	ltndok=tndok
    ltdat=tdat
	zak_dok=0
    sprzed_dok=0	
    sur_dok=0
    polwyr_dok=0
    wyr_dok=0
    tow_dok=0
    inne_dok=0
    plac_dok=0	
	do while tndok=ltndok
	  ltnaz=tnaz
	  ltkod=tkod
	  ltjm=tjm
	  select &sel_bz
	  if kj_mseek(ltnaz,ltkod,ltjm)
      lmcen_m=mcen_m
      lsred_plac=sred_plac

*	    lmcen_m=round(mcen_m,2)
*		lsred_plac=round(sred_plac,2)
      else
	    lmcen_m=0
		lsred_plac=0
	    set device to screen
		kj_tkom(8," Uwaga! ","Wykryto konflikt w bazie bz* w pozycji",ltnaz+ltkod,"Popraw i ponow probe",5)
	    set device to printer
	  endif
	  select &sel_sp
*      sprzed_dok=sprzed_dok+round(til*tcen,2)
*plac_dok=plac_dok+til*lsred_plac
      sprzed_dok=sprzed_dok+round(til*tcen,2)
	  plac_dok=plac_dok+round(til*lsred_plac,2)
	  do case     
        case substr(tkod,1,2)="01"
		  wyr_dok=wyr_dok+til*lmcen_m
        case substr(tkod,1,2)="02"
		  polwyr_dok=polwyr_dok+til*lmcen_m
        case substr(tkod,1,2)="03"
		  sur_dok=sur_dok+til*lmcen_m
        case substr(tkod,1,2)="04"
		  tow_dok=tow_dok+til*lmcen_m		  		  		  
		otherwise
		  inne_dok=inne_dok+til*lmcen_m
	  endcase
	  skip
	enddo
	zak_dok=wyr_dok+polwyr_dok+sur_dok+tow_dok+inne_dok
	lmarza=((sprzed_dok-zak_dok)/sprzed_dok)*100
	sprzed_sum=sprzed_sum+sprzed_dok
	sur_sum=sur_sum+sur_dok
	polwyr_sum=polwyr_sum+polwyr_dok
	wyr_sum=wyr_sum+wyr_dok
	tow_sum=tow_sum+tow_dok
	inne_sum=inne_sum+inne_dok
	plac_sum=plac_sum+plac_dok
	
	@ w,0 say "|"
	@ w,1 say lp picture "9999"
	@ w,6 say ltndok  
	@ w,22 say ltdat
    @ w,31 say zak_dok picture "99999999.99"
	@ w,43 say sprzed_dok picture "99999999.99"
	@ w,55 say sur_dok picture "99999999.99"
	@ w,67 say polwyr_dok picture "99999999.99"
	@ w,79 say wyr_dok picture "99999999.99"
	@ w,91 say tow_dok picture "99999999.99"
	@ w,103 say inne_dok picture "99999999.99"
	@ w,115 say lmarza picture "999.9"
	@ w,121 say plac_dok picture "999999.99"
    @ w,130 say "|"
  enddo
  w=w+1
  @ w,0 say "=====================|========|===========|===========|===========|===========|===========|===========|===========|=====|=========|"
  w=w+1
  @ w,21 say "|"
  @ w,23 say "Razem:"
    @ w,31 say sur_sum+polwyr_sum+wyr_sum+tow_sum+inne_sum picture "99999999.99"
	@ w,43 say sprzed_sum picture "99999999.99"
	@ w,55 say sur_sum picture "99999999.99"
	@ w,67 say polwyr_sum picture "99999999.99"
	@ w,79 say wyr_sum picture "99999999.99"
	@ w,91 say tow_sum picture "99999999.99"
	@ w,103 say inne_sum picture "99999999.99"
	@ w,121 say plac_sum picture "999999.99"
    @ w,130 say "|"
  w=w+1
  @ w,21 say replicate("=",110)
  
  sprzed_all=sprzed_all+sprzed_sum
  sur_all=sur_all+sur_sum
  polwyr_all=polwyr_all+polwyr_sum
  wyr_all=wyr_all+wyr_sum
  tow_all=tow_all+tow_sum
  inne_all=inne_all+inne_sum
  plac_all=plac_all+plac_sum
  eject
  lcykl=lcykl+1
  lstrona=1
enddo

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
RETURN .T.


FUNCTION SPRZEDAZ_TYT(pstrona)
local ltx0:="Zestawienie sprzedazy w cenach zakupu  i sprzedazy                                                   Strona:"                   
local ltx1:="==================================================================================================================================="
local ltx2:="| Lp | Numer         | Data   |   Wartosc w cenach    |          Wartosc w cenach zakupu z podzialem na :         |marza| Placa   |"
local ltx3:="|    | dokumentu     |        | zakupu    | sprzedazy | Surowce   | Polwyroby | Wyroby    | Towary    | I n n e   | [%] |         |"
local ltx4:="|====|===============|========|===========|===========|===========|===========|===========|===========|===========|=====|=========|"
local ltx5:="|                                                                                                                                 |"
local ltx6:="|                                                                                                                                 |"
@ w,0 say ltx0
@ w,110 say pstrona picture "99999"
w=w+1
@ w,0 say ltx1
w=w+1
@ w,0 say ltx2
w=w+1
@ w,0 say ltx3
w=w+1
@ w,0 say ltx4
*w=w+1
*@ w,0 say ltx5
*w=w+1
RETURN nil


*******************************************************************************
* Funkcja drukuje zestawienie dokumentow  przerobu. Wylicza w cenach          *
* zakupu wartosc wyrobow i polwyrobow oraz wartosc zawartych w nich           *
* surowcow, polwyrobow i wyrobow                                              *
*******************************************************************************
FUNCTION MM_DRUK()
local lcykl:=1,lstrona:=1,lp:=0
local sel_bz,sel_sp,sel_mm
local ltxt1:="",ltxt2
local ltx0:="|                                                                                                                 |"
local ltyt:=""
local gwyr_dok,gpolwyr_dok,gwyr_sum,gpolwyr_sum,gsur_dok,gsur_sum,gtow_dok,gtow_sum
local sur_sum,polwyr_sum,wyr_sum,tow_sum,inne_sum,plac_sum
local sur_dok,polwyr_dok,wyr_dok,tow_dok,inne_dok,plac_dok
ltyt="                ZESTAWIENIE DOKUMENTOW PRZEROBU                 "

  pmagdefault(1)
  bz_use(bil_num_mies)
  sel_bz=select()
  set default to 1dok
  use mmdok index mmdok new
  sel_mm=select()
  use bilp_sur new
  index on tndok to bilp_sur
  use bilp_sur index bilp_sur
  set filter to month(tdat)=bil_num_mies
  go top
  sel_psur=select()
do startdruk
set device to printer
do while.t.
  @ prow(),pcol() say &zdr_kkond
  w=prow()
  @ w,7 say ltyt
  w=w+1
  @ w,6 say "================================================================="
  w=w+2
*  @ w,0 say ltxt2
  w=w+2
  @ w,0 say "OKRES ROZLICZENIOWY   Rok:"
  @ w,26 say year(bil_dat) 
  @ W,37 say "Miesiac:"
  @ w,46 say bil_miesiac
  w=w+3
  if lcykl=2
   	sur_sum=round(sur_sum,2)
	polwyr_sum=round(polwyr_sum,2)
	wyr_sum=round(wyr_sum,2)
    tow_sum=round(tow_sum,2)
	inne_sum=round(inne_sum,2)
	lrazem=sur_sum+polwyr_sum+wyr_sum+tow_sum+inne_sum 
    lwyroby=round((wyr_udzial*lrazem)/100,2)
    w=w+5
    @ w,0 say "Laczna wartosc wytworzonych:"
	w=w+2
    @ w,15 say "W Y R O B O W  ..................."
    
	*@ w,50 say lwyroby picture "99 999 999.99"
	@ w,50 say gwyr_sum picture "99 999 999.99"
	w=w+2
    @ w,15 say "P O L W Y R O B O W  ............."
    *@ w,50 say lrazem-lwyroby picture "99 999 999.99"
	@ w,50 say gpolwyr_sum picture "99 999 999.99"
	if.not.gsur_sum=0
	  w=w+2
      @ w,15 say "S U R O W C O W .................."
	  @ w,50 say gsur_sum picture "99 999 999.99"	
	endif
	if.not.gtow_sum=0
	  w=w+2
      @ w,15 say "T O W A R O W ...................."
	  @ w,50 say gtow_sum picture "99 999 999.99"	
	endif	
*****************
	w=w+4
    @ w,0 say "Laczna wartosc zawartych w wyrobach :"
	w=w+2
	@ w,15 say "S U R O W C O W .................."
    @ w,50 say sur_sum picture "99 999 999.99"
	w=w+2
	@ w,15 say "P O L W Y R O B O W .............."
    @ w,50 say polwyr_sum picture "99 999 999.99"	
	w=w+2
	@ w,15 say "I N N Y C H   W Y R O B O W ......"
    @ w,50 say wyr_sum picture "99 999 999.99"	
	w=w+2
	@ w,15 say "T O W A R O W    HANDLOWYCH ......"
    @ w,50 say tow_sum picture "99 999 999.99"	
	w=w+2
	@ w,15 say "I N N Y C H   P O Z Y C J I ......"
    @ w,50 say inne_sum picture "99 999 999.99"		
	w=w+2
    @ w,50 say "-----------"			
	w=w+2
    @ w,40 say "Razem:  "				

	@ w,50 say lrazem picture "99 999 999.99"	
*	w=w+6
*    @ w,0 say "Laczna wartosc wynagrodzenia ...................."
*	@ w,50 say plac_sum picture "99999999.99"			
	eject
	exit
  endif
  @ prow(),pcol() say &zdr_kond  
  mm_tyt(lstrona)
  ***************************koniec naglowka
  sur_sum=0
  polwyr_sum=0
  wyr_sum=0
  tow_sum=0
  inne_sum=0
  plac_sum=0 
  gwyr_sum=0
  gsur_sum=0
  gtow_sum=0
  gpolwyr_sum=0
  lp=0
  do while.not.eof()
      w=w+1
      if w>dlugosc_str
	    eject
        w=prow()
		lstrona=lstrona+1
		mm_tyt(lstrona)
		w=prow()+1
	  endif	    
    lp=lp+1
	ltndok=tndok
    ltdat=tdat
    ltnkon =tnkon  
    sur_dok=0
    polwyr_dok=0
    wyr_dok=0
    tow_dok=0
    inne_dok=0
	do while tndok=ltndok
	  ltnaz=tnaz
	  ltkod=tkod
	  ltjm=tjm
	  select &sel_bz
	  if kj_mseek(ltnaz,ltkod,ltjm)
	    lmcen_m=mcen_m
		lsred_plac=sred_plac
      else
	    lmcen_m=0
		lsred_plac=0
	    set device to screen
		kj_tkom(8," Uwaga! ","Wykryto konflikt w bazie bz* w pozycji",lsnaz+lskod,"Popraw i ponow probe",5)
	    set device to printer
	  endif
	  select &sel_psur
	  do case     
        case substr(tkod,1,2)="01"
		  wyr_dok=wyr_dok+til*lmcen_m
        case substr(tkod,1,2)="02"
		  polwyr_dok=polwyr_dok+til*lmcen_m
        case substr(tkod,1,2)="03"
		  sur_dok=sur_dok+til*lmcen_m
        case substr(tkod,1,2)="04"
		  tow_dok=tow_dok+til*lmcen_m		  		  		  
		otherwise
		  inne_dok=inne_dok+til*lmcen_m
	  endcase
	  skip
	enddo
	sur_sum=sur_sum+sur_dok
	polwyr_sum=polwyr_sum+polwyr_dok
	wyr_sum=wyr_sum+wyr_dok
	tow_sum=tow_sum+tow_dok
	inne_sum=inne_sum+inne_dok
*   plac_sum=plac_sum+plac_dok
*********************************	
	select &sel_mm
    gwyr_dok=0
	gpolwyr_dok=0
	gsur_dok=0
	gtow_dok=0
	plac_dok=0
	seek ltndok
	do while tndok=ltndok
	  ltnaz=tnaz
	  ltkod=tkod
	  ltjm=tjm
	  select &sel_bz
      if kj_mseek(ltnaz,ltkod,ltjm)
	    lmcen_m=prod_cen
	  else
	    lmcen_m=0
	  endif
	  select &sel_mm
	  plac_dok=plac_dok+til*tcen
      do case
	    case substr(tkod,1,2)="01"
		  gwyr_dok=gwyr_dok+til*lmcen_m
	    case substr(tkod,1,2)="02"
		  gpolwyr_dok=gpolwyr_dok+til*lmcen_m		  
	    case substr(tkod,1,2)="03"
		  gsur_dok=gsur_dok+til*lmcen_m		  
	    case substr(tkod,1,2)="04"
		  gtow_dok=gtow_dok+til*lmcen_m		  
	  endcase
	  skip
	enddo
	plac_sum=plac_sum+plac_dok
	gwyr_sum=gwyr_sum+gwyr_dok
	gpolwyr_sum=gpolwyr_sum+gpolwyr_dok
	gsur_sum=gsur_sum+gsur_dok
	gtow_sum=gtow_sum+gtow_dok	
    wyr_udzial=round((gwyr_dok/(gwyr_dok+gpolwyr_dok))*100,1)
    polwyr_udzial=round((gpolwyr_dok/(gwyr_dok+gpolwyr_dok))*100,1)
	@ w,0 say "|"
	@ w,1 say lp picture "9999"
	@ w,6 say ltndok  
	@ w,22 say ltdat
*   @ w,31 say gwyr_dok picture "99999999.99"
*	@ w,44 say gpolwyr_dok picture "99999999.99"
	
    @ w,34 say wyr_udzial picture "999.9"
	@ w,41 say "%"
	@ w,47 say polwyr_udzial picture "999.9"
	@ w,54 say "%"
	@ w,58 say sur_dok picture "99999999.99"
	@ w,71 say polwyr_dok picture "99999999.99"
	@ w,84 say wyr_dok picture "99999999.99"
	@ w,97 say tow_dok picture "99999999.99"
	@ w,110 say inne_dok picture "99999999.99"
*	@ w,109 say plac_dok picture "999999.99"
    @ w,122 say "|"
    select &sel_psur
  enddo
  w=w+1
  @ w,0 say "=====================|========|================|===============|================|===============|===========|=======|"
  w=w+1
  @ w,21 say "|"
  @ w,23 say "Razem:"
    wyr_udzial=round((gwyr_sum/(gwyr_sum+gpolwyr_sum))*100,1)
    polwyr_udzial=round((gpolwyr_sum/(gwyr_sum+gpolwyr_sum))*100,1)
*   @ w,31 say gwyr_sum picture "99999999.99"
*   @ w,44 say gpolwyr_sum picture "99999999.99"
    @ w,34 say wyr_udzial picture "999.9"
	@ w,41 say "%"
	@ w,47 say polwyr_udzial picture "999.9"
	@ w,54 say "%"
	@ w,58 say sur_sum picture "99999999.99"
	@ w,71 say polwyr_sum picture "99999999.99"
	@ w,84 say wyr_sum picture "99999999.99"
	@ w,97 say tow_sum picture "99999999.99"
	@ w,110 say inne_sum picture "99999999.99"
*	@ w,109 say plac_sum picture "9999999.99"
    @ w,122 say "|"
  w=w+1
  @ w,21 say replicate("=",96)
  eject
  lcykl=lcykl+1
enddo

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
RETURN .T.


RETURN .T.


FUNCTION MM_TYT(pstrona)
local ltx0:="Zestawienie dokumentow przerobu                                                                      Strona:"        
local ltx1:="==========================================================================================================================="
local ltx2:="| Lp | Numer         | Data   |     Procentowy udzial   ||                Wartosc zawartych w produktach :                |"
local ltx3:="|    | dokumentu     |        |  Wyrobow   | Polwyrobow || Surowcow   | Polwyrobow |  Wyrobow   |  Towarow   |Innych poz. |"
local ltx4:="|====|===============|========|============|============||============|============|============|============|============|"
local ltx5:="|                                                                                                                         |"
local ltx6:="|                                                                                                                         |"
@ w,0 say ltx0
@ w,110 say pstrona picture "99999"
w=w+1
@ w,0 say ltx1
w=w+1
@ w,0 say ltx2
w=w+1
@ w,0 say ltx3
w=w+1
@ w,0 say ltx4
*w=w+1
*@ w,0 say ltx5
*w=w+1
RETURN nil




*******************************************************************************
* Funkcja drukuje zestawienie dokumentow  zakupu  w cenach zakupu             *
* z rozdzieleniem na sprzedaz wyrobow, polwyrobow, surowcow i towarow         *
*******************************************************************************
FUNCTION ZAKUP_DRUK()
local lcykl:=1,lstrona:=1,lp:=0
local sel_bz,sel_zak
local ltxt1:="",ltxt2
local ltx0:="|                                                                                                                 |"
local ltyt:=""
local zak_all:=0,sur_all:=0,polwyr_all:=0,wyr_all:=0,tow_all:=0,inne_all:=0
local zak_sum:=0,sur_sum:=0,polwyr_sum:=0,wyr_sum:=0,tow_sum:=0,inne_sum:=0
local zak_dok:=0,sur_dok:=0,polwyr_dok:=0,wyr_dok:=0,tow_dok:=0,inne_dok:=0
ltyt="              ZESTAWIENIE DOKUMENTOW ZAKUPU                  "
  pmagdefault(1)
  bz_use(bil_num_mies)
  sel_bz=select()
  set default to 1dok
  use zakup index zakup new
  sel_zak=select()
do startdruk
set device to printer

do while.t.
  @ prow(),pcol() say &zdr_kkond
  w=prow()
  @ w,7 say ltyt
  w=w+1
  @ w,6 say "================================================================="
  w=w+2
*  @ w,0 say ltxt2
  w=w+2
  @ w,0 say "OKRES ROZLICZENIOWY   Rok:"
  @ w,26 say year(bil_dat) 
  @ W,37 say "Miesiac:"
  @ w,46 say bil_miesiac
  w=w+2
  set filter to month(tdat)=bil_num_mies
  go top
  @ w,0 say ltxt1
  w=w+3
  if lcykl=2
    w=w+5
    @ w,0 say "Laczna wartosc zakupow z podzialem na :"
	w=w+2
	@ w,15 say "S U R O W C E ...................."
    @ w,50 say sur_sum picture "99999999.99"
	w=w+2
	@ w,15 say "P O L W Y R O B Y ................"
    @ w,50 say polwyr_sum picture "99999999.99"	
	w=w+2
	@ w,15 say "W Y R O B Y ......................"
    @ w,50 say wyr_sum picture "99999999.99"	
	w=w+2
	@ w,15 say "T O W A R Y   H A N D L O W E ...."
    @ w,50 say tow_sum picture "99999999.99"	
	w=w+2
	@ w,15 say "I N N E  ........................."
    @ w,50 say inne_sum picture "99999999.99"
	w=w+2
    @ w,50 say "-----------"			
	w=w+2
    @ w,40 say "Razem:  "				
    zak_sum=sur_sum+polwyr_sum+wyr_sum+tow_sum+inne_sum
	@ w,50 say zak_sum picture "99999999.99"	  
	w=w+4
    @ w,0 say "Laczna wartosc dokumentow ......................."
	@ w,50 say zak_sum picture "99999999.99"
	eject
	exit
  endif
  @ prow(),pcol() say &zdr_kond  
  zakup_tyt(lstrona)
  ***************************koniec naglowka
  zak_sum=0
  sprzed_sum=0
  sur_sum=0
  polwyr_sum=0
  wyr_sum=0
  tow_sum=0
  inne_sum=0
  plac_sum=0
  lp=0
  do while.not.eof()
      w=w+1
      if w>dlugosc_str
	    eject
        w=prow()
		lstrona=lstrona+1
        zakup_tyt(lstrona)
		w=prow()+1
	  endif	    
    lp=lp+1
	ltndok=tndok
    ltzewndok=tzewndok
	ltdat=tdat
	zak_dok=0
    sur_dok=0
    polwyr_dok=0
    wyr_dok=0
    tow_dok=0
    inne_dok=0
	do while tndok=ltndok
	  do case     
        case substr(tkod,1,2)="01"
		  wyr_dok=wyr_dok+til*tcen_m
        case substr(tkod,1,2)="02"
		  polwyr_dok=polwyr_dok+til*tcen_m
        case substr(tkod,1,2)="03"
		  sur_dok=sur_dok+til*tcen_m
        case substr(tkod,1,2)="04"
		  tow_dok=tow_dok+til*tcen_m		  		  		  
		otherwise
		  inne_dok=inne_dok+til*tcen_m
	  endcase
	  skip
	enddo
	zak_dok=wyr_dok+polwyr_dok+sur_dok+tow_dok+inne_dok
	sur_sum=sur_sum+sur_dok
	polwyr_sum=polwyr_sum+polwyr_dok
	wyr_sum=wyr_sum+wyr_dok
	tow_sum=tow_sum+tow_dok
	inne_sum=inne_sum+inne_dok
	
	@ w,0 say "|"
	@ w,1 say lp picture "9999"
*	@ w,6 say ltndok  
    @ w,6 say ltzewndok  
	@ w,22 say ltdat
    @ w,32 say zak_dok picture "99999999.99"
	@ w,48 say sur_dok picture "99999999.99"
	@ w,64 say polwyr_dok picture "99999999.99"
	@ w,80 say wyr_dok picture "99999999.99"
	@ w,96 say tow_dok picture "99999999.99"
	@ w,112 say inne_dok picture "99999999.99"
    @ w,126 say "|"
  enddo
  w=w+1
  @ w,0 say "|====================|========|===============|===============|===============|===============|===============|===============|"
  w=w+1
  @ w,21 say "|"
  @ w,23 say "Razem:"
    @ w,32 say sur_sum+polwyr_sum+wyr_sum+tow_sum+inne_sum picture "99999999.99"
	@ w,48 say sur_sum picture "99999999.99"
	@ w,64 say polwyr_sum picture "99999999.99"
	@ w,80 say wyr_sum picture "99999999.99"
	@ w,96 say tow_sum picture "99999999.99"
	@ w,112 say inne_sum picture "99999999.99"
    @ w,126 say "|"
  w=w+1
  @ w,21 say replicate("=",107)
  eject
  lcykl=lcykl+1
enddo

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
RETURN .T.


FUNCTION ZAKUP_TYT(pstrona)
local ltx0:="Zestawienie dokumentow zakupu                                                                        Strona:"                   
local ltx1:="==============================================================================================================================="
local ltx2:="| Lp | Numer         | Data   |   Wartosc     |                      Wartosc z podzialem na zakupione :                       |"
local ltx3:="|    | dokumentu     |        |  r a z e m    |   Surowce     |   Polwyroby   |    Wyroby     | Towary handl. |   I n n e     |"
local ltx4:="|====|===============|========|===============|===============|===============|===============|===============|===============|"
local ltx5:="|                                                                                                                             |"
local ltx6:="|                                                                                                                             |"
@ w,0 say ltx0
@ w,110 say pstrona picture "99999"
w=w+1
@ w,0 say ltx1
w=w+1
@ w,0 say ltx2
w=w+1
@ w,0 say ltx3
w=w+1
@ w,0 say ltx4
*w=w+1
*@ w,0 say ltx5
*w=w+1
RETURN nil

*******************************************************************************
* Export - przeliczenie sprzedazy z cen dolarowych na zlotowkowe              *
* Tprac przechowuje przelicznik walutowy pomnozony przez 10000                *
*******************************************************************************
FUNCTION IMP_EXPO()
local plik:=z_eksp_plik,plik_ue:=z_ue_plik,ek
local przed:=0,po:=0,lcolor:=setcolor()
set color to n/w,w/n
save screen to ek
plik=alltrim(plik)
plik_ue=alltrim(plik_ue)
copy file &plik to 1dok\sp_expo.dbf
copy file &plik_ue to 1dok\sp_ue.dbf
set default to 1dok
select 1
use sp_expo
set filter to month(tdat)=bil_num_mies
go top
do while.not.eof()
  przed=przed+til*tcen
  lnum=val(substr(tndok,9,2))
  if tprac#0
    replace tcen with tcen*(tprac/10000)
  else
    kj_tkom(8," Uwaga! Operacja nie moze byc wukonana. ","Brak kursu dnia dla dokumentu",tndok,"Uzupelnij i ponow probe",5)
    close all
	restore screen from ek
	return
  endif	
  skip
enddo
sum til*tcen to po
**
use sp_ue
set filter to month(tdat)=bil_num_mies
go top
do while.not.eof()
  przed=przed+til*tcen
  lnum=val(substr(tndok,9,2))
  if tprac#0
    replace tcen with tcen*(tprac/10000)
  else
    kj_tkom(8," Uwaga! Operacja nie moze byc wukonana. ","Brak kursu dnia dla dokumentu",tndok,"Uzupelnij i ponow probe",5)
    close all
	restore screen from ek
	return
  endif	
  skip
enddo
sum til*tcen to po
**
close all
@ 7,2 say "W dolarach:"
@ 8,2 say "W zlotowkach:"
@ 7,16 say przed
@ 8,16 say po
@ 9,2 say "Sredni kurs za miesiac:"
@ 9,26 say po/przed   
*kj_tkom(10,"","Przeliczanie zakonczone.","","Nacisnij dowolny klawisz",5)
inkey(5)
restore screen from ek
setcolor(lcolor)
RETURN nil


*******************************************************************************
* Funkcja wprowadza ceny srednie z bz_m do magazynu glownego i podmagazynow   *
*******************************************************************************
FUNCTION CENY_BZ_MAG()
local lmag:=1,sel_mag,sel_bz
pmagdefault(1)
*use bz4 index bz4_naz new
bz_use(bil_num_mies)
sel_bz=select()
do while.t.
  pmagdefault(lmag)
  if file("magazyn.dbf")
    use magazyn new
    sel_mag=select()
  else
    save screen to ek
	kj_tkom(8,"","Uaktualniono ceny srednie w",str(lmag-1,3),"magazynach.  Nacisnij dowolny klawisz",5) 
    restore screen from ek
	exit
  endif	
  select &sel_mag
  do while.not.eof()
    lmnaz=mnaz
	lmkod=mkod
	lmjm=mjm
    lmil=mil
	select &sel_bz
    if.not.(empty(lmnaz).and.empty(lmkod)).and..not.lmil=0
      if kj_mseek(lmnaz,lmkod,lmjm)
	    lmcen_m=mcen_m
		select &sel_mag
		replace mcen_m with lmcen_m
	  else
        kj_tkom(8," Uwaga! ","Brak pozycji w BZ*.dbf",lmnaz+lmkod+lmjm,str(lmag),5)
	  endif
	endif  
	select &sel_mag
	skip
  enddo
  use
  lmag=lmag+1
enddo
RETURN nil


FUNCTION SETUP()
local lcolor:=setcolor(),ek
save screen to ek
kj_okno(18,1,5,"                        PARAMETRY PROGRAMU AN_BIL-FIRMA                       ",1)
@ 20,12 say "Eksport ...."
@ 21,12 say "Sciezka ...."
@ 22,12 say "Sciezka UE."
@ 23,12 say "Wydruk do pliku ..."
set cursor on
@ 20,25 get z_eksport
@ 21,25 get z_eksp_plik
@ 22,25 get z_ue_plik
@ 23,32 get plikdruk
read
if lastkey()#27
  set default to kas_baz
  use b_setup new
  replace eksport with z_eksport,eksp_plik with z_eksp_plik,plik with plikdruk
  replace ue_plik with z_ue_plik
endif
set cursor off
use
restore screen from ek
setcolor(lcolor)
RETURN nil



*******************************************************************************
* Funkcja tworzy pliki BZ* dla kazdego magazynu na podstawie BO, przesuniec   *
* zwrotow oraz przerobu ( bo lub bz(*-1), przes1, przes2, bilp_sur )          *
*******************************************************************************
FUNCTION STANY_MAG()
local lmag:=2,sel_gbz,sel_bz,sel_dok,sel_magdef,lcykl
local lmag_nazwa,lmag_miasto,lmag_ulica
local lsurowce:=0,lpolwyroby:=0,lwyroby:=0,ltowary:=0,linne:=0
local gsurowce:=0,gpolwyroby:=0,gwyroby:=0,gtowary:=0,ginne:=0
local lsur_all:=0,lpol_all:=0,lwyr_all:=0,ltow_all:=0,linne_all:=0
local ltyt:=" WARTOSCIOWY BILANS ZAMKNIECIA MAGAZYNOW POMOCNICZYCH "
p_surowce()
set default to 1dok
use magdef new
sel_magdef=select()
pmagdefault(1)
bz_use(bil_num_mies)
sel_gbz=select()
set device to printer
do startdruk
@ prow(),pcol() say &zdr_kkond
w=prow()
@ w,11 say ltyt
w=w+1
@ w,10 say "========================================================="
w=w+3
@ w,0 say "OKRES ROZLICZENIOWY   Rok:           Miesiac:"
@ w,26 say year(bil_dat) 
@ w,46 say bil_miesiac
w=w+3
@ prow(),pcol() say &zdr_kond
mag_pom_tyt()
w=prow()+1
set device to screen

do while.t.
  pmagdefault(lmag)
  if file("magazyn.dbf")
    @ 23,1 say "Magazyn           "
    @ 23,10 say lmag picture "999"
	if.not.file("bo.dbf")
	  use magazyn new
	  copy structure to bo
      use bo
	  index on mnaz to bo_naz
	  index on mkod to bo_kod
	  use
	endif
 	bom(bil_num_mies)
    bz_use(bil_num_mies)
    sel_bz=select()	
	lcykl=1
	do while.t.
      set default to 1dok
	  do case
	    case lcykl=1
          @ 24,1 say "Przesuniecia      "
	      use przes1 new
	    case lcykl=2
          @ 24,1 say "Zwroty            "		
          use przes2 new
	    case lcykl=3
          @ 24,1 say "Przerob           "		
          use bilp_sur new
	  endcase
	  set filter to month(tdat)=bil_num_mies.and.tnkon=lmag
	  go top
      sel_dok=select()
	  do while.not.eof().and..not.(empty(tnaz).and.empty(tkod).and.empty(tjm))
	    lmnaz=tnaz
		lmkod=tkod
		lmjm=tjm
		if lcykl=1
		  lmil=til
		else
		  lmil=-til
		endif  
		lmstawka=tstawka
		lmsymbol=tsymbol
        lmcen_m=tcen_m
		select &sel_gbz
		if kj_mseek(lmnaz,lmkod,lmjm)
		  lmcen_m=mcen_m
		else
		  kj_tkom(8," Uwaga! ","Wykryto konflikt w bazie bzg* w pozycji",lmnaz+lmkod+lmjm,"Popraw i ponow probe",5)
		  close all
		  return
		endif
		select &sel_bz
		if kj_mseek(lmnaz,lmkod,lmjm)
		  replace mil with mil+lmil,mcen_m with lmcen_m
		else
		  append blank
		  replace mnaz with lmnaz,mkod with lmkod,mjm with lmjm,mil with lmil
		  replace mstawka with lmstawka, msymbol with lmsymbol,mcen_m with lmcen_m
		endif
	    select &sel_dok
		skip
	  enddo
	  use
	  lcykl=lcykl+1
	  if lcykl>3
	    exit
	  endif
    enddo
  else
    save screen to ek
	kj_tkom(8,"","Przeanalizowano ilosci w",str(lmag-1,3),"magazynach.  Nacisnij dowolny klawisz",5) 
    restore screen from ek
	exit
  endif
  select &sel_magdef
  locate for mag_nr=lmag
  lmag_nazwa=mag_nazwa
  lmag_miasto=mag_miasto
  lmag_ulica=mag_ulica
  select &sel_bz
  go top
  lsurowce=0
  lpolwyroby=0
  lwyroby=0
  ltowary=0
  linne=0
  do while.not.eof()
    do case
	  case substr(mkod,1,2)="03"
	    lsurowce=lsurowce+mil*mcen_m
	  case substr(mkod,1,2)="02"
	    lpolwyroby=lpolwyroby+mil*mcen_m		
	  case substr(mkod,1,2)="01"
	    lwyroby=lwyroby+mil*mcen_m				
	  case substr(mkod,1,2)="04"
	    ltowary=ltowary+mil*mcen_m				
      otherwise
	    linne=linne+mil*mcen_m
	endcase    
    skip
  enddo
  lsur_all=lsur_all+lsurowce
  lpol_all=lpol_all+lpolwyroby
  lwyr_all=lwyr_all+lwyroby
  ltow_all=ltow_all+ltowary
  linne_all=linne_all+linne
  set device to printer
  @ w,0 say "|"
  @ w,1 say lmag picture "999"
  @ w,7 say lmag_nazwa
  @ w,24 say lmag_miasto
  @ w,40 say lmag_ulica
  @ w,56 say lsurowce picture "9999999.99"
  @ w,67 say lpolwyroby picture "9999999.99"
  @ w,78 say lwyroby picture "9999999.99"
  @ w,89 say ltowary picture "9999999.99"
  if.not.linne=0
    @ w,100 say linne picture "9999999.99"        
  endif	
  @ w,111 say lsurowce+lpolwyroby+lwyroby+ltowary+linne picture "9999999.99"  
  @ w,122 say "|"
  w=w+1
  set device to screen 
  use  
  lmag=lmag+1
enddo

select &sel_gbz
go top
  do while.not.eof()
    do case
	  case substr(mkod,1,2)="03"
	    gsurowce=gsurowce+mil*mcen_m
	  case substr(mkod,1,2)="02"
	    gpolwyroby=gpolwyroby+mil*mcen_m		
	  case substr(mkod,1,2)="01"
	    gwyroby=gwyroby+mil*mcen_m				
	  case substr(mkod,1,2)="04"
	    gtowary=gtowary+mil*mcen_m				
      otherwise
	    ginne=ginne+mil*mcen_m
	endcase    
    skip
  enddo
  use
  select &sel_magdef
  lmag=1
  locate for mag_nr=lmag
  lmag_nazwa=mag_nazwa
  lmag_miasto=mag_miasto
  lmag_ulica=mag_ulica
  use
gsurowce=gsurowce-lsur_all
gpolwyroby=gpolwyroby-lpol_all
gwyroby=gwyroby-lwyr_all
gtowary=gtowary-ltow_all
ginne=ginne-linne_all

set device to printer  		
  @ w,0 say "|"
  @ w,122 say "|"
  w=w+1
  @ w,0 say "|"
  @ w,1 say lmag picture "999"
  @ w,7 say lmag_nazwa
  @ w,24 say lmag_miasto
  @ w,40 say lmag_ulica
  @ w,56 say gsurowce picture "9999999.99"
  @ w,67 say gpolwyroby picture "9999999.99"
  @ w,78 say gwyroby picture "9999999.99"
  @ w,89 say gtowary picture "9999999.99"
  if.not.ginne=0
    @ w,100 say ginne picture "9999999.99"        
  endif	
  @ w,111 say gsurowce+gpolwyroby+gwyroby+gtowary+ginne picture "9999999.99"  
  @ w,122 say "|"
  w=w+1
gsurowce=gsurowce+lsur_all
gpolwyroby=gpolwyroby+lpol_all
gwyroby=gwyroby+lwyr_all
gtowary=gtowary+ltow_all
ginne=ginne+linne_all

@ w,0 say "|======================================================|==========|==========|==========|==========|==========|===========|"
w=w+1
@ w,55 say "|"
  @ w,56 say gsurowce picture "9999999.99"
  @ w,67 say gpolwyroby picture "9999999.99"
  @ w,78 say gwyroby picture "9999999.99"
  @ w,89 say gtowary picture "9999999.99"
  if.not.ginne=0
    @ w,100 say ginne picture "9999999.99"        
  endif	
  @ w,111 say gsurowce+gpolwyroby+gwyroby+gtowary+ginne picture "9999999.99"  
  @ w,122 say "|"
w=w+1
@ w,0 say "                                                       ===================================================================|"
eject
set device to screen   		
close all
RETURN

FUNCTION MAG_POM_TYT()
local ltx1:="==========================================================================================================================="
local ltx2:="|Lp.|    Magazyn       |           A D R E S           |                   WARTOSC W CENACH SREDNICH                      |"  
local ltx3:="|   |                  |     Miasto    |      Ulica    | Surowce  | Polwyroby| Wyroby   | Towary   | Inne     | Razem     |"
local ltx4:="|===|==================|===============|===============|==========|==========|==========|==========|==========|===========|"
local ltx5:="|                                                                                                                         |"
@ w,0 say ltx1
w=w+1
@ w,0 say ltx2
w=w+1
@ w,0 say ltx3
w=w+1
@ w,0 say ltx4
RETURN NIL


FUNCTION MAG_REPLAC()  
		replace mnaz with zmnaz,mindex with zmindex,nmag with znmag 
	    replace mil with zmil,mrez with zmrez,mcen_m with zmcen_m
        replace mkod with zmkod,magaz with zmagaz,mjm with zmjm    		
		replace mdata with zmdata,mstawka with zmstawka,msymbol with zmsymbol
		replace mwaluta with zmwaluta,mntrah with zmntrah,magnum with zmagnum
		replace mdokzak with zmdokzak,mster with zmster,mcen_p with zmcen_p 
        replace mcen_d with zmcen_d,mcen_h with zmcen_h		
RETURN	nil	
