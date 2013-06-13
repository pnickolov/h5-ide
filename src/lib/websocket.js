(function() {
  var __slice = [].slice;

  define(['Meteor', 'underscore'], function(Meteor, _) {
    var WebSocket, host, websocketInit;

    host = "211.98.26.7:3000";
    websocketInit = function() {
      var func, notifyFunc;

      _.extend(Meteor, {
        default_connection: null,
        refresh: notifyFunc = function(notification) {}
      });
      if (Meteor.isClient) {
        Meteor.default_connection = Meteor.connect(host, true);
        return _.each(['subscribe', 'methods', 'call', 'apply', 'status', 'reconnect'], func = function(name) {
          return Meteor[name] = _.bind(Meteor.default_connection[name], Meteor.default_connection);
        });
      }
    };
    WebSocket = (function() {
      function WebSocket() {
        this.collection = {
          'request': new Meteor.Collection("request"),
          'request_detail': new Meteor.Collection("request_detail")
        };
      }

      WebSocket.prototype.status = function(state, status_callback) {
        var stFunc;

        if (state == null) {
          state = false;
        }
        if (status_callback == null) {
          status_callback = null;
        }
        if (status_callback) {
          return Deps.autorun(stFunc = function() {
            if (Meteor.status().connected === state) {
              return status_callback();
            }
          });
        } else {
          return Meteor.status().connected;
        }
      };

      WebSocket.prototype.sub = function() {
        var args, name, sub_callback, sub_instance, _i;

        name = arguments[0], args = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), sub_callback = arguments[_i++];
        sub_instance = Meteor.subscribe.apply(Meteor, [name].concat(__slice.call(args), [sub_callback]));
        return sub_instance;
      };

      WebSocket.prototype.unsub = function(sub_instance) {
        var error;

        console.log("Stopping subscription");
        try {
          return sub_instance.stop();
        } catch (_error) {
          error = _error;
          return console.log("Stop subscription failed. " + error);
        }
      };

      WebSocket.prototype.get = function(name) {
        if (this.collection[name] != null) {
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
