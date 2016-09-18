function line_var = LeftLines(input)
%Crops the image so only the right edge is considered (This is the
%connecting edge for a page on the left side of a bifolio)
%Uses Steerable pyramids to find most prominent edge directions. Then uses edge detection 
%and returns the centres and orientations of these edges
%For left images
I = input;
if ndims(I) == 3
    I = rgb2gray(I);
end
[a,b] = size(I);
%Crop the image to only contain a thin strip at the connecting edge
rect = [(9*b)/10,0,b/5,a];
I = imcrop(I,rect);
line_var = zeros(0,3);
%Divide this thin strip into ten rectangles
for z = 1:10
    rect = [0,(a/10)*(z-1),b/10,a/10];
    I1 = imcrop(I,rect);
    %use steerable pyramids to find the most prominent edge direction in
    %each small rectangle
    %This cell array contains the images for pyramids at different
    %orientations
    steers = cell(1,37);
    I1 = (mat2gray(I1));
    pyrlev = 2;
    spyr = sepspyr.build(I1,'13-tap-inphase-quadrature',pyrlev);
    for r = 0:5:180
        steers{1,(r/5)+1} = sepspyr.steer(spyr,r*(pi/180),pyrlev);
    end
    %Find the orientation with the strongest output, this is the direction
    %with the most dominant edges
    maximage = steers{1,1}{1,pyrlev};
    for i = 1:size(steers,2)
        if sum(sum(abs(steers{1,i}{1,pyrlev}))) >= sum(sum(abs(maximage)))
            maximage = steers{1,i}{1,pyrlev};
        end
    end
    I1 = real(maximage);
    %If there are very few edges then the output will be weak and the lines
    %produced will be false positives so ignore weak outputs
    if sum(sum(abs(maximage))) <=40
        continue
    end
    %Remove background to make edges stand out more
    background = imopen(I1,strel('disk',20));
    I1 = I1 - background;
    %increase contrast to show edges more clearly
    I1 = imadjust(I1);
    thresh = [0.2,0.21];
    %Find edges with a custom threshold level which best finds the strong
    %edges
    I1 = edge(I1,'canny',thresh);
    %Remove small objects which are not proper edges
    I1 = bwareaopen(I1, 6);
    %Find the properties of each edge
    stats = regionprops(I1,'Centroid','Orientation','MajorAxisLength');
    centroids = cat(1, stats.Centroid);
    orients = cat(1, stats.Orientation);
    lengths = cat(1, stats.MajorAxisLength);
    
    %--------------------------------------------------------------
    
    %%This commented out section shows the edges found on the original
    %%image to check reliability
    
    %rect = [(9*b)/10,(a/10)*(z-1),b/10,a/10];
    %original = input;
    %croppy = imcrop(original,rect);
    %figure
    %imshow(croppy)

    %%show lines and centroids on a plot

    %for i= 1:size(stats,1)
    %    coordsmax = [centroids(i,1) + 0.5 * lengths(i) * cosd(orients(i))   ,   centroids(i,1) - 0.5 * lengths(i) * cosd(orients(i))];
    %    coordsmin = [centroids(i,2) - 0.5 * lengths(i) * sind(orients(i))   ,   centroids(i,2) + 0.5 * lengths(i) * sind(orients(i))];
    %   line((2^(pyrlev-1))*coordsmax,(2^(pyrlev-1))*coordsmin,'Color','r','LineWidth',3)
    %end
    
    %%----------------------------------------------------------------
    
    %Put the edge properties into an output variable to be used later in
    %the program
    for i = 1:size(orients)
    %coordinates need to be rescaled as the pyramid uses a lower resolution
    %image
    line_var(end+1,1) = 9*b/10 + (2^(pyrlev-1))*centroids(i,1);
    line_var(end,2) = a/10*(z-1) + (2^(pyrlev-1))*centroids(i,2);
    line_var(end,3) = orients(i);
    end
end

%Uncomment this next section if you want to see all the lines along the
%edge of the original image

%-------------------------------------------------------------------

%figure
%imshow(input)
%for i= 1:size(line_var,1)
%        coordsx = [line_var(i,1) + 0.5 * 50 * cosd(line_var(i,3))   ,   line_var(i,1) - 0.5 * 50 * cosd(line_var(i,3))];
%        coordsy = [line_var(i,2) - 0.5 * 50 * sind(line_var(i,3))   ,   line_var(i,2) + 0.5 * 50 * sind(line_var(i,3))];
%        line(coordsx,coordsy,'Color','b','LineWidth',2)
%end

%-------------------------------------------------------------------
end
