
BRDF Viewer
===========

This is a simple THREE.js application that plots several 3D BRDF distributions. This can be helpful for visualizing and understanding how these analytic specular functions will scatter incident light.

GUI options are available to let you vary the roughness, view theta, and fresnel.

Links
-----

There are several other implementations of a BRDF viewer online. Most are either in C++ or written with custom WebGL rendering engines. I find that this code is much easier to use and understand due to its support for THREE.js.

* [bv](http://www.graphics.stanford.edu/~smr/brdf/bv/)
* [Disney's BRDF Explorer](https://www.disneyanimation.com/technology/brdf.html)
* [WebGL BRDF Explorer](https://depot.floored.com/brdf_explorer)
* [BRDFLab](http://brdflab.sourceforge.net/)

![alt text][viewer.gif]
