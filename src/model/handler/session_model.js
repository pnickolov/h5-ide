/*
Description:
	model know service interface, and provide operation to vo
Action:
	1.define vo
	2.provide encapsulation of api for controller
	3.dispatch event to controller
*/


(function() {
  define(['backbone', 'session_service', 'session_vo'], function(Backbone, session_service, session_vo) {
    var SessionModel, session_model;

    SessionModel = Backbone.Model.extend({
      defaults: {
        vo: session_vo.session_info
      },
      login: function(username, password) {
        var me;

        me = this;
        return session_service.login(username, password, function(forge_result) {
          var session_info;

          if (!forge_result.is_error) {
            session_info = forge_result.resolved_data;
            me.set('vo.usercode', session_info.usercode);
            me.set('vo.region_name', session_info.region_name);
          } else {
            console.log('login failed, error is ' + forge_result.error_message);
          }
          return me.trigger('SESSION_LOGIN_RETURN', forge_result);
        });
      }
    });
    session_model = new SessionModel();
    return session_model;
  });

}).call(this);
