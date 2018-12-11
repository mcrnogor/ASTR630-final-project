;modified 07/24/07, see all DJ below:
;DJ add datFileName, timeEvolutionFile, flatFieldFUVPostBurn, flatFieldFUVPreBurn to params
pro Get_FUV_07_lab_calibration,f_wavelength,f_calibration,f_calibration_error,slit_width,input_spectrum,window_definition,bin_definition,sctime,datFileName, timeEvolutionParamFile, flatFieldFUVPostBurn, flatFieldFUVPreBurn, noff=noff,noevolve=noevolve
if n_params() le 0 then begin
;DJ Print,'Pro Get_FUV_07_Lab_Calibration,e_wavelength,e_calibration,e_calibration_error,slit_width,input_spectrum,window_definition,bin_definition,sctime,noff=noff,noevolve=noevolve'
;DJ Print,'1999 FUV Channel Laboratory Calibration including adjustment to fit H2 model electron lamp spectrum'
;DJ Print,' Adjusted to correct for changes over time, as modeled by the observed change in the spectrum of Spica'
;DJ Print,' '
;DJ Print,'f_wavelength is the wavelength vector
;DJ Print,' '
;DJ Print,'f_calibration is the data MULTIPLIER that converts couts/sec to kilorayleighs/pixel (or kilorayleighs/Angstrom)'
;DJ Print,' '
;DJ Print,'f_calibration_error is the 1-sigma error in e_calibration'
;DJ Print,' '
;DJ print,'slit_width selects ocultation (0), low_resolution (1), or high_resolution (2)'
;DJ print,'
;DJ print,'input_spectrum selects calibration for continuous spectra (1) or for discrete lines (2) '
;DJ print,' '
;DJ print,'window_definition is a four element array that defines the four corners of the detector sub-array containing valid data'
;DJ print,'default is full spectral-spatial window (0,0,1023,63)'
;DJ print,' '
;DJ print,'bin_definition is a two element array that defines the spectralxspatial format'
;DJ print,'for the wavelength scale and the calibration vector'
;DJ print,' '
;DJ print,'sctime is a double-precision floats or longword integer representing the spacecraft time'
;DJ print,' '
;DJ print,'noff is a flag, nonzero to NOT apply the flat field (default is to apply flat field)'
;DJ print,' there is a preburn and postburn flat field, and sctime will determine which to use based on the time of the starburn event'
;DJ print, ' '
;DJ print,'noevolve is a flag, nonzero to NOT time-evolve the sensitivity (default is to apply the time-evolved sensitivity correction)'
;DJ print,' '
;DJ print, 'required data files: '
;DJ print, '  FUV_1999_Lab_Cal.dat'
;DJ print, '  FUV_calibration_time_evolution_parameters.dat'
;DJ print, '  FLATFIELD_FUV_POSTBURN.txt'
;DJ print, '  FLATFIELD_FUV_PREBURN.txt'
;DJ print, ' '
;DJ print, 'required routines:'
;DJ print, '  read_spica_ff_data.pro'
;DJ return
end
if keyword_set(sctime) eq 0 then begin
  print, '*************************************'
  print, '** ERROR: you must provide sctime  **'
  print, '*************************************'
  return
endif
;DJ print,' '
;DJ print,'**************************************************************************************************************'
;DJ Print,'** 1999 FUV Channel Laboratory Calibration including adjustment to fit H2 model electron lamp spectrum      **'
;DJ Print,'**   Adjusted to correct for changes over time, as modeled by the observed change in the spectrum of Spica  **'
;*********************************************
;set up calibration matrix parameters and format
; slit width
if n_params() lt 4 then slit_width=1 ;default is low resolution slit
if (slit_width ne 1) and (slit_width ne 2) and (slit_width ne 0) then read,'*******  Select occultation (0), low resolution (1), or high resolution entrance slit ',slit_width
;DJ if slit_width eq 1 then print,'** Calibration values for low_resolution (0.15mm wide) spectrograph slit                                    **'
;DJ if slit_width eq 2 then print,'** Calibration values for hi_resolution (0.075mm wide) spectrograph slit                                    **'
;DJ if slit_width eq 0 then print,'** Calibration values for occultation (0.80mm wide) spectrograph slit                                    **'
if slit_width eq 0 then slit_width=1.5/8

; input spectrum
if n_params() lt 5 then input_spectrum=1 ;default is continuous
if (input_spectrum ne 1) and (input_spectrum ne 2) then read,'*******  Select either a continus input spectrum (1) or discrete line (2) ',input_spectrum
;DJ if input_spectrum eq 2 then Print,'** Multiply the Data (counts/pixel/sec) by f_calibration to obtain kiloRayleighs/pixel                      **'
;DJ if input_spectrum eq 1 then Print,'** Multiply the Data (counts/pixel/sec) by f_calibration to obtain kiloRayleighs/Angstrom                   **'

