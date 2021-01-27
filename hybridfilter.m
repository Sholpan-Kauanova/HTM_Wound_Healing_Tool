function filtered = hybridfilter(original,winsize)
%Gradient hybrid filtering is summarize gradient in sliding window to perform
%image degradation without loss of essential information about object
%The filtering procedure is similar to Kuwahara filter architectire, but
%does not produce "oil paint" effect on images
%
% This function is optimised using vectorialisation, convolution and the
% A nested-for loop approach is still used in the final part as it is more
% readable, a commented-out, fully vectorialised version is provided as
% well.
% The optimization part was used based on Faster Kuwahara Filter featured
% by Luca Balbi
% https://www.mathworks.com/matlabcentral/fileexchange/15027-faster-kuwahara-filter
%
% Inputs:
% original      -->    image to be filtered
% windowSize    -->    size of the filter kernel: legal values are
%                      3, 5, 9, 13, ... = (2*k+1)
% Filter description:
% 
%% Incorrect input handling (uncomment to switch it on)
% error(nargchk(2, 3, nargin, 'struct'));

% non-double data will be cast
if ~isa(original, 'double')
    original = double(original);
end % if
% wrong-sized kernel is an error
if mod(winsize,4)~=1
    error([mfilename ':IncorrectWindowSize'],'Incorrect window size: %d',winsize)
end 

%% Build the subwindows
HorDirect = [zeros((winsize-1)/2,(winsize)); ones(1,(winsize)); zeros((winsize-1)/2,(winsize))];
DiagUD=diag(ones(1,winsize));

% tmpavgker is a 'north-west' subwindow (marked as 'a' above)
% we build a vector of convolution kernels for computing average and
% variance
avgker(:,:,1) = HorDirect;          % North-west (a)
avgker(:,:,2) = rot90(HorDirect);   % North-east (b)
avgker(:,:,3) = DiagUD;             % South-east (c)
avgker(:,:,4) = rot90(DiagUD);      % South-west (d)

% this is the (pixel-by-pixel) square of the original image
% squaredImg = original.^2;

% preallocationg these arrays makes it about 15% faster
avgs = zeros([size(original) 4]);
stddevs = zeros([size(original) 4]);

%% Calculation of averages and variances on subwindows
for k=1:4
    avgs(:,:,k) = conv2(original,avgker(:,:,k),'same'); % mean on subwindow
end % for
%% Choice of the index with minimum variance
[minima,indices] = min(avgs,[],3); %smallest elements in array after kernels 

%% Building of the filtered image (with nested for loops)
filtered = zeros(size(original));
for k=1:size(original,1)
    for n=1:size(original,2)
        filtered(k,n) = avgs(k,n,indices(k,n)); %rendered image of after 4 kernels applied
    end % for
end % for
end % function