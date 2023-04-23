# Reflectance model

As illustrated in Merusi et al. (2022), the reflectance calibration of Mastcam-Z is made by extracting the radiance of 8 small regions in the images of the calibration targets in every filter, and making the linear fit between these 8 radiances and the reference reflectance of the same 8 regions under the same illumination geometry as the calibration target observation. The 8 regions are color and grayscale patches (blue, green, yellow, red, white, light gray, dark gray, black), while the illumination geometry is defined by 3 angles (incidence, emission, azimuth). The reference reflectances were measured in laboratory in Bern and Copenhagen. Those from Bern are organized in 8 csv files, one for each color and grayscale material, where the reflectances are listed at some combinations of incidence, emission and azimuth angles and wavelengths. The reflectances from Copenhagen are stored in an IDL save file for the whole spectrum (400-1050nm) but for one fixed value of incidence, emission and azimuth angles.

Therefore, the final aim of the model is to compute the value of reflectance for any color and grayscale material at any possible wavelength under any illumination geometry. This is done in the 3 routines in this folder, which process together the data from Bern and Copenhagen and make large use of interpolation to retrieve the values of reflectance that are were not sampled in the laboratory measurements. The 3 routines, properly modified, were implemented in the Mastcam-Z calibration pipeline.

The routines make use of the 8 csv files from Bern, the save file from Copenhagen, and an additional file containing the reflectance spectrum of Spectralon, a reference material. These files are not provided here.

## How it works

Basically, the 3 routines could be merged in one (they are nested functions), but when they were written they were also used separately for other possible targets.<br>
<i>refl_fac_filter.pro</i> is the high-level routine, which calls <i>ratio_lab2img.pro</i>, which in turn calls <i>refl_angles.pro</i>. More information on the aim of the single routines is given in the preamble of each file.

The reflectance model is activated by running <code>refl_fac_filter.pro</code>, which receives 5 parameters: a string denoting the chosen color or grayscale material, an incidence angle, an emission angle and an azimuth angle, and the name of one of the 18 filters of Mastcam-Z. 

For example, let's suppose we want to compute the reference reflectance corresponding to the green material illuminated under incidence = 18°, azimuth = 134° and emission = 58° in the filter R1 (800 nm). The syntax is:

```
print, refl_fac_filter("g", 18, 134, 58, "R1")
```
which will yield:
```
0.26627811
```

We can also compute the sampled reflectance spectrum of the green material under the same illumination geometry as above. It's done by iterating it over all the filters of Mastcam-Z:
```
filters = [ "L6", "L5", "L4", "L3", "L2", "L1", "R1", "R2", "R3", "R4", "R5", "R6" ]
foreach f, filters do print, refl_fac_filter("g", 18, 134, 58, f)
```
which yields:
```
0.22019831
0.40171133
0.22300054
0.22114554
0.27922450
0.26633506
0.26627811
0.36291124
0.55440525
0.70108114
0.77102798
0.75846178
```
Just to give a visual example, we can plot these values against their corresponding wavelengths:
```
filters = [ "L6", "L5", "L4", "L3", "L2", "L1", "R1", "R2", "R3", "R4", "R5", "R6" ]
wavelength = [441, 529, 605, 687, 754, 801, 801, 866, 910, 940, 979, 1012] ; in nanometers
refl = [] ; this array will contain the resulting reference reflectances
foreach f, filters do refl = [ refl, refl_fac_filter("g", 18, 134, 58, f) ]
plot, wavelength, refl, psym = 5, yrange = [0,1], xtitle = "Wavelength [nm]", ytitle = "Reflectance factor"
```
The result is shown below.
<img width="723" alt="Screenshot 2023-04-23 at 17 44 37" src="https://user-images.githubusercontent.com/74593667/233849873-682b2a14-c940-40a4-84e4-4fa15cbf9b69.png">

