clear all;
close all;
echo off
clc;    % Clear the command window.
workspace;  % Make sure the workspace panel is showing.
format longg;
format compact;
%%WOUND HEALING ASSAY

%Release date August 22, 2018, updated May 19, 2019

%This read the folder content and extract file names. this ends with error
%message since every folder contain 2 system files that cannot be
%processed. however it does not affect on result in case if there is only
%images at folder or subfolders

% Start with a folder and get a list of all subfolders.
% Finds and prints names of all PNG, JPG, and TIF images in 
% that folder and all of its subfolders.

% Ask user to confirm or change.
topLevelFolder = uigetdir;
savePath=uigetdir('','Select path to save');

Infolder = dir(topLevelFolder);
if topLevelFolder == 0
	return;
end
% Get list of all subfolders.
allSubFolders = genpath(topLevelFolder);
% Parse into a cell array.
remain = allSubFolders;
listOfFolderNames = {};
while true
	[singleSubFolder, remain] = strtok(remain, ';');
	if isempty(singleSubFolder)
		break;
	end
	listOfFolderNames = [listOfFolderNames singleSubFolder];
end
numberOfFolders = length(listOfFolderNames)

% Process all image files in those folders.
for k = 1 : numberOfFolders
	% Get this folder and print it out.
	thisFolder = listOfFolderNames{k};
	fprintf('Processing folder %s\n', thisFolder);
		% Get PNG files.
	filePattern = sprintf('%s/*.png', thisFolder);
	baseFileNames = dir(filePattern);
	% Add on TIF files.
	filePattern = sprintf('%s/*.tif', thisFolder);
	baseFileNames = [baseFileNames; dir(filePattern)];
	% Add on JPG files.
	filePattern = sprintf('%s/*.jpg', thisFolder);
	baseFileNames = [baseFileNames; dir(filePattern)];
	numberOfImageFiles = 1: length(baseFileNames);
	% Now we have a list of all files in this folder.
	
for i = 1:length(numberOfImageFiles)
    if numberOfImageFiles >= 1
		% Go through all those image files.
	fullFileName = fullfile(thisFolder, baseFileNames(i).name);
                 
OrigInput= imread(fullFileName);  %% figure; imshow(OrigInput); title('1. Orig');

%THE RGB2GRAY loop.  4 rows check image to be Gray. If they are RGB it converts image to Gray
 [rows, columns, numberOfColorChannels] = size(OrigInput);
   if numberOfColorChannels > 1;%check images if they are RGB and converts it to Gray
    OrigInput=rgb2gray(OrigInput);
   end
%END OF THE RGB2GRAY loop

%%BEGINING OF MAIN LOOPS
InputImage=mat2gray(OrigInput);
PoweredInput=InputImage.^2; %% figure; imshow(PoweredInput); title('orig power')

%%Noise and shading correction by difference os Gaussian. Sigma of
%%gaussian2 is fixed while gaussian1 extracted from image size 
gaussian1 = fspecial('Gaussian', 3, 2);
gaussian2 = fspecial('Gaussian', 1, 1);
dog = gaussian1 - gaussian2;
dogFI = conv2(double(PoweredInput), dog, 'same');
%%Normalization d
DoGimage=mat2gray(dogFI); %% figure; imshow(DoGimage);title('DoG');

%%Instead of Kuwahar there is local grad filter with tunable kernel is
%%applied 

HybridFilteredImage2 = hybridfilter(mat2gray(DoGimage),5);%free to play with values size of the gradfilter filter window: legal values are
% %                      5, 9, 13, ... = (4*k+1)
%% Another row of image shadding correction. It is necessary to do it with any approach like std we made here. 

HybridFilteredImage = mat2gray(HybridFilteredImage2); % figure; imagesc(HybridFilteredImage2); title ('6 Entropy');

seTH = strel('disk',13);
TopHat = imtophat(HybridFilteredImage,seTH); % figure; imagesc(TopHat); title ('6 TopHat');
TopHatImage=mat2gray(TopHat); % figure; imagesc(TopHat); title ('6 TopHat_norm');

AveFlt=averagefilter(TopHatImage, [20 20]); %figure; imagesc(AveFlt); title('7 averagefilter');
AveragedImage=mat2gray(AveFlt);%figure; imagesc(M4G); title ('8 averagefilter_Norm');

%This point is the "bottle neck' to bad segmentation. The images
%obtained as result of Kuwahara and cascade filtering has local
%signal "imperfections" which makes time-global variables like DoG sigma,
%Kuwahara sigma and etc not applicable for the particular frames. 

%Thresholding set here
ImMean=mean(mean(AveragedImage))
ImStd=std(std(AveragedImage))
ImMed=median(median(AveragedImage))
%SegTres=ImMean/2*pi %for very faded fine focus images
SegTres=ImMean/pi %for ORCA
% SegTres=ImMean/exp(1) %for ORCA HPF
% SegTres=ImMean/2.2 %for EVOS also
% SegTres=ImMean/1.5 %for EVOS
% SegTres=ImMed-ImStd %for HPF cells
% SegTres=ImMed-ImStd*1.5 %for HPF cells

