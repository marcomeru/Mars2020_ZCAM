# Utilities

I wrote the few routines in this folder because I really needed them every now and then, and I didn't find them in any of the large libraries. They are described below.

## One term linear fit (<i>oneterm_linfit.pro</i>)

IDL is provided with the function <code>linfit</code> which computes the linear fit between two arrays, but with two terms (one multiplicative and one additive). What if I want to make a fit with only one coefficient? 

Given two arrays of numerical data with the same number of elements (plus, optionally, a third array of the uncertainties on the second array), this routine computes a linear fit between the two arrays with only one multiplicative factor (in the form y = x * A), such that the fit passes by the origin. The routine returns the slope of the fit and its associated uncertainty. 

The two (or three) arrays, x and y, must have the same length and at least 2 elements to make the fit. If the third array (of uncertainties on y) is given, it's used as weight for the fit.

The syntax is:
```
result = oneterm_linfit(x_array, y_array, Y_ERRORS= y_err)
```
For example:
```
x_array = [ 0.1986, 0.2124, 0.8113, 0.7896, 0.0838 ]
y_array = [ 0.0319, 0.0364, 0.0912, 0.0912, 0.0220 ]
y_err = [ 0.0010, 0.0009, 0.0018, 0.0016, 0.0009 ]
print, oneterm_linfit(x_array, y_array, Y_ERRORS = y_err)
```
will yield:
```
0.125563  1.43248e-05
```
The output is an array of two elements, that are the slope of the fit and its uncertainty, respectively. The parameter <code>Y_ERRORS</code> can be dropped if not available.


## Weighted average (<i>weighted_avg.pro</i>)

Given one array of numerical values and a similar one containing the associated uncertainties, this routine computes the weighted average and its uncertainty. Both arrays must have at least one element and must have the same length.<br>
The syntax is:
```
print, weighted_avg(x_val, x_err)
```
For example:
```
x_val = [ 0.1986, 0.2124, 0.8113, 0.7896, 0.0838 ]
x_err = [ 0.0010, 0.0009, 0.0018, 0.0016, 0.0009 ]
print, weighted_avg(x_val, x_err)
```
will yield:
```
0.269436  0.000489796
```
The output is an array of two elements, that are the weighted average and its weighted uncertainty, respectively. 


## Print decimal digits (<i>print_digits.pro</i>)

This simple routine receives one floating-point number N and one integer k, and rounds N to the k-th decimal digit. For example, if N has 10 decimal digits and k=6, the result will have 6 decimal digits.<br>
For example:
```
N = 3.1928674605
k = 4
print, print_digits(N, k)
```
will yield:
```
3.1929
```
