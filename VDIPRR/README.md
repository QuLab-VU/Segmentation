VDIPRR segmentation code for batch processing plates read at the HTC.
Note this code assumes 2 channel images were taken such that the nucleus
preceeds the other stain such that nucleus and other stain alternate order.


VDIPRR GUI structure:

VDIPRR_V1 is called from the command line.  This is imperative or some variables will not be 
initialized 

This opens a GUI for testing the segmentation parameters

First is the experimental directory

This can either be a single plate or a folder with a series of plates.  

If a folder with a series of plates check the Batch check box.

Select a single plate to test the segmentation parameters on within this folder

Give the image extension including the "."

Nuclear segmentation level is the number of levels for Otsu's thresholding

Select Background Correction Method from the following
None
CIDRE Correction
Rolling Ball Filter
Constant Thresholding
Image Subtraction


CIDRE Correction will ask for a previously defined map.  A folder with previous
CIDRE maps is located in the folder "CIDRE correction maps"
To generate a new CIDRE map use the imageJ plug in from the supplement here
http://www.nature.com/nmeth/journal/v12/n5/full/nmeth.3323.html#supplementary-information
Do not correct the images, just generate a correction map.  The same correction
is applied to all plates and images

Rolling Ball Filter is used to estimate background on a per image basis.

Contant Threshold subtracts a constant amount from the image

Image Subtraction asks for a correction image which will be used to subtract background

Segmentation Smoothing Factor is used to dilate the segmented objects to result in more consistent sizes across the segmented objects.  This number is typically <=5 and often can be as low as 1

Nuclear noise filter convolves the image with a structured element disk to remove any remaining debris smaller than the disk

Split Nuclei is a parameter used by the watershed segmentation step.  Lower numbers result
in more split nuclei.  

Next the Test Segment button displays the result of the parameters on the first image.
Next image moves between images

Increase/Decrease contrast does not adjust the underlying image, only how it 
is displayed.

Export Image saves a .png file of the tested segmentation parameters in the experimental directory.

Check the Parallel segmentation box to use multiple processors in segmentation.

Segment then runs the Segmentation code for all files


Code Structure:
Once the segment button is pressed, VDIPRR code calls one of 2 functions depending on whether 
parallel processing was selected.  This happens at line 112 in VDIPRR_V1 code
All functions are found in the GUI_Functions folder which
is automatically added to your path when running VDIPRR from the command line.
These functions are MultiChSegmenter_Parallel_VDIPRR.m and MultiChSegmenterNoParallel_VDIPRR.m 
respectively.

These set up the parfor (for multithreading) and for loops respectively and call the 
initialization function InitializeHandles_VDIPRR.m which reads the segmentation parameters
selected in each widget into the structure handles which contains all the handles to the GUI
widgets.  This structure is then passed to NaiveSegment_VDIPRR_v1.m which runs the actual 
segmentation.
The segmentation stores the information in a sturctured array comprised of 3 types.
There is the image data such as how many cells were in the image, the image background, and the like
There is the cell data which are the parameters both shape and intensity based that describe each
cell
And finaly there is the final segmented image.
These are stored in the structures
CO.ImData
CO.CData
CO.Nuc_label  respectively.

This structure is written to a file called Segmented which is created in each experiment.
At the end of the plate, the code runs
ExportSegmentation_VDIPRR which reads each file and compiles the results into 3 tables
The first are the segmentation settings
The second are the cell events with feature set
The third are image statistics.
Note! If no cells were found in an image, there is a row of nan in the cell events table!

Finally there is the option of using a bayes classifier to better the segmentation.  This
 functionality has not been fully developed and will be updated in subsequent rounds.

Please direct questions to 
christian.t.meyer@vanderbilt.edu
