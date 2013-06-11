(function() {
  define(['app_model', 'stack_model', 'ec2_model', 'backbone', 'jquery', 'underscore'], function(app_model, stack_model, ec2_model) {
    var OverviewModel, model, region_labels, stack_region_list;
    region_labels = [];
    stack_region_list = [];
    OverviewModel = Backbone.Model.extend({
      defaults: {
        'app_list': null,
        'stack_list': null,
        'region_list': null,
        'region_empty_list': null
      },
      initialize: function() {
        return null;
      },
      temp: function() {
        var me;
        me = this;
        return null;
      },
      appListService: function() {
        var me;
        me = this;
        console.log('overview_init_model');
        return app_model.on('RESULT_APP_LIST', function(result) {
          var app_list;
          console.log('Overview_APP_LST_RETURN');
          console.log(result);
          app_list = _.map(result.resolved_data, function(value, key) {
            return {
              'region_group': region_labels[key],
              'region_count': value.length,
              'region_name_group': value
            };
          });
          console.log(app_list);
          me.set('app_list', app_list);
          return null;
        });
      }
    });
    model = new OverviewModel();
    return model;
  });

}).call(this);
