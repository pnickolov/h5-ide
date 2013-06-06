(function() {
  define(['jquery', 'text!/module/design/canvas/template.html', 'event'], function($, template, event) {
    var loadModule, unLoadModule;
    loadModule = function() {
      template = '<script type="text/x-handlebars-template" id="canvas-tmpl">' + template + '</script>';
      $(template).appendTo('#canvas');
      return require(['./module/design/canvas/view'], function(View) {
        var view;
        view = new View();
        return view.render();
      });
    };
    unLoadModule = function() {};
    return {
      loadModule: loadModule,
      unLoadModule: unLoadModule
    };
  });

}).call(this);
