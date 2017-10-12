function [ tform,outputView ] = imgeometric_matrixout( baseimage, otherimage )
%imgeometric_matrixout aligns image 2 to image 1
%   aligns image 2 to image 1 by doing uncalibrated stereo image
%   rectification. matches the strongest features in each of the images and
%   transforms the image. presumes the input images are already in
%   black/white matrices. outputs transformation matrixes

colorbaseimage=baseimage;
colorotherimage=otherimage;
%if the images are in color, get graycopies of the image
if size(baseimage,3)==3
    baseimage=rgb2gray(baseimage);
    otherimage=rgb2gray(otherimage);
end
%surf=SURF:Speeded Up Robust Features
bfeaturelocations = detectSURFFeatures(baseimage, 'MetricThreshold', 125);
ofeaturelocations = detectSURFFeatures(otherimage, 'MetricThreshold', 125);

[bfeatures, validBlobs1] = extractFeatures(baseimage, bfeaturelocations);
[ofeatures, validBlobs2] = extractFeatures(otherimage, ofeaturelocations);

indexPairs = matchFeatures(bfeatures, ofeatures, 'Metric', 'SAD', ...
  'MatchThreshold', 10);

matchedPoints1 = validBlobs1(indexPairs(:,1),:);
matchedPoints2 = validBlobs2(indexPairs(:,2),:);

% figure;
% showMatchedFeatures(baseimage, otherimage, matchedPoints1, matchedPoints2);
% legend('Putatively matched points in I1', 'Putatively matched points in I2');

[fMatrix, epipolarInliers, status] = estimateFundamentalMatrix(...
  matchedPoints1, matchedPoints2, 'Method', 'RANSAC', ...
  'NumTrials', 10000, 'DistanceThreshold', 0.1, 'Confidence', 99.99);

% improve this part below: test program says that there was not enough
% matches
if status ~= 0 || isEpipoleInImage(fMatrix, size(baseimage)) ...
  || isEpipoleInImage(fMatrix', size(otherimage))
  error(['Either not enough matching points were found or '...
         'the epipoles are inside the images. You may need to '...
         'inspect and improve the quality of detected features ',...
         'and/or improve the quality of your images.']);
end

inlierPoints1 = matchedPoints1(epipolarInliers, :);
inlierPoints2 = matchedPoints2(epipolarInliers, :);

% figure;
% showMatchedFeatures(baseimage, otherimage, inlierPoints1, inlierPoints2);
% legend('Non-outlier points in base image', 'Non-outlier points in comparison image');

[tform, inlierDistorted, inlierOriginal] = estimateGeometricTransform(...
    inlierPoints2, inlierPoints1, 'similarity');
% tform=tform.invert;
outputView = imref2d([size(baseimage,1)*3 size(baseimage,2)*3 size(baseimage,3)]);
% imout  = imwarp(colorotherimage,tform,'OutputView',outputView);



end

