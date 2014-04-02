
/*
 */

(function() {
  define(['underscore', 'backbone'], function() {

    /*
     *private
    event = {
        NAVIGATION_COMPLETE : 'NAVIGATION_COMPLETE'
    }
    
     *bind event to Backbone.Events
    _.extend event, Backbone.Events
    
     *public
    event
     */
    var Event, event;
    Event = (function() {
      Event.prototype.NAVIGATION_COMPLETE = 'NAVIGATION_COMPLETE';

      Event.prototype.HEADER_COMPLETE = 'HEADER_COMPLETE';

      Event.prototype.DASHBOARD_COMPLETE = 'DASHBOARD_COMPLETE';

      Event.prototype.DESIGN_COMPLETE = 'DESIGN_COMPLETE';

      Event.prototype.RESOURCE_COMPLETE = 'RESOURCE_COMPLETE';

      Event.prototype.DESIGN_SUB_COMPLETE = 'DESIGN_SUB_COMPLETE';

      Event.prototype.IDE_AVAILABLE = 'IDE_AVAILABLE';

      Event.prototype.LOGOUT_IDE = 'LOGOUT_IDE';

      Event.prototype.OPEN_DESIGN = 'OPEN_DESIGN';

      Event.prototype.OPEN_SUB_DESIGN = 'OPEN_SUB_DESIGN';

      Event.prototype.CREATE_DESIGN_OBJ = 'CREATE_DESIGN_OBJ';

      Event.prototype.OPEN_PROPERTY = 'OPEN_PROPERTY';

      Event.prototype.FORCE_OPEN_PROPERTY = "FORCE_OPEN_PROPERTY";

      Event.prototype.REFRESH_PROPERTY = "REFRESH_PROPERTY";

      Event.prototype.RELOAD_AZ = 'RELOAD_AZ';

      Event.prototype.RESOURCE_API_COMPLETE = 'RESOURCE_API_COMPLETE';

      Event.prototype.SHOW_DESIGN_OVERLAY = 'SHOW_DESIGN_OVERLAY';

      Event.prototype.HIDE_DESIGN_OVERLAY = 'HIDE_DESIGN_OVERLAY';

      Event.prototype.UPDATE_RESOURCE_STATE = 'UPDATE_RESOURCE_STATE';

      Event.prototype.SWITCH_TAB = 'SWITCH_TAB';

      Event.prototype.SWITCH_DASHBOARD = 'SWITCH_DASHBOARD';

      Event.prototype.SWITCH_PROCESS = 'SWITCH_PROCESS';

      Event.prototype.SWITCH_LOADING_BAR = 'SWITCH_LOADING_BAR';

      Event.prototype.SWITCH_WAITING_BAR = 'SWITCH_WAITING_BAR';

      Event.prototype.SWITCH_MAIN = 'SWITCH_MAIN';

      Event.prototype.ADD_TAB_DATA = 'ADD_TAB_DATA';

      Event.prototype.DELETE_TAB_DATA = 'DELETE_TAB_DATA';

      Event.prototype.OPEN_DESIGN_TAB = 'OPEN_DESIGN_TAB';

      Event.prototype.CLOSE_DESIGN_TAB = 'CLOSE_DESIGN_TAB';

      Event.prototype.UPDATE_DESIGN_TAB = 'UPDATE_DESIGN_TAB';

      Event.prototype.UPDATE_DESIGN_TAB_ICON = 'UPDATE_DESIGN_TAB_ICON';

      Event.prototype.UPDATE_DESIGN_TAB_TYPE = 'UPDATE_DESIGN_TAB_TYPE';

      Event.prototype.HIDE_STATUS_BAR = 'HIDE_STATUS_BAR';

      Event.prototype.UPDATE_STATUS_BAR = 'UPDATE_STATUS_BAR';

      Event.prototype.UPDATE_TA_MODAL = 'UPDATE_TA_MODAL';

      Event.prototype.UNLOAD_TA_MODAL = 'UNLOAD_TA_MODAL';

      Event.prototype.TA_SYNC_START = 'TA_SYNC_START';

      Event.prototype.TA_SYNC_FINISH = 'TA_SYNC_FINISH';

      Event.prototype.RESULT_APP_LIST = 'RESULT_APP_LIST';

      Event.prototype.RESULT_STACK_LIST = 'RESULT_STACK_LIST';

      Event.prototype.RESULT_EMPTY_REGION_LIST = 'RESULT_EMPTY_REGION_LIST';

      Event.prototype.UPDATE_DASHBOARD = 'UPDATE_DASHBOARD';

      Event.prototype.UPDATE_REGION_THUMBNAIL = 'UPDATE_REGION_THUMBNAIL';

      Event.prototype.RETURN_OVERVIEW_TAB = 'RETURN_OVERVIEW_TAB';

      Event.prototype.RETURN_REGION_TAB = 'RETURN_REGION_TAB';

      Event.prototype.APPEDIT_2_APP = 'APPEDIT_2_APP';

      Event.prototype.RESTORE_CANVAS = 'RESTORE_CANVAS';

      Event.prototype.ENABLE_RESOURCE_ITEM = 'ENABLE_RESOURCE_ITEM';

      Event.prototype.DISABLE_RESOURCE_ITEM = 'DISABLE_RESOURCE_ITEM';

      Event.prototype.SHOW_PROPERTY_PANEL = 'SHOW_PROPERTY_PANEL';

      Event.prototype.PROPERTY_REFRESH_ENI_IP_LIST = 'PROPERTY_REFRESH_ENI_IP_LIST';

      Event.prototype.PROPERTY_DISABLE_USER_DATA_INPUT = 'PROPERTY_DISABLE_USER_DATA_INPUT';

      Event.prototype.UNDELEGATE_PROPERTY_DOM_EVENTS = 'UNDELEGATE_PROPERTY_DOM_EVENTS';

      Event.prototype.CANVAS_CREATE_LINE = 'CANVAS_CREATE_LINE';

      Event.prototype.CANVAS_DELETE_OBJECT = 'CANVAS_DELETE_OBJECT';

      Event.prototype.CANVAS_UPDATE_APP_RESOURCE = 'CANVAS_UPDATE_APP_RESOURCE';

      Event.prototype.CREATE_LINE_TO_CANVAS = 'CREATE_LINE_TO_CANVAS';

      Event.prototype.DELETE_LINE_TO_CANVAS = 'DELETE_LINE_TO_CANVAS';

      Event.prototype.REDRAW_SG_LINE = 'REDRAW_SG_LINE';

      Event.prototype.UPDATE_SG_LINE = 'UPDATE_SG_LINE';

      Event.prototype.START_APP = 'START_APP';

      Event.prototype.STOP_APP = 'STOP_APP';

      Event.prototype.TERMINATE_APP = 'TERMINATE_APP';

      Event.prototype.DELETE_STACK = 'DELETE_STACK';

      Event.prototype.DUPLICATE_STACK = 'DUPLICATE_STACK';

      Event.prototype.SAVE_STACK = 'SAVE_STACK';

      Event.prototype.UPDATE_APP_LIST = 'UPDATE_APP_LIST';

      Event.prototype.UPDATE_STACK_LIST = 'UPDATE_STACK_LIST';

      Event.prototype.UPDATE_STATUS_BAR_SAVE_TIME = 'UPDATE_STATUS_BAR_SAVE_TIME';

      Event.prototype.UPDATE_APP_STATE = 'UPDATE_APP_STATE';

      Event.prototype.CANVAS_SAVE = 'CANVAS_SAVE';

      Event.prototype.NAVIGATION_TO_DASHBOARD_REGION = 'NAVIGATION_TO_DASHBOARD_REGION';

      Event.prototype.RECONNECT_WEBSOCKET = 'RECONNECT_WEBSOCKET';

      Event.prototype.WS_COLLECTION_READY_REQUEST = 'WS_COLLECTION_READY_REQUEST';

      Event.prototype.UPDATE_REQUEST_ITEM = 'UPDATE_REQUEST_ITEM';

      Event.prototype.UPDATE_IMPORT_ITEM = 'UPDATE_IMPORT_ITEM';

      Event.prototype.RESOURCE_QUICKSTART_READY = 'RESOURCE_QUICKSTART_READY';

      Event.prototype.SAVE_APP_THUMBNAIL = 'SAVE_APP_THUMBNAIL';

      Event.prototype.UPDATE_PROCESS = 'UPDATE_PROCESS';

      Event.prototype.UPDATE_HEADER = 'UPDATE_HEADER';

      Event.prototype.UPDATE_REGION_RESOURCE = 'UPDATE_REGION_RESOURCE';

      Event.prototype.UPDATE_AWS_CREDENTIAL = 'UPDATE_AWS_CREDENTIAL';

      Event.prototype.ACCOUNT_DEMONSTRATE = 'ACCOUNT_DEMONSTRATE';

      Event.prototype.UPDATE_APP_RESOURCE = 'UPDATE_APP_RESOURCE';

      Event.prototype.UPDATE_APP_INFO = 'UPDATE_APP_INFO';

      Event.prototype.UPDATE_STATE_STATUS_DATA = 'STATE_STATUS_DATA_UPDATE';

      Event.prototype.UPDATE_STATE_STATUS_DATA_TO_EDITOR = 'UPDATE_STATE_STATUS_DATA_TO_EDITOR';

      Event.prototype.STATE_EDITOR_SAVE_DATA = 'STATE_EDITOR_SAVE_DATA';

      Event.prototype.GET_STATE_MODULE = 'GET_STATE_MODULE';

      Event.prototype.SHOW_STATE_EDITOR = 'SHOW_STATE_EDITOR';

      Event.prototype.STATE_EDITOR_DATA_UPDATE = 'STATE_EDITOR_DATA_UPDATE';

      function Event() {
        _.extend(this, Backbone.Events);
      }

      Event.prototype.onListen = function(type, callback, context) {
        return this.once(type, callback, context);
      };

      Event.prototype.onLongListen = function(type, callback, context) {
        return this.on(type, callback, context);
      };

      Event.prototype.offListen = function(type, function_name) {
        if (function_name) {
          return this.off(type, function_name);
        } else {
          return this.off(type);
        }
      };

      return Event;

    })();
    event = new Event();
    return event;
  });

}).call(this);
