(function() {
  define(['backbone', 'jquery', 'underscore'], function() {
    var RegionModel, model;

    RegionModel = Backbone.Model.extend({
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
    model = new RegionModel();
    return model;
  });

}).call(this);
