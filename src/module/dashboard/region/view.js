(function() {
  define(['event', 'backbone', 'jquery', 'handlebars'], function(event) {
    var GegionView;
    GegionView = Backbone.View.extend({
      el: $('#tab-content-region'),
      template: Handlebars.compile($('#region-tmpl').html()),
      events: {
        'click .return-overview': 'returnOverviewClick'
      },
      returnOverviewClick: function(target) {
        console.log('returnOverviewClick');
        return this.trigger('RETURN_OVERVIEW_TAB', null);
      },
      render: function() {
        console.log('dashboard region render');
        return $(this.el).html(this.template());
      }
    });
    return GegionView;
  });

}).call(this);
