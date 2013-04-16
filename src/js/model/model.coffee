
###
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
###

#model
define [ 'backbone' ], ( Backbone ) ->

	Item = Backbone.Model.extend {
		defaults :
			'title' : 'stabilo彩色铅笔'
			'price' : 12.4
	}

	item = new Item()
	return item