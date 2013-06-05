(function() {
  define(['event', 'backbone', 'jquery', 'handlebars'], function(event) {
    var CanvasView;
    CanvasView = Backbone.View.extend({
      el: $('#canvas'),
      template: Handlebars.compile($('#canvas-tmpl').html()),
      render: function() {
        console.log('canvas render');
        return $(this.el).html(this.template());
      }
    });
    return CanvasView;
  });

}).call(this);
