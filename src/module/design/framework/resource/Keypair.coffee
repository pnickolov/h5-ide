
define [ "constant", "../Design", "../ResourceModel"  ], ( constant, Design, ResourceModel )->

  Model = GroupModel.extend {
    type : constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair

    deserialize : ( data, layout_data, resolve )->

      new Model({
        id   : data.uid
        name : data.name
      })

  }

  Model