% SegTres=ImMean/6 %for EVOS

BW224=im2bw(AveragedImage,SegTres); % figure;imshow(BW224); title('13im2bw');
BW2=BW224;
%It is nesessary due to different size of cam matrix pixels, composition, intensity range of various manufacturers. There is 3 cam available for TESTs Zeiss Axiocam which is CCD, Rolera EMC2 is EM CCD and Hamamtsu ORCA V2 is CMOS camera. 
%%Binarization of images; Almost done, there is must be Coefficient it is
%%works this way

%DECISION MAKING BLOCK STARTS HERE

%If loop here to check image to be in positive scale for further convertion
[m n]=size(BW2);
md=ceil(m/2);
AAA=[md+5, md+4, md+3, md+2, md+1, md, md-1, md-2, md-3, md-4,md-5];
nd=ceil(n/2);
BBB=[nd+5, nd+4, nd+3, nd+2, nd+1, nd, nd-1, nd-2, nd-3, nd-4,nd-5];

KA=impixel(BW2, AAA, BBB);

if KA<11;
   BW2=imcomplement(BW2);
end

BW2=imfill(BW2,'holes'); % figure;imshow(BW2);title('9 fill holes');
[m n]=size(BW2);

if impixel(BW2, [1: m] , [ 1: m])==1;
   SegTres=ImMean
   BW2=im2bw(AveragedImage,SegTres);
end
BW2=imfill(BW2,'holes');

% SE1=strel('disk',1); %was 7
SE1=strel('disk',2); %HSF update 2020-06-24 

SE2=strel('rectangle',[2,2]);
SE3=strel('disk',5); %was 3

Iec=imclose(BW2,SE2);% figure;imshow(Iec);title('1 close');
ImD=imdilate(Iec,SE1);% figure;imshow(ImD);title('2 dilate');
IeCc=imclose(ImD,SE1);% figure;imshow(IeCc);title('3 close2');
Iee=imerode(IeCc,SE3);% figure;imshow(Iee);title('2 erode');

BWimage=bwareafilt(Iee,1);% figure;imshow(BWimage);title('5 area filt');

%%get the perimeter and Area
BWP=bwperim(BWimage,8);% figure; imshow(BWP); title('9 Perimeter');

AREA = regionprops(BWimage,'Area'); %display(STATS);
WH_area(i,1)=extractfield(AREA,'Area');
% PERIM = regionprops(BWP,'Perimeter'); %display(STATS);
% WH_perim(i,1)=extractfield(PERIM,'Perimeter');

BWoutline = bwperim(BWP);
Segout = InputImage;
Segout(BWoutline) = 255; % figure; imshow(Segout)

%%%this part ON_FLIGHT is only for onine display of segmentation during
%%%flight. 
% Area_fig=figure; subplot(2,1,1); plot(WH_area);title('Area'); subplot(2,1,2);imshow(Segout); title('Outline')
%%%END of part ON_FLIGHT

