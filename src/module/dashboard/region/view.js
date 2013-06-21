(function() {
  define(['event', 'backbone', 'jquery', 'handlebars'], function(ide_event) {
    var GegionView;
    GegionView = Backbone.View.extend({
      time_stamp: new Date().getTime(),
      el: $('#tab-content-region'),
      template: Handlebars.compile($('#region-tmpl').html()),
      events: {
        'click .return-overview': 'returnOverviewClick',
        'click .refresh': 'returnRefreshClick',
        'modal-shown .run-app': 'runAppClick',
        'modal-shown .stop-app': 'stopAppClick',
        'modal-shown .terminate-app': 'terminateAppClick',
        'modal-shown .duplicate-stack': 'duplicateStackClick',
        'modal-shown .delete-stack': 'deleteStackClick'
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
      },
      runAppClick: function(event) {
        var id, target;
        target = $(this.el);
        id = event.currentTarget.id;
        $('#btn-confirm').on('click', {
          target: this
        }, function(event) {
          console.log('dashboard region run app');
          modal.close();
          return event.data.target.trigger('RUN_APP_CLICK', id);
        });
        return true;
      },
      stopAppClick: function(event) {
        var id, target;
        target = $(this.el);
        id = event.currentTarget.id;
        $('#btn-confirm').on('click', {
          target: this
        }, function(event) {
          console.log('dashboard region stop app');
          event.data.target.trigger('STOP_APP_CLICK', id);
          return modal.close();
        });
        return true;
      },
      terminateAppClick: function(event) {
        var id, target;
        target = $(this.el);
        id = event.currentTarget.id;
        $('#btn-confirm').on('click', {
          target: this
        }, function(event) {
          console.log('dashboard region terminal app');
          modal.close();
          return event.data.target.trigger('TERMINATE_APP_CLICK', id);
        });
        return true;
      },
      duplicateStackClick: function(event) {
        var id, target;
        target = $(this.el);
        id = event.currentTarget.id;
        $('#btn-confirm').on('click', {
          target: this
        }, function(event) {
          console.log('dashboard region duplicate stack');
          modal.close();
          return event.data.target.trigger('DUPLICATE_STACK_CLICK', id, "new_name");
        });
        return true;
      },
      deleteStackClick: function(event) {
        var id, target;
        target = $(this.el);
        id = event.currentTarget.id;
        $('#btn-confirm').on('click', {
          target: this
        }, function(event) {
          console.log('dashboard region delete stack');
          modal.close();
          return event.data.target.trigger('DELETE_STACK_CLICK', id);
        });
        return true;
      },
      createStackClick: function(event) {
        console.log('dashboard region create stack');
        return ide_event.trigger(ide_event.ADD_STACK_TAB, region_name);
      }
    });
    return GegionView;
  });

}).call(this);
