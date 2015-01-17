define ['backbone', '../template/TplMember'], (Backbone, TplMember) ->

    Backbone.View.extend

        events:

            'change #t-m-select-all': '__checkAll'
            'change .one-cb': '__checkOne'

        className: 'member-setting'

        initialize: () ->

            @render()

        render: () ->

            @$el.html TplMember.main(
                {
                    columns: [
                        {
                            sortable: true
                            width: "50%"
                            name: "Member"
                        },
                        {
                            sortable: true
                            rowType: 'datetime'
                            width: "33%"
                            name: "Role"
                        },
                        {
                            sortable: true
                            name: "Status"
                        },
                        {
                            sortable: false
                            name: "Edit"
                        }
                    ]
                })
            @renderList()
            @$el

        renderList: () ->

            @$el.find('.t-m-content').html TplMember.list([
                {
                    avatar: ""
                    name: "John Doe"
                    mail: "id@mc2.io"
                    role: "ADMIN"
                    status: "Active"
                },
                {
                    avatar: ""
                    name: "John Doe"
                    mail: "id@mc2.io"
                    role: "ADMIN"
                    status: "Active"
                },
                {
                    avatar: ""
                    name: "John Doe"
                    mail: "id@mc2.io"
                    role: "ADMIN"
                    status: "Active"
                }
            ])

        # follow code ref from toolbarModal
        __checkOne: ( event ) ->

            $target = $ event.currentTarget
            @__processDelBtn()
            cbAll = @$ '#t-m-select-all'
            cbAmount = @$('.one-cb').length
            checkedAmount = @$('.one-cb:checked').length
            $target.closest('tr').toggleClass 'selected'

            if checkedAmount is cbAmount
                cbAll.prop 'checked', true
            else if cbAmount - checkedAmount is 1
                cbAll.prop 'checked', false

            @__triggerChecked event

        __checkAll: ( event ) ->

            @__processDelBtn()
            if event.currentTarget.checked
                @$('input[type="checkbox"]:not(:disabled)').prop 'checked', true
                .parents('tr.item').addClass 'selected'
            else
                @$('input[type="checkbox"]').prop 'checked', false
                @$('tr.item').removeClass 'selected'

            @__triggerChecked event

        __triggerChecked: ( param ) ->

            @trigger 'checked', param, @getChecked()

        getChecked: () ->

            allChecked = @$('.one-cb:checked')
            checkedInfo = []
            allChecked.each () ->
                checkedInfo.push id: @id, value: @value, data: $(@).data()

            checkedInfo
