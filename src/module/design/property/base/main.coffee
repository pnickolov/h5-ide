
####################################
#  Base Class for Property Module
####################################

define [ 'event', 'backbone' ], ( event )->

    activeModule        = null
    activeSubModule     = null
    activeModuleType    = null
    activeSubModuleType = null
    slice               = [].slice

    # Bind an event listener to ide_event,
    # Then dispatch the event to the current active property modul
    ide_event.onLongListen "all", ( eventName ) ->

        # Current property-pane and sub-property-pane are not interested in ideEvents at all
        if ( not activeModule or not activeModule.ideEvents ) and ( not activeSubModule or not activeSubModule.ideEvents )
           return

        # Current property-pane are insterested in current ideEvent, dispatch
        if activeModule and activeModule.ideEvents and activeModule.ideEvents.hasOwnProperty eventName

            args    = slice.call arguments, 1
            handler = activeModule.ideEvents[ eventName ]
            if _.isString handler
                handler = activeModule[ handler ]
            handler.apply activeModule, args

        # Current sub-property-pane are insterested in current ideEvent too, dispatch
        if activeSubModule and activeSubModule.ideEvents and activeSubModule.ideEvents.hasOwnProperty eventName

            if not args
                args = slice.call arguments, 1
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

    propertyTypeMap = {}
    propertyTypeMap.DEFAULT_TYPE = "default"
    propertyMain    = null
    propertyView    = null

    # # # # # # # # # # # # # # # # # # # # # # # # #
    ###
    # Above is internal implementation. User doesn't have to care about its detail.
    ###
    # # # # # # # # # # # # # # # # # # # # # # # # #



    ###

    -------------------------------
     PropertyModule is a base class that every property controller ( a.k.a property main )
     should inherit.
    -------------------------------

    ++ Class attributes ++

    # ideEvents : Map
                  ( Defined by user )
        example : this.ideEvents = {
                    ABC : "functionNameOfModule"
                    DEF : () -> null
                  }
        description : This attributes specify what kind of ide_event this property cares. The event will dispatch to the property when the property is active.

    # subPanelID : String
                  ( Defined by user )
        description : If is not falsy, this Module is meaned to be used as sub panel, or part of another module. For example, sglist / acl / sgrule should set this to true

    # uid        : String
                  ( Defined by library when property is loaded )
        description : This uid is the uid of current component. It is set before `init#{type}` is called.


    # type      : PropertyModule.TYPE.STACK || PropertyModule.TYPE.APP
                  ( Defined by library when property is loaded)
        description : User can use this attribute to determine what mode ( stack or app ) it is right now.

    # handleTypes : String | StringArray
                  ( Defined by user )
        description : This attribute is used to determine which Property should be shown. The String can be one of constant.AWS_RESOURCE_TYPE

    # model     : PropertyModel
                  ( Assigned by user when `init#{type}` is called )
        description : This points to current model for the property.

    # view      : PropertyView
                  ( Assigned by user when `init#{type}` is called )
        description : This points to current view for the property.



    ++ Class Protocol ( Should be implemented by user ) ++
    # init#{type} :
         example     : initApp, initStack
         description : These methods are called when the property is loaded. In these method, user has to assign `this.model` and `this.view`. If this method returns false, it means the property is unable to load. And default property panel ( Stack Panel ) will be used.

    # setup#{type} :
         example     : setupApp, setupStack
         description : These methods are called after the first time the property is inited. User should use these methods to do proper setup. These methods are called only once, since the `controller`, the `model` and the `view` are all singleton.

    # afterLoad#{type} :
         example     : afterLoadApp, afterLoadStack
         description : These methods are called when the property finished loading. The view is guaranteed to be loaded.



    ++ Class Method ++

    # extend :
         description : User must use this method to inherit from PropertyModule. The usage is the same as Backbone's extend

    # activeModule :
        description : Returns the currently showing property.

    # activeSubModule :
        description : Returns the currently showing sub property. Maybe null.

    ###


    PropertyModule = ()->
        this.type = PropertyModule.TYPE.Stack
        null

    PropertyModule.TYPE = PropertyModule.prototype.TYPE =
        Stack : "Stack"
        App   : "App"


    PropertyModule.prototype.extend = ( protoProps, staticProps ) ->
        if not protoProps.hasOwnProperty "handleTypes"
            console.warning "The property doesn't specify what kind of component it can handle"
            return

        # 1. Create a new property module
        newPropertyClass = Backbone.Model.extend.call PropertyModule, protoProps, staticProps
        newProperty      = new newPropertyClass()

        # 2. Register it
        if _.isString newProperty.handleTypes
            propertyTypeMap[ newProperty.handleTypes || propertyTypeMap.DEFAULT_TYPE ] = newProperty
        else
            for type in newProperty.handleTypes
                propertyTypeMap[ newProperty.handleTypes || propertyTypeMap.DEFAULT_TYPE ] = newProperty

        # 3. Return the Property Class
        newPropertyClass

    PropertyModule.prototype.activeModule = () ->
        activeModule

    PropertyModule.prototype.activeSubModule = () ->
        activeSubModule



    PropertyModule.initialize = ( PropertyMain, PropertyView ) ->
        # This method is called by PropertyMain to do proper setup.
        # The dependency is injected, so that we don't have a hard
        # dependency to the PropertyMain and PropertyView, thus no
        # circular reference exists.
        propertyMain = PropertyMain   # This is module/design/property/main
        propertyView = PropertyView   # This is module/design/property/view

        PropertyModule.initialize = null
        null


    PropertyModule.load  = ( componentType, componentUid, tab_type ) ->
        if not componentType and not this._doLoad componentType, componentUid, tab_type
            if componentType
                console.error "Cannot open component for type: #{ componentType }, data : #{componentUid }"
            this._doLoad propertyTypeMap.DEFAULT_TYPE, "", tab_type
        null


    PropertyModule._doLoad = ( componentType, componentUid, tab_type, noRender ) ->

        # 1. Find the corresponding property
        property = propertyTypeMap[ componentType ]
        if not property
            return false

        # 2. Set the property type to "App" or "Stack"
        property.type = tab_type

        # 3. Init
        procName = "init#{property.type}"
        if property[ procName ]
            property.uid = componentUid
            property[ procName ].call this, componentUid
        else
            # The property cannot init. Default to use Stack property.
            return false

        # 4. Setup ( Only run once )
        procName = "setup#{property.type}"
        if property[ procName ]
            property[ procName ].call property
            property[ procName ] = null

        # 5. Register the property as active property
        if property.subPanelID
            activeSubModule     = property
            activeSubModuleType = componentType
        else
            activeSubModule     = null
            activeSubModuleType = null
            activeModule        = property
            activeModuleType    = componentType

        # 6. Re-init the `model` and `view`
        if property.model.init
            # Since the model is singleton, need to clear all the attributes.
            property.model.clear()
            # If the model cannot init. Default to use Stack property.
            if property.model.init( componentUid ) is false
                return false
        else
            console.error "This model has no init() method. Type: #{componentType}."

        # Injects the model to the view. So that the view doesn't have hard dependency
        # to the model. Thus they're decoupled.
        property.view.model     = property.model
        property.view._isSub    = !!property.subPanelID
        property.view._noRender = noRender # If we are restore state of a tab, no need to render the property panel

        # 7. Tell view to Render
        if property.subPanelID
            property.view._loadAsSub()
            # In the previous version, here uses "ide_event.PROPERTY_OPEN_SUBPANEL" to open the subpanel.
            # I'm against using ide_event, because it seems like something is decoupled, but it
            # will create dependency hell, for example, you have no idea who will use your ide_event.
            propertyView.opernSubPanel property.subPanelID
        else
            property.view._load()

        # 8. After load callback.
        procName = "afterLoad#{type}"
        property[ procName ] and property[ procName ].apply( property )

        true

    PropertyModule.snapshot = ()->
        data =
            activeModuleType    : activeModuleType
            activeSubModuleType : activeSubModuleType
            activeModuleId      : activeModule.uid
            activeSubModuleId   : if activeSubModule then activeSubModule.uid else null
            tab_type            : activeModule.type

        data

    PropertyModule.restore  = ( snapshot )->
        PropertyModule.load snapshot.activeModuleType, snapshot.activeModuleId, snapshot.tab_type, true

        if snapshot.activeSubModuleType
            PropertyModule.load snapshot.activeSubModuleType, snapshot.activeSubModuleId, snapshot.tab_type, true

        null


    # Export PropertyModule
    PropertyModule

