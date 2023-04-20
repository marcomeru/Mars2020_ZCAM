# Mars2020 ZCAM Repository

Welcome!

This repository contains all the routines that I developed for the handling of data from the calibration targets of Mastcam-Z (or ZCAM), the multispectral camera on the NASA Perseverance Mars rover. 
For a better understanding of the nomenclature and how the reflectance calibration of Mastcam-Z works, the user should rely on the articles by Merusi et al. (2022), DOI: 10.1029/2022EA002552, and by Kinch et al. (2020), DOI: 10.1007/s11214-021-00828-5.

The files are basically organized in this way:
- <i>reflectance_model</i>: this directory contains the codes that are used upon calibration to extract the reference values of reflectance at any wavelength and under any illumination geometry. In the calibration pipeline of ZCAM, these values are plotted against the corresponding observed radiances, from which the radiometric coefficients are computed.
- <i>database_creation</i>: this directory contains two routines that search for the Radiometric Coefficient files (RC files) recursively, open them one by one, and store all their data in a structure, so that the data are easily accessible.
- <i>RC_data_analysis</i>: this directory contains several codes used to extract a lot of different results and make plots using the data from the RC file database structure.
