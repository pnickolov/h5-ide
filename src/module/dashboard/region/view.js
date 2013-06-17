(function() {
  define(['event', 'backbone', 'jquery', 'handlebars'], function(event) {
    var GegionView;
    GegionView = Backbone.View.extend({
      time_stamp: new Date().getTime(),
      el: $('#tab-content-region'),
      template: Handlebars.compile($('#region-tmpl').html()),
      events: {
        'click .return-overview': 'returnOverviewClick',
        'click .refresh': 'returnRefreshClick'
      },
      returnOverviewClick: function(target) {
        console.log('returnOverviewClick');
        return this.trigger('RETURN_OVERVIEW_TAB', null);
      },
      returnRefreshClick: function(target) {
        console.log('returnRefreshClick');
        return this.trigger('REFRESH_REGION_BTN', null);
      },
      render: function(time_stamp) {
        console.log('dashboard region render');
        $(this.el).html(this.template(this.model.attributes));
        if (time_stamp) {
          this.time_stamp = time_stamp;
        }
        return this.update_time();
      },
      update_time: function() {
        var me;
        me = this;
        $('#update-time').html(MC.intervalDate(me.time_stamp));
        setInterval(function() {
          return $('#update-time').html(MC.intervalDate(me.time_stamp));
        }, 60000);
        return null;
      }
    });
    return GegionView;
  });

}).call(this);
