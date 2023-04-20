function cal_mars2020_struct, file_array
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
; MAKE STRUCTURE WITH THE DATA OF CAL-TARGET OBSERVATIONS FROM RC_FILES
; Marco Merusi, University of Copenhagen, November 2021
; 
; DESCRIPTION
; This function receives a list of rc_file filepaths from which to extract relevant data.
; It opens every single RC file in the array, reads it and stores all the information in a structure array.
; Every element of this array is one structure, related to one RC file and one caltarget image.
; At the end, it returns the structure array. 
; 
; SYNTAX
; result = cal_mars2020_struct(array_of_rc_filepaths)
; 
; INPUT
; - file_array: (array of strings) The array containing a list of complete paths to rc_files.
; 
; OUTPUT
; - result: (array of structures) Array of structures (each structure is related to one rc_file).
; 
; VALUES IN THE STRUCTURE ARRAY:
; - img_name: (string) name of the caltarget image
; - rc_file: (string) name of the RC file 
; - sel_file: (string) name of the selection file
; - sol: (int) sol number
; - time: (double) timestamp
; - dust_correction: (string) dust correction?
; - outliers_ex: (string) outliers excluded from selections?
; - force_fit: (string) force fit to intercept origin?
; - rc_creation_time: (string) time of creation of the RC file
; - rc_version: (string) version of the RC file
; - rc_version_date: (string) date of the current version of RC file
; - eye: (string) camera eye of the image (L or R)
; - camera_id: (int) camera ID of the eye
; - filter: (string) name of the filter
; - filter_wl: (int) central wavelength of the filter
; - filter_band: (int) half bandwidth of the filter
; - filter_num: (int) filter number
; - zoom: (int) zoom in millimeters
; - seq: (string) sequence ID (starts with ZCAM...)
; - unique_seq_id: (string) unique sequence identifier
; - local_time: (string) local Mars time of the image
; - rad2iof_scaling: (double) RAD-to-IOF scaling factor
; - rad2iof_error: (double) uncertainty on the RAD-to-IOF scaling factor
; - fit_method: (string) fit method
; - rover_frame.sun_azi: (float) solar azimuth in the rover frame
; - rover_frame.sun_elev: (float) solar elevation in the rover frame
; - caltarget_angles.incidence: (double, array) solar incidence angle on the caltarget ROI
; - caltarget_angles.emission: (double, array) solar emission angle on the caltarget ROI
; - caltarget_angles.azimuth: (double, array) solar azimuth angle on the caltarget ROI
; - elements.roi_name: (string, array) name of the ROI
; - elements.roi_selected: (integer, array) 1 if the ROI is selected, 0 if not
; - elements.roi_bad: (integer, array) 1 if the ROI is marked bad, 0 if not
; - elements.roi_fit: (integer, array) 1 if the ROI is used for the radiance fit, 0 if not
; - elements.radiance: (double, array) radiance of the ROI
; - elements.radiance_err: (double, array) uncertainty on the radiance of the ROI
; - elements.roi_count: (string, array) number of counts in the ROI
; - elements.reflectance: (double, array) reflectance of the ROI
; - parameters.oneterm_slope: (array, double) slope and uncertainty of the 1-term fit of the primary patch centers
; - parameters.twoterm_parms: (double, array) offset and slope, respectively, of the 2-term fit of the primary patch centers
; 
; Just as a reference, these are the 41 Regions Of Interest (ROIs) in order:
; CHIP CENTERS [0:7] "Blue Chip Center"  "Green Chip Center"  "Yellow Chip Center"  "Red Chip Center"  "Black Chip Center"  "Dark Gray Chip Center"  "Light Gray Chip Center"  "White Chip Center"
; GREYSCALE RINGS [8:11] "Black Ring"  "Dark Gray Ring"  "Light Gray Ring"  "White Ring"  
; RING SHADOWS [12:15] "Black Ring Shadow"  "Dark Gray Ring Shadow"  "Light Gray Ring Shadow"  "White Ring Shadow"  
; SECONDARY HORIZONTAL [16:22] "Black Secondary Horizontal"  "Dark Gray Secondary Horizontal"  "Light Gray Secondary Horizontal"  "White Secondary Horizontal"  "Red Secondary Horizontal"  "Green Secondary Horizontal"  "Blue Secondary Horizontal"  
; SECONDARY VERTICAL [23:29] "Black Secondary Vertical"  "Dark Gray Secondary Vertical"  "Light Gray Secondary Vertical"  "White Secondary Vertical"  "Red Secondary Vertical"  "Green Secondary Vertical"  "Blue Secondary Vertical"  
; CHIP OUTER [30:37] "Blue Chip Outer"  "Green Chip Outer"  "Yellow Chip Outer"  "Red Chip Outer"  "Black Chip Outer"  "Dark Gray Chip Outer"  "Light Gray Chip Outer"  "White Chip Outer"  
; SURFACES [38:40] "Gnomon"  "Gold"  "Deck"
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;; Count the files in the array and raise an error if it's empty
n_files = n_elements(file_array)
if n_files eq 0 then begin
  message, "No rc_files were found! Please change the parameters."
