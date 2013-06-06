(function() {
  define(['jquery', 'text!/module/design/toolbar/template.html', 'event'], function($, template, event) {
    var loadModule, unLoadModule;
    loadModule = function() {
      template = '<script type="text/x-handlebars-template" id="toolbar-tmpl">' + template + '</script>';
      $(template).appendTo('#main-toolbar');
      return require(['./module/design/toolbar/view'], function(View) {
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
