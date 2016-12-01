
BRDF and Linearly Transformed Cosines Visualizer
================================================

This code base is has several demos which help to visually understand several BRDF lobes as well as LTC transformations.

tree structure:
demos
|- BRDFViewer.html - 
|- MERL_AreaLight.html
|- TransformationViewer.html

###BRDFViewer

Dynamically switch between analytic and fitted lobes with the 'switchPlots' button. Use sliders to change inputs of view theta, fresnel at normal incidence, and roughness.

###MERL_AreaLight

Running code demo of a simple sphere primitive lite by an area light using linearly transformed cosines. This particular demo uses a modified version of the LTC LUT, which has been fitted to use MERL emperical BRDF data. The dimensionality of the LUT is 64x3 (theta, color channel). Code for generating and exporting such textures can be found here: https://github.com/romanlarionov/LTC_Fitting/tree/merl.

###TransformationViewer

Visualization of the polygonal light prior to and during transformation. A static clamped cosine lobe is used to visualize D_0 being `(1/pi) * max(cos(theta), 0)`. The area light projection can also be seen transforming with the polygon. 

Varying the theta or roughness value will show how the polygon warps to compensate for the irradiance it should be emitting.

## Running

Simple python server should do:
```
python -m SimpleHTTPServer
```