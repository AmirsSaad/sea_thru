# matlab-readraw
Read RAW camera images from within Matlab, using DCRAW

![Image of READRAW](https://github.com/farhi/matlab-readraw/blob/master/readraw.jpg)

The use of this class boils down to simply creating the object. Then, you
may simply use the **imread** and **imfinfo** call as usual, and RAW files
will magically be handled.

Example:
--------

In the following example, we just call **readraw** once, and then all is done 
with **imread** and **imfinfo** as you would do with other image formats.

  ```matlab
  readraw;
  im   = imread('file.RAW');  % this creates a file.tiff
  info = imfinfo('file.RAW'); 
  delete('file.tiff');  % to save disk space, if ever needed
  ...
  delete(readraw);
  ```
  
The default DCRAW setting for the importation is '-T -4 -t 0 -v' to get the raw data.

NOTES:
------

NOTE: Each RAW file will be converted to a 16-bits TIFF one at the same
location as the initial RAW file. This file is then read again by imread
to actually get the image RGB channels. If you have created these files
(which are each 146 Mb for 6x4k images), you may either remove them, or further access
them without requiring conversion.

Supported RAW camera image formats include:

- RAW CRW CR2 KDC DCR MRW ARW NEF NRW DNG ORF PTX PEF RW2 SRW RAF KDC

If you wish to import the RAW files with specific DCRAW options, use the
readraw class method 'imread' with options as 3rd argument e.g:

  ```matlab
  dc = readraw;
  im = imread(dc, 'file.RAW', '-a -T -6 -n 100');
  ```
  
and if you wish to get also the output file name and some more information:

  ```matlab
  [im, info, output] = imread(dc, 'file.RAW', '-T -4 -t 0 -v');
  ```
  
Some useful DCRAW options are:

- -T              write a TIFF file, and copy metadata in
- -w -T -6 -q 3   use camera white balance, and best interpolation AHD
- -a -T -6        use auto white balance
- -T -4           use raw data, without color scaling, nor white balance
- -i -v           print metadata
- -z              set the generated image date to that of the camera
- -n 100          remove noise using wavelets
- -w              use white balance from camera or auto
- -t 0            do not flip the image

Methods:
--------

- **readraw**     class instantiation. No argument.
- **compile**     check for DCRAW availability or compile it
- **delete**      remove readraw references in imformats
- **imread**      read a RAW image using DCRAW. Allow more options
- **imfinfo**     read a RAW image metadata using DCRAW

Credits: 
--------

- **DCRAW** is a great tool <https://www.cybercom.net/~dcoffin/dcraw/>
- Reading RAW files into MATLAB and Displaying Them <http://www.rcsumner.net/raw_guide/>
- RAW Camera File Reader by Bryan White 2016 <https://fr.mathworks.com/matlabcentral/fileexchange/7412-raw-camera-file-reader?focused=6779250&tab=function>

Installation:
-------------

Copy the directory and navigate to it. Then type from the Matlab prompt:

  ```matlab
  addpath('path-to-readraw')
  readraw;
  ```

If DCRAW is not yet installed on the computer, you will need a C compiler.
The DCRAW C source file (provided with READRAW) will be built and used.

License: (c) E. Farhi, GPL2 (2018)
