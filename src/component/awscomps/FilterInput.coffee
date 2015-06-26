define [ 'constant', 'Design', 'component/awscomps/FilterInputTpl' ], ( constant, Design, template) ->

    ResNameToType = _.invert constant.RESNAME

    DefaultValues = {
      Empty         : '(empty)'
      NotTagged     : 'Not tagged'
      AllValues     : 'All values'
      AllAttributes : 'All Attributes'
    }

    filterInput = Backbone.View.extend
      className: "filter-input"
      tplDropdown: template.dropdown
      tplTag: template.tag
      selection: []
      events:
        "click .tags li"            : "clickTagHandler"
        "blur input"                : "blurInputHandler"
        "focus input"               : "focusInputHandler"
        "click input"               : "clickInputHandler"
        "click .fake-input"         : "clickFakeInputHandler"
        "keydown input"             : "keydownHandler"
        "keyup input"               : "keyupHandler"
        "click .dropdown li.option" : "selectHandler"
        "mouseover .dropdown"       : "overDrop"
        "mouseleave .dropdown"      : "leaveDrop"
        "mouseover .dropdown li"    : "overDropItem"

      valueModeRegex: /^[a-zA-Z0-9]+\s*[=:]\s*$/

      seperate: (str, sep) ->
        pos = str.indexOf(sep)

        if pos is -1 then return false

        tmp = str.split(sep)
        before = tmp[0]
        after = tmp[1]

        { before: before, after: after, pos: pos }

      getState: (value) ->
        input = @$("input").get(0)
        text = input.value
        subKey = null
        state = 'value'

        equalSplit = @seperate text, '='

        key = equalSplit?.before or text
        value = equalSplit?.after or ''

        tagSplit = @seperate key, 'tag:'
        dotSplit = @seperate key, '.'


        if tagSplit
          mode = 'tag'
          key = tagSplit.after
        else if dotSplit
          mode = 'resource.attribute'
          key = dotSplit.before
          subKey = dotSplit.after
        else
          mode = 'resource'
          subKey = ''

        cursorPos = input.selectionStart

        if equalSplit and cursorPos > equalSplit.pos
          state = 'value'
        else
          state = mode

        mode: mode
        state: state
        key: key
        subKey: subKey
        value: value
        effect: if state is 'value' then value else key

      getTags: ->
        @selection

      initialize: (options) ->
        @selection = options.selection  if options and options.selection
        null

      render: ->
        tpl = template.frame
        @$el.html tpl
        @renderTag()
        @

      renderDropdown: ->
        state = @getState()
        filter = state.effect

        data = @getDropdownData(state.state, state.key, state.subKey)
        data = @filterByInput(data, filter)
        @$(".dropdown").html @tplDropdown data
        @

      removeDropdown: ->
        @$(".dropdown").html ""

      renderTag: ->
        @$(".tags").html @tplTag @selection
        @

      renderLineTip: ($fakeInput) ->
        $fakeInput = $fakeInput or @$(".fake-input")
        $li = @$(".tags li").first()

        unless $li.size() then return

        computedStyle = window.getComputedStyle($li[0])
        liHeight = $li.outerHeight() + parseInt(computedStyle.marginTop) + parseInt(computedStyle.marginBottom)
        line = Math.floor($fakeInput[0].scrollHeight / liHeight)
        hideLine = line - 1

        if not hideLine or hideLine < 1
          @$(".line-tip").text ""
        else
          @$(".line-tip").text "(+" + hideLine + ")"

      addTag: (key, value) ->
        switch arguments.length
          when 0
            key = @$("input").val()
          when 1
            split = undefined
            tmp = undefined
            if key.indexOf("=") > -1
              split = "="
            else if key.indexOf(":") > -1
              split = ":"
            else
              return @
            tmp = key.split(split)
            key = tmp[0].trim()
            value = tmp[1].trim()
        tag =
          key: key
          value: value

        return @ unless value
        @clearInput()
        return @ if _.some(@selection, (t) ->
          _.isEqual t, tag
        )
        @selection.push tag
        @renderTag()
        @

      removeTag: ($tag) ->
        return  unless $tag.size()
        tag =
          key: $tag.data("key")
          value: $tag.data("value").toString()

        @selection = _.filter(@selection, (t) ->
          t.key isnt tag.key or t.value isnt tag.value
        )
        $tag.remove()

      removeLastTag: ->
        $last = @$(".tags li").last()
        @removeTag $last

      getDropdownData: (state, key, subKey) ->
        if state is 'value'
          if subKey
            @getAttributeValueDd(key, subKey)
          else
            @getTagValueDd(key)
        else
          if subKey
            @getAttributeDd(key)
          else
            @getTagKeyDd().concat(@getResourceDd())


      uniqSortDd: (dd) -> _.sortBy (_.uniq dd, (d) -> d.value), 'value'

      getAttributeDd: ( resName ) ->
        type = ResNameToType[ resName ]
        unless type then return

        attrs = []
        _.each Design.modelClassForType(type).first().serialize().resource, ( v, k ) ->
          unless _.isObject(v) then attrs.push(k)

        dd = _.map attrs, (a) ->
          { type: 'attribute', value: a }

        dd = @uniqSortDd dd

        dd.unshift { type: 'default', value: DefaultValues.AllAttributes }
        dd.unshift { type: 'label', value: 'Attributes', for: 'attribute' }

        dd

      getResourceDd: ->
        resources = []
        Design.instance().eachComponent (component) ->
          if component.isVisual() and !component.port
            resources.push component

        dd = _.map resources, (r) ->
          { id: r.id, type: 'resource', value: constant.RESNAME[r.type] }

        dd = @uniqSortDd dd
        dd.unshift { type: 'label', value: 'Resources', for: 'resource' }

        dd

      getTagKeyDd: ->
        tags = Design.modelClassForType(constant.RESTYPE.TAG).all()
        dd = _.map tags, (tag) ->
          { id: tag.id, type: 'tag.key', value: tag.get('key') }

        dd = @uniqSortDd dd
        dd.unshift { type: 'label', value: 'Tag Keys', for: 'tag.key' }

        dd

      getTagValueDd: (tagKey) ->
        tags = Design.modelClassForType(constant.RESTYPE.TAG).all()
        matchTags = _.filter tags, (tag) -> tag.get('key') is tagKey
        dd = _.map matchTags, (tag) ->
          { id: tag.id, type: 'tag.value', value: tag.get('value') }

        for defaultTag in [ DefaultValues.AllValues, DefaultValues.NotTagged, DefaultValues.Empty ]
          dd.unshift { type: 'default', value: defaultTag }

      getAttributeValueDd: ( resource, attr ) ->

      focusInput: ($input) ->
        ($input or @$("input")).focus()

      clearInput: ($input) ->
        ($input or @$("input")).val ""

      getMatchItemIndex: () ->


      wrapDropdown: ->

      filterByInput: (data, filter) ->
        filter = filter and filter.trim().toLowerCase()

        setSelected = false
        filtered = []

        _.each data, (d) ->
          d.text = d.value
          if d.type is 'label'
            hasLabelType = _.some data, (dd) -> dd.type is d.for
            if hasLabelType then filtered.push d
          else if not filter or (matchIdx = d.value.toLowerCase().indexOf(filter)) > -1
            unless setSelected then d.selected = setSelected = true

            if matchIdx > -1
              match = d.value.slice(matchIdx, matchIdx + filter.length)
              d.text = d.text.replace(match, "<span class=\"match\">" + match + "</span>")

            filtered.push d

        filtered

      fold: (force) ->
        that = @
        unless @hoverDrop
          that.$(".dropdown").empty()
        else if force is true
          @hoverDrop = false
          @fold()

      # ## Event Handler
      overDrop: ->
        @hoverDrop = true
        null

      leaveDrop: ->
        @hoverDrop = false
        null

      overDropItem: (e) ->
        $tgt = $(e.currentTarget)
        @$(".dropdown li").removeClass "selected"
        $tgt.addClass "selected"

      clickTagHandler: (e) ->
        $tgt = $(e.currentTarget)
        @removeTag $tgt

      keyupHandler: (e) ->
        code = e.which
        $input = $(e.currentTarget)
        unless ( _.contains([27, 38, 40], code) )
          @renderDropdown()

      keydownHandler: (e) ->
        code = e.which
        $input = $(e.currentTarget)
        switch code
          when 8 # Delete
            if $input[0].selectionStart is 0
              @removeLastTag()
              @focusInput()

          when 13 # Enter
            dropdown = @$(".dropdown")
            if dropdown.children().size()
              @selectHandler currentTarget: dropdown.find(".selected")
            else
              @addTag $input.val()
          when 27 # Esc
            @fold()
          when 38 # Up
            $selected = @$(".dropdown .selected")
            $prev = $selected.prev('.option')
            if $prev.size()
              dropdown = @$(".dropdown")
              $dropdown[0].scrollTop -= $prev.outerHeight()  if $prev.position().top < 0
              $selected.removeClass "selected"
              $prev.addClass "selected"
            false
          when 40 # Down
            $selected = @$(".dropdown .selected")
            $next = $selected.next('.option')
            if $next.size()
              $dropdown = @$(".dropdown")
              $dropdown[0].scrollTop += $next.outerHeight()  if $next.position().top >= $dropdown.outerHeight()
              $selected.removeClass "selected"
              $next.addClass "selected"
            false

      focusInputHandler: ->
        clearTimeout @timeoutRemoveFocus
        @renderDropdown()
        @$(".fake-input").addClass "focus"

      blurInputHandler: ->
        that = @
        @timeoutRemoveFocus = setTimeout ->
          that.fold()
          that.removeDropdown()
          $fakeInput = that.$(".fake-input")
          $fakeInput.removeClass "focus"
          that.renderLineTip $fakeInput
        , 180

        null

      clickInputHandler: (e) ->
        @renderDropdown()
        false

      clickFakeInputHandler: (e) ->
        $(e.currentTarget).addClass "focus"
        @$("input").focus()

      selectHandler: (e) ->
        @focusInput()
        $tgt = $(e.currentTarget)
        $input = @$("input")
        type = $tgt.data('type')

        state = @getState()

        if state.state is 'value'
          key = state.key + if state.subKey then ".#{state.subKey}" else ''
          @addTag key + " = " + $tgt.data('value')
        else
          key = $tgt.data('value')
          if type is 'attribute'
            subKey = key
            key = state.key
          else if type is 'resource'
            key = key + '.'
          else
            key = "tag:#{key} = "

          $input.val(key)

        @renderDropdown()


    filterInput