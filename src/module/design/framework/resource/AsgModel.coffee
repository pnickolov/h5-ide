
define [ "../ComplexResModel", "CanvasManager", "Design", "constant", "./scalingPolicyModel" ], ( ComplexResModel, CanvasManager, Design, constant, scalingPolicy )->

  Model = ComplexResModel.extend {

    defaults :
      x        : 0
      y        : 0
      width    : 13
      height   : 13

    type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group

    __asso: [
      {
        key: 'LaunchConfigurationName'
        type: constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
        suffix: 'LaunchConfigurationName'
      }
    ]

    #scalingPolicies: new Backbone.Collection()
    #launchConfigurations: new Backbone.Collection()

    #addScalingPolicy: ( policyModel ) ->

    #  @scalingPolicies.add policyModel

    draw : ( isCreate )->

      if isCreate

        design = Design.instance()

        x      = @x()
        y      = @y()
        width  = @width()  * MC.canvas.GRID_WIDTH
        height = @height() * MC.canvas.GRID_HEIGHT

        node = Canvon.group().append(

          Canvon.rectangle( 1, 1, width - 1, height - 1 ).attr({
            'class' : 'group group-asg'
            'rx'    : 5
            'ry'    : 5
          }),

          # title bg
          Canvon.path( MC.canvas.PATH_ASG_TITLE ).attr({'class':'asg-title'}),

          # dragger
          Canvon.image(MC.IMG_URL + 'ide/icon/asg-resource-dragger.png', width - 21, 0, 22, 21).attr({
            'class'        : 'asg-resource-dragger tooltip'
            'data-tooltip' : 'Expand the group by drag-and-drop in other availability zone.'
            'id'           : @id + '_asg_resource_dragger'
          }),

          # prompt
          Canvon.group().append(
            Canvon.text(25, 45,  'Drop AMI from'),
            Canvon.text(20, 65,  'resource panel to'),
            Canvon.text(30, 85,  'create launch'),
            Canvon.text(30, 105, 'configuration')
          ).attr({
            'id'      : @id + '_prompt_text'
            'class'   : 'prompt_text'
            'display' : "none"
          }),

          # title
          Canvon.text( 4, 14, @get("name") ).attr({
            'id'    : @id + '_name'
            'class' : 'group-label'
          })

        ).attr({
          'id'         : @id
          'class'      : 'dragable node AWS-AutoScaling-Group'
          'data-type'  : 'group'
          'data-class' : @type
        })

        # Move the node to right place
        $("#asg_layer").append node
        CanvasManager.position node, @x(), @y()

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group

    deserialize : ( data, layout_data, resolve )->

      attr =
        id           : data.uid
        name         : data.name

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]

        width: layout_data.size[0]
        height: layout_data.size[1]

      for key, value of data.resource
        attr[ key ] = value

      model = new Model( attr )

      ElbAsso = Design.modelClassForType( "ElbAmiAsso" )

      for elbName in attr.LoadBalancerNames
        elb = resolve MC.extractID elbName
        new ElbAsso( model, elb )

      model.associate resolve
      null

  }

  Model

