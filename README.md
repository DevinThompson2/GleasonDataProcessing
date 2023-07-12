# GleasonDataProcessing
Repo for the scripts that are used to process the Gleason ALS Project EMG and other data

## Data to Process
* EMG
EMG data is stored in .xlsx files as time series data. For each participantn the MVC needs to be found for each muscle. Then, each trial needs to be normalized to the MVC (Isometric strength normal, isometric strength collar, isometric strength flexed). Also, we want to look at co-contraction and relationship between the level of contraction and the force output.
* Imaging
Imaging data is stored as .jpg files. There are calibration files and trials. The calibration files are used to generate the camera intrinsics, which can then be used to tranlate the camera coordinate system into a global coordinate system to calculate the locations of the markers. The marker locations will then be used to calculate other variables.
* Dynamometry
Force data is stored in .xlsx files. This data will be used with the marker location data to calculate other variables as well. 
* Anthropometric
Anthropometric data are also stored in .xlsx files. This data is used to calculate descriptive sample statistics up the control and PALS groups
* Survey
The survey data is stored in the .xlsx files as well. This is a combination of qualitative and quantitative data. We may be able to relate this data to force production and muscle activation
