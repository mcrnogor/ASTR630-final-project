pro read_spica_ff_data,file,ff
; reads the spica asci ff files
openr,1,file
x=''
readf,1,x
readf,1,x
readf,1,x
ff=fltarr(1024,64)
for l=0,63 do begin
test=fltarr(1024)
readf,1,test
ff(*,l)=test
readf,1,x
readf,1,x
end
close,1
return
end
