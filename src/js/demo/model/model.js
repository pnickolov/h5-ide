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
    });
    item = new Item();
    return item;
  });

}).call(this);
