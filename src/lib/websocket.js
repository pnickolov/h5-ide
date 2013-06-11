(function() {
  var __slice = [].slice;

  define(['vender/meteor/meteor', 'underscore'], function(Meteor, _) {
    var WebSocket, host, websocketInit;
    host = "211.98.26.7:3000";
    websocketInit = function() {
      var dd_url, func, notifyFunc;
      _.extend(Meteor, {
        default_connection: null,
        refresh: notifyFunc = function(notification) {}
      });
      if (Meteor.isClient) {
        dd_url = '/';
        if (typeof __meteor_runtime_config__ !== 'undefined') {
          if (__meteor_runtime_config__.DDP_DEFAULT_CONNECTION_URL) {
            dd_url = __meteor_runtime_config__.DDP_DEFAULT_CONNECTION_URL;
          }
        }
        Meteor.default_connection = Meteor.connect(host, true);
        return _.each(['subscribe', 'methods', 'call', 'apply', 'status', 'reconnect'], func = function(name) {
          return Meteor[name] = _.bind(Meteor.default_connection[name], Meteor.default_connection);
        });
      }
    };
    WebSocket = (function() {
      var get, sub, unsub;

      function WebSocket() {
        this.collection = {
          'request': new Meteor.Collection("request"),
          'request_detail': new Meteor.Collection("request_detail")
        };
      }

      sub = function() {
        var args, callback, checkReady, name, sub_callback, sub_instance, _i;
        name = arguments[0], args = 4 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 2) : (_i = 1, []), sub_callback = arguments[_i++], callback = arguments[_i++];
        sub_instance = Meteor.subscribe.apply(Meteor, [name].concat(__slice.call(args), [sub_callback]));
        Deps.autorun(checkReady = function(c) {
          if (sub_instance.ready()) {
            if (callback) {
              callback();
            }
            return c.stop();
          }
        });
        return sub_instance;
      };

      unsub = function(sub_instance) {
        var error;
        console.log("Stopping subscription");
        try {
          return sub_instance.stop();
        } catch (_error) {
          error = _error;
          return console.log("Stop subscription failed. " + error);
        }
      };

      get = function(name) {
        if (this.collection[name] === void 0) {
          console.log("No such collection");
          return null;
        } else {
          return this.collection[name].find().fetch();
        }
      };

      return WebSocket;

    })();
    return {
      websocketInit: websocketInit,
      WebSocket: WebSocket
    };
  });

}).call(this);
