(function() {
  define(['event', 'backbone', 'jquery', 'handlebars'], function(event) {
    var ToolbarView;

    ToolbarView = Backbone.View.extend({
      el: $('#main-toolbar'),
      template: Handlebars.compile($('#toolbar-tmpl').html()),
      render: function() {
        console.log('toolbar render');
        return $(this.el).html(this.template());
      }
    });
    return ToolbarView;
  });

}).call(this);
