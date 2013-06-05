(function() {
  define(['event', 'backbone', 'jquery', 'handlebars'], function(event) {
    var PropertyView;
    PropertyView = Backbone.View.extend({
      el: $('#property-panel'),
      template: Handlebars.compile($('#property-tmpl').html()),
      render: function() {
        console.log('property render');
        return $(this.el).html(this.template());
      }
    });
    return PropertyView;
  });

}).call(this);
