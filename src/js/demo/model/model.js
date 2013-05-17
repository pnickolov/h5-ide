/*
//model
define( [ 'backbone' ], function( Backbone ) {

    var Item = Backbone.Model.extend({

        defaults : {
            'title' : 'stabilo彩色铅笔',
            'price' : 12.4
        }

    });

    var item = new Item();

    return item;

});
*/


(function() {
  define(['backbone', 'service', 'vo'], function(Backbone, Session, VO) {
    var Item, item;

    Item = Backbone.Model.extend({
      defaults: {
        'title': 'stabilo彩色铅笔',
        'price': 12.4
      },
      login: function() {
        var me;

        me = this;
        return Session.login('/session/', 'login', ['kenshin', 'aaa123aa'], function(result, status) {
          if (status === VO.STATIC.E_OK) {
            me.set('title', result.usercode);
            me.set('price', result.session_id);
            return me.trigger('login_succcess', result);
          } else {
            return alert('login unsucess, error is ' + result);
          }
        });
      }
    });
    item = new Item();
    return item;
  });

}).call(this);
