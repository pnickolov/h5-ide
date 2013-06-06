(function() {
  define(['event', 'backbone', 'jquery', 'handlebars'], function(event) {
    var ResourceView;
    ResourceView = Backbone.View.extend({
      el: $('#resource-panel'),
      template: Handlebars.compile($('#resource-tmpl').html()),
      render: function() {
        console.log('resource render');
        return $(this.el).html(this.template());
      }
    });
    return ResourceView;
  });

}).call(this);
