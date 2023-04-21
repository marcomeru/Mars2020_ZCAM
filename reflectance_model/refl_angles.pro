;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION refl_angles, color, my_incidence, my_azimuth, my_emission
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; +
; NAME:
;   REFL_ANGLES
;   
; PURPOSE:
;   This routine gets one of the 8 colors of the Cal-targets, an incidence, azimuth and emission angle (the input triplet)
;   and returns the corresponding reflectance factor from the Bern goniometric dataset in 6 different wavelengths.
;   The 6 wavelengths are 450, 550, 650, 750, 905 and 1064 nm. The Bern dataset does not cover all the possible combinations 
;   of the 3 angles but only several samples, so if the routine does not find the input triplet as it is,
;   it interpolates between the combinations that are sampled. 
;   The routine first checks in which of the 9 possible cases we are, and proceeds consequently. It checks if the input triplet 
;   is in the Bern data as it is; otherwise, if at least two angles of the triplet are sampled together in the Bern data;
;   otherwise, at least one angle; otherwise, it interpolates between the closest combinations sampled.
;   The numerical values given in input are checked and rounded to integers. 
; 
; SYNTAX:
;   result = refl_angles("color", incidence, azimuth, emission)
; 
; INPUT:
;   - color: a string denoting one of the 8 colors of the Cal-targets. Yellow='y', red='r', green='g', blue='b',
;            black='k', dark grey='dg', light grey='lg', white='w'.
;   - my_incidence: incidence angle in degrees, a value from 0 to 90.
;   - my_azimuth: azimuth angle in degrees, a value from 0 to 360. Thanks to the hemispherical symmetry, if this variable is >180, 
;                 its refl. factor is computed at azimuth 360-my_azimuth.
;   - my_emission: emission angle in degrees, a value from 0 to 90. The angle at which MCZ sees the Cal-targets is 58deg.
;   
; OUTPUT
;   - result: a 6-element array containing the values of the reflectance factor in 6 wavelengths (450, 550, 650, 750, 905, 1064)nm.
; 
; -
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;; MODIFY THIS VARIABLE ;;;;;;;;;;;;;;;;;;;;;;;;
bern_path = 'WRITE HERE THE PATH OF THE BERN DATA' ; the path of the folder containing the Bern data files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Check the spelling of the color name
IF color NE 'y' AND color NE 'b' AND color NE 'g' AND color NE 'r'$
  AND color NE 'k' AND color NE 'dg' AND color NE 'lg' AND color NE 'w' THEN BEGIN
    PRINT, 'Error! Please write the color using the right names!'
    PRINT, 'For yellow, use "y", for blue use "b", for green, use "g",'
    PRINT, 'for red, use "r", for black, use "k", for dark grey use "dg",'
    PRINT, 'for light grey use "lg", for white use "w".'
    RETURN, -1
ENDIF
; Check the value of the incidence angle
IF my_incidence LT 0 OR my_incidence GT 90 THEN BEGIN
  PRINT, 'Error! The incidence must be a value from 0 to 90 degrees'
  RETURN, -1
ENDIF
; Check the value of the azimuth angle
IF my_azimuth LT 0 OR my_azimuth GT 360 THEN BEGIN
  PRINT, 'Error! The azimuth must be a value from 0 to 360 degrees'
  RETURN, -1
ENDIF
; Check the value of the emission angle
IF my_emission LT 0 OR my_emission GT 90 THEN BEGIN
  PRINT, 'Error! The emission must be a value from 0 to 90 degrees'
  RETURN, -1
ENDIF

; Extract the Bern dataset related to the color chosen by the user
CASE color OF
  'y': readcol, bern_path+'20200303_mastcamz_yellow.csv', skipline=1, c, inc, emi, azi, pha, refl, sdev, err, q, abt, relt, filt, fwhm, temp, airt, airh, format='D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D'
  'b': readcol, bern_path+'20200304_mastcamz_blue.csv', skipline=1, c, inc, emi, azi, pha, refl, sdev, err, q, abt, relt, filt, fwhm, temp, airt, airh, format='D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D'
  'g': readcol, bern_path+'20200305_mastcamz_green.csv', skipline=1, c, inc, emi, azi, pha, refl, sdev, err, q, abt, relt, filt, fwhm, temp, airt, airh, format='D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D'
  'r': readcol, bern_path+'20200306_mastcamz_red.csv', skipline=1, c, inc, emi, azi, pha, refl, sdev, err, q, abt, relt, filt, fwhm, temp, airt, airh, format='D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D'
  'k': readcol, bern_path+'20200309_mastcamz_black.csv', skipline=1, c, inc, emi, azi, pha, refl, sdev, err, q, abt, relt, filt, fwhm, temp, airt, airh, format='D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D'
  'dg': readcol, bern_path+'20200310_mastcamz_dark-grey.csv', skipline=1, c, inc, emi, azi, pha, refl, sdev, err, q, abt, relt, filt, fwhm, temp, airt, airh, format='D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D'
  'lg': readcol, bern_path+'20200311_mastcamz_light-grey.csv', skipline=1, c, inc, emi, azi, pha, refl, sdev, err, q, abt, relt, filt, fwhm, temp, airt, airh, format='D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D'
  'w': readcol, bern_path+'20200316_mastcamz_aluwhite.csv', skipline=1, c, inc, emi, azi, pha, refl, sdev, err, q, abt, relt, filt, fwhm, temp, airt, airh, format='D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D'
