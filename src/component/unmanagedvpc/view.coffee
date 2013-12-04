#############################
#  View(UI logic) for component/unmanagedvpc
#############################

define [ 'event',
         'text!./component/unmanagedvpc/template.html',
         'backbone', 'jquery', 'handlebars',
         'UI.modal'
], ( ide_event, template ) ->

    UnmanagedVPCView = Backbone.View.extend {

        events   :
            'closed' : 'closedPopup'
            'click .unmanaged-VPC-resource-item' : 'resourceItemClickEvent'

        render     :  ->
            console.log 'pop-up:unmanaged vpc render'

            # popup
            modal template, true

            # set element
            @setElement $( '#unmanaged-VPC-modal-body' ).closest '#modal-wrap'

            null

        closedPopup : ->
            console.log 'closedPopup'
            @trigger 'CLOSE_POPUP'

        resourceItemClickEvent : ( event ) ->
            console.log 'resourceItemClickEvent', event

            # push OPEN_DESIGN_TAB
            ide_event.trigger ide_event.OPEN_DESIGN_TAB, 'NEW_APPVIEW', 'vpc-1222232', 'ap-northeast-1', 'vpc-1222232'

            # close
            @closedPopup()

            # modal.close()
            modal.close()

            null

    }

    return UnmanagedVPCView