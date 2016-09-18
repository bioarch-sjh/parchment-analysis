function counter = TestPairPrint(input1,input2)
%This does the same job as Test4.m but it also plots the lines which the
%program finds along with features which contribute to the score of the
%match. Using this makes it easier to check if the program is accurately
%finding features.
img1 = input1;
img2 = input2;
lines1 = LeftLines(img1);
lines2 = RightLines(img2);
figure 
I1 = img1;
I2 = img2;
[a,b] = size(I1);
imshowpair(I1,I2,'montage')
for i= 1:size(lines1,1)
        coordsx = [lines1(i,1) + 0.5 * 125 * cosd(lines1(i,3))   ,   lines1(i,1) - 0.5 * 25 * cosd(lines1(i,3))];
        coordsy = [lines1(i,2) - 0.5 * 125 * sind(lines1(i,3))   ,   lines1(i,2) + 0.5 * 25 * sind(lines1(i,3))];
        line(coordsx,coordsy,'Color','r','LineWidth',2)
end
for i= 1:size(lines2,1)
        coordsx = [b + lines2(i,1) + 0.5 * 25 * cosd(lines2(i,3))   ,  b + lines2(i,1) - 0.5 * 125 * cosd(lines2(i,3))];
        coordsy = [lines2(i,2) - 0.5 * 25 * sind(lines2(i,3))   ,   lines2(i,2) + 0.5 * 125 * sind(lines2(i,3))];
        line(coordsx,coordsy,'Color','b','LineWidth',2)
end

%attempt to connect lines between the two images
%Move along one line and look for centroids of other lines with similar
%orientations along the path
lines2(:,1) = b + lines2(:,1);
lines = 0;
pointer = zeros(2,1);
maxdist_match = 4;
maxorient_match = 6;
%Score for each line match is by default 1
for i = 1:size(lines1,1);
    pointer(1) = lines1(i,1);
    pointer(2) = lines1(i,2);
    j = 1;
    while j <=35;
        for k = 1:size(lines2,1)
            if (sqrt((pointer(1)-lines2(k,1))^2 +(pointer(2)-lines2(k,2))^2) <= maxdist_match) && (abs(lines1(i,3) - lines2(k,3)) <= maxorient_match)
                lines = lines +1;
                
                hold on 
                plot(pointer(1),pointer(2),'g*');
                %plot(lines1(i,1),lines1(i,2),'y*')
                %plot(lines2(k,1),lines2(k,2),'b*');
                hold off
            end
                
        end
        j = j+1;
        pointer(1) = pointer(1) + 5*cosd(lines1(i,3));
        pointer(2) = pointer(2) - 5*sind(lines1(i,3));
        %hold on
        %plot(pointer(1),pointer(2),'wo','MarkerSize',10)
        %hold off
    end
end
for i = 1:size(lines2,1);
    pointer(1) = lines2(i,1);
    pointer(2) = lines2(i,2);
    j = 1;
    while j <=35;
        for k = 1:size(lines1,1)
            if (sqrt((pointer(1)-lines1(k,1))^2 +(pointer(2)-lines1(k,2))^2) <= maxdist_match) && (abs(lines2(i,3) - lines1(k,3)) <= maxorient_match)
                lines = lines +1;
                %Plots stars at the point where the match is made along
                %with the centroids of the matching lines on both sides of
                %the boundary
                hold on 
                plot(pointer(1),pointer(2),'g*');
                %plot(lines2(i,1),lines2(i,2),'y*');
                %plot(lines1(k,1),lines1(k,2),'w*');
                hold off
            end
                
        end
        j = j+1;
        pointer(1) = pointer(1) - 5*cosd(lines2(i,3));
        pointer(2) = pointer(2) + 5*sind(lines2(i,3));
        %It is possible to plot the path that the pointer follows if
        %desired
        %hold on
        %plot(pointer(1),pointer(2),'wo','MarkerSize',10)
        %hold off
    end
end
%Now match areas with vertical lines on either side of the boundary since
%these won't match across the boundary using the previous method
vertical = 0;
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
        vertical = vertical +vertical_score;

        hold on
        plot (b,(z-0.5)*a/10,'ms','MarkerSize',70)
        hold off
    end
end

%Another matching criterion is background intensity
%These regions will be 1/20 of the height (instead of 1/10) to improve accuracy
background = 0;
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
        background = background + background_score;

        hold on
        plot (b,(z-0.5)*a/20,'cs','MarkerSize',35)
        hold off
    end
end
%Uncomment these to get a breakdown on how the score is distributed between
%the 3 criteria
%-----------------------------
%lines
%vertical
%background
%-----------------------------

counter = lines + vertical + background;

end