function output = textposition(varargin)
%extracts the text position in an image
%returns whether the parchment is from the left or right side of a folio
centroids = 0;
for i = 1:nargin
    I = imread(varargin{i});
    I = rgb2gray(I);
    [a,b] = size(I);
    Filt = imgaussfilt(I,6);
    threshold = [0.26,0.27];
    while (size(centroids,1)<=25)&&(threshold(1)>=0)
        threshold = threshold - [0.03,0.03];
        %I2 = edge(Filt,'canny'); test how image is changed by thresholding
        I3 = edge(Filt,'canny',threshold);
        I3 = imdilate(I3,strel('disk',2));
        I3 = bwareaopen(I3, 1000);
        imshow(I3);
        stats = regionprops(I3,'Centroid');
        centroids = cat(1, stats.Centroid);
    end
    meanx = mean(centroids(:,1));
    if meanx <= b/2;
        output = 'R';
    end
    if meanx >= b/2
        output = 'L';
    end
end
end