; window definition
if n_params() lt 6 then window_definition=[0,0,1023,63]
if n_elements(window_definition) ne 4 then begin
    window_definition=intarr(4)
    read,'*******  input the column and row values of the upper left corner of the window ',temp1,temp2
    window_definition(0)=temp1
    window_definition(1)=temp2
    read,'*******  input the column and row values of the lower right corner of the window ',temp1,temp2
    window_definition(2)=temp1
    window_definition(3)=temp2
end
windef:
if (window_definition(2) lt window_definition(0)) or (window_definition(2) lt window_definition(0))  then begin
  print,'******** faulty window definition try again'
  window_definition=intarr(4)
     read,'*******  input the column and row values of the upper left corner of the window ',temp1,temp2
     window_definition(0)=temp1
     window_definition(1)=temp2
     read,'*******  input the column and row values of the lower right corner of the window ',temp1,temp2
     window_definition(2)=temp1
     window_definition(3)=temp2
end
if (window_definition(2) lt window_definition(0)) or (window_definition(2) lt window_definition(0)) then goto,windef
ul_w=[window_definition(0),window_definition(1)]
lr_w=[window_definition(2),window_definition(3)]
;Print,'** Upper Left Window Corner is ',strtrim(string(ul_w(0)),2),' x ',strtrim(string(ul_w(1)),2),' **'
;Print,'** Lower Right Window Corner is ',strtrim(string(lr_w(0)),2),' x ',strtrim(string(lr_w(1)),2),' **'
format='(I4)'
;DJ Print,'** Upper Left Window Corner is   ',string(ul_w(0),format=format),' x ',string(ul_w(1),format=format),'                                                                **'
;DJ Print,'** Lower Right Window Corner is  ',string(lr_w(0),format=format),' x ',string(lr_w(1),format=format),'                                                                **'
; bin_definition
if n_params() lt 7 then bin_definition=[1,1]  ;defalut is spectral & spatial binning=1
if n_elements(bin_definition) ne 2 then begin
    bin_definition=intarr(2)
    read,'*******  input spectral binning parameter (1=no binning) ' ,temp
    bin_definition(0)=temp
    read,'*******  input spatial binning parameter ((1=no binning) ' ,temp
    bin_definition(1)=temp
end
spectral_bin=bin_definition(0)
spatial_bin=bin_definition(1)
;if (n_params() eq 6) and (n_elements(bin_definition) eq 2) then
spectral_bin=bin_definition(0)
;if (n_params() eq 6) and (n_elements(bin_definition) eq 2) then
spatial_bin=bin_definition(1)
;Print,'** Spectral x Spatial Binning is ', strtrim(string(spectral_bin),2),' x ',strtrim(string(spatial_bin),2),' **'
format='(I4)'
;DJ Print,'** Spectral x Spatial Binning is ', string(spectral_bin,format=format),' x ',string(spatial_bin,format=format),'                                                                **'
;DJ ;print,'*********************************************************************************************************'
;DJ ;print,' '
;get size of unbinned window for later
width=lr_w(0)-ul_w(0)+1
height=lr_w(1)-ul_w(1)+1
; pad it out to integral multiples of the binning parameters
width_pad=spectral_bin*ceil(1.*width/spectral_bin)
height_pad=spatial_bin*ceil(1.*height/spatial_bin)
; get the size of the final returned array partial bins at the endsare included
width_final=ceil(1.*width/spectral_bin)
height_final=ceil(1.*height/spatial_bin)
;**************************
;read calibration data file
get_lun,uu
;DJ removed next line, replaced with following
;DJ openr,uu,'FUV_1999_Lab_Cal.dat'
openr, uu, datFileName ;DJ
x=' '
readf,uu,x
dat=fltarr(13*6)
readf,uu,dat
free_lun,uu
wcal=fltarr(26)
ecalerror=wcal
ecal=wcal
for k=0,12 do wcal(k)=dat(k*6)
for k=0,12 do ecal(k)=dat(k*6+1)
for k=0,12 do ecalerror(k)=dat(k*6+2)
for k=13,25 do wcal(k)=dat((k-13)*6+3)
for k=13,25 do ecal(k)=dat((k-13)*6+4)
for k=13,25 do ecalerror(k)=dat((k-13)*6+5)
;*********************
;generate calibration matrix
;wf(1024)
;f_cal(1024,64)
;f_cal_error(1024,64)
f_flight_wavelength,wf
f_cal=fltarr(1024,64)
f_cal_error=fltarr(1024,64)
fcal=interpol(ecal,wcal,wf)/60.
fcalerror=interpol(ecalerror,wcal,wf)/60.
;----------------------------------------------------------------------------------
; adjust sensitivity to account for elimination of evil pixels in original calibration
fcal = fcal / 0.91
fcalerror = fcalerror / 0.91
if (keyword_set(noevolve) eq 0) then begin
  ; read in parameters for the time-variable sensitivity correction
