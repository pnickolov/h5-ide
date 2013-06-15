(function() {
  define(['event', 'backbone', 'jquery', 'handlebars'], function(event) {
    var GegionView;
    GegionView = Backbone.View.extend({
      time_stamp: 0,
      el: $('#tab-content-region'),
      template: Handlebars.compile($('#region-tmpl').html()),
      events: {
        'click .return-overview': 'returnOverviewClick'
      },
      returnOverviewClick: function(target) {
        console.log('returnOverviewClick');
        return this.trigger('RETURN_OVERVIEW_TAB', null);
      },
      render: function(time_stamp) {
        console.log('dashboard region render');
        $(this.el).html(this.template());
        if (time_stamp) {
          this.time_stamp = time_stamp;
        }
        return this.update_time(time_stamp);
      },
      update_time: function(time_stamp) {
        $('#update-time').html(MC.intervalDate(time_stamp));
        setInterval(function() {
          return $('#update-time').html(MC.intervalDate(time_stamp));
        }, 60000);
        return null;
      }
    });
    return GegionView;
  });

}).call(this);
