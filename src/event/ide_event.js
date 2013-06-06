/*
*/


(function() {
  define(['underscore', 'backbone'], function() {
    /*
    #private
    event = {
        NAVIGATION_COMPLETE : 'NAVIGATION_COMPLETE'
    }
    
    #bind event to Backbone.Events
    _.extend event, Backbone.Events
    
    #public
    event
    */

    var Event, event;
    Event = (function() {
      Event.prototype.NAVIGATION_COMPLETE = 'NAVIGATION_COMPLETE';

      Event.prototype.HEADER_COMPLETE = 'HEADER_COMPLETE';

      Event.prototype.DESIGN_COMPLETE = 'DESIGN_COMPLETE';

      function Event() {
        _.extend(this, Backbone.Events);
      }

      Event.prototype.onListen = function(type, callback) {
        return this.once(type, callback);
      };

      return Event;

    })();
    event = new Event();
    return event;
  });

}).call(this);
