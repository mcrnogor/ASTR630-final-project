PRO F_Flight_Wavelength,e_wavelength,bin
if n_params(0) le 1 then bin=1
RAD=180./3.1415926
D=1.E7/1066
ALP=(9.22+.032)/RAD
ALP=ALP+3.46465e-5 ; 11-1-99 ADJUSTMENT
BET=(FINDGEN(1024)-511.5)*.025*.99815/300.
BET=ATAN(BET)+.032/RAD+3.46465e-5  ; 11-1-99 ADJUSTMENT
LAM=D*(SIN(ALP)+SIN(BET))
e_wavelength=lam
if bin eq 1 then return

e_wavelength=fltarr(1024/bin)
for k=0,1024/bin-1 do e_wavelength(k)=total(lam(k*bin:(k+1)*bin-1))/bin
RETURN
END
