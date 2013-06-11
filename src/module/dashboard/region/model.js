(function() {
  define(['backbone', 'jquery', 'underscore'], function() {
    var OverviewModel, model;

    OverviewModel = Backbone.Model.extend({
      defaults: {
        temp: null
      },
      initialize: function() {
        return null;
      },
      temp: function() {
        var me;

        me = this;
        return null;
      }
    });
    model = new OverviewModel();
    return model;
  });

}).call(this);
