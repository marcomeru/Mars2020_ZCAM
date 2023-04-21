# Utilities

I wrote the few routines in this folder because I really needed them every now and then, and I didn't find them in any of the large libraries. They are described below.

## One term linear fit

IDL is provided with the function <code>linfit</i> which computes the linear fit between two arrays, but with two terms (one multiplicative and one additive). What if I want to make a fit with only one coefficient? 

Given two arrays of numerical data with the same number of elements (plus, optionally, a third array of the uncertainties on the second array), this routine computes a linear fit between the two arrays with only one multiplicative factor (in the form y = x * A), such that the fit passes by the origin. The routine returns the slope of the fit and its associated uncertainty. 

The two (or three) arrays, x and y, must have the same length and at least 2 elements to make the fit. If the third array (of uncertainties on y) is given, it's used as weight for the fit.

The syntax is:
```
result = oneterm_linfit, x_array, y_array, y_errors
```
where the <code>y_errors</code> parameter can be dropped if not available. The <code>result</code> parameter is an array of two elements, that are the slope of the fit and its uncertainty.

## 
