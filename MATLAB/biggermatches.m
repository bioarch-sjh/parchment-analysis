function [output] = biggermatches(varargin)
imgpairs = cell(0);
BestPairs = assignment_pairs(varargin{:})
for i = 1:size(BestPairs,1)
    imgpairs{i} = imfuse(imread(BestPairs{i,1}),imread(BestPairs{i,2}),'montage');
end
%imgpairs{1} = imread('pair1.png');
%imgpairs{2} = imread('pair2.png');
%imgpairs{3} = imread('pair3.png');
%imgpairs{4} = imread('pair4.png');
%imgpairs{5} = imread('pair5.png');
%imgpairs{6} = imread('pair6.png');
imgrotate = cell(0);
for i = 1:size(imgpairs,2)
    imgrotate{2*i} = (textfilter(imrotate(imgpairs{i},90)));
    imgrotate{2*i-1} = (textfilter(imrotate(imgpairs{i},270)));
end
ScoreMat = zeros(size(imgrotate,2));
%This matrix has each page from Rightpages along the top and each page from
%Leftpages along the side, the matrix values are the rating for fitting
%those two pages together along their common edge
for i = 1:size(imgrotate,2)
    for j = 1:size(imgrotate,2)
        value = TestPair(imgrotate{i},imgrotate{j});   
        ScoreMat(i,j) = value; 
        if i == j
            ScoreMat(i,j) = 0;
        end
        if mod(j,2)==0;
            ScoreMat(j-1,j) = 0;
            ScoreMat(j,j-1) = 0;
        end
            
    end
end

%If you want to see the score matrix then output it here as the values are
%changed in the next section

for x = 1:size(ScoreMat,2)/2
    [maximum ,  idx1] = max(ScoreMat);
    [~ , idx2] = max(maximum);
    figure 
    imshowpair(imgrotate{idx1(idx2)},imgrotate{idx2},'montage')
    TestPairPrint(imgrotate{1,idx1(idx2)},imgrotate{1,idx2})
    ScoreMat(idx1(idx2),idx2) = 0;
end
output = 0;
end
