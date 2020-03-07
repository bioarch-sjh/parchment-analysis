
This is a set of functions which can be used for assessing how well images fit together
Primarily the use is for pages of parchment which have striation marks, although the programs could be adapted for other similar purposes.

This has been made with MatLab R2015a with the image processing toolbox

The functions contained within are:

assignment_pairs.m  }
top_pairs.m	    } - These three find the best side by side pairings of input images using different ranking methods
probability_pairs.m }

textfilter.m - This finds text in an image and masks it by interpolating pixel values from the surrounding background, also resizes images toa standard size

biggermatches.m - This finds possible squares of pages, you can either input individual images or chosen pairs which fit together

TestPair.m - This gives a score for matching two images side by side

TestPairPrint.m - Same as above but also prints an image of what the computer sees when matching the images

LeftLines.m - Finds all of the lines down the connecting side of an image on the left of a pair

RightLines.m - Finds all of the lines down the connecting side of an image on the right of a pair


There are a few other more experimental programs such as lines.m, textposition.m, and AllLines.m which can be played with but aren't well commented or very useful at the moment

See the tutorial document to test out some of the functions and read through the comments on each to see how they work

Thanks,

Cameron
