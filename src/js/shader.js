
var Shader = function(vert_file, frag_file, uniforms) {
    this.vert_file = vert_file;
    this.frag_file = frag_file;

    if (!uniforms) uniforms = {};
    this.material = new THREE.RawShaderMaterial({
        uniforms,
        side: THREE.DoubleSide,
        vertexShader: this._loadShaderFile(this.vert_file + ".vert"),
        fragmentShader: this._loadShaderFile(this.frag_file + ".frag")
    });
};

Shader.prototype = {
    constructor: Shader,

    _loadShaderFile: function(file) {
        var loadedFile;

        $.ajax({
            async: false, // todo: this is deprecated. see to that
            url: '../src/shaders/' + file,
            complete: function(result) {
                loadedFile = result.responseText;
            } 
        });

        return loadedFile;
    }
};