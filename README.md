# PTVProcessor
post-processing tools, including main Gaussian Process regression (GPR) function 

# Requirements (and Recommendations)
MATLAB 
Statistics and Machine Learning Toolbox (included in MATLAB 2016+) 
Parallel Processing Toolbox (optional, but recommended)

# Structure

The prepare function takes a raw tiff file and either a .xml file or .csv file from a tracking algorithm (TrackMate or Mosaic) and converts to a format easily readable into GPR function. The format is also useful for exploring with other methods. We call this format "input" and include functions for converting to "vol" which give velocities as pairs of 3D volumes.  (Note that doing so will lose some subpixel resolution in the location of the observed velocities.) This may prove useful for researchers exploring other postprocessing methods.

The hyperparams includes our grid-search based hyperparameter tuning, built on top of MATLAB's fitrgp function, and will output a pair of matrices encoding the computed velocities, as well as a number of parameter options and model standard deviation.

# GUI 

Coming soon!
