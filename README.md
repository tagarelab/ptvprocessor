# PTVProcessor
post-processing tools, including main Gaussian Process regression (GPR) function 

# Requirements (and Recommendations)
MATLAB 
Statistics and Machine Learning Toolbox (included in MATLAB 2016+) 
Parallel Processing Toolbox (optional, but recommended)

# Functions and structure

The prepare function takes a raw tiff file and either a .xml file or .csv file from a tracking algorithm (TrackMate or Mosaic) and converts to a format easily readable into GPR function. The format is also useful for exploring with other methods. We call this format "input" and include functions for converting to "vol" which give velocities as pairs of 3D volumes.  (Note that doing so will lose some subpixel resolution in the location of the observed velocities.) This may prove useful for researchers exploring other postprocessing methods.

The hyperparams includes our grid-search based hyperparameter tuning, built on top of MATLAB's fitrgp function, and will output a pair of matrices encoding the computed velocities, as well as a number of parameter options and model standard deviation.

# Data

The data includes every file we used except for the raw tiff file and segmentation data files. Both types are too large for Github, but either the first or last author would be more than happy to provide the dataset. The segmentation files in particular are easy to produce on your own and do not significantly affect the results.

# GUI 

Coming soon!