endif
;;;;;
;print, file_array

; Create an empty instance of the structure
cal_single = {img_name: 'Empty', rc_file: 'Empty', sel_file: 'Empty', sol: !VALUES.F_NAN, time: !VALUES.F_NAN, dust_correction:'Empty', outliers_ex: 'Empty', force_fit: 'Empty', rc_creation_time: 'Empty',$
  rc_version: 'Empty', rc_version_date: 'Empty', eye: 'Empty', camera_id: !VALUES.F_NAN, filter: 'Empty', filter_wl: !VALUES.F_NAN, filter_band: !VALUES.F_NAN, $
  filter_num: !VALUES.F_NAN, zoom: !VALUES.F_NAN, seq: 'Empty', unique_seq_id: 'Empty', local_time: 'Empty', rad2iof_scaling: !VALUES.F_NAN, rad2iof_error: !VALUES.F_NAN, fit_method: 'Empty',$
  rover_frame:{sun_azi: !VALUES.F_NAN, sun_elev: !VALUES.F_NAN}, caltarget_angles:{incidence: fltarr(41), emission: fltarr(41), azimuth: fltarr(41)}, $
  elements:{roi_name: strarr(41), roi_selected: fltarr(41), roi_bad: fltarr(41), roi_fit: fltarr(41), radiance: fltarr(41), radiance_err: fltarr(41), roi_count: fltarr(41), reflectance: fltarr(41)},$
  parameters:{oneterm_slope: fltarr(2), twoterm_parms: fltarr(2)}}

; Make the array of structures from the instance
caltarget_db = replicate(cal_single, n_files)
;help, caltarget_db

; Make the arrays with the filter names and wavelengths for later
filt_string = ['L0B', 'L0G', 'L0R', 'R0B', 'R0G', 'R0R', 'L6', 'L5', 'L4', 'L3', 'L2', 'L1', 'R1', 'R2', 'R3', 'R4', 'R5', 'R6']
filt_value = [480, 544, 630, 480, 544, 631, 442, 528, 605, 677, 754, 800, 800, 866, 910, 939, 978, 1022]
filt_band = [46, 41, 43, 46, 42, 43, 12, 11, 9, 11, 10, 9, 9, 10, 12, 12, 10, 19]


