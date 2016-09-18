function output = textfilter(input)
%Finds the positions of the pixels which are part of the text
%returns an image which has the text removed with interpolated values.
%Uncomment the last line if the input images do not already have increased
%contrast

Contrast_Level = 0.2; %Between 0 and 0.5 for increasing contrast in last line

Filt_Level = 0.1; %Determines how dark the pixels must be to be text, this 
%will need to be adjusted depending on size of text/amount of text

Min_Size = 5; %The minimum size of an object to be considered text, will
%vary depending on text size/style

if isa(input,'char') == true
    I = imread(input);
else
    I = input;
end
if ndims(I) ==3;
    I = rgb2gray(I);
end
%resize the images to standardise them
I = imresize(I,[750,NaN]);
%Threshold image to find the text position, use a high threshold so that
%only the very dark pixels are chosen
I1 = ~im2bw(I,Filt_Level);
%Filter out small regions since these are likely to be noise from the
%background
I1 = bwareaopen(I1, Min_Size);
%Then interpolate the points at the edges of the text to cover it up
textpos = cell(0);
for i = 2:(size(I1,1)-1)
    for j  = 2:(size(I1,2)-1)
        %Create a cell array with the positions of all the text pixels in
        if I1(i,j) == 1;
            textpos{end+1,1} = [i,j];
        end
    end
end
for i = 1:size(textpos,1)
    x = textpos{i,1};
    while I1(x(1),x(2)) == 1 && (x(1) ~=size(I1,1)-1)
        x(1) = x(1)+1;
    end
    first = [x(1)+1,x(2)];
    x = textpos{i,1};
    while (I1(x(1),x(2)) == 1)&&(x(1) ~= 1)
        x(1) = x(1)-1;
    end
    last = [x(1)-1,x(2)];
    %Do not interpolate if connected to edge of image since it is likely a
    %dark part of background
    if first(1) == 750
        continue
    elseif last(1) == 1
        continue
    end 
    %Only interpolate vertically if region is smaller than a certain size,
    %this is so we don't get big vertical 'stripes' from a large capital
    %letter
    if first(1)-last(1) <= 20;
            for k = 1:(first(1)-last(1))
            if last(1) ~=0
                I(x(1)+k,x(2)) = I(first(1),x(2))+(k/(first(1)-last(1)))*(I(last(1),x(2))-I(first(1),x(2)));
            else
                I(x(1)+k,x(2)) = I(first(1),x(2))+(k/(first(1)-last(1)-1))*(I(last(1)+1,x(2))-I(first(1),x(2)));
            end
            end
    %Interpolate horizontally for those which are not interpolated vertically       
    else 
        x = textpos{i,1};
        while I1(x(1),x(2)) == 1 && (x(2) ~=size(I1,2)-1)
            x(2) = x(2)+1;
        end
        first = [x(1),x(2)+1];
        x = textpos{i,1};
        while (I1(x(1),x(2)) == 1)&&(x(2) ~= 1)
            x(2) = x(2)-1;
        end
        last = [x(1),x(2)-1];
        %Do not interpolate if connected to edge of image since it is likely a
        %dark part of background        
        if first(2) == size(I1,2)
            continue
        elseif last(2) == 1
            continue
        end
        for k = 1:(first(2)-last(2))
            if last(2) ~=0
                I(x(1),x(2)+k) = I(x(1),first(2))+(k/(first(2)-last(2)))*(I(x(1),last(2))-I(x(1),first(2)));
            else
                I(x(1),x(2)+k) = I(x(1),first(2))+(k/(first(2)-last(2)-1))*(I(x(1),last(2)+1)-I(x(1),first(2)));
            end
        end
        
    end
end
%I = imadjust(I,[Contrast_Level,1-Contrast_Level],[]);
output = I;