%%This loop SET path where you files will be saved and provides names of
%%saved images
for i=i
    splitEntry=strsplit(fullFileName,'\');
    [n m]=size(splitEntry);
    last=m-1; 
    first=2;
    splitEntry=splitEntry(first:last);
    splitEntry=strjoin(splitEntry, '\');
end
% Generating output file name
        savePathName=strcat(savePath,splitEntry,'\Results\');
        savePathName=char(savePathName);
        mkdir(savePathName);
        
%saving the image features
ImMeanBulk(i,1)=ImMean;
[filenameImMean]=strcat(savePathName,'ImMeanBulk.txt');
csvwrite(filenameImMean,ImMeanBulk);

ImStdBulk(i,1)=ImStd;
[filenameImStd]=strcat(savePathName,'ImStdBulk.txt');
csvwrite(filenameImStd,ImStdBulk);

ImMedBulk(i,1)=ImMed;
[filenameImMed]=strcat(savePathName,'ImMedBulk.txt');
csvwrite(filenameImMed,ImMedBulk);

SegTresBulk(i,1)=SegTres;
[filenameSegTres]=strcat(savePathName,'SegTresBulk.txt');
csvwrite(filenameSegTres,SegTresBulk);

% Generating names of files and saving images at specified folder                 
SaveNameBin=strcat(savePathName,'\',sprintf('08_binary_%03d.png',i));
SaveNameBin=char(SaveNameBin);
imwrite(BWimage,SaveNameBin,'png');

SaveNameSegout=strcat(savePathName,'\',sprintf('Segout_%03d_.jpg',i));
SaveNameSegout=char(SaveNameSegout);
imwrite(Segout,SaveNameSegout,'jpg');

%EXTRA FILES may be commented to avoid stacking the HDD storage with
% input
% SaveNameInput=strcat(savePathName,'\',sprintf('01_Input_%03d.png',i));
% SaveNameInput=char(SaveNameInput);
% imwrite(InputImage,SaveNameInput,'png');
% 
% % powered
% SaveNamePoweredInput=strcat(savePathName,'\',sprintf('02_PoweredInput_%03d.png',i));
% SaveNamePoweredInput=char(SaveNamePoweredInput);
% imwrite(PoweredInput,SaveNamePoweredInput,'png');
% 
% % DoG
% SaveNameDoGimage=strcat(savePathName,'\',sprintf('03_DoGimage_%03d.png',i));
% SaveNameDoGimage=char(SaveNameDoGimage);
% imwrite(DoGimage,SaveNameDoGimage,'png');
% 
% % Hybrid Filtered
% SaveNameHybridFiltered=strcat(savePathName,'\',sprintf('04_HybridFiltered%03d.png',i));
% SaveNameHybridFiltered=char(SaveNameHybridFiltered);
% imwrite(HybridFilteredImage,SaveNameHybridFiltered,'png');
% 
% % TopHat
% SaveNameTopHat=strcat(savePathName,'\',sprintf('05_TopHatImage%03d.png',i));
% SaveNameTopHat=char(SaveNameTopHat);
% imwrite(TopHatImage,SaveNameTopHat,'png');
% 
% % AveragedImage
% SaveNameAveraged=strcat(savePathName,'\',sprintf('06_AveragedImage%03d.png',i));
% SaveNameAveraged=char(SaveNameAveraged);
% imwrite(AveragedImage,SaveNameAveraged,'png');
% 
% %Thresholded
% SaveNameBW224=strcat(savePathName,'\',sprintf('07_binarized%03d.png',i));
% SaveNameBW224=char(SaveNameBW224);
% imwrite(BW224,SaveNameBW224,'png');
% 
% %inverted and tested
% SaveNameBW2=strcat(savePathName,'\',sprintf('07_BW2%03d.png',i));
% SaveNameBW2=char(SaveNameBW2);
% imwrite(BW2,SaveNameBW2,'png');
    end
    %This piece will save Area mesuremens
for k=k  
    splitEntryName=strsplit(fullFileName,'\');
    [n m]=size(splitEntryName);
    splitEntryName=splitEntryName(m);
    SaveNameArea=strcat(savePathName,'\', sprintf('WH_area.csv'));
%     splitEntryName=strsplit(fullFileName,'.')
    SaveNameArea=char(SaveNameArea);
    csvwrite(SaveNameArea,WH_area);
    splitEntryName=char(splitEntryName);
fprintf(' Saving image file %s\n', splitEntryName);
   
end
end

%extracting properties of original image
% H=histogram(OrigInput);
% A(i,1)=max(max(OrigInput));
% B(i,1)=min(min(OrigInput));
% % C(i,1)=std(std(OrigInput));
% M(i,1)=mean(mean(OrigInput));
% MD(i,1)=mode(mode(OrigInput));
% ME(i,1)=median(median(OrigInput));
% 
% AA(i,1)=max(max(M4G));
% BB(i,1)=min(min(M4G));
% CC(i,1)=std(std(M4G));
% MM(i,1)=mean(mean(M4G));
% MMD(i,1)=mode(mode(M4G));
% MME(i,1)=median(median(M4G));
% 
% H=H';
% [filename]=sprintf('H:/TEST_WH/HIST/WH_hist_%03d.csv',i);
% csvwrite(filename,H);
% csvwrite('H:/TEST_WH/WH_max.csv',A);
% csvwrite('H:/TEST_WH/WH_min.csv',B);
% % csvwrite('H:/TEST_WH/WH_std.csv',C);
% csvwrite('H:/TEST_WH/WH_mean.csv',M);
% csvwrite('H:/TEST_WH/WH_mode.csv',MD);
% csvwrite('H:/TEST_WH/WH_median.csv',ME);
% 
% csvwrite('H:/TEST_WH/WH_max_FT.csv',AA);
% csvwrite('H:/TEST_WH/WH_min_FT.csv',BB);
% csvwrite('H:/TEST_WH/WH_std_FT.csv',CC);
% csvwrite('H:/TEST_WH/WH_mean_FT.csv',MM);
% csvwrite('H:/TEST_WH/WH_mode_FT.csv',MMD);
% csvwrite('H:/TEST_WH/WH_median_FT.csv',MME);
display ('End of Run')
		end

% WH_area = VarName1;
% image_thresholded = WH_area;
% image_thresholded(WH_area>4000000) = 0;
% area_transpozed=reshape(image_thresholded, [145, 96]);
% csvwrite('H:/WH_area_transposed.csv',area_transpozed);
% csvwrite('H:/Infolder.csv',Infolder);

