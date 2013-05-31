(function() {
  define(['jquery', 'text!/module/design/resource/template.html', 'event'], function($, template, event) {
    var loadModule, unLoadModule;

    loadModule = function() {
      template = '<script type="text/x-handlebars-template" id="resource-tmpl">' + template + '</script>';
      $(template).appendTo('#resource-panel');
      return require(['./module/design/resource/view'], function(View) {
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
