function [BestPairs] = probability_pairs(varargin)
%This is a modified version of scrapings5.m and scrapings6.m
%It uses the probablility that a pair is a match to rank them. This is
%based on the score of the "best match" as a percentage of the score of all
%the possible matches for that image and hence uses the "sharpness" of the
%peak as a ranking criteria

Leftlist = cell(0);
Rightlist = cell(0);
%Create a copy of the filename in both the left and right sides of possible
%bifolia
for i = 1:size(varargin,2)
        Leftlist{end+1} = varargin{i};
        Rightlist{end+1} = varargin{i};
end
Leftnotext = cell(1,size(Leftlist,2));
Rightnotext = cell(1,size(Rightlist,2));
%Remove the text from the images
for i = 1:size(Leftlist,2)
    Leftnotext{1,i} = textfilter(Leftlist{1,i});
    Rightnotext{1,i} = textfilter(Rightlist{1,i});
end
%Define score matrix
ScoreMat = zeros(size(varargin,2));
%This matrix has each page from Rightpages along the top and each page from
%Leftpages along the side, the matrix values are the rating for fitting
%those two pages together along their common edge
for i = 1:size(varargin,2)
    for j = 1:size(varargin,2)
        if (i<=size(Leftlist,2)) && (j<=size(Rightlist,2))
            value = TestPair(Leftnotext{1,i},Rightnotext{1,j});   
            ScoreMat(i,j) = value; 
            if i == j
                ScoreMat(i,j) = 0;
            end
        else
            ScoreMat(i,j) = 0;
        end
    end
end

NewScoreMat = zeros(size(varargin,2));
for i = 1:size(ScoreMat)
    for j = 1:size(ScoreMat)
        NewScoreMat(i,j) = (ScoreMat(i,j)/sum(ScoreMat(i,:)))+(ScoreMat(i,j)/sum(ScoreMat(:,j)));
    end
end

BestPairs = cell(0,2);
for x = 1:size(varargin,2)
    [maximum , idx1] = max(NewScoreMat);
    [~ , idx2] = max(maximum);
    
%Uncomment this section if you want to print out the matches found in
%descending order of liklihood of a match
%-------------------------------------------------------------------    
    
    %figure 
    %s = strcat(Leftlist{idx1(idx2)},{', '}, Rightlist{idx2},{', '}, num2str(NewScoreMat(idx1(idx2),idx2)));
    %imshowpair(imread(Leftlist{idx1(idx2)}),imread(Rightlist{idx2}),'montage')
    %title(s);
    %TestPairPrint(Leftnotext{1,idx1(idx2)},Rightnotext{1,idx2})
    
%-------------------------------------------------------------------
    
    NewScoreMat(idx1(idx2),idx2) = 0;
    BestPairs{end+1,1} = Leftlist{idx1(idx2)};
    BestPairs{end,2} = Rightlist{idx2};
end


end