ENDCASE

result = fltarr(6) ; This will contain the 6-element result array
IF my_azimuth GT 180 THEN my_azimuth = 360 - my_azimuth ; There is hemispherical symmetry of azimuth, so we only deal with azimuth <= 180deg

all_filters = [ 450 , 550 , 650 , 750 , 905 , 1064 ] ; The 6 wavelength filters
inc_samp = [ 0 , 15 , 30 , 45 , 58 , 70 ] ; The 6 values of the incidence angle sampled in the Bern dataset

; I round the three angles to the closest integer, and swap incidence and emission thanks to the reciprocity law
new_emission = round(my_incidence) 
new_incidence = round(my_emission)
new_azimuth = round(my_azimuth)

ind = 0 ; Index to store the results in the array
prin_comb = 0 ; Do we want the program to PRINT the number of the combination used for each cycle? 1=yes, 0=no
FOREACH wl, all_filters DO BEGIN ; For each of the 6 filters
  fil = where(filt EQ wl) ; create arrays of the angles and refl. factors related to that filter
  incc = inc[fil]
  emii = emi[fil]
  azii = azi[fil]
  refll = refl[fil]
  
  ; Remove all the combinations of azimuth=0, incidence=58 and emission between 55 and 60 because there 
  ; the refl. factor has a weird behaviour (the light is right behind the detector, so the target is in shadow.
  rem = where(incc EQ 58 AND azii EQ 0 AND (emii EQ 55 OR emii EQ 60))
  REMOVE, rem, incc, emii, azii, refll
  
  ; I count the occurrences of combinations of input angles into the Bern data
  test = where(azii EQ new_azimuth AND incc EQ new_incidence AND emii EQ new_emission, count1) ; 1
  test = where(incc EQ new_incidence AND emii EQ new_emission, count2) ; 2
  test = where(azii EQ new_azimuth AND incc EQ new_incidence, count3) ; 3
  test = where(azii EQ new_azimuth AND emii EQ new_emission, count4) ; 4
  test = where(azii EQ new_azimuth, count5) ; 5
  test = where(incc EQ new_incidence, count6) ; 6
  test = where(emii EQ new_emission, count7) ; 7
    
  ; Using a rigorous logical order, for each case I check if countN is greater than 0 and choose the right method.
  IF count1 GT 0 THEN check = 1 ELSE $ ; 1
  IF count2 GT 0 THEN check = 2 ELSE $ ; 2
  IF count3 GT 0 THEN check = 3 ELSE $ ; 3
  IF count4 GT 0 THEN check = 4 ELSE $ ; 4
  IF count5 GT 0 THEN check = 5 ELSE $ ; 5
  IF count6 GT 0 THEN check = 6 ELSE $ ; 6
  IF count7 GT 0 THEN check = 7 ELSE $ ; 7
  ; If none of the angles are in the Bern data, use a different approach, but separating if i<70 or i>70 (if i>70 I have to extrapolate).
  IF new_incidence LT 70 THEN check = 8 ELSE check = 9 
  
  ; According to the input parameters and their occurrence in the Bern data, compute the refl. factor.
  CASE check OF
    1: BEGIN ;;;;;;;;;; 1 (All the three angles)
      k = where(azii EQ new_azimuth AND incc EQ new_incidence AND emii EQ new_emission) 
      result[ind] = refll[k]
      IF prin_comb EQ 1 THEN PRINT, 1
      END
    2: BEGIN ;;;;;;;;;; 2 (Only incidence and emission)
      j = where(incc EQ new_incidence AND emii EQ new_emission) 
      azi_alfa = azii[j]
      refl_alfa = refll[j]
      azim_refl = interpol(refl_alfa[sort(azi_alfa)], azi_alfa[sort(azi_alfa)], indgen(181), /quadratic)
      result[ind] = azim_refl[new_azimuth]
      IF prin_comb EQ 1 THEN PRINT, 2
      END
    3: BEGIN ;;;;;;;;;; 3 (Only incidence and azimuth)
      j = where(incc EQ new_incidence AND azii EQ new_azimuth) 
      emi_beta = emii[j]
      refl_beta = refll[j]
      emis_refl = interpol(refl_beta[sort(emi_beta)], emi_beta[sort(emi_beta)], indgen(91), /quadratic)
      result[ind] = emis_refl[new_emission]
      IF prin_comb EQ 1 THEN PRINT, 3
      END
    4: BEGIN ;;;;;;;;;; 4 (Only azimuth and emission)
      j = where(emii EQ new_emission AND azii EQ new_azimuth) 
      inci_theta = incc[j]
      refl_theta = refll[j]
      inci_refl = interpol(refl_theta[sort(inci_theta)], inci_theta[sort(inci_theta)], indgen(91), /quadratic)
      result[ind] = inci_refl[new_incidence]
      IF prin_comb EQ 1 THEN PRINT, 4
      END
    5: BEGIN ;;;;;;;;;; 5 (Only the azimuth)
      n = 0
      i = where(azii EQ new_azimuth) 
      inc_iota = incc[i]
      emi_iota = emii[i]
      refl_iota = refll[i]
      inc_ord = inc_iota[uniq(inc_iota, sort(inc_iota))]
      matri = fltarr(n_elements(inc_ord),91)
      FOREACH ii, inc_ord DO BEGIN ; For each incidence, interpolate over the emissions
        jj = where(inc_iota EQ ii)
        emi_psi = emi_iota[jj]
        refl_psi = refl_iota[jj]
        matri[n,*] = interpol(refl_psi[sort(emi_psi)], emi_psi[sort(emi_psi)], indgen(91), /quadratic)
        n = n+1
      ENDFOREACH
      incix = interpol(matri[*,new_emission], inc_ord, indgen(91), /quadratic) ; Interpolate over the incidences 
      result[ind] = incix[new_incidence]
      IF prin_comb EQ 1 THEN PRINT, 5
      END
    6: BEGIN ;;;;;;;;;; 6 (Only the incidence)
      en = 0
      g = where(incc EQ new_incidence) 
      azi_gamma = azii[g]
      emi_gamma = emii[g]
      refl_gamma = refll[g]
      azi_ord = azi_gamma[uniq(azi_gamma, sort(azi_gamma))]
      cupola = fltarr(n_elements(azi_ord),91)
      FOREACH aa, azi_ord DO BEGIN
        ff = where(azi_gamma EQ aa); For each azimuth, interpolate over the emissions
        emi_ni = emi_gamma[ff]
        refl_ni = refl_gamma[ff]
        cupola[en,*] = interpol(refl_ni[sort(emi_ni)], emi_ni[sort(emi_ni)], indgen(91), /quadratic)
        en = en + 1
      ENDFOREACH
      azimuxx = interpol(cupola[*,new_emission], azi_ord, indgen(181), /quadratic) ; For my emission, interpolate over the azimuths
      result[ind] = azimuxx[new_azimuth]
      IF prin_comb EQ 1 THEN PRINT, 6
      END
    7: BEGIN ;;;;;;;;;; 7 (Only the emission)
      enn = 0
      m = where(emii EQ new_emission) 
      inc_mu = incc[m]
      azi_mu = azii[m]
      refl_mu = refll[m]
      azi_ord = azi_mu[uniq(azi_mu, sort(azi_mu))]
      cupola = fltarr(n_elements(azi_ord),91)
      FOREACH aa, azi_ord DO BEGIN ; For each azimuth, interpolate over the incidences
        hh = where(azi_mu EQ aa)
        inc_sigma = inc_mu[hh]
        refl_sigma = refl_mu[hh]        
        cupola[enn,*] = interpol(refl_sigma[sort(inc_sigma)], inc_sigma[sort(inc_sigma)], indgen(91), /quadratic)
        enn = enn + 1
      ENDFOREACH
      azimuyy = interpol(cupola[*,new_incidence], azi_ord, indgen(181), /quadratic) ; For my incidence, interpolate over the azimuths
      result[ind] = azimuyy[new_azimuth]
      IF prin_comb EQ 1 THEN PRINT, 7
      END
    8: BEGIN ;;;;;;;;;; 8 (None of the three angles, but incidence is less than 70deg)       
      FOR pp = 0, n_elements(inc_samp)-2 DO BEGIN  
        IF new_incidence GT inc_samp[pp] AND new_incidence LT inc_samp[pp+1] THEN BEGIN          
          inc_min = inc_samp[pp] ; Find the two values of the incidence (from the Bern data) closest to my input incidence
          inc_max = inc_samp[pp+1]         
        ENDIF        
      ENDFOR
      ;;;;;;; Find the refl. factor using the lower boundary of the interval, that is in the Bern data
      ab = 0
      om = where(incc EQ inc_min)
      azi_omega = azii[om]
      emi_omega = emii[om]
      refl_omega = refll[om]
      azi_ord1 = azi_omega[uniq(azi_omega, sort(azi_omega))]
      cupola1 = fltarr(n_elements(azi_ord1),91)
      FOREACH aa1, azi_ord1 DO BEGIN
        dd = where(azi_omega EQ aa1)
        emi_delta = emi_omega[dd]
        refl_delta = refl_omega[dd]
        cupola1[ab,*] = interpol(refl_delta[sort(emi_delta)], emi_delta[sort(emi_delta)], indgen(91), /quadratic) ; Same procedure as for case #6
        ab = ab + 1
      ENDFOREACH
      azimuxy = interpol(cupola1[*,new_emission], azi_ord1, indgen(181), /quadratic)
      refl_min = azimuxy[new_azimuth]
      ;;;;;;; Find the refl. factor using the higher boundary of the interval, that is in the Bern data
      ba = 0
      ta = where(incc EQ inc_max)
      azi_tau = azii[ta]
      emi_tau = emii[ta]
      refl_tau = refll[ta]
      azi_ord2 = azi_tau[uniq(azi_tau, sort(azi_tau))]
      cupola2 = fltarr(n_elements(azi_ord2),91)
      FOREACH aa2, azi_ord2 DO BEGIN
        ss = where(azi_tau EQ aa2)
        emi_zeta = emi_tau[ss]
        refl_zeta = refl_tau[ss]
        cupola2[ba,*] = interpol(refl_zeta[sort(emi_zeta)], emi_zeta[sort(emi_zeta)], indgen(91), /quadratic) ; Same procedure as for case #6
        ba = ba + 1
      ENDFOREACH
      azimuyx = interpol(cupola2[*,new_emission], azi_ord2, indgen(181), /quadratic)
      refl_max = azimuyx[new_azimuth]
      ;;
      bridge = interpol([refl_min, refl_max], [inc_min, inc_max], indgen(inc_max-inc_min+1, start=inc_min)) ; Interpolate over the interval
      result[ind] = bridge[where(bridge EQ my_incidence)] ; Find the refl. factor of my incidence in the interval
      IF prin_comb EQ 1 THEN PRINT, 8
      END
    9: BEGIN ;;;;;;;;;; 9 (Same as #8, but here the incidence is greater than 70deg)
      base = fltarr(3)
      ip = 0
      FOR ac = 3, 5 DO BEGIN ; If inc>70deg, I have to extrapolate, so I need to interpolate over inc=45, 58 and 70
        ad = 0
        al = where(incc EQ inc_samp[ac])
        azi_eps = azii[al]
        emi_eps = emii[al]
        refl_eps = refll[al]
        azi_ord = azi_eps[uniq(azi_eps, sort(azi_eps))]
        cupola = fltarr(n_elements(azi_ord),91)
        FOREACH aa, azi_ord DO BEGIN
          ww = where(azi_eps EQ aa)
          emi_lambda = emi_eps[ww]
          refl_lambda = refl_eps[ww]
          cupola[ad,*] = interpol(refl_lambda[sort(emi_lambda)], emi_lambda[sort(emi_lambda)], indgen(91), /quadratic) ; Same interpolation procedure as in #6
          ad = ad + 1
        ENDFOREACH
        azimuxxx = interpol(cupola[*,new_emission], azi_ord, indgen(181), /quadratic)
        base[ip] = azimuxxx[new_azimuth] ; Stack the three values of the refl. factor in an array
        ip = ip + 1
      ENDFOR
      short = interpol(base, [45, 58, 70], indgen(46, start=45), /quadratic) ; Interpolate the incidence from 45 to 90deg
      result[ind] = short[where(short EQ my_incidence)] ; Find my value of the incidence from the interval
      IF prin_comb EQ 1 THEN PRINT, 9
      END    
  ENDCASE

ind = ind+1 ; update the index of the result vector
ENDFOREACH

RETURN, result ; If the program succeeded, return the 6 values
END