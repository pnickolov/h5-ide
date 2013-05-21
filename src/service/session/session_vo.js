(function() {
  define([], function() {
    var session_info;

    session_info = {
      userid: null,
      usercode: null,
      session_id: null,
      region_name: null,
      email: null,
      has_cred: null
    };
    return {
      session_info: session_info
    };
  });

}).call(this);
