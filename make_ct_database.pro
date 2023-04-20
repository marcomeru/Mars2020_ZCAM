function make_ct_database, RC_FP=rc_filepath, SOLS=sol_arr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
; FIND RC_FILES TO MAKE A STRUCTURE OF CALTARGET DATA. 
; Marco Merusi, University of Copenhagen, June 2021
; 
; DESCRIPTION
; This function searches for rc_files in some specified (or not) directories and passes their filepaths to 
; 'cal_mars2020_struct' function. Then, it returns the structure array related to those rc_files.
; (1 structure of the array = 1 rc_file = 1 caltarget image).
; If no parameters are passed, it searches within all the subdirectories of "/scratch/cal_wg/flight/products/".
; If an rc_file path is passed, it searches there; if a list of sols is passed, it searches only within the 
; directories of those sols. 
; 
; SYNTAX
; result = make_ct_database([RC_FP=rc_filepath] [,SOLS=sol_arr])
; 
; INPUT (BOTH OPTIONALS)
; - RC_FP=rc_filepath: (string) The path to a directory in which we want to search for rc_files, 
;   including all its subdirectories except for "manual_sorting" to avoid duplicates.
;   If it's not specified, we use the standard one: "/scratch/cal_wg/flight/products/".
; - SOLS=sol_arr: (array of integers) An array of the sol numbers in which we want to look for rc_files.
; 
; OUTPUT
; - result (array of structures) Array of structures related to all the rc_files found.
; 
; For more info on the all the fields of the structure, read the head of cal_mars2020_struct.pro
; 
; SHORTCUT ON HOW TO USE IT
; If you want to search in all sols of the cal_wg directory, don't pass any parameter.
; If you want to search only in some specific sols of the cal_wg directory, just pass the sol list (as integer array).
; If you want to search somewhere else, pass the rc_filepath. If the directory that you choose contains directories of sols
; written as 4-digit names (like /0035/) you can also pass the sol_arr.
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; Check the rc_filepath:
if keyword_set(rc_filepath) eq 0 then begin ; if it's not specified,
  rc_filepath = "/scratch/cal_wg/flight/products2/" ; set it as the standard /cal_wg/ one.
endif else begin 
  if strmid(rc_filepath, 0, 1, /REVERSE_OFFSET) ne "/" then begin ; If it's specified by the user, take it but
    rc_filepath = rc_filepath+"/" ; add the slash / at the end
  endif  
endelse

; Now that the filepath is ok, let's see the sol numbers.
file_list = [] ; Make an empty list for the filepaths.
inex_paths = []
if keyword_set(sol_arr) eq 0 then begin ; If the user does not pass the sol numbers,
  file_list = file_search(rc_filepath, "rc_*.txt") ; just find all the rc_files in the (sub)directories of the path set before.
endif else begin ; If instead the user passes an array of sols as integer numbers,
  
  n_sols = n_elements(sol_arr) ; count how many they are,
  
  for k = 0, n_sols-1 do begin ; and for each one of them, 
    
    sol_num = sol_arr[k] + 10000 ; add 10000 (easy trick)
    sol_str = string(sol_num)+"/" ; convert it to string and add a / at the end
    sol_str = strmid(sol_str, 4, 5) ; only take the 4-digit number and the final /.
    
    ; Finally, the complete path is rc_filepath + sol_str.
    complete_path = rc_filepath+sol_str
    
    if file_test(complete_path) then begin ; Now, if this filepath exists: 
      filesol = file_search(complete_path, "rc_*.txt", COUNT=cnt) ; search for all rc_files in that path and subdirectories,
      if cnt gt 0 then begin
        file_list = [ file_list , filesol ] ; and store them into the file_list array, that updates at every iteration.
      endif
    endif else begin
      inex_paths = [ inex_paths , complete_path ] ; If the path doesn't exist, store it in an array.
    endelse
    
  endfor

  if n_elements(inex_paths) gt 0 then begin ; If at least one filepath was not found, tell the user.
    print, "A total of "+trim(string(n_elements(inex_paths)))+" paths were not found"
    print, "The following paths were not found:"
    print, inex_paths
  endif
  
endelse

; Now we have the whole file_list!
; Remove all those duplicates in the "manual_sorting" directories
file_list_ok = []
for fl=0,n_elements(file_list)-1 do begin
  if strmid(file_list[fl], 37, 14) ne "manual_sorting" then begin
    file_list_ok = [ file_list_ok , file_list[fl] ]
  endif
endfor

; print, file_list
print, "I found "+trim(string(n_elements(file_list_ok)))+" rc_files from which to extract the data."
print, "Starting the extraction..."

; Call cal_mars2020_struct function to build the structure array
caltarget_db = cal_mars2020_struct(file_list_ok)

; Print a joyful message
print, "This function did its job! Say with me, thank you function!"

;; In the old version of the RC files, some arrays were in a wrong order. So here I change the order in those.
;for db = 0,n_elements(caltarget_db)-1 do begin
;  if caltarget_db[db].rc_version eq "Empty" then begin
;    ord = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,17,20,24,27,30,33,36,18,21,25,28,31,34,37,16,19,22,23,26,29,32,35,38,39,40]
;    caltarget_db[db].elements.radiance = caltarget_db[db].elements.radiance[ord]
;    caltarget_db[db].elements.radiance_err = caltarget_db[db].elements.radiance_err[ord]
;    caltarget_db[db].elements.roi_count = caltarget_db[db].elements.roi_count[ord]
;  endif
;endfor




; Return the structure array
return, caltarget_db

end