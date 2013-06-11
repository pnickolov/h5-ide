(function() {
  define(['event', 'backbone', 'jquery', 'handlebars'], function(event) {
    var OverviewView;
    OverviewView = Backbone.View.extend({
      el: $('#tab-content-dashboard'),
      template: Handlebars.compile($('#overview-tmpl').html()),
      events: {
        'click #map-region-spot-list li a ': 'mapRegionClick'
      },
      mapRegionClick: function(target) {
        console.log('mapRegionClick');
        return this.trigger('RETURN_REGION_TAB', null);
      },
      render: function() {
        console.log('dashboard overview render');
        return $(this.el).html(this.template());
      }
    });
    return OverviewView;
  });

}).call(this);
