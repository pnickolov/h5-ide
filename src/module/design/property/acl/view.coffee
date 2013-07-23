#############################
#  View(UI logic) for design/property/acl
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

   ACLView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        initialize : ->
            #handlebars equal logic
            Handlebars.registerHelper 'ifCond', (v1, v2, options) ->
                if v1 is v2
                    return options.fn this
                options.inverse this

            null

        events   :
            'click .secondary-panel .back' : 'returnMainPanel'
            'click #acl-add-rule-icon' : 'showCreateRuleModal'

        instance_expended_id : 0

        render     : (expended_accordion_id, template, attributes) ->
            console.log 'property:acl render'
            htmlTpl = Handlebars.compile template

            $('#acl-secondary-panel-wrap').html htmlTpl(attributes)

            this.instance_expended_id = expended_accordion_id

            secondary_panel_wrap = $('#acl-secondary-panel-wrap')

            fixedaccordion.resize()

            secondary_panel_wrap.animate({
                right: 0
            }, {
                duration: 200,
                specialEasing: {
                    width: 'linear'
                },
                complete : () ->

                }
            )

        returnMainPanel : () ->
            me = this
            console.log 'returnMainPanel'
            secondary_panel_wrap = $('#acl-secondary-panel-wrap')
            secondary_panel_wrap.animate({
                right: "-280px"
            }, {
                duration: 200,
                specialEasing: {
                    width: 'linear'
                },
                complete : () ->
                    # ide_event.trigger ide_event.OPEN_PROPERTY, 'component', $('#sg-secondary-panel').attr('parent'), me.instance_expended_id
                }
            )

        showCreateRuleModal : () ->
            modal MC.template.modalAddACL {}, true
            scrollbar.init()
            return false
    }

    view = new ACLView()

    return view