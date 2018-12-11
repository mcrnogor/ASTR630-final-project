# ASTR630-final-project
Final project for ASTR630: FUV data reduction of Saturn's B ring.

The repository contains the following:

observations.csv -- list of the observations that passed the selection criteria set by Bradley et al. (2010) for B ring
FLATFIELD_FUV_POSTBURN.TXT -- flatfield file
GET_FUV_07_LAB_CALIBRATION.PRO -- provides time-sensitive flux calibration
F_FLIGHT_WAVELENGTH.PRO -- provides the wavelength calibration
READ_SPICA_FF_DATA.PRO -- dependency routine for the flux calibration
read_netcdf.pro -- converts netCDF files (solar continuum flux is provided as .ncdf) to a readable format

FUV2005_230_15_15:
* FUV2005_230_15_15.DAT -- example of the raw observation
* FUV2005_230_15_15.LBL -- info about the observation
* FUV2005_230_15_15_CAL_3.DAT -- calibration file
* FUV2005_230_15_15_CAL_3.LBL -- info about the calibration file
* see__L3_2005230_012_01.ncdf -- solar continuum
* FUV2005_230_15_15_clean+cal.fits -- cleaned and calibrated data
* image.pdf -- image of the cleaned and calibrated data
