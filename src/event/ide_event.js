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

      Event.prototype.OPEN_DASHBOARD = 'OPEN_DASHBOARD';

      Event.prototype.OPEN_STACK_TAB = 'OPEN_STACK_TAB';

      Event.prototype.RESULT_APP_LIST = 'RESULT_APP_LIST';

      Event.prototype.RESULT_STACK_LIST = 'RESULT_STACK_LIST';

      Event.prototype.RESULT_REGION_LIST = 'RESULT_REGION_LIST';

      Event.prototype.RESULT_EMPTY_REGION_LIST = 'RESULT_EMPTY_REGION_LIST';

      Event.prototype.RETURN_OVERVIEW_TAB = 'RETURN_OVERVIEW_TAB';

      Event.prototype.RETURN_REGION_TAB = 'RETURN_REGION_TAB';

      function Event() {
        _.extend(this, Backbone.Events);
      }

      Event.prototype.onListen = function(type, callback) {
        return this.once(type, callback);
      };

      Event.prototype.onLongListen = function(type, callback) {
        return this.on(type, callback);
      };

      return Event;

    })();
    event = new Event();
    return event;
  });

}).call(this);
