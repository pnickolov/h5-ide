#############################
#  View(UI logic) for design/property/acl(app)
#############################

define [ '../base/view',
         'text!./template/app.html'
], ( PropertyView, template ) ->

    template = Handlebars.compile template

    ACLAppView = PropertyView.extend {

        events    :
            'OPTION_CHANGE #acl-sort-rule-select' : 'sortACLRule'

        render     : () ->
            @$el.html template @model.attributes
            @model.attributes.component.name

        sortACLRule : ( event ) ->
            sg_rule_list = $('#acl-rule-list')

            sortType = $(event.target).find('.selected').attr('data-id')

            sorted_items = $('#acl-rule-list li')

            if sortType is 'number'
                sorted_items = sorted_items.sort(this._sortNumber)
            else if sortType is 'action'
                sorted_items = sorted_items.sort(this._sortAction)
            else if sortType is 'direction'
                sorted_items = sorted_items.sort(this._sortDirection)
            else if sortType is 'source/destination'
                sorted_items = sorted_items.sort(this._sortSource)

            sg_rule_list.html sorted_items

        _sortNumber : ( a, b) ->
            valueA = $(a).find('.acl-rule-number').attr('data-id')
            valueB = $(b).find('.acl-rule-number').attr('data-id')
            if valueA is '*' then valueA = 0
            if valueB is '*' then valueB = 0
            return Number(valueA) > Number(valueB)

        _sortAction : ( a, b) ->
            return $(a).find('.acl-rule-action').attr('data-id') >
                $(b).find('.acl-rule-action').attr('data-id')

        _sortDirection : ( a, b) ->
            return $(a).find('.acl-rule-direction').attr('data-id') >
                $(b).find('.acl-rule-direction').attr('data-id')

        _sortSource : ( a, b) ->
            return $(a).find('.acl-rule-reference').attr('data-id') >
                $(b).find('.acl-rule-reference').attr('data-id')

    }

    new ACLAppView()
