#############################
#  View(UI logic) for design/property/eni
#############################

define [ '../base/view',
         'text!./template/stack.html',
         'i18n!nls/lang.js'
], ( PropertyView, template, lang ) ->

    template = Handlebars.compile template

    ENIView = PropertyView.extend {

        events   :
            "change #property-eni-desc"             : "setEniDesc"
            "change #property-eni-source-check"     : "setEniSourceDestCheck"

            'click .toggle-eip'                     : 'setEIP'
            'click #property-eni-ip-add'            : "addIP"
            'click #property-eni-list .icon-remove' : "removeIP"
            'blur .input-ip'                        : 'syncIPList'

        render     : () ->
            @$el.html( template( @model.attributes ) )

            @refreshIPList()

            @model.attributes.name

        setEniDesc : ( event ) ->
            @model.setEniDesc event.target.value
            null

        setEniSourceDestCheck : ( event ) ->
            @model.setSourceDestCheck event.target.checked
            null

        addIP : () ->
            if $("#property-eni-ip-add").hasClass("disabled")
                return

            data = @model.addIP()
            $('#property-eni-list').append MC.template.propertyIpListItem( data )
            @updateIPAddBtnState()
            null

        setEIP : ( event ) ->
            $target = $(event.currentTarget)
            index   = $target.closest("li").index()
            attach  = not $target.hasClass("associated")

            @model.attachEIP index, attach
            null

        removeIP : (event) ->

            $li = $(event.currentTarget).closest("li")
            index = $li.index()
            $li.remove()

            @model.removeIP index
            @updateIPAddBtnState()
            null


        syncIPList : (event) ->
            currentAvailableIPAry = _.map $('#property-eni-list li'), (ipInputItem) ->
                $item   = $(ipInputItem)
                prefix  = $item.find(".input-ip-prefix").text()
                value   = $item.find(".input-ip").val()
                has_eip = $item.find(".input-ip-eip-btn").hasClass("associated")

                {
                    ip  : prefix + value
                    eip : has_eip
                }

            @model.setIPList currentAvailableIPAry
            null

        refreshIPList : ( event ) ->
            html = ""
            for ip in @model.attributes.ips
                html += MC.template.propertyIpListItem ip

            $( '#property-eni-list' ).html( html )
            @updateIPAddBtnState()
            null

        updateIPAddBtnState : () ->
            enabled = @model.canAddIP()

            if enabled is true
                tooltip = "Add IP Address"
            else
                if _.isString enabled
                    tooltip = enabled
                else
                    tooltip = "Cannot add IP address"
                enabled = false

            $("#property-eni-ip-add").toggleClass("disabled", !enabled).data("tooltip", tooltip)
            null

    }

    new ENIView()
