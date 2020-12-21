clear
licz1:=0
licz2:=0
licz3:=0
do while.t.
set cursor on
@ 5,2 say "Pierwsza liczba: "
@ 5,20 get licz1 picture "99999.99999999999999"
@ 7,2 say "Druga liczba: "
@ 7,20 get licz2 picture "99999.99999999999999"
read
if lastkey()=27
  return
endif
licz3=licz1/licz2
set cursor off
@ 10,2 say "Wynik dzielenia: "
@ 10,20 say licz3  picture "99999.99999999999999"
enddo
return