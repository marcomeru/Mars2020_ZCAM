;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION ratio_lab2img, color, incidence, azimuth, emission, filt_18
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; +
; NAME:
;   RATIO_LAB2IMG
;
; PURPOSE:
;   This routine gets a color (one of the 8 of the Cal-targets), the incidence, azimuth and emission angles
;   and a filter (one of the 18 of Mastcam-Z), and returns the ratio between the reflectance factor in that color and filter
;   but in lab conditions (fixed at i=0, az=90, e=58) and the refl. factor in the input geometric conditions.
;   Each filter has a bandwidth, so the value of the refl. factor in one filter is hereby named 'fold value' since it is computed 
;   as the mean of its spectrum inside the correspondent filter band.
;   The routine uses the 'refl_angles' function to compute the refl. factors in the two illumination geometries (from the Bern dataset),
;   then it makes the spectrum of their ratio from 400 to 1065nm. Finally, it computes the fold value in the chosen filter.
;   
; SYNTAX
;   fold_value = ratio_lab2img("color", incidence, azimuth, emission, "filt_18")
;
; INPUT
;   - color: a string denoting one of the 8 colors of the Cal-targets. Yellow='y', red='r', green='g', blue='b',
;            black='k', dark grey='dg', light grey='lg', white='w'.
;   - incidence: incidence angle in degrees, a value from 0 to 90.
;   - azimuth: azimuth angle in degrees, a value from 0 to 360.
;   - emission: emission angle in degrees, a value from 0 to 90. The angle at which MCZ sees the Cal-targets is 58deg.
;   - filt_18: a string denoting one of the 18 filters of Mastcam-Z. 'L0B', 'L0G', 'L0R', 'R0B', 'R0G', 'R0R',
;              'L6', 'L5', 'L4', 'L3', 'L2', 'L1', 'R1', 'R2', 'R3', 'R4', 'R5', 'R6'.
;   
; OUTPUT
;   - fold_value: the fold value of the ratio in the chosen filter is returned.
;                 
; -
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Create the 18-element arrays containing the 18 filters of Mastcam-Z 
filt_str = ['L0B', 'L0G', 'L0R', 'R0B', 'R0G', 'R0R', 'L6', 'L5', 'L4',$
  'L3', 'L2', 'L1', 'R1', 'R2', 'R3', 'R4', 'R5', 'R6'] ; Names of the filters as strings
IF where(filt_str eq filt_18) eq -1 THEN BEGIN ; Give error if the filter name inserted by the user is not existent
  print, 'Error! Please write the name of the filter using the right expression!'
  print, 'The admitted filter names are: L0B, L0G, L0R, R0B, R0G, R0R, '
  print, 'L6, L5, L4, L3, L2, L1, R1, R2, R3, R4, R5, R6.'
  RETURN, -1
ENDIF
filt_value = [471, 546, 638, 471, 546, 638, 441, 529, 605, 687, 754,$ ; Central wavelengths of the filters
  801, 801, 866, 910, 940, 979, 1012] 
filt_band = [46, 42, 43, 45, 42, 43, 12, 11, 9, 11, 10, 9, 10, 10, 12, 13, 10, 18] ; Delta (half width) of each filter
which_filt = where(filt_str eq filt_18) ; Find the index of the filter chosen by the user

; Define the incidence, azimuth and emission angles of the laboratory conditions (that are fixed)
lab_inc = 58
lab_az = 90
lab_emi = 0

; Compute the 6 values of the refl. factor in the 6 wavelengths from the Bern data in the lab conditions
lab_six = refl_angles(color, lab_inc, lab_az, lab_emi)

; Compute the 6 values of the refl. factor in the 6 wavelengths in the conditions given by the user
img_six = refl_angles(color, incidence, azimuth, emission) 

filt_six = [450, 550, 650, 750, 905, 1064] ; The 6 wavelengths of the Bern data
wl_all = indgen(666, start=400) ; All the wavelengths from 400nm to 1065nm (on which to interpolate)

; Compute the 6 ratios between the lab values and the user's value and interpolate over all the spectrum
ratio_spectrum = interpol(lab_six/img_six, filt_six, wl_all, /spline)

fvwf = filt_value[which_filt] ; Find the value of the central wavelength of the filter chosen by the user
ratio_elem = fvwf-min(wl_all) ; Find the index of that central value from the full spectrum (400-1065nm)

delta = filt_band[which_filt] ; Find the delta of the filter chosen by the user

; Compute the fold value of the lab-to-user ratio related to the filter chosen by the user (= mean of central-delta to central+delta interval)
fold_ratio = mean(ratio_spectrum[ratio_elem-delta:ratio_elem+delta]) 

RETURN, fold_ratio ; Return the fold value of the refl. factor

END