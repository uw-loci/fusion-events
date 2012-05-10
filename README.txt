The purpose of this ImageJ macro & MATLAB function is to provide an automated
way to sort through large image sets. After collecting image data, the ImageJ
macro identifies fusion events in the image stack and stores information (e.g.
area, X & Y coordinates) about them in .txt files. These .txt files must be
converted to .xls files before further analysis can be done. Finally, the
MATLAB function (IntensityGraph) is run on the .xls files and returns the
number of identified fusion events and classifies each as proliferating or
unchanging. Scatter plots are also shown of area, X coordinates, and Y
coordinates of the fusion events.

For further details, see the website at:
   http://loci.wisc.edu/software/fusion-event-locator-classifier
