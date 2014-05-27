define ["CloudResources", 'constant','combo_dropdown', 'toolbar_modal', 'i18n!nls/lang.js'], ( CloudResources, constant, comboDropdown, toolbarModal, lang )->

    sslCertView = Backbone.View.extend

        # constructor:->
        #     # @render()

        getModalOptions: ->

            that = @

            title: "Manage SSL Cert"
            context: that
            buttons: [
                {
                    icon: 'new-stack'
                    type: 'create'
                    name: 'Create Key Pair'
                }
                {
                    icon: 'import'
                    type: 'import'
                    name: 'Import Key Pair'
                }
                {
                    icon: 'del'
                    type: 'delete'
                    disabled: true
                    name: 'Delete'
                }
                {
                    icon: 'refresh'
                    type: 'refresh'
                    name: ''
                }
            ]
            columns: [
                {
                    sortable: true
                    width: "100px" # or 40%
                    name: 'Name'
                }
                {
                    sortable: false
                    width: "100px" # or 40%
                    name: 'Fingerprint'
                }
            ]

        initModal: () ->

            @modal = new toolbarModal @getModalOptions()
            @modal.render()

        render: ->

            @initModal()

    sslCertView