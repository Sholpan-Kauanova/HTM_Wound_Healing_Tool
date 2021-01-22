# Wound_Healing_Tool_2
This tool performs an automatic segmentation and recognition of empty gap for in vitro Wound healing a.k.a "Scratch assay" 

The tool requires MatLab2014 or higher with Simulink, Image Processing and Mapping Toolbox to run. 

After the initialization of tool it requires from user to set path for folder with data and an path for output.
The data must be organized as a folder with image sequence or subfolder(s) with an image seuence in. The input image format must be TIFF, PNG or JPG. 
The output path can be set in the same folder, by default it will set the system default. The result will be mirrored structure of input folder with data files and B&W images of binary mask. As an option the image with oulined gap overlay available (string 217-219 must be active). 
The WH_area.xlx contain counts of gap in pixel for every frame as a column in ascending order. 
ImMeanBulk.txt, ImMedBulk.txt and ImStdBulk.txt contain image mean, image median and image standart deviation of image after filtration. 

Input <br>
-Data folder<br>
--Folder with image sequence 1
--Folder with image sequence 2
--Folder with image sequence 3
...
--Folder with image sequence n

Output<br>
Path name_Data folder<br>
--Folder with image sequence 1
---bin  
--Folder with image sequence 2
---bin 
--Folder with image sequence 3
---bin 
...
--Folder with image sequence n
---bin

<b>Processing parameters</b><br>
There is only treshold to be set for processing. Threshold is defined as a fraction of mean and set by a coeficient which must be non-zero positive integer. The default parameter is 3.14 (Pi). The other parameters is listed in the coments withing script.


<b>Results</b><br>
The results is an area of the gap in a middle of gap in a pixel. The pixel counts need to be further converted to metric units according to user microscope scale. 
