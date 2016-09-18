function [output] = AllLines(input)
%Find all the lines on an image and plot a histogram of their positions

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
I = imresize(I,[1500,NaN]);
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

[a,b] = size(I);

line_var = zeros(0,3);
for x = 1:40
    for z = 1:20
        rect = [(b/40)*(x-1),(a/20)*(z-1),b/40,a/20];
        I1 = imcrop(I,rect);
        %use steerable pyramids to find the most prominent edge direction in
        %each small rectangle
        %This cell array contains the images for pyramids at different
        %orientations
        steers = cell(1,37);
        I1 = (mat2gray(I1));
        pyrlev = 3;
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
    
       
    
        %Put the edge properties into an output variable to be used later in
        %the program
        for i = 1:size(orients)
            %coordinates need to be rescaled as the pyramid uses a lower resolution
            %image
            distlist = zeros(1,size(textpos,1));
            for w = 1:size(textpos,1)
                distlist(w) = (((b/40)*(x-1) + (2^(pyrlev-1))*centroids(i,1)-textpos{w}(2))^2+(a/20*(z-1) + (2^(pyrlev-1))*centroids(i,2)-textpos{w}(1))^2)^0.5;
            end
            min_dist = min(distlist);
            if (min_dist<=10) && (abs(orients(i))<=15)
                continue
            else
                line_var(end+1,1) = (b/40)*(x-1) + (2^(pyrlev-1))*centroids(i,1);
                line_var(end,2) = a/20*(z-1) + (2^(pyrlev-1))*centroids(i,2);
                line_var(end,3) = orients(i);
            end
        end
        x
        z
    end
end

hello_var = 0;

for x = 1:39
    for z = 1:19
        rect = [(b/80)+(b/40)*(x-1),(a/40)+(a/20)*(z-1),b/40,a/20];
        I1 = imcrop(I,rect);
        %use steerable pyramids to find the most prominent edge direction in
        %each small rectangle
        %This cell array contains the images for pyramids at different
        %orientations
        steers = cell(1,37);
        I1 = (mat2gray(I1));
        pyrlev = 3;
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
    
       
    
        %Put the edge properties into an output variable to be used later in
        %the program
        for i = 1:size(orients)
            %coordinates need to be rescaled as the pyramid uses a lower resolution
            %image
            distlist = zeros(1,size(textpos,1));
            for w = 1:size(textpos,1)
                distlist(w) = ((b/80 + (b/40)*(x-1) + (2^(pyrlev-1))*centroids(i,1)-textpos{w}(2))^2+(a/40 + a/20*(z-1) + (2^(pyrlev-1))*centroids(i,2)-textpos{w}(1))^2)^0.5;
            end
            mindist = min(distlist);
            if (mindist<=10) && (abs(orients(i))<=15)
                continue
            else
                line_var(end+1,1) = b/80 + (b/40)*(x-1) + (2^(pyrlev-1))*centroids(i,1);
                line_var(end,2) = a/40 + a/20*(z-1) + (2^(pyrlev-1))*centroids(i,2);
                line_var(end,3) = orients(i);
            end
        end
        x
        z
    end
end

figure
imshow(I)
for i= 1:size(line_var,1)
    coordsx = [line_var(i,1) + 0.5 * 50 * cosd(line_var(i,3))   ,   line_var(i,1) - 0.5 * 50 * cosd(line_var(i,3))];
    coordsy = [line_var(i,2) - 0.5 * 50 * sind(line_var(i,3))   ,   line_var(i,2) + 0.5 * 50 * sind(line_var(i,3))];
    line(coordsx,coordsy,'Color','r','LineWidth',0.5)
end
line_var(:,1) = floor(line_var(:,1));
line_var(:,2) = floor(line_var(:,2));
heat_map = zeros(floor((a/10-1)),floor(b/10));
for x = 1:floor(b/10)
    for y = 1:floor(a/10)-1
        dist_list = zeros(1,size(line_var,1));
        for i = 1:size(line_var,1)
            dist_list(i)= (((10*x-line_var(i,1))^2)+((10*y-line_var(i,2))^2)).^0.5;
        end
        [~,idx] = min(dist_list);
        heat_map(floor(a/10)-y,x) = line_var(idx,3);           
    end
end
%figure
%histogram(line_var(:,3),18);
mymap = [1.0000    1.0000    1.0000
    0.9422    0.9711    0.9891
    0.8844    0.9422    0.9783
    0.8266    0.9133    0.9674
    0.7687    0.8844    0.9566
    0.7109    0.8555    0.9457
    0.6531    0.8266    0.9349
    0.5953    0.7977    0.9240
    0.5375    0.7688    0.9131
    0.4797    0.7399    0.9023
    0.4218    0.7110    0.8914
    0.3640    0.6821    0.8806
    0.3062    0.6532    0.8697
    0.2484    0.6243    0.8588
    0.1906    0.5954    0.8480
    0.1328    0.5664    0.8371
    0.0749    0.5375    0.8263
    0.0703    0.5039    0.7746
    0.0656    0.4704    0.7230
    0.0609    0.4368    0.6713
    0.0562    0.4032    0.6197
    0.0515    0.3696    0.5681
    0.0468    0.3360    0.5164
    0.0422    0.3024    0.4648
    0.0375    0.2688    0.4131
    0.0328    0.2352    0.3615
    0.0281    0.2016    0.3099
    0.0234    0.1680    0.2582
    0.0187    0.1344    0.2066
    0.0141    0.1008    0.1549
    0.0094    0.0672    0.1033
    0.0047    0.0336    0.0516
         0         0         0
    0.0513    0.0385    0.0140
    0.1025    0.0770    0.0281
    0.1538    0.1155    0.0421
    0.2050    0.1540    0.0561
    0.2563    0.1925    0.0702
    0.3075    0.2310    0.0842
    0.3588    0.2695    0.0982
    0.4101    0.3080    0.1123
    0.4613    0.3465    0.1263
    0.5126    0.3849    0.1403
    0.5638    0.4234    0.1544
    0.6151    0.4619    0.1684
    0.6663    0.5004    0.1824
    0.7176    0.5389    0.1965
    0.7689    0.5774    0.2105
    0.8201    0.6159    0.2245
    0.8714    0.6544    0.2386
    0.9226    0.6929    0.2526
    0.9739    0.7314    0.2666
    0.9761    0.7538    0.3278
    0.9782    0.7762    0.3889
    0.9804    0.7985    0.4500
    0.9826    0.8209    0.5111
    0.9848    0.8433    0.5722
    0.9869    0.8657    0.6333
    0.9891    0.8881    0.6944
    0.9913    0.9105    0.7555
    0.9935    0.9328    0.8167
    0.9956    0.9552    0.8778
    0.9978    0.9776    0.9389
    1.0000    1.0000    1.0000];
figure
contourf(heat_map);
ax = gca;
ax.DataAspectRatio = [1,1,1];
colormap(mymap);
output = 0;
end

