(function() {
  define(['event', 'backbone', 'jquery', 'handlebars'], function(ide_event) {
    var GegionView;
    GegionView = Backbone.View.extend({
      time_stamp: new Date().getTime(),
      el: $('#tab-content-region'),
      stat_table: Handlebars.compile($('#region-resource-tables-tmpl').html()),
      unmanaged_table: Handlebars.compile($('#region-unmanaged-resource-tables-tmpl').html()),
      vpc_attrs: Handlebars.compile($('#vpc-attrs-tmpl').html()),
      aws_status: Handlebars.compile($('#aws-status-tmpl').html()),
      stat_app_count: Handlebars.compile($('#stat-app-count-tmpl').html()),
      stat_stack_count: Handlebars.compile($('#stat-stack-count-tmpl').html()),
      stat_app: Handlebars.compile($('#stat-app-tmpl').html()),
      stat_stack: Handlebars.compile($('#stat-stack-tmpl').html()),
      events: {
        'click .return-overview': 'returnOverviewClick',
        'click .refresh': 'returnRefreshClick',
        'modal-shown .run-app': 'runAppClick',
        'modal-shown .stop-app': 'stopAppClick',
        'modal-shown .terminate-app': 'terminateAppClick',
        'modal-shown .duplicate-stack': 'duplicateStackClick',
        'modal-shown .delete-stack': 'deleteStackClick',
        'click #btn-create-stack': 'createStackClick',
        'click .app-thumbnail': 'clickAppThumbnail',
        'click .stack-thumbnail': 'clickStackThumbnail'
      },
      renderVPCAttrs: function() {
        console.log('dashboard region vpc_attrs render');
        $(this.el).find('.vpc-attrs-list').html(this.vpc_attrs(this.model.attributes));
        return null;
      },
      renderAWSStatus: function() {
        console.log('dashboard region aws_status render');
        $(this.el).find('.aws-status-list').html(this.aws_status(this.model.attributes));
        return null;
      },
      renderRegionResource: function() {
        console.log('dashboard region resource render');
        $(this.el).find('.region-resource-tables').html(this.stat_table(this.model.attributes));
        return null;
      },
      renderUnmanagedRegionResource: function(time_stamp) {
        console.log('dashboard unmanaged region resource render');
        $(this.el).find('.region-unmanaged-resource-tables').html(this.unmanaged_table(this.model.attributes));
        if (time_stamp) {
          this.time_stamp = time_stamp;
        }
        this.update_time();
        return null;
      },
      renderRegionStatInfo: function() {
        console.log('dashboard region stat info render');
        $(this.el).find('.region-stat-info').html(this.stat_info(this.model.attributes));
        return null;
      },
      renderRegionStatApp: function() {
        console.log('dashboard region stat app render');
        $(this.el).find('#stat-app-count').html(this.stat_app_count(this.model.attributes));
        $(this.el).find('#region-stat-app').html(this.stat_app(this.model.attributes));
        return null;
      },
      renderRegionStatStack: function() {
        console.log('dashboard region stat stack render');
        $(this.el).find('#stat-stack-count').html(this.stat_stack_count(this.model.attributes));
        $(this.el).find('#region-stat-stack').html(this.stat_stack(this.model.attributes));
        return null;
      },
      checkCreateStack: function(is_disabled) {
        console.log('checkCreateStack');
        if (is_disabled) {
          $('#btn-create-stack').removeClass('disabled').addClass('btn-primary');
        } else {
          $('#btn-create-stack').removeClass('btn-primary').addClass('disabled');
        }
        return null;
      },
      returnOverviewClick: function(target) {
        console.log('returnOverviewClick');
        return this.trigger('RETURN_OVERVIEW_TAB', null);
      },
      returnRefreshClick: function(target) {
        console.log('returnRefreshClick');
        return this.trigger('REFRESH_REGION_BTN', null);
      },
      render: function(template) {
        console.log('dashboard region render');
        return $(this.el).html(template);
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
        var id, name, target;
        target = $(this.el);
        id = event.currentTarget.id;
        name = event.currentTarget.name;
        $('#btn-confirm').on('click', {
          target: this
        }, function(event) {
          var new_name;
          console.log('dashboard region duplicate stack');
          new_name = $('#modal-input-value').val();
          if (!new_name || new_name === name) {
            return;
          }
          modal.close();
          return event.data.target.trigger('DUPLICATE_STACK_CLICK', id, new_name);
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
        ide_event.trigger(ide_event.ADD_STACK_TAB, this.region);
        return false;
      },
      clickAppThumbnail: function(event) {
        console.log('dashboard region click app thumbnail');
        console.log($(event.currentTarget).find('.thumbnail-name').text(), event.currentTarget.id, this.region);
        return ide_event.trigger(ide_event.OPEN_APP_TAB, $(event.currentTarget).find('.thumbnail-name').text(), this.region, event.currentTarget.id);
      },
      clickStackThumbnail: function(event) {
        console.log('dashboard region click stack thumbnail');
        console.log($(event.currentTarget).find('.thumbnail-name').text(), event.currentTarget.id, this.region);
        return ide_event.trigger(ide_event.OPEN_STACK_TAB, $(event.currentTarget).find('.thumbnail-name').text(), this.region, event.currentTarget.id);
      }
    });
    return GegionView;
  });

}).call(this);
