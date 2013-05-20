/*
Description:
    model know service interface, and provide operation to vo
Action:
    1.define vo
    2.provide encapsulation of api for controller
    3.dispatch event to controller
*/


(function() {
  define(['backbone', 'instance_service', 'instance_vo'], function(Backbone, instance_service, instance_vo) {
    var InstancesModel, instances_model;

    InstancesModel = Backbone.Model.extend({
      defaults: {
        instanceList: []
      },
      describeInstances: function(username, session_id, region_name, instance_ids, filters) {
        var me;

        if (instance_ids == null) {
          instance_ids = null;
        }
        if (filters == null) {
          filters = null;
        }
        me = this;
        return instance_service.DescribeInstances(username, password, function(aws_result) {
          var instanceList;

          if (!aws_result.is_error) {
            instanceList = aws_result.resolved_data;
          } else {
            console.log('describeInstances failed, error is ' + aws_result.error_message);
          }
          return me.trigger('EC2_INS_DESC_INSTANCES_RETURN', aws_result);
        });
      }
    });
    instances_model = new InstancesModel();
    return instances_model;
  });

}).call(this);
