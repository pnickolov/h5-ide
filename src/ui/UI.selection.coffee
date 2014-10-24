define ['UI.selectize'], () ->

    initSelection = ($valueDom, selectTpl, validationInstance) ->

        return if (not $valueDom or not $valueDom.length)

        if not $valueDom.hasClass('selectized')

            mutil = false
            maxItems = undefined
            if $valueDom.hasClass('dropdown') then return false
            if $valueDom.hasClass('mutil')
                mutil = true
                maxItems = null

            if $valueDom.hasClass('bool')

                $valueDom.selectize({
                    multi: mutil,
                    maxItems: maxItems,
                    persist: true,
                    valueField: 'value',
                    labelField: 'text',
                    searchField: ['text'],
                    create: false,
                    openOnFocus: false,
                    plugins: ['custom_selection'],
                    onInitialize: () ->
                        value = @$input.attr('value')
                        @setValue(value.split(','), true) if value
                        $valueDom.trigger 'selectized', @
                    options: [
                        {text: 'True', value: 'true'},
                        {text: 'False', value: 'false'}
                    ],
                    render: {
                        option: (item) ->
                            return '<div>' + item.text + '</div>'
                        item: (item) ->
                            return '<div>' + item.text + '</div>'
                    }
                })

            if $valueDom.hasClass('option')

                create = false
                validHandleName = $valueDom.data('valid-handle')
                if validHandleName and selectTpl and selectTpl[validHandleName]
                    validHandle = selectTpl[validHandleName]
                    create = true if validHandle

                $valueDom.selectize({
                    multi: mutil,
                    maxItems: maxItems,
                    persist: true,
                    create: create,
                    createOnBlur: create,
                    openOnFocus: false,
                    plugins: ['custom_selection']
                    onInitialize: () ->
                        value = @$input.attr('value')
                        @setValue(value.split(','), true) if value
                        $valueDom.trigger 'selectized', @
                    validHandle: validHandle
                    render: {
                        option: (item) ->
                            tplName = @$input.data('option-tpl')
                            if tplName and selectTpl and selectTpl[tplName]
                                return selectTpl[tplName].call(@$input, item)
                            else
                                return '<div>' + item.text + '</div>'

                        item: (item) ->
                            tplName = @$input.data('item-tpl')
                            if tplName and selectTpl and selectTpl[tplName]
                                return selectTpl[tplName].call(@$input, item)
                            else
                                return '<div>' + item.text + '</div>'
                        button: () ->
                            tplName = @$input.data('button-tpl')
                            if tplName and selectTpl and selectTpl[tplName]
                                return selectTpl[tplName].call(@$input)
                            else
                                return null
                    }
                    createFilter: (value) ->
                        return validHandle.call(@$input, value) if validHandle
                        return false
                })

            if validationInstance and $valueDom.is('input, textarea')

                $valueDom.attr('data-selection-id', MC.guid())
                $valueDom.selectionValid(validationInstance)

    listenSelectionInserted = ($parent, selectTpl, validationInstance) ->

        $parent.off('DOMNodeInserted').on 'DOMNodeInserted', (event) ->

            $target = $(event.target)
            $target.find('select.selection, input').each () ->
                initSelection($(@), selectTpl, validationInstance)
            if ($target[0].nodeName is 'SELECT' or $target[0].nodeName is 'INPUT') and $target.hasClass('.selection')
                initSelection($target, selectTpl, validationInstance)

    listenSelectionInserted.unbind = ($parent, selectTpl) ->
        $parent.unbindSelection()

    return listenSelectionInserted
