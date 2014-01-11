#############################
#  View(UI logic) for component/statestatus
#############################

define [ 'event',
         'text!./template.html',
         'backbone', 'jquery', 'handlebars'
], (ide_event, template) ->

    StateStatusView = Backbone.View.extend {

        el: '#status-bar-modal'

        events:
            'click .modal-close': 'closedPopup'

        initialize: () ->

            this.compileTpl()

        render: () ->

            that = this
            that.$statusModal = @$el

            that.$statusModal.html(that.statusModalTpl({}))
            that.$statusModal.find('.modal-state-statusbar').html that.statusContentTpl({})
            that.$stateStatusList = that.$statusModal.find('.state-status-list')

            that.$statusModal.show()
            that.refreshStateStatusList()
            null

        compileTpl: () ->

            # generate template
            tplRegex = /(\<!-- (.*) --\>)(\n|\r|.)*?(?=\<!-- (.*) --\>)/ig
            tplHTMLAry = template.match(tplRegex)
            htmlMap = {}
            _.each tplHTMLAry, (tplHTML) ->
                commentHead = tplHTML.split('\n')[0]
                tplType = commentHead.replace(/(<!-- )|( -->)/g, '')
                htmlMap[tplType] = tplHTML
                null

            stateStatusModalHTML = htmlMap['statestatus-template-modal']
            stateStatusContentHTML = htmlMap['statestatus-template-status-content']
            stateStatusItemHTML = htmlMap['statestatus-template-status-item']

            Handlebars.registerPartial('statestatus-template-status-item', stateStatusItemHTML)

            this.statusModalTpl = Handlebars.compile(stateStatusModalHTML)
            this.statusContentTpl = Handlebars.compile(stateStatusContentHTML)
            this.statusItemTpl = Handlebars.compile(stateStatusItemHTML)

        refreshStateStatusList: () ->

            that = this
            stateStatusDataAry = that.model.get('stateStatusDataAry')

            stateStatusViewAry = []
            _.each stateStatusDataAry, (statusObj) ->
                stateStatusViewAry.push({
                    # state_id: "State #{logObj.state_id}",
                    # log_time: logObj.time,
                    # stdout: logObj.stdout,
                    # stderr: logObj.stderr
                })
                null

            renderHTML = that.statusItemTpl({
                state_statuses: stateStatusViewAry
            })

            that.$stateStatusList.html(renderHTML)

        closedPopup : ->

            that = this
            if that.$statusModal.html()
                that.$statusModal.empty()
                that.trigger 'CLOSE_POPUP'
                that.$statusModal.hide()
    }

    return StateStatusView