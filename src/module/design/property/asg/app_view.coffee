#############################
#  View(UI logic) for design/property/instance(app)
#############################

define [ '../base/view',
         'text!./template/app.html',
         'i18n!nls/lang.js',
         'UI.zeroclipboard'
], ( PropertyView, template, lang, zeroclipboard )->

    template = Handlebars.compile template

    ASGAppEditView = PropertyView.extend {
        events   :
            "change #property-asg-min"      : "setSizeGroup"
            "change #property-asg-max"      : "setSizeGroup"
            "change #property-asg-capacity" : "setSizeGroup"

        render : () ->
            @$el.html template @model.attributes

            $name = $( "#property_app_asg .icon-copy" )
            if $name.length
                zeroclipboard.copy $name

            @model.attributes.name


        setSizeGroup: ( event ) ->
            $min        = @$el.find '#property-asg-min'
            $max        = @$el.find '#property-asg-max'
            $capacity   = @$el.find '#property-asg-capacity'

            $min.parsley 'custom', ( val ) =>
                if + val < 1
                    return 'ASG size must be equal or greater than 1'
                if + val > + $max.val()
                    return 'Minimum Size must be <= Maximum Size.'

            $max.parsley 'custom', ( val ) =>
                if + val < 1
                    return 'ASG size must be equal or greater than 1'
                if + val < + $min.val()
                    return 'Minimum Size must be <= Maximum Size'

            $capacity.parsley 'custom', ( val ) ->
                if + val < 1
                    return 'Desired Capacity must be equal or greater than 1'
                if + val < + $min.val() or + val > + $max.val()
                    return 'Desired Capacity must be >= Minimal Size and <= Maximum Size'

            if $( event.currentTarget ).parsley 'validateForm'
                @trigger 'SET_ASG_MIN', $min.val()
                @trigger 'SET_ASG_MAX', $max.val()
                @trigger 'SET_DESIRE_CAPACITY', $capacity.val()
    }

    new ASGAppEditView()
