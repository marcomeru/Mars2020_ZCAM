;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION refl_fac_filter, color, incidence, azimuth, emission, filt_18
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; +
  ; NAME
  ;   REFL_FAC_FILTER
  ; 
  ; PURPOSE
  ;   This routine gets one of the 8 colors of the Cal-targets, one of the 18 filters of MCZ, an incidence,
  ;   azimuth and emission angle, and it returns the value of the reflectance factor in those conditions.
  ;   It's called 'fold value' as it is the mean of the refl. factor over the bandwidth of the filter.
  ;   The routines makes use of 'ratio_lab2img' function to compute the ratio between the fold values in the lab conditions
  ;   (i=0, az=90, e=58) and in the input conditions using the Bern dataset. The fold result is then obtained by dividing
  ;   the corresponding value in the Copenhagen lab data (at i=0, az=90, e=58) by the fold ratio. 
  ;   This is equivalent to take the fold value in the input conditions (Bern data), dividing it by the lab conditions (Bern data)
  ;   and multiplying it by the lab conditions (Copenhagen data).
  ;   
  ; SYNTAX
  ;   fold_res = refl_fac_filter("color", incidence, azimuth, emission, "filt_18")
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
  ;   - fold_res: fold value of the reflectance factor in the chosen color, filter and illumination conditions.
  ; -
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ; Filepath containing the 'datastructure.sav' file ;;; CHANGE THIS PATH
  datastruct_path = 'WRITE HERE THE FILEPATH OF THE DATASTRUCTURE.SAV'
  
  ; Check the spelling of the color name
  IF color NE 'y' AND color NE 'b' AND color NE 'g' AND color NE 'r'$
    AND color NE 'k' AND color NE 'dg' AND color NE 'lg' AND color NE 'w' THEN BEGIN
    PRINT, 'Error! Please write the color using the right names!'
    PRINT, 'For yellow, use "y", for blue use "b", for green, use "g",'
    PRINT, 'for red, use "r", for black, use "k", for dark grey use "dg",'
    PRINT, 'for light grey use "lg", for white use "w".'
    RETURN, -1
  ENDIF
  
  ; Create the 18-element arrays containing the 18 filters of Mastcam-Z
  filt_str = ['L0B', 'L0G', 'L0R', 'R0B', 'R0G', 'R0R', 'L6', 'L5', 'L4',$
    'L3', 'L2', 'L1', 'R1', 'R2', 'R3', 'R4', 'R5', 'R6'] ; Names of the filters as strings
  
  IF where(filt_str eq filt_18) eq -1 THEN BEGIN ; Give error if the filter name inserted by the user is not correct
    print, 'Error! Please write the name of the filter using the right expression!'
    print, 'The admitted filter names are: L0B, L0G, L0R, R0B, R0G, R0R, '
    print, 'L6, L5, L4, L3, L2, L1, R1, R2, R3, R4, R5, R6.'
    RETURN, -1
  ENDIF
  
  filt_value = [471, 546, 638, 471, 546, 638, 441, 529, 605, 687, 754,$ ; Central wavelengths of the filters
    801, 801, 866, 910, 940, 979, 1012] 
  filt_band = [46, 42, 43, 45, 42, 43, 12, 11, 9, 11, 10, 9, 10, 10, 12, 13, 10, 18] ; Delta (half width) of each filter
  which_filt = where(filt_str eq filt_18) ; Find the index of the filter chosen by the user
  
  ; restore the file with the spectra of the samples measured in Copenhagen
  restore, datastruct_path+'datastructure.sav'
  ; keep only the 8 witness samples
  data=datalist[where(datalist.aux.flag)]
  data=data[where(data.target.color ne 'Spectralon' and data.target.mount eq 'witness')]
  data=data[0:7]
  
  ; Extend the name of the color to extract the fold value from the Copenhagen lab spectra
  CASE color OF
    'y': crom = 'Yellow'
    'r': crom = 'Red'
    'g': crom = 'Green'
    'b': crom = 'Blue'
    'k': crom = 'Black'
    'dg': crom = 'Darkgray'
    'lg': crom = 'Lightgray'
    'w': crom = 'Aluwhite'
  ENDCASE
 
  ; Extract the right fold value of the lab spectra in the chosen color and filter
  FOR i = 0, n_elements(data)-1 DO BEGIN
    IF data[i].target.color EQ crom THEN BEGIN
      labcph = (data[i].r_star.folded[2,which_filt])
    ENDIF
  ENDFOR
  
  ; Compute the ratio of the refl. factors in the Bern dataset between the input conditions and the lab conditions (i=0, az=90, e=58)
  fold_labimg = ratio_lab2img(color, incidence, azimuth, emission, filt_18)
  
  ; Compute the fold value of the refl. factor in the chosen color, illumination geometry and filter
  fold_res = labcph/fold_labimg
  
  RETURN, fold_res ; return the value
  
END