REQUIREMENTS
Matlab Machine Learning Toolbox

Matlab 2018/2017/2016

TrackMateCSVImporter: You must have this plug-in installed (may require restarting Fiji/ImageJ) to use TrackMate tracks. You should be able to find a function importTrackMateTracks in ...\fiji-win64\fiji.app\scripts folder if it is installed correctly. Make sure that this folder is added to the path in Matlab, or move this function to the folder you are using

INSTRUCTIONS:
1) Open Matlab. Make sure working path contains all PTVProcessor files
2) Type 'PTVProcessor' to load GUI
3) Input tiff/tif filename and tracks filename. 
3a) Change partition size 
3b) Draw segmentation 
4) Click process tracks or process express
5) Either will prompt a segmentation - can draw new or use pre-existing
6) Process tracks will begin right after and take about 5-10 minutes
7) Process Express will prompt parameter inputs and take 1-5 minutes
8) Visualize vectorfield or colormaps to load figures

RECOMMENDED PARAMETERS
For fast, dense flows with narrow passageways, like the brain: 
Recommended: 
Subset of data approximation method (for speed)
Partition size 33 typical, 17 minimum (or  33>n>17 typical, 17 minimum)
No outlier detection

For slow, sparse flows (like early-stage Xenopus embryonic flow)
Recommended:
Exact or subset of regressors 
Partiton size 33 typical, 33 minimum
Outlier detection

For medium/fast, dense flows with wide fields (like late-stage Xenopus embryonic flow)
Recommended:
Exact or subset of regressors
Partition size 33 typical, 33 minimum
Outlier detection

COMMON ERRORS:
- filenames should include the extension. Both .tif and .tiff files are allowed, and so should be specified in the input. "flow14.tiff" and "flow1.tif" are likely to be OK, "flow14" is likely to be wrong. 
- if using Mosaic, the function import_Trajectories may be acting up. We are working on a permanent fix. 
- tiff file must be in 8-bit, not RGB. This is highly deceptive. 
- tiff must be interpreted in pixels, not cm. On fiji, go to analyze -> set scale.. and click "remove scale"
- the tiff reader may have trouble with files that are not directly in the folder - try moving data into current directory
- or try '~/filename.tiff'
- Mosaic: after obtaining results, click on "All Trajectoreis to Table" 
Make sure the table that pops is as follows: a column with just numbers in sequence, no column name, a column of "Trajectory", a column for "Frame", a column for "x", and a column for "y". Note that the file will be a .csv file, not a .xml file