; For each file in the list, do all the following to fill the structure:
for j = 0, n_files-1 do begin
  
  ; Select a text file and open for reading
  OPENR, lun, file_array[j], /GET_LUN
  ; Read one line at a time, saving the result into array
  array = ''
  line = ''
  WHILE NOT EOF(lun) DO BEGIN & $
    READF, lun, line & $
    array = [array, line] & $
  ENDWHILE
  ; Close the file and free the file unit
  FREE_LUN, lun
  
  
  ; Search for the data in each line of the file
  for righe=0, n_elements(array)-1 do begin
    
    ; Separate each word of the line as a string array
    riga_arr = strsplit(array[righe], ' ', /EXTRACT)
    
    ; If the line has at least 2 words, check what words these are and behave accordingly
    if n_elements(riga_arr) gt 1 then begin
      
      
      if riga_arr[1] eq 'responsivity' and riga_arr[2] eq 'constants' then begin
        
        ; RC FILENAME
        rc_flnm = strmid(array[righe], 40, 41, /REVERSE_OFFSET)
        caltarget_db[j].rc_file = rc_flnm
        
        ; IMAGE FILTER
        img_filter = strmid(rc_flnm, 4, 3)
        if (strmid(img_filter, 2, 1) eq "_") THEN BEGIN
          img_filter = strmid(img_filter, 0, 2)
        endif
        caltarget_db[j].filter = img_filter
        
        ; FILTER CENTER WAVELENGTH
        wf = where(filt_string eq img_filter)
        filter_wavelength = filt_value[wf]
        caltarget_db[j].filter_wl = filter_wavelength
        
        ; FILTER BAND WAVELENGTH
        filter_bnd = filt_band[wf]
        caltarget_db[j].filter_band = filter_bnd
      endif
      
      if riga_arr[1] eq 'associated' and riga_arr[2] eq 'selection' then begin
        ; SELECTION FILE
        if strmid(array[righe], 40, 1, /REVERSE_OFFSET) eq "Z" then begin
          selec_file = strmid(array[righe], 40, 41, /REVERSE_OFFSET)
          caltarget_db[j].sel_file = selec_file
        endif   
      endif
      
      
      if riga_arr[1] eq 'dust' and riga_arr[2] eq 'correction:' then begin
        ; DUST CORRECTION
        caltarget_db[j].dust_correction = riga_arr[-1]
      endif
      
      
      if riga_arr[1] eq 'outliers' and riga_arr[2] eq 'excluded' then begin
        ; OUTLIERS EXCLUDED FROM SELECTIONS
        caltarget_db[j].outliers_ex = riga_arr[-1]
      endif
      
      
      if riga_arr[1] eq 'force' and riga_arr[2] eq 'fit' then begin
        ; FORCE FIT TO INTERCEPT ORIGIN
        caltarget_db[j].force_fit = riga_arr[-1]
      endif
      
      
      if riga_arr[1] eq 'RC' and riga_arr[2] eq 'file' then begin
        if riga_arr[3] eq 'creation' then begin
          ; RC FILE CREATION TIME
          caltarget_db[j].rc_creation_time = riga_arr[-1]
        endif else begin
          ; RC FILE FORMAT VERSION
          caltarget_db[j].rc_version = riga_arr[5]
          caltarget_db[j].rc_version_date = riga_arr[6]
        endelse
      endif
        
      
      if riga_arr[1] eq 'cal-target' and riga_arr[2] eq 'file:' then begin
        ; IMAGE NAME
        img_nm = strmid(array[righe], 57, 58, /REVERSE_OFFSET)
        caltarget_db[j].img_name = img_nm
        
        ; EYE
        eyee = strmid(img_nm, 1, 1)
        caltarget_db[j].eye = eyee
        
        ; SOL NUMBER
        sol_n = fix(strmid(img_nm, 4, 4))
        caltarget_db[j].sol = sol_n
        
        ; TIMESTAMP
        timest1 = double(strmid(img_nm, 9, 10))
        timest2 = double(strmid(img_nm, 20, 3))
        timestmp = timest1 + timest2 / 1000
        caltarget_db[j].time = timestmp
        
        ; ZOOM IN MILLIMETERS
        zooms = fix(strmid(img_nm, 12, 4, /REVERSE_OFFSET))
        caltarget_db[j].zoom = zooms
        
        ; SEQUENCE CODE
        sequence = strmid(img_nm, 22, 9, /REVERSE_OFFSET)
        caltarget_db[j].seq = sequence
      endif
      
      
      if riga_arr[1] eq 'unique' and riga_arr[2] eq 'sequence' then begin
        ; UNIQUE SEQUENCE IDENTIFIER
        caltarget_db[j].unique_seq_id = riga_arr[-1]
      endif
      
      
      if riga_arr[1] eq 'local' and riga_arr[2] eq 'true' then begin
        ; LOCAL TRUE SOLAR TIME
        caltarget_db[j].local_time = riga_arr[-1]
      endif
      
      
      if riga_arr[1] eq 'solar' and riga_arr[2] eq 'azimuth' then begin
        ; SOLAR AZIMUTH
        sun_a = strsplit(array[righe], ' ', /EXTRACT)
        sun_az = float(sun_a[-1])
        caltarget_db[j].rover_frame.sun_azi = sun_az
      endif
      
      
      if riga_arr[1] eq 'solar' and riga_arr[2] eq 'elevation' then begin
        ; SOLAR ELEVATION
        sun_e = strsplit(array[righe], ' ', /EXTRACT)
        sun_el = float(sun_e[-1])
        caltarget_db[j].rover_frame.sun_elev = sun_el
      endif
      
      
      if riga_arr[1] eq 'fit' and riga_arr[2] eq 'method:' then begin
        ; FIT METHOD
        caltarget_db[j].fit_method = riga_arr[-1]
      endif
      
      
      if riga_arr[1] eq 'ROI' and riga_arr[2] eq 'names:' then begin
        ; ROI NAME
        roi_nm = strsplit(array[righe], '"  "', /REGEX, /EXTRACT)
        roi_nm = roi_nm[0:N_ELEMENTS(roi_nm)-1]
        roi_nm[0] = strmid(roi_nm[0], 15, 16, /REVERSE_OFFSET)
        roi_nm[40] = strmid(roi_nm[40], 0, 4)
        caltarget_db[j].elements.roi_name = roi_nm
      endif
      
      
      if riga_arr[1] eq 'ROI' and riga_arr[2] eq 'is' then begin
        ; ROI IS SELECTED
        roi_sel = strsplit(array[righe], ' ', /EXTRACT)
        roi_sel = roi_sel[4:N_ELEMENTS(roi_sel)-1]
        roi_sel = fix(roi_sel)
        caltarget_db[j].elements.roi_selected = roi_sel
      endif
      
      
      if riga_arr[1] eq 'ROI' and riga_arr[2] eq 'marked' then begin
        ; ROI IS MARKED BAD
        roi_bad = strsplit(array[righe], ' ', /EXTRACT)
        roi_bad = roi_bad[4:N_ELEMENTS(roi_bad)-1]
        roi_bad = fix(roi_bad)
        caltarget_db[j].elements.roi_bad = roi_bad
      endif
      
      
      if riga_arr[1] eq 'ROI' and riga_arr[2] eq 'used' then begin
        ; ROI IS USED IN FIT
        roi_fit = strsplit(array[righe], ' ', /EXTRACT)
        roi_fit = roi_fit[5:N_ELEMENTS(roi_fit)-1]
        roi_fit = fix(roi_fit)
        caltarget_db[j].elements.roi_fit = roi_fit
      endif
      
      
      if riga_arr[1] eq 'ROI' and riga_arr[2] eq 'radiances:' then begin
        ; ROI RADIANCE
        radiance = strsplit(array[righe], ' ', /EXTRACT)
        radiance = radiance[3:N_ELEMENTS(radiance)-1]
        radiance = double(radiance)
        caltarget_db[j].elements.radiance = radiance
      endif
      
      
      if riga_arr[1] eq 'ROI' and riga_arr[2] eq 'uncertainty:' then begin
        ; ROI RADIANCE UNCERTAINTY
        rad_uncert = strsplit(array[righe], ' ', /EXTRACT)
        rad_uncert = rad_uncert[3:N_ELEMENTS(rad_uncert)-1]
        rad_uncert = double(rad_uncert)
        caltarget_db[j].elements.radiance_err = rad_uncert
      endif
      
      
      if riga_arr[1] eq 'ROI' and riga_arr[2] eq 'count:' then begin
        ; ROI COUNT
        r_count = strsplit(array[righe], ' ', /EXTRACT)
        r_count = r_count[3:N_ELEMENTS(r_count)-1]
        r_count = fix(r_count)
        caltarget_db[j].elements.roi_count = r_count
      endif
      
      
      if riga_arr[1] eq 'ROI' and riga_arr[2] eq 'incidence' then begin
        ; ROI INCIDENCE ANGLE
        inc_ang = strsplit(array[righe], ' ', /EXTRACT)
        inc_ang = inc_ang[4:N_ELEMENTS(inc_ang)-1]
        inc_ang = double(inc_ang)
        caltarget_db[j].caltarget_angles.incidence = inc_ang
      endif
      
      
      if riga_arr[1] eq 'ROI' and riga_arr[2] eq 'emission' then begin
        ; ROI EMISSION ANGLE
        emi_ang = strsplit(array[righe], ' ', /EXTRACT)
        emi_ang = emi_ang[4:N_ELEMENTS(emi_ang)-1]
        emi_ang = double(emi_ang)
        caltarget_db[j].caltarget_angles.emission = emi_ang
      endif
      
      
      if riga_arr[1] eq 'ROI' and riga_arr[2] eq 'azimutih' then begin
        ; ROI AZIMUTH ANGLE
        azi_ang = strsplit(array[righe], ' ', /EXTRACT)
        azi_ang = azi_ang[4:N_ELEMENTS(azi_ang)-1]
        azi_ang = double(azi_ang)
        caltarget_db[j].caltarget_angles.azimuth = azi_ang
      endif
      
      
      if riga_arr[1] eq 'reflectances:' then begin
        ; REFLECTANCE
        reflect = strsplit(array[righe], ' ', /EXTRACT)
        reflect = reflect[2:N_ELEMENTS(reflect)-1]
        reflect = double(reflect)
        caltarget_db[j].elements.reflectance = reflect
      endif
      
      
      if riga_arr[0] eq '4007' or riga_arr[0] eq '102801' then begin
        ; CAMERA ID
        cam_id = fix(riga_arr[0])
        caltarget_db[j].camera_id = cam_id
        ; FILTER NUMBER
        filt_num = fix(riga_arr[1])
        caltarget_db[j].filter_num = filt_num
        ; RAD-TO-IOF SCALING FACTOR
        rad2iof = double(riga_arr[2])
        caltarget_db[j].rad2iof_scaling = rad2iof
        ; UNCERTAINTY ON RAD-TO-IOF FACTOR
        rad2iof_err = double(riga_arr[-1])
        if rad2iof_err ne rad2iof then begin
          caltarget_db[j].rad2iof_error = rad2iof_err
        endif
      endif
      
    endif
    
  endfor
  
  ; 1-TERM SLOPE OF THE FIT OF THE PRIMARY CHIP CENTERS
  ix = where(roi_sel[0:7] eq 1 and roi_bad[0:7] eq 0)
  ra = radiance[ix]
  re = reflect[ix]
  rae = rad_uncert[ix]
  slope = oneterm_linfit(re,ra,Y_ERRORS=rae) ; = the linear fit slope with error
  caltarget_db[j].parameters.oneterm_slope = slope
  ; 2-TERM OFFSET AND SLOPE OF THE FIT OF THE PRIMARY CHIP CENTERS
  lifi = linfit(re, ra, MEASURE_ERRORS = rae)
  caltarget_db[j].parameters.twoterm_parms = lifi
  
  
endfor

print, "Creation of the structure array: complete!"

RETURN, caltarget_db


end