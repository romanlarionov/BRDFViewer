
var Model = function() {
    this.loadedMesh = {};
    this.meshIsLoaded = false;
    this.usesCustomShader = false;
};
        
Model.prototype = {
    constructor: Model,

    loadOBJ: function(path, name, shader, createShader) {
        var that = this; // Used to save global Model scope in loader callback.

        var onProgress = function(xhr) {
		    if (xhr.lengthComputable) {
			    var percentComplete = xhr.loaded / xhr.total * 100;
			    console.log(Math.round(percentComplete, 2) + "% downloaded");
			}
		};

        var onError = function(err) {
		    console.log("Model:" + name + " failed to load");
		    console.log(err);
        };

        var mtlLoader = new THREE.MTLLoader();
        mtlLoader.setPath(path);
        mtlLoader.load(name + ".mtl", function(materials) {
            materials.preload();

            var objLoader = new THREE.OBJLoader();
            objLoader.setMaterials(materials);
            objLoader.setPath(path);
            objLoader.load(name + ".obj", function(object) {
                if (createShader) {
                    object.traverse(function (child) {
                        if (child instanceof THREE.Mesh) {
                            if (!(child.material instanceof THREE.MultiMaterial)) {
                                child.material = createShader(child);
                            }
                            child.geometry.computeVertexNormals();
                        }
                    });

                    that.usesCustomShader = true;
                }

                scene.add(object);
                that.loadedMesh = object;
                that.meshIsLoaded = true;
            });
        }, onProgress, onError);
    },

    loadJSON: function(path, name, shader) {
        var that = this;
        var jsonLoader = new THREE.JSONLoader();
        jsonLoader.load(path + name + '.js', function(geometry, materials) {
            var material = shader;
            if (!material) {
                material = new THREE.MultiMaterial(materials);
            }
            geometry.computeVertexNormals();
            var mesh = new THREE.Mesh(geometry, material);
            scene.add(mesh);
            that.loadedMesh = mesh;
            that.meshIsLoaded = true;
        });
    },

    updateUniforms: function(uniforms) {
        if (!this.meshIsLoaded) {
            return;
        }

        this.loadedMesh.traverse(function(child) {
            if (child instanceof THREE.Mesh) {
                if (!(child.material instanceof THREE.MultiMaterial)) {

                    for (var uniform in uniforms) {
                        if (uniforms.hasOwnProperty(uniform)) { // if input not undefined
                            // If uniform never defined.
                            if (!child.material.uniforms[uniform]) {
                                child.material.uniforms[uniform] = {};
                            }
                            child.material.uniforms[uniform] = uniforms[uniform];
                        }
                    }

                }
            }
        });
    }
};