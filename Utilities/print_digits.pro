function print_digits, N, k
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
; PRINT A FLOATING-POINT NUMBER WITH A CHOSEN NUMBER OF DECIMAL DIGITS AS STRING
; Marco Merusi, University of Copenhagen, November 2021
; 
; DESCRIPTION
; This function receives a floating-point number N and an integer number k.
; It takes the integer and the decimal part of N separately
; and converts them to string. Then it cuts the decimal part to the k-th digit
; (given in input), after rounding it, and puts together the resulting string,
; which is the initial number with k decimal digits.
; 
; SYNTAX
; result = print_digits(num, dec)
; 
; INPUT
; - N: (float) number to 'cut'
; - k: (positive int) the number of decimal digit that we want to keep
; 
; OUTPUT 
; - result (float) the same initial number but with k decimal digits
; If k is greater than the number of decimal digits of N, the function will
; add 0's in order to reach a number k of decimal digits.
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; The only check is that k is positive
if k lt 1 then begin
  print, "Error! k must be positive!"
  return, 0
endif

if k - fix(k) gt 0 then begin
  print, "Attention, k must be an integer number! I will use only its integer part: k = "+trim(string(fix(k)))
  k = fix(k)
endif


int_part = fix(N) ; Take the integer part of N 

dec_part = N-int_part ; Take the decimal part of N

rounder = fix(strmid(trim(string(dec_part)), 2+k, 1)) ; For the rounding, take the (k+1)-th decimal digit

if rounder lt 5 then begin ; If it's <5, don't round
  ; Just put together the int part and decimal part cut in a string
  result = trim(string(int_part))+'.'+strmid(trim(string(dec_part)), 2, k) 
  return, result
endif else begin ; otherwise, it must round
  
  
  newnum = N + 10^(-1.*k) ; round the k-th decimal digit
  
  round_int = fix(newnum) ; Take the new int part
  
  round_dec = newnum - round_int ; Take the new decimal part
  ; Put them together, cutting the decimal part to the k-th digit
  result = trim(string(round_int)) + '.' + strmid(trim(string(round_dec)), 2, k)
  return, result
endelse

end