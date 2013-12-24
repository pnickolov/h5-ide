#############################
#  View(UI logic) for design/property/sgrule
#############################

define [ '../base/view',
         'text!./template/stack.html',
         'text!./template/app.html'
], ( PropertyView, template, app_template ) ->

    template     = Handlebars.compile template
    app_template = Handlebars.compile app_template

    SgRuleView = PropertyView.extend {
        events   :
            "click #sg-edit-rule-button" : "onEditRule"

        render : () ->
            tpl = if @model.isApp then app_template else template

            for group in @model.attributes.groups
                group.ruleListTpl = MC.template.sgRuleList( group.rules )

            @$el.html tpl @model.attributes

            "Security Group Rule"

        onEditRule : ( event ) ->
            this.trigger "EDIT_RULE"
            null

    }

    new SgRuleView()
