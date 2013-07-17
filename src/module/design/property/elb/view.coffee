#############################
#  View(UI logic) for design/property/elb
#############################

define [ 'event', 'MC', 'backbone', 'jquery', 'handlebars',
        'UI.fixedaccordion',
        'UI.secondarypanel',
        'UI.selectbox',
        'UI.tooltip',
        'UI.notification',
        'UI.toggleicon',
        'UI.slider'], ( ide_event, MC ) ->

    ElbView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-elb-tmpl' ).html()

        initialize : ->
            #handlebars equal logic
            Handlebars.registerHelper 'ifCond', (v1, v2, options) ->
                if v1 is v2
                    return options.fn this
                options.inverse this

        events   :
            'blur #property-elb-name' : 'elbNameChange'
            'change #elb-scheme-select1' : "schemeSelectChange"
            'change #elb-scheme-select2' : "schemeSelectChange"
            'SLIDER_CHANGE .slider' : 'sliderChange'

        render     : ( attributes ) ->
            console.log 'property:elb render'
            $( '.property-details' ).html this.template attributes
            $('.slider').setSliderValue(5)
            #fixedaccordion.resize()

        sliderChange : ( event, value ) ->
            alert $($('.slider')[0]).data('value')
            $('.slider').setSliderValue(5)
            alert $($('.slider')[0]).data('value')

        elbNameChange : ( event ) ->
            console.log 'elbNameChange'
            value = event.target.value
            cid = $( '#elb-property-detail' ).attr 'component'
            this.model.setELBName cid, value
            MC.canvas.update cid, 'text', 'elb_name', value

        schemeSelectChange : ( event ) ->
            console.log 'schemeSelectChange'
            value = event.target.value
            cid = $( '#elb-property-detail' ).attr 'component'
            this.model.setScheme cid, value

            if value is 'internal'
                MC.canvas.update cid, 'image', 'elb_scheme', MC.canvas.IMAGE.ELB_INTERNAL_CANVAS
            else
                MC.canvas.update cid, 'image', 'elb_scheme', MC.canvas.IMAGE.ELB_INTERNET_CANVAS
                
    }
    
    view = new ElbView()

    return view