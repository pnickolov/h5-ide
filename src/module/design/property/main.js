(function() {
  define(['jquery', 'text!/module/design/property/template.html', 'event'], function($, template, event) {
    var loadModule, unLoadModule;

    loadModule = function() {
      template = '<script type="text/x-handlebars-template" id="property-tmpl">' + template + '</script>';
      $(template).appendTo('#property-panel');
      return require(['./module/design/property/view'], function(View) {
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
