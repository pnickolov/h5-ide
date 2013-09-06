## IDE for HTML5 Project configuration guidelines

### Feature
* Automation
    * Build automation
    * Validation automation
    * Test automation
    * Publish automation
* Package manager
    * [Grunt package manager](http://gruntjs.com)
    * [Javascript libs package manager](http://twitter.github.com/bower/)(for example jquery, requirejs, backbone...)
* Source manager
    * [watch](https://github.com/yeoman/grunt-regarde)
    * [jshint](https://github.com/gruntjs/grunt-contrib-jshint)
    * [csslint](https://github.com/gruntjs/grunt-contrib-csslint)
    * [coffee](https://npmjs.org/package/grunt-contrib-coffee)
    * [coffeelint](https://github.com/vojtajina/grunt-coffeelint)
* Publish manager
    * [uglify](http://lisperator.net/uglifyjs)
    * [cssmin](https://github.com/gruntjs/grunt-contrib-cssmin)
    * [htmlmin](https://npmjs.org/package/grunt-contrib-htmlmin)
    * [livereload](https://npmjs.org/package/grunt-contrib-livereload)

### Framework
* [Backbone.js](http://backbonejs.org)
* [Underscore.js](http://underscorejs.org)
* [Require.js](http://requirejs.org)
* [jQuery](http://jquery.com)
* [Handlebars.js](http://handlebarsjs.com)
* [CoffeeScript](http://coffeescript.org)

### Node.js(NPM)

* Install: <http://nodejs.org/download/>

* Validation:
<pre>
windows command shell or use sudo (for OSX, *nix, BSD etc)
node --version
npm --version
</pre>

### Grunt & Bower

* Install:
<pre>
windows command shell or use sudo (for OSX, *nix, BSD etc)
npm install grunt-cli bower coffee-script -g
</pre>

* Validation:
<pre>
windows command shell or use sudo (for OSX, *nix, BSD etc)
grunt --version
bower --version
</pre>

### Livereload
* Installing browser extensions: <http://feedback.livereload.com/knowledgebase/articles/86242-how-do-i-install-and-use-the-browser-extensions->

### Setup H5 Project
<pre>
In the H5 Project directory
windows command shell or use sudo (for OSX, *nix, BSD etc)
npm install
grunt init    //Initialize this project
grunt         //watch and validation this project's source change
grunt develop //run server on brower( Chrome or Firfox )
grunt publish //publish and run this's project on brower( Chrome or Firfox )
</pre>

### Comment
<pre>
When change package.json, please run "npm install" in project dir
When change compnent.json, please run "grunt init" in project dir
</pre>pre>