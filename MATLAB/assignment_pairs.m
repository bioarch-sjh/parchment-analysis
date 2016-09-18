function [BestPairs] = assignment_pairs(varargin)
%Enter as many image filenames as necessary
%This is a modified version of scrapings 4, it also uses background and vertical line matching across the boundary
%and it uses a textfilter to remove the effect of strong edges from text
%left/rightlist store the filenames of respective pages

Leftlist = cell(0);
Rightlist = cell(0);
for i = 1:size(varargin,2)
    %if textposition(varargin{i}) == 'L'
        Leftlist{end+1} = varargin{i};
    %    disp('L')
    %end
    %if textposition(varargin{i}) == 'R'
        Rightlist{end+1} = varargin{i};
    %    disp('R')
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
            %assignment minimises so we must make a good score small
            ScoreMat(i,j) = 500 - value; 
        else
            ScoreMat(i,j) = 500;
        end
        if i == j
            ScoreMat(i,j) = 500;
        end             
    end
end
[arrangement] = assignmentoptimal(ScoreMat);

BestPairs = cell(0,2);

for i = 1:size(varargin,2)
    if (i<=size(Leftlist,2)) && (arrangement(i) <= size(Rightlist,2))
        
        %Uncomment this section if you want to print out the matches
        %---------------------------------------------------------------
        
        %figure 
        %s = strcat(Leftlist{i},{', '}, Rightlist{arrangement(i)},{', '}, num2str(500-ScoreMat(i,arrangement(i))));
        %imshowpair(imread(Leftlist{i}),imread(Rightlist{arrangement(i)}),'montage')
        %title(s);
        %TestPairPrint(Leftnotext{1,i},Rightnotext{1,arrangement(i,1)})
        
        %---------------------------------------------------------------
        
        BestPairs{end+1,1} = Leftlist{i};
        BestPairs{end,2} = Rightlist{arrangement(i)};
    end
end

end
