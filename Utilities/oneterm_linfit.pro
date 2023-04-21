function oneterm_linfit, x, y, Y_ERRORS = yerr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; COMPUTE THE SLOPE OF 1-TERM LINEAR FIT
; 
; Marco Merusi, University of Copenhagen, November 2021
; 
; DESCRIPTION
; This function receives two arrays of the same length and computes the slope
; of the 1-term linear fit between them (y = A * x). If the 'yerr' array of uncertainties
; on y is provided in input, it is used to weight the computation (as minimization of
; the chi_squared of the fit). The function returns this slope.
; 
; SYNTAX
; result = oneterm_linfit, X, Y [, Y_ERRORS=YERR]
; 
; INPUT
; - x: (array) first array, at least 2 elements.
; - y: (array) second array, at least 2 elements.
; 
; Optional: yerr (array) array containing the uncertainties related to y
; 
; x, y and yerr must have the same length!
; 
; OUTPUT
; - slope: (float) slope of the 1-term linear fit between x and y
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

nx = n_elements(x)
ny = n_elements(y)

; Check if x has at least 2 elements
if nx lt 2 then begin
  print, "Error! Vector x must contain at least 2 elements!"
  return, 0
endif

; Check if y has at least 2 elements
if ny lt 2 then begin
  print, "Error! Vector y must contain at least 2 elements!"
  return, 0
endif

; Check that x and y have the same length
if nx ne ny then begin
  print, "Error! Vectors x and y must have the same number of elements!"
  print, "Length of x = "+trim(string(nx))+", length of y = "+trim(string(ny))
  return, 0
endif

; If yerr is given in input, check that it has the same length as x and y
if keyword_set(yerr) eq 1 then begin
  nye = n_elements(yerr)
  if nye ne nx then begin
    print, "Error! Vector y_error must have the same number of elements as x and y!"
    print, "Length of y_errors = "+trim(string(nye))+", length of x and y = "+trim(string(nx))
    return, 0
  endif
  ; After the check, if it succeded, compute the slope using x, y and yerr by minimizing the chi_squared
  tmp1 = 0
  tmp2 = 0
  tmp3 = 0
  for i=0,nx-1 do begin
    tmp1 = tmp1 + x[i]*y[i]/(yerr[i]^2)
    tmp2 = tmp2 + x[i]^2 / yerr[i]^2
  endfor
  slope = tmp1/tmp2
  for j=0,nx-1 do begin ; and compute the mean error
    tmp3 = tmp3 + (y[j] - x[j]*slope)^2
  endfor
  slerr = sqrt(tmp3/(nx-1)) / sqrt(tmp2)
  return, [ slope , slerr ]
endif else begin ; If yerr was not given, do the same computation but without yerr
  tmp4 = 0
  tmp5 = 0
  tmp6 = 0
  for i=0,nx-1 do begin
    tmp4 = tmp4 + x[i]*y[i]
    tmp5 = tmp5 + x[i]^2
  endfor
  slope = tmp4/tmp5
  for j=0,nx-1 do begin ; and compute the mean error
    tmp6 = tmp6 + (y[j] - x[j]*slope)^2
  endfor
  slerr = sqrt(tmp6/(nx-1)) * sqrt(tmp5) / tmp5
  return, [ slope , slerr ]
endelse ; In both cases, return the slope and error


end