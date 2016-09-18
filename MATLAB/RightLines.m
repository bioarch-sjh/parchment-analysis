function line_var = RightLines(input)
%Does the same as Left.m but this time uses the left edge of the picture as
%that is the connecting edge for the pages on the right side of a bifolio
I = input;
if ndims(I) == 3
    I = rgb2gray(I);
end
[a,b] = size(I);
rect = [0,0,b/10,a];
I = imcrop(I,rect);
line_var = zeros(0,3);
for z = 1:10
    rect = [0,(a/10)*(z-1),(b/10),(a/10)];
    I1 = imcrop(I,rect);
    %figure
    %imshow(I1)
    %use steerable pyramids to filter
    steers = cell(1,37);
    I1 = (mat2gray(I1));
    pyrlev = 2;
    spyr = sepspyr.build(I1,'13-tap-inphase-quadrature',pyrlev);
    for r = 0:5:180
        steers{1,(r/5)+1} = sepspyr.steer(spyr,r*(pi/180),pyrlev);
    end
    maximage = steers{1,1}{1,pyrlev};
    for i = 1:size(steers,2)
        if sum(sum(abs(steers{1,i}{1,pyrlev}))) >= sum(sum(abs(maximage)))
            maximage = steers{1,i}{1,pyrlev};
        end
    end
    %figure
    %imshow(abs(maximage))
    I1 = real(maximage);
    if sum(sum(abs(maximage))) <=40
        continue
    end
    %[pyr,pind] = buildSpyr(I, 4, 'sp3Filters','reflect1');
    %I = reconSpyr(pyr, pind, 'sp3Filters','reflect1',[4,5]); //use
    %reconstructed image
    background = imopen(I1,strel('disk',20));
    %figure
    %surf(double(background(1:8:end,1:8:end))),zlim([0 255]);
    %set(gca,'ydir','reverse');
    I1 = I1 - background;
    I1 = imadjust(I1);
    thresh = [0.2,0.21];
    I1 = edge(I1,'canny',thresh);
    I1 = bwareaopen(I1, 6);
    %figure
    %imshow(I1);
    stats = regionprops(I1,'Centroid','Orientation','MajorAxisLength');
    centroids = cat(1, stats.Centroid);
    orients = cat(1, stats.Orientation);
    lengths = cat(1, stats.MajorAxisLength);

    %original = imread(filename);
    %croppy = imcrop(original,rect);
    %figure
    %imshow(croppy)

    %show lines and centroids on a plot

    %for i= 1:size(stats,1)
    %    coordsmax = [centroids(i,1) + 0.5 * lengths(i) * cosd(orients(i))   ,   centroids(i,1) - 0.5 * lengths(i) * cosd(orients(i))];
    %    coordsmin = [centroids(i,2) - 0.5 * lengths(i) * sind(orients(i))   ,   centroids(i,2) + 0.5 * lengths(i) * sind(orients(i))];
    %    line(8*coordsmax,8*coordsmin,'Color','r','LineWidth',3)
    %end
    for i = 1:size(orients)
    line_var(end+1,1) = (2^(pyrlev-1))*centroids(i,1);
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