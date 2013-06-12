(function() {
  require(['underscore', 'Meteor', 'WS'], function(_, Meteor, WS) {
    var call, subscirbed;

    console.log(1);
    subscirbed = new WS.WebSocket;
    return subscirbed.sub("request", 'a2Vu', '6738a80f-f22d-4281-b933-f743ca7f8a57', 'us-east-1', call = function() {
      return console.log(subscirbed.collection.request.find());
    });
  });

}).call(this);
