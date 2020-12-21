set default to 1mag
use defi_new new
set device to printer
@ prow(),pcol() say chr(15)
w=prow()
@ w,0 say "Skladnik nie odnaleziony:                    W wyrobie:"
w=w+2
set filter to silosc=-1
go top
do while.not.eof()
  @ w,0 say snazwa+" "+skod+" "+sjm
  @ w,50 say gnazwa+"  "+gkod
  w=w+1
  skip
enddo  
w=w+3
@ w,0 say "Wyroby nie odnalezione: "
w=w+2
set filter to silosc=-2
go top
do while.not.eof()
  @ w,0 say gnazwa+"  "+gkod
  w=w+1
  skip
enddo 
set device to screen 
return