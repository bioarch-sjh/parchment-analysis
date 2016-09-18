function counter = TestPair(input1,input2)

% Put 2 images side by side and see how well the edges overlap
%input1 is on the left, input2 is on the right
% Uses several matching methods:
%Trying to join up lines from opposite sides of the boundary
%Matches regions where the lines are vertical on both sides
%Matches regions where the background intensity is very similar

img1 = input1;
img2 = input2;
%Get variables containing properties of lines from the connecting edges
lines1 = LeftLines(img1);
lines2 = RightLines(img2);
[a,b] = size(img1);

%attempt to connect lines between the two images

%Move along a line from input1 and look for centroids of other lines with similar
%orientations near the path
lines2(:,1) = b + lines2(:,1);

%The counter records the total 'score' for the pair of images. This is the
%number of line matches across the boundary + score from matching vertical lines + score from
%matching the background intensity
counter = 0;


pointer = zeros(2,1);
%The numbers which are used to estimate whether lines match or not are
%purely empirical
maxdist_match = 4;
maxorient_match = 6;
for i = 1:size(lines1,1);
    %pointer starts on the centroid of a line on input1
    pointer(1) = lines1(i,1);
    pointer(2) = lines1(i,2);
    j = 1;
    while j <=35;
        %Test whether there is a line from input2 which is close to the
        %pointer and has a similar orientation to the initial line from
        %input1
        for k = 1:size(lines2,1)
            if (sqrt((pointer(1)-lines2(k,1))^2 +(pointer(2)-lines2(k,2))^2) <= maxdist_match) && (abs(lines1(i,3) - lines2(k,3)) <= maxorient_match)
                counter = counter +1;
            end
                
        end
        j = j+1;
        %Move the pointer forward along the line
        pointer(1) = pointer(1) + 5*cosd(lines1(i,3));
        pointer(2) = pointer(2) - 5*sind(lines1(i,3));
    end
end
%Now repeat the process but for lines going from input2 towards input 1.
%This improves the reliability of the matching process
for i = 1:size(lines2,1);
    pointer(1) = lines2(i,1);
    pointer(2) = lines2(i,2);
    j = 1;
    while j <=35;
        for k = 1:size(lines1,1)
            if (sqrt((pointer(1)-lines1(k,1))^2 +(pointer(2)-lines1(k,2))^2) <= maxdist_match) && (abs(lines2(i,3) - lines1(k,3)) <= maxorient_match)
                counter = counter +1;
            end  
        end
        j = j+1;
        pointer(1) = pointer(1) - 5*cosd(lines2(i,3));
        pointer(2) = pointer(2) + 5*sind(lines2(i,3));
    end
end
%Now match areas with vertical lines on either side of the boundary since
%these won't match across the boundary using the previous method
%Divide the boundary into 10 regions on each side and if the average line
%orientation is near vertical for corresponding regions then add to the
%score 
angle_threshold = 80;
vertical_score = 10;
for z = 1:10    
    anglesL = 0;
    anglesR = 0;
    j=0;
    k=0;
    for i = 1:size(lines1,1)
        if (lines1(i,2)<=z*a/10)&&(lines1(i,2)>=(z-1)*a/10)
            anglesL = anglesL + abs(lines1(i,3));
            j = j+1;
        end
    end
    meanL = anglesL/j;
    for i = 1:size(lines2,1)
       if (lines2(i,2)<=z*a/10)&&(lines2(i,2)>=(z-1)*a/10)
           anglesR = anglesR + abs(lines2(i,3));
           k = k+1;
       end
    end
    meanR = anglesR/k;
    if (meanL>=angle_threshold)&&(meanR>=angle_threshold)
        counter = counter +vertical_score;

    end
end

%Another matching criterion is background intensity
%divide into 20 regions on each side of the boundary
%Find the background by filtering only large features
%Then find the mean intensity of the background and if it is similar across
%the boundary add to the score

maxintensity_difference = 10;
background_score = 4;

back1 = imopen(img1,strel('disk',10));
back2 = imopen(img2,strel('disk',10));
mean1 = mean(back1(:,floor(9*b/10):b),2);
mean2 = mean(back2(:,1:floor(b/10)),2);
for z = 1:20
    sum1 = sum(mean1(floor((z-1)*a/20)+1:floor(z*a/20)-1));
    sum2 = sum(mean2(floor((z-1)*a/20)+1:floor(z*a/20)-1));
    final1 = sum1/(a/20);
    final2 = sum2/(a/20);
    if abs(final1-final2) <= maxintensity_difference;
        counter = counter + background_score;
    end
end

end