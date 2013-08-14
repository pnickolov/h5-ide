
####################################
#  Base Class for Property Module
####################################

define [ 'event', 'backbone' ], ( event )->

    activeModule    = null
    activeSubModule = null
    slice           = [].slice

    # Bind an event listener to ide_event,
    # Then dispatch the event to the current active property modul
    ide_event.onLongListen "all", ( eventName ) ->
        if not activeModule or not activeModule.ideEvents
            return

        if not activeModule.ideEvents.hasOwnProperty eventName
            return

        args    = slice.call arguments, 1
        handler = activeModule.ideEvents[ eventName ]

        if _.isString handler
            handler = activeModule[ handler ]
        handler.apply activeModule, args

        # Delegate to sub module
        if not activeSubModule
            return

        handler = activeSubModule.ideEvents[ eventName ]

        if _.isString handler
            handler = activeSubModule[ handler ]
        handler.apply activeSubModule, args

        null

    # TODO : Set activeSubModule to null, when :
    # 1. Second panel is hidden
    # 2. Tag switch to another one.
    ide_event.onLongListen "HIDE_SECOND_PANEL", ()->
        activeSubModule = null
        null


    PropertyModule = () ->

        # ideEvents is a map, can be :
        # ide_event.ABC : "functionNameOfModule"
        # ide_event.DEF : () -> null

        ideEvents : null

        type      : "Stack" # Can be "Stack" or "App"

        isSub     : false # If true, this Module is meaned to be used as sub panel, or part of another module
                          # For example, sglist / acl / sgrule should set this to true

        doInit : ( type ) ->

            # When the Module is loaded the first time.
            # Call init...() of the Module
            # If there's no init...(), fallback to init()
            initProc = "init#{type}"

            # Initialization involves but not limited to :
            # 1. Create Modal / Create View
            # 2. Wired up Modal to View

            if this[initProc]
                this[initProc].call( this )
                this[initProc] = null
            else
                this.init()
                this.init = null

            null


        doLoad : ( componentUid, tab_type ) ->

            # Set this type
            type = this.type = if tab_type is "OPEN_APP" then "Stack" else "App"

            # This might be the first time we load the module,
            # So init it.
            this.doInit type

            if this.isSub
                activeSubModule = this
            else
                activeSubModule = null
                activeModule    = this

            # Call subclass's load...() or load() to :
            # set their `modal` and `view`
            loadProc = "load#{type}"
            if this[loadProc]
                this[loadProc].call( this )
            else
                this.load()


            # Then we do some re-init for the `modal` and `view` here.
            # Re-init the modal
            this.modal.init componentUid

            # Re-init the view
            this.view.modal = this.modal

            if this.isSub
                this.view._loadAsSub()
                # Trigger a event, so that Property/View can open the panel for us.
                ide_event.trigger ide_event.PROPERTY_OPEN_SUBPANEL
            else
                this.view._load()

            null


    # Use Backbone's extend to setup inheritance
    PropertyModule.extend = Backbone.Model.extend

    # Export PropertyModule
    PropertyModule

