# Tutorial

Contents:
1- Initial setup
2- Preprocessing of images
3- Uses of different functions, with examples

--------------------

# 1 - Initial Setup

Make sure to add the base folder and all subfolders to your matlab path, click the "set path" button on the home tab to do this.

Have a look at the ReadMe for a brief introduction to each function and the overall aim of the package

---------------------------------------------------------------------------------------------------------------------------------

# 2 - Preprocessing of images

It is important that your images are cropped correctly before being submitted to any of the programs.

See image 'precrop.tif'. This is how many digitised manuscripts are presented but this isn't suitable for our purpose.

The input image must consist of only one page and nothing else so the entire edge must be cropped.

Also the page has a missing corner where the page behind shows, this must be removed also.

'69v.png' shows a suitable crop of the original. The key features on the parchment have been retained right up to the edge of the image
and there is no evidence of any other pages. Try to keep the edge of the crop as close to the dege of the page as possible

When cropping .tif pictures to be non-rectangular, problems can arise because the cropped area is not white but transparent.

Therefore I recommend another file format which does not preserve transparency to avoid bugs (such as .png)

For the best performance, input images should be of similar aspect ratios but they do not have to be identical sizes.

---------------------------------------------------------------------------------------------------------------------------------
# 3 - Uses of different functions with examples

For this section we shall begin at the smaller scale functions dealing with individual images then build up to the large functions which
combine multiple images together


## 3.1    --textfilter.m--


This function can take either filename inputs, or if you have already read an image into MatLab then that can be used too

The function standardises the image size to 750 pixels in height, if you decide to change this then there will be implications in
other functions. Leftlines.m and Rightlines.m may have to have a different pyrlev variable and there could be other unforseen consequences,
especially in the displaying of lines on images.

Try typing into the console: imshow(textfilter('69v.png'));

An image should appear showing the previous image but with the text masked.

Adjust the Filt_level variable and run the same command again, compare the differences. A level of 0.2 seems to work well for this image

Now with the level at 0.2 type the command: imshow(textfilter('A_140_010r_19.jpg'));

The text filter has distorted the background a lot and so it is important to find which level works best for each set of images

In general if the program is not finding all the text then increase Filt_level, and if the program is distorting the background
too much then decrease it

In addition uncommenting the last line will increase the contrast of the output which can be altered with the variable Contrast_level.

Finally the variable Min_size determines the size of the smallest object which could be considered as text, this will need to be 
changed depending on the style and size of the text on different sets of parchment


## 3.2    --LeftLines.m and RightLines.m--


These functions only take images which have been read in as input, not filenames. So to examine '69v.png' you need to write LeftLines(imread('69v.png'))
or LeftLines(textfilter('69v.png'))

The names of these two functions could be a little misleading Leftlines.m returns the lines from the right side of an image and vice versa.

This is because the left/right refers to the position of the image in a pair:


		-----------------       -----------------
		|this is the 	|	|this is the	|
		|left page so	|	|right page so	|
		|use 		|	|use 		|
		|LeftLines.m	|	|RightLines.m	|
		|		|	|		|
		|		|	|		|
		|		|	|		|
		|		|	|		|
		-----------------	-----------------

The programs divide the edge of the image into 10 rectangles upon which a steerable pyramid filter is used

This filter essentially looks for linear features at different scales and any orientation rather than the orthogonal 
directions which limit some other filters

For more information see a paper entitled "The Design and Use of Steerable Filters" by W. Freeman and E. Adelson

The variable pyrlev is an integer which determines the scale at which the image is examined.

Larger features will be detected if pyr_lev is increased.

pyrlev = 1 means the image is examined at the input resolution

pyrlev = 2 means the image is examined with the resolution halved in each direction

pyrlev = 3, resolution is quartered in each direction etc.....

The image stepyr.png has three near vertical stripes on. The gifs stepyr1.gif to stepyr4.gif show how a steerable pyramid
sees the image at larger scales

If you change pyrlev on one of the functions remember to change it on the other. 

The edges are then taken from the steerable pyramid image with the greatest response and these lines are passed on as the output
of the function. This is in the form of a matrix with the first column as x coordinates, the second column as y coordinates
and the third column as orientations. Each row corresponds to an individual line found.

