function [BestPairs] = top_pairs(varargin)
%This is a modified version of scrapings5.m
%It returns the 10 highest scoring matches for a bifolio from any number of
%input images so images can be repeated
Leftlist = cell(0);
Rightlist = cell(0);
for i = 1:size(varargin,2)
    %if textposition(varargin{i}) == 'L'
        Leftlist{end+1} = varargin{i};
        %disp('L')
    %end
    %if textposition(varargin{i}) == 'R'
        Rightlist{end+1} = varargin{i};
        %disp('R')
    %end
end
Leftnotext = cell(1,size(Leftlist,2));
Rightnotext = cell(1,size(Rightlist,2));
for i = 1:size(Leftlist,2)
    Leftnotext{1,i} = textfilter(Leftlist{1,i});
    Rightnotext{1,i} = textfilter(Rightlist{1,i});
end
%Define distance matrix
ScoreMat = zeros(size(varargin,2));
%This matrix has each page from Rightpages along the top and each page from
%Leftpages along the side, the matrix values are the rating for fitting
%those two pages together along their common edge
for i = 1:size(varargin,2)
    for j = 1:size(varargin,2)
        if (i<=size(Leftlist,2)) && (j<=size(Rightlist,2))
            value = TestPair(Leftnotext{1,i},Rightnotext{1,j});   
            ScoreMat(i,j) = value; 
        else
            ScoreMat(i,j) = 0;
        end
        if i == j
            ScoreMat(i,j) = 0;
        end
    end
end
BestPairs = cell(0,2);
for x = 1:size(varargin,2)
    [maximum idx1] = max(ScoreMat);
    [maximum2 idx2] = max(maximum);
    
    %Uncomment this section if you want to print out the matches found in
%descending order of liklihood of a match
%-------------------------------------------------------------------
    
    %figure 
    %s = strcat(Leftlist{idx1(idx2)},{', '}, Rightlist{idx2},{', '}, num2str(ScoreMat(idx1(idx2),idx2)));
    %imshowpair(imread(Leftlist{idx1(idx2)}),imread(Rightlist{idx2}),'montage')
    %title(s);
    %TestPairPrint(Leftnotext{1,idx1(idx2)},Rightnotext{1,idx2})
    
%-------------------------------------------------------------------

    ScoreMat(idx1(idx2),idx2) = 0;
    BestPairs{end+1,1} = Leftlist{idx1(idx2)};
    BestPairs{end,2} = Rightlist{idx2};
    
end
end