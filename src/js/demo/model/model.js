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
  define(['backbone'], function(Backbone) {
    var Item, item;

    Item = Backbone.Model.extend({
      defaults: {
        'title': 'stabilo彩色铅笔',
        'price': 12.4
      }
      /*
      #login api
      login       : () ->
      
          me = this
      
          Session.login '/session/', 'login', [ 'kenshin', 'aaa123aa' ], ( result, status ) ->
      
              if status is VO.STATIC.E_OK
      
                  #set vo
                  me.set 'title', result.usercode
                  me.set 'price', result.session_id
      
                  #event
                  me.trigger 'login_succcess', result
              else
                  alert 'login unsucess, error is ' + result
      */

    });
    item = new Item();
    return item;
  });

}).call(this);
