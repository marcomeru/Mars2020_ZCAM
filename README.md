# Mars2020 ZCAM Repository

Welcome!

This repository contains all the routines that I developed for the handling of data from the calibration targets of Mastcam-Z (or ZCAM), the multispectral camera on the NASA Perseverance Mars rover.<br>
For a better understanding of the nomenclature and how the reflectance calibration of Mastcam-Z works, the user should rely on the articles by Merusi et al. (2022), DOI: <a href="https://doi.org/10.1029/2022EA002552">10.1029/2022EA002552</a>, and by Kinch et al. (2020), DOI: <a href="https://doi.org/10.1007/s11214-021-00828-5">10.1007/s11214-021-00828-5</a>.

The files are basically organized in this way:
- <i>reflectance_model</i>: this directory contains the codes that are used upon calibration to extract the reference values of reflectance at any wavelength and under any illumination geometry. In the calibration pipeline of ZCAM, these values are plotted against the corresponding observed radiances, from which the radiometric coefficients are computed.
- <i>database_creation</i>: this directory contains two routines that search for the Radiometric Coefficient files (RC files) recursively, open them one by one, and store all their data in a structure, so that the data are easily accessible.
- <i>RC_data_analysis</i>: this directory contains several codes used to extract a lot of different results and make plots using the data from the RC file database structure.

<b>NB</b>: All the codes are written in IDL (Interactive Data Language), a programming language used mainly in astronomy.<br>
<b>NB2</b>: This repository only hosts the code files used to handle and extract the data, but not the data files. More information is given in the readme files in each directory.
