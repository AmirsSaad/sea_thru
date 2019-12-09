% Copyright Sidra Riaz (c), 2016
% PhD student in Sogang University. Korea
% sidra@sogang.ac.kr

function histRGB(I)


if (size(I, 3) ~= 3)
    error('Input image must be RGB.')
end

nBins = 256;

rHist = imhist(I(:,:,1), nBins);
gHist = imhist(I(:,:,2), nBins);
bHist = imhist(I(:,:,3), nBins);

%RGBHIST Histogram Plot
hFig = figure;

subplot(2,1,1); 
imshow(I); 
title('Input image');

subplot(2,1,2);
h(1) = area(1:nBins, rHist, 'FaceColor', 'r'); hold on; 
h(2) = area(1:nBins, gHist,  'FaceColor', 'g'); hold on; 
h(3) = area(1:nBins, bHist,  'FaceColor', 'b'); hold on; 
title('RGB image histogram');