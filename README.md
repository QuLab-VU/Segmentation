<<<<<<< HEAD
# Segmentation Code Christian Meyer christian.t.meyer@vanderbilt.edu
#2.17.16
#Segmentation code for the cellavista and BD pathway imaging platforms
#Currently under construction:
#Integration of Bayes Classifier
#Tracking Code
#Making GUI windows normalized to the screen they are on
#Compile in a matlab project to run on other computers without matlab
#Put a button to open SegmenterV2 GUI on the FileSorterGUI
#Put widget to open bayes classifier from SegmenterV2
#Generate introduction box when first initiated to give run down of pipeline
#Put widget in Bayes classifier gui to move to next image
#Put widget in bayes classifier gui to build logistic regression classifier
#Put widget in bayes classifier to run cell tracking algorithm based

#Code works by calling FileSorterGUI first from the command line to sort the 
#images in the experimental folder generated from the Cellavista
#After closing the Window, Run SegmenterV2 from the command line to open the
#GUI involved in segmenting the cells.  
#Algorithm follows the following:
#1)Illumination correction by either cidre correction where a predefined CIDRE 
#map has been generated or by subtraction of a control image.
#2)Otsu's multithresholding algorithm to binarize image
#3)Filter image with matlab's imtophat function to remove noise
#4)Water shed segmentation by image inversion -> pixel suppression -> and 
#watershed segmentation using matlab function
#5)K-nearest neighbor algorithm to predict cytoplasm

#Segmentation can be run in parallel.  Currently the waitbar assumes the 
#number of available workers is 4.

#Next is creation of a classifier to generate probabilities associated with 
#the characteristics of the nuclei generated from the segmentation used in
#the subsequent tracking algorithm


=======
BreastCancer
============
Breast Cancer project data repository.

Contributing researchers are:

Peter Lee Frick: 		peter.l.frick@vanderbilt.edu

Jing Hao: 				jing.hao@vanderbilt.edu

Keisha Nicole Hardeman: 	keisha.n.hardeman@vanderbilt.edu

Katherine L. Jameson: 	k.jameson@vanderbilt.edu

Buddhi Bishal Paudel: 	buddhi.b.paudel@vanderbilt.edu

Chengwei Peng: 			chengwei.peng@vanderbilt.edu

Darren Tyson: 			darren.tyson@vanderbilt.edu

Akshata Udyavar: 		akshata.udyavar@vanderbilt.edu
>>>>>>> 9f58421fcc1d655471f36eb519dc0f5e208519b4
