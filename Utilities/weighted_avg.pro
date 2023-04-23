function weighted_avg, x_vec, e_vec
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; COMPUTE THE WEIGHTED AVERAGE OF AN ARRAY
;
; Marco Merusi, University of Copenhagen, November 2021
;
; DESCRIPTION
; Very simple routine that receives an array of data and one of 
; associated uncertainties, and computes the weighted average and weighted error.
; 
; SYNTAX
; result = WEIGHTED_AVG(x_val, x_err)
; 
; INPUT
; - x_val: (array) array of values.
; - x_err: (array) array of associated uncertainties.
; 
; x_val and x_err must have the same length!
; 
; OUTPUT
; - array containing two values: the weighted average and the weighted error.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

nx = n_elements(x_vec)
ny = n_elements(e_vec)

; Check that everything is fine
if nx lt 1 or ny lt 1 then begin
  print, "At least one of the arrays doesn't contain any element!" 
  return, -1
endif
if nx ne ny then begin
  print, "The two arrays have different numbers of elements!"
  return, -1
endif
; If the arrays only contain one element, return that as result
if nx eq 1 and ny eq 1 then begin
  return, [x_vec[0], e_vec[0]]
endif

; Initialize the two parameters for the sums
sum1 = 0
sum2 = 0

for i = 0, nx-1 do begin ; For each element of the arrays:
  
  ; compute the numerator of the average
  sum1 = sum1 + x_vec[i] / e_vec[i]^2
  
  ; compute the denominator of the average and the error
  sum2 = sum2 + 1 / e_vec[i]^2
  
endfor

x_avg = sum1 / sum2 ; weighted average

e_avg = sqrt(1 / sum2) ; weighted uncertainty

return, [x_avg, e_avg] ; return!

end