;DJ removed following file, replaced with next
;DJ  fr = 'FUV_calibration_time_evolution_parameters.dat'
  fr = timeEvolutionParamFile  ;DJ

  openr,fid,fr,/get_lun,/xdr
  sctime0 = 0.d
  a = fltarr(1024,3)
  readu,fid,sctime0
  readu,fid,a
  free_lun,fid
  f_time_var = a[*,0] * exp( a[*,1] * (double(sctime) - sctime0) ) + a[*,2]
  ; adjust the 1999 _sensitivity_ to the current sctime
  fcal = fcal * f_time_var
  fcalerror = fcalerror * f_time_var
endif
;----------------------------------------------------------------------------------
for k=2,61 do f_cal(*,k)=fcal            ; calibration per spatialpixel at the detector center row
for k=2,61 do f_cal_error(*,k)=fcalerror  ; error per spatial pixelat the detector center row
;apply slit width correction
f_cal=f_cal/slit_width
f_cal_error=f_cal_error/slit_width
;apply factor for continuous input spectrum
if input_spectrum eq 1 then begin
    f_cal=f_cal*.78
    f_cal_error=f_cal_error*.78
end
;----------------------------------------------------------------------------------
; apply flat field (default)
sctimeburn = 1402021717d  ; approximate spacecraft time of the starburn even (June 6, 2002)
if keyword_set(noff) eq 0 then begin
  ; read postburn ff
  if sctime gt sctimeburn then begin
    ;DJ removed following file, replaced with next
    ;DJ file = 'FLATFIELD_FUV_POSTBURN.txt'
    file = flatFieldFUVPostBurn    ;DJ
    read_spica_ff_data,file,ff
;DJ    print, '** POSTBURN flat field applied                                                                              **'
  endif
  ; read preburn ff
  if sctime lt sctimeburn then begin
    ;DJ removed following file, replaced with next
    ;DJ file = 'FLATFIELD_FUV_PREBURN.txt'
    file = flatFieldFUVPreBurn
    read_spica_ff_data,file,ff
;DJ    print, '** PREBURN flat field applied                                                                               **'
  endif
  ff = ff * 1.05  ; adjust flat field normalization to account for asymmetry in histogram distribution
  ; the flat field must be multiplied by the data, or equivalently, divided into the _sensitivity_ (calibration=1/sensitivity)
  f_cal = f_cal / ff
  f_cal_error = f_cal_error / ff
endif else begin
  ; if no flat field is applied, set all evil pixels to NaN as the calibration now only applies to good pixels
  file = 'FLATFIELD_FUV_POSTBURN.txt'
  read_spica_ff_data,file,ff
  ndxnan = where( finite(ff) eq 0 )
  f_cal[ndxnan] = !values.f_nan
  f_cal_error[ndxnan] = !values.f_nan
endelse
;DJ print,'**************************************************************************************************************'
;DJ print,' '
;----------------------------------------------------------------------------------
;extract the correct window padded out to integral binning
;wave_temp
;f_cal_temp(width_pad,height_pad)
;f_err_temp(width_pad,height_pad)

wave_temp=fltarr(width_pad)
f_cal_temp=fltarr(width_pad,height_pad)
f_err_temp=fltarr(width_pad,height_pad)
wave_temp(0:width-1)=wf(ul_w(0):lr_w(0))
f_cal_temp(0:width-1,0:height-1)=f_cal(ul_w(0):lr_w(0),ul_w(1):lr_w(1))
f_err_temp(0:width-1,0:height-1)=f_cal_error(ul_w(0):lr_w(0),ul_w(1):lr_w(1))
f_wavelength=fltarr(width_final)
f_calibration=fltarr(width_final,height_final)
f_calibration_error=fltarr(width_final,height_final)
for k=0,width_final-1 do f_wavelength(k)=mean(wave_temp(k*spectral_bin:(k+1)*spectral_bin-1))
for k=0,height_final-1 do for l=0,width_final-1 do begin
    f_calibration(l,k)=total(f_cal_temp(l*spectral_bin:(l+1)*spectral_bin-1,k*spatial_bin:(k+1)*spatial_bin-1))
    f_calibration_error(l,k)=total(f_err_temp(l*spectral_bin:(l+1)*spectral_bin-1,k*spatial_bin:(k+1)*spatial_bin-1))/sqrt(spatial_bin*spectral_bin)
end
cal_temp=(f_calibration eq 0)*1.e10+f_calibration
err_temp=(f_calibration eq 0)*1.e10+f_calibration_error
f_calibration=1./cal_temp
f_calibration_error=err_temp/cal_temp/cal_temp
f_calibration=(f_calibration gt 1.e-9)*f_calibration
f_calibration_error=(f_calibration_error gt 1.e-9)*f_calibration_error
end
return
end