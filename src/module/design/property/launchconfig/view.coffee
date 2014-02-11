#############################
#  View(UI logic) for design/property/instacne
#############################

define [ '../base/view', 'text!./template/stack.html', 'event' ], ( PropertyView, template, ide_event ) ->

    template = Handlebars.compile template

    LanchConfigView = PropertyView.extend {

        events   :
            'change .launch-configuration-name'           : 'lcNameChange'
            'change .instance-type-select'                : 'instanceTypeSelect'
            'change #property-instance-ebs-optimized'     : 'ebsOptimizedSelect'
            'change #property-instance-enable-cloudwatch' : 'cloudwatchSelect'
            'change #property-instance-user-data'         : 'userdataChange'
            'change #property-instance-public-ip'         : 'publicIpChange'
            'OPTION_CHANGE #instance-type-select'         : "instanceTypeSelect"
            'OPTION_CHANGE #keypair-select'               : "setKP"
            'EDIT_UPDATE #keypair-select'                 : "addKP"
            "EDIT_FINISHED #keypair-select"               : "updateKPSelect"

            'click #property-ami'                         : 'openAmiPanel'

        render : () ->

            @$el.html template @model.attributes

            $( "#keypair-select" ).on("click", ".icon-remove", _.bind(this.deleteKP, this) )

            @model.attributes.name

        publicIpChange : ( event ) ->
            @model.setPublicIp event.currentTarget.checked
            null

        lcNameChange : ( event ) ->
            target = $ event.currentTarget
            name = target.val()

            if @checkResName( target, "LaunchConfiguration" )
                @model.setName name
                @setTitle name
            null

        instanceTypeSelect : ( event, value )->

            has_ebs = @model.setInstanceType value
            $ebs = $("#property-instance-ebs-optimized")
            $ebs.closest(".property-control-group").toggle has_ebs
            if not has_ebs
                $ebs.prop "checked", false

        ebsOptimizedSelect : ( event ) ->
            @model.setEbsOptimized event.target.checked
            null

        cloudwatchSelect : ( event ) ->
            @model.setCloudWatch event.target.checked
            $("#property-cloudwatch-warn").toggle( $("#property-instance-enable-cloudwatch").is(":checked") )

        userdataChange : ( event ) ->
            @model.setUserData event.target.value

        setKP : ( event, id ) ->
            @model.setKP id

        addKP : ( event, id ) ->
            result = @model.addKP id
            if not result
                notification "error", "KeyPair with the same name already exists."
                return result

        updateKPSelect : () ->
            # Add remove icon to the newly created item
            $("#keypair-select").find(".item:last-child").append('<span class="icon-remove"></span>')

        openAmiPanel : ( event ) ->
            @trigger "OPEN_AMI", $("#property-ami").attr("data-uid")
            null

        deleteKP : ( event ) ->
            me = this
            $li = $(event.currentTarget).closest("li")

            selected = $li.hasClass("selected")
            using = if using is "true" then true else selected

            removeKP = () ->

                $li.remove()
                # If deleting selected kp, select the first one
                if selected
                    $("#keypair-select").find(".item").eq(0).click()


                me.model.deleteKP $li.attr("data-id")


            if using
                data =
                    title   : "Delete Key Pair"
                    confirm : "Delete"
                    color   : "red"
                    body    : "<p class='modal-text-major'>Are you sure to delete #{$li.text()}?</p><p class='modal-text-minor'>Resources using this key pair will change automatically to use DefaultKP.</p>"
                # Ask for confirm
                modal MC.template.modalApp data
                $("#btn-confirm").one "click", ()->
                    removeKP()
                    modal.close()
            else
                removeKP()

            return false
    }

    new LanchConfigView()
