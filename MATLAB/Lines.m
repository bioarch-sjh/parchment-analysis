%Lines.m
%Try to find the distance between (roughly) parallel lines caused by
%scrapings

%Plan of attack:

%Find lines which have centres close to each other and also similar
%orientations. Need to make sure it only considers the closest line and not
%others further away in the same pattern

%Find the distance (In pixels presumably) between the two lines by
%projecting a perpendicular line between them and finding the distance
%between the intersection points

%This would be solving 2 simultaneous equations

%Could average over several points on the line to increase accuracy

%Here's code from Right.m which finds lines, gives us the
%data

I = imread(imgfile);
if ndims(I) == 3
    I = rgb2gray(I);
end
[a,b] = size(I);
rect = [0,0,200,3000];
I = imcrop(I,rect);
%figure
%imshow(I)
%use steerable pyramids to filter
I = (mat2gray(I));
spyr = sepspyr.build(I,'9-tap',4,'reflect1');
[pyr,pind] = buildSpyr(I, 4, 'sp3Filters','reflect1');
I = reconSpyr(pyr, pind, 'sp3Filters','reflect1',[4,5]);

background = imopen(I,strel('disk',20));
%figure
%surf(double(background(1:8:end,1:8:end))),zlim([0 255]);
%set(gca,'ydir','reverse');
%figure 
%imshow(I)
I = I - background;
%figure 
%imshow(I)
I = imadjust(I);
%figure
%imshow(I);
thresh = [0.2,0.5];
I = edge(I,'canny',thresh);
I = imdilate(I,strel('disk',1));
I = bwareaopen(I, 300);
%I = imfill(I,'holes');
%figure
%imshow(I)
stats = regionprops(I,'Centroid','Orientation','MajorAxisLength');
centroids = cat(1, stats.Centroid);
orients = cat(1, stats.Orientation);
lengths = cat(1, stats.MajorAxisLength);

original = imread(imgfile);
figure
imshow(original)

%show lines and centroids on a plot

for i= 1:size(stats,1)
    coordsmax = [centroids(i,1) + 0.5 * lengths(i) * cosd(orients(i))   ,   centroids(i,1) - 0.5 * lengths(i) * cosd(orients(i))];
    coordsmin = [centroids(i,2) - 0.5 * lengths(i) * sind(orients(i))   ,   centroids(i,2) + 0.5 * lengths(i) * sind(orients(i))];
    line(coordsmax,coordsmin,'Color','r','LineWidth',3)
end

%Creat a matrix of distances between all of the centroids

centroids = transpose(centroids);
DistMat = dist(centroids);
DistMat(~DistMat) = inf;
mins = zeros(0,2);
for i = 1:size(stats,1)
    %Find the closet line to every other line
    [minimum idx] = min(DistMat(i,:));
    %Only continue to analyse if the line is close enough to be sure they
    %are neighbouring lines
    if minimum <= 150
        mins(end+1,1) = i;
        mins(end,2) = idx;
    end
end
centroids = transpose(centroids);
hold on
plot(centroids(:,1),centroids(:,2), 'b*')
hold off
%Solve equations for x and y, the point of intersection of one line with
%the line perpendicular to the other which passes thorugh its centroid
syms x y
for i = 1:size(mins,1)
    [x1,y1] = solve([y-centroids(mins(i,1),2) == (1/tand(orients(mins(i,1))))*(x-centroids(mins(i,1),1)),y-centroids(mins(i,2),2) == -(tand(orients(mins(i,2))))*(x-centroids(mins(i,2),1))],[x,y]);
    hold on
    plot(x1,y1,'g*')
    hold off
    coordx = [centroids(mins(i,1),1),x1];
    coordy = [centroids(mins(i,1),2),y1];
    line(coordx,coordy,'Color','y','LineWidth',3)
end