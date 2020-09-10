The purpose of this ImageJ macro & MATLAB function is to provide an automated
way to sort through large image sets. After collecting image data, the ImageJ
macro identifies fusion events in the image stack and stores information (e.g.
area, X & Y coordinates) about them in .txt files. These .txt files must be
converted to .xls files before further analysis can be done. Finally, the
MATLAB function (IntensityGraph) is run on the .xls files and returns the
number of identified fusion events and classifies each as proliferating or
unchanging. Scatter plots are also shown of area, X coordinates, and Y
coordinates of the fusion events.

## Download

* [FusionAnalysisMacro.txt](https://raw.github.com/uw-loci/fusion-events/master/FusionAnalysisMacro.txt)
* [IntensityGraph.m](https://raw.github.com/uw-loci/fusion-events/master/IntensityGraph.m)

## Instructions

Download the ImageJ macro and MATLAB functions. Running the ImageJ macro
creates two text files: Summary & Results. These files store the analyzed image
data, such as area and X & Y coordinates. Once the text files are converted to
Excel .xls files, they can be further analyzed using the MATLAB function.
Running this function returns three figures and a textual output. The figures
display Area, X Coordinate, and Y Coordinate of the identified fusion events.
The textual output displays the following:

```
Number of fusion events=x
Number of proliferating fusion events=x
Number of unchanging fusion events=x
```

Based on this output, the user can choose to manually review the images if
interesting events exist (e.g. proliferating fusion events).

## Installation and Usage

1. Download each file (ImageJ macro & MATLAB function)

2. Start ImageJ & MATLAB

3. Open the ImageJ macro by choosing Plugins --> Macros --> Edit, and selecting the "FusionAnalysisMacro" macro

4. Change the directory and names of the input image stack & the output (i.e. where the stack will be saved)

5. Run the ImageJ macro by choosing Macros --> Run Macro

6. Open the Summary and Results .txt files in Microsoft Excel and "Save As" each as a .xls file

7. Run the MATLAB function by typing `IntensityGraph('Summary_File_Name.xls', 'Results_File_Name.xls')`
