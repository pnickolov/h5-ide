define ['backbone', '../template/TplMember', 'UI.selectbox'], (Backbone, TplMember) ->

    Backbone.View.extend

        events:

            'change #t-m-select-all': '__checkAll'
            'change .one-cb': '__checkOne'
            'click #invite': 'inviteMember'
            'click #delete': 'delMember'
            'click #done': 'doneModify'
            'click #edit': 'enterModify'
            'click #cancle': 'cancleInvite'


        className: 'member-setting'

        initialize: () ->

            @render()

        render: () ->

            @$el.html TplMember.main(
                {
                    columns: [
                        {
                            sortable: true
                            name: "Member"
                        },
                        {
                            sortable: true
                            rowType: 'datetime'
                            width: "15%"
                            name: "Role"
                        },
                        {
                            sortable: true
                            width: "10%"
                            name: "Status"
                        },
                        {
                            sortable: false
                            width: "20%"
                            name: ""
                        },
                        {
                            sortable: false
                            width: "150px"
                            name: "Edit"
                        }
                    ]
                }
            )
            @memList = @$el.find('.t-m-content')
            @renderList()
            @$el

        renderList: () ->

            @memList.html TplMember.list([
                {
                    id: "1"
                    avatar: ""
                    name: "John Doe"
                    mail: "id@mc2.io"
                    role: "ADMIN"
                    status: "Active"
                },
                {
                    id: "2"
                    avatar: ""
                    name: "John Doe"
                    mail: "id@mc2.io"
                    role: "ADMIN"
                    status: "Active"
                },
                {
                    id: "3"
                    avatar: ""
                    name: "John Doe"
                    mail: "id@mc2.io"
                    role: "ADMIN"
                    status: "Active"
                }
            ])

        enterModify: (event) ->

            $memItem = $(event.currentTarget).parents('.memlist-item')
            $memItem.addClass('edit')

        doneModify: (event) ->

            $memItem = $(event.currentTarget).parents('.memlist-item')
            $memItem.removeClass('edit')

        # follow code ref from toolbarModal
        __checkOne: ( event ) ->

            $target = $ event.currentTarget
            cbAll = @$ '#t-m-select-all'
            cbAmount = @$('.one-cb').length
            checkedAmount = @$('.one-cb:checked').length
            $target.closest('tr').toggleClass 'selected'

            if checkedAmount is cbAmount
                cbAll.prop 'checked', true
            else if cbAmount - checkedAmount is 1
                cbAll.prop 'checked', false
            @__processDelBtn()

        __checkAll: ( event ) ->

            if event.currentTarget.checked
                @$('input[type="checkbox"]:not(:disabled)').prop 'checked', true
                .parents('tr.item').addClass 'selected'
            else
                @$('input[type="checkbox"]').prop 'checked', false
                @$('tr.item').removeClass 'selected'

            @__processDelBtn()

        __processDelBtn: () ->

            that = @
            if that.$('.one-cb:checked').length
                that.$('#delete').prop 'disabled', false
            else
                that.$('#delete').prop 'disabled', true

        getChecked: () ->

            allChecked = @$('.one-cb:checked')
            checkedInfo = []
            allChecked.each () ->
                checkedInfo.push id: @id, value: @value, data: $(@).data()

            checkedInfo