There is code at the bottom of the programs to show the lines found on the original image to check if the program is correct


## 3.3    --TestPair.m and TestPairPrint.m--


These functions require as input 2 images which have been previously read in to MatLab, often it is useful to perform the textfilter 
on the two images as part of this process, example code to be run from the command window would be:

		TestPair(textfilter('69v.png'),textfilter('64r.png'))

the first input is the left image and the second input is the right image. The function scores how well they match side by side

The functions use three methods to compare how well the images fit together. Each has associated variables.


\\Along the lines// - this follows a line along from one image to the other and checks if it hits a line with a similar orientation

The variables associated are:

maxdist_match , this is the maximum pixel distance for a line from one image to be considered a match to a line from the other image

maxorient_match , this is the maximum difference in orientation in degrees for which two lines which will be considered a match

Try varying these, increasing them will increase the score for any pairing but will lead to more matches which aren't true.

Each match counts as one point towards the score counter.


\\Across the lines// - this looks across for sets of vertical lines which are consistent across the boundary between the images but can't
be matched by the previous method since the lines don't cross the boundary

The boundary is divided up into 10 regions for this.

The variables associated are:

angle_threshold , The angle above which lines will be considered as vertical, maximum is 90 minimum is 0, I think 80-85 is sensible here

vertical_score, This is the score for each set of vertical lines matched across the boundary. The higher you change this to be then the greater
		the effect of this matching criteria on the overall score


\\Background// - takes only the large scale features from the background of both images and matches those with similar intensity

It is important to note that this can be affected when increasing the contrast of input images so the background intensity no longer matches

The boundary is divided into 20 regions for this and the mean intensity is taken within each region

The variables associated are:

maxintensity_difference , if the mean intensity is greater than this then the background is not considered to match across. The intensity 
			  scale ranges from 0 to 255.

background_score , same as vertical_score but for each region where the backgrounds match



The contribution of the score from each of these three methods is heavily weighted towards along the lines. This is because it seems to be
the most rigorous method of testing a pair

use TestPair.m to just show the score for better speed, however if you wish to check the matches then use TestPairPrint.m which
prints the pair as a figure

The images produced from TestPairPrint.m have red lines from the left image, blue lines from the right image, cyan squares for background matching and
magenta squares for matching of vertical lines.


## 3.4    --assignment_pairs.m , top_pairs.m , and probability_pairs.m--


For each of these three you input the filenames of the images which you want to find the pairs between.

The inputs should be inside apostrophes and separated by commas like so: 'file1','file2','file3',...

The output is a matrix containing the filenames of the images in the best pairs. There is code at the end of each which you can use to 
print out the pairs in the output using the TestPairPrint function, this is useful as there will always be pairs which are not true 
matches so looking at them can help to weed these out.

All work in a similar way:

They test every possible pair together to create a matrix of all the different scores. Then the pairs which are chosen as the best depend
on the different ranking algorithms in each

The simplest is in top_pairs.m this takes the pairs with the highest scores and outputs them in descending order, although this can lead to
multiple repetitions of the same image in different pairs

The next is probability_pairs.m, the ranking method is a bit more complex here. instead of the raw score of a pair this uses the score of a
specific pair as a percentage of the scores of all the pairs involving those two images added together. This means there is a bit more diversity 
in the images within the best pairs chosen as those which have consistently high scores do not dominate as much.

Finally assignment_pairs.m uses each image only once on the left side and right side of a pair. It then finds the configuration which maximises
the total score. The benefit of this is that it means there are no repeats of the same image in different pairs, however there will be some low
scoring pairs which are in the output and are unlikely to be matches, This method is useful only when you know that every image will fit
into a pair with another image in the input


## 3.5 --biggermatches.m--

This function performs one of the functions from 3.4 on a set of input images.

It then takes the best pairs and tries to find the best square of four images and prints the top scorers

It is also possible to make your own sets of pairs and put these in manually, as it is possible to see commented out near the top of the function
If you use manually chosen pairs then remember to comment out the first part of the function


---------------------------------------------------------------------------------------------------------------------------------

