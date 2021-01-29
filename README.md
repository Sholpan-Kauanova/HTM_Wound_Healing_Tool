# HTM Wound_Healing_Tool
This is Hight-Throughput Microscopy Wound healing tool to perform an automatic segmentation and recognition of empty gap for in vitro Wound healing a.k.a "Scratch assay" 

The tool requires MatLab2014 or higher with Simulink, Image Processing and Mapping Toolbox to run. 

After the initialization of tool it requires from user to set path for folder with data and an path for output.
The data must be organized as a folder with image sequence or subfolder(s) with an image seuence in. The input image format must be TIFF, PNG or JPG. 
The output path can be set in the same folder, by default it will set the system default. The result will be mirrored structure of input folder with data files and B&W images of binary mask. As an option the image with oulined gap overlay available (string 217-219 must be active). 
The WH_area.xlx contain counts of gap in pixel for every frame as a column in ascending order. 
ImMeanBulk.txt, ImMedBulk.txt and ImStdBulk.txt contain image mean, image median and image standart deviation of image after filtration. 

Input <br>
-Data folder<br>
--Folder with image sequence 1<br>
--Folder with image sequence 2<br>
--Folder with image sequence 3<br>
...<br>
--Folder with image sequence n<br>

Output<br>
Path name_Data folder<br>
--Folder with image sequence 1<br>
---bin  <br>
--Folder with image sequence 2<br>
---bin <br>
--Folder with image sequence 3<br>
---bin <br>
...<br>
--Folder with image sequence n<br>
---bin<br>

<b>Processing parameters</b><br>
There is only treshold to be set for processing. Threshold is defined as a fraction of mean and set by a coeficient which must be non-zero positive integer. The default parameter is 3.14 (Pi). The other parameters is listed in the coments within the script.


<b>Results</b><br>
The results is a pixel count of area gap in a middle of image. The user then can convert pixel counts to metric units according to microscope scale. 

Examples of processing <br>
<img src="https://user-images.githubusercontent.com/35289663/106069474-925d8a80-60d0-11eb-9a98-65dcd7941119.png" width="200" height="150">
<img src="https://user-images.githubusercontent.com/35289663/106069475-92f62100-60d0-11eb-8038-ce24c157fe45.png" width="200" height="150">
<img src="https://user-images.githubusercontent.com/35289663/106069476-92f62100-60d0-11eb-90e6-e891e6ead4f2.png" width="200" height="150"><br>
set of binary masks<br>
<img src="https://user-images.githubusercontent.com/35289663/106069477-92f62100-60d0-11eb-82c3-4b8e55829681.jpg" width="200" height="150">
<img src="https://user-images.githubusercontent.com/35289663/106069479-938eb780-60d0-11eb-9f25-edf946928172.jpg" width="200" height="150">
<img src="https://user-images.githubusercontent.com/35289663/106069480-938eb780-60d0-11eb-918e-e2e30929b6aa.jpg" width="200" height="150"><br>
set of wound contour overlay<br>
Image source is TScratch test set
