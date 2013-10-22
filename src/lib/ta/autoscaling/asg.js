(function() {
  define(['jquery', 'MC', 'constant'], function($, MC, constant) {
    var getASGInAZ, getAZofASGNode, updateASGCount;
    getAZofASGNode = function(uid) {
      var asg_parent, comp_data, layout_data, parent_id, res_type, tgt_az;
      comp_data = MC.canvas_data.component;
      layout_data = MC.canvas_data.layout;
      res_type = constant.AWS_RESOURCE_TYPE;
      tgt_az = '';
      parent_id = layout_data.component.group[uid].groupUId;
      asg_parent = layout_data.component.group[parent_id];
      if (asg_parent) {
        switch (asg_parent.type) {
          case res_type.AWS_EC2_AvailabilityZone:
            tgt_az = asg_parent.name;
            break;
          case res_type.AWS_VPC_Subnet:
            tgt_az = comp_data[parent_id].resource.AvailabilityZone;
        }
      }
      return tgt_az;
    };
    updateASGCount = function(app_id) {
      var appData, asg_comp, asg_data, comp, component, layout, uid;
      if (MC.canvas.getState() === 'stack') {
        return null;
      }
      appData = MC.data.resource_list[MC.canvas_data.region];
      component = MC.canvas_data.component;
      layout = MC.canvas_data.layout;
      for (uid in component) {
        comp = component[uid];
        if (comp.type === constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration) {
          asg_comp = component[layout.component.node[uid].groupUId];
          asg_data = appData[asg_comp.resource.AutoScalingGroupARN];
          if (asg_data) {
            MC.canvas.update(uid, 'text', 'lc_name', asg_data.Instances.member.length + " in service");
          }
        }
      }
      return null;
    };
    getASGInAZ = function(orig_uid, az) {
      var asg_layout, asg_parent, comp_data, group, layout_data, parent_id, res_type, result, tgt_az, tgt_layout, uid, _ref;
      result = '';
      comp_data = MC.canvas_data.component;
      layout_data = MC.canvas_data.layout;
      res_type = constant.AWS_RESOURCE_TYPE;
      tgt_az = '';
      asg_layout = layout_data.component.group[orig_uid];
      if (asg_layout) {
        if (asg_layout.originalId) {
          orig_uid = asg_layout.originalId;
          asg_layout = layout_data.component.group[orig_uid];
        }
        parent_id = asg_layout.groupUId;
        asg_parent = layout_data.component.group[parent_id];
        _ref = layout_data.component.group;
        for (uid in _ref) {
          group = _ref[uid];
          if (group.type === res_type.AWS_AutoScaling_Group) {
            tgt_layout = layout_data.component.group[group.groupUId];
            if (tgt_layout) {
              switch (tgt_layout.type) {
                case res_type.AWS_EC2_AvailabilityZone:
                  tgt_az = tgt_layout.name;
                  break;
                case res_type.AWS_VPC_Subnet:
                  tgt_az = comp_data[group.groupUId].resource.AvailabilityZone;
              }
              if ((group.originalId === orig_uid || uid === orig_uid) && az === getAZofASGNode(uid)) {
                result = uid;
              }
            }
          }
        }
      }
      return result;
    };
    return {
      getAZofASGNode: getAZofASGNode,
      getASGInAZ: getASGInAZ,
      updateASGCount: updateASGCount
    };
  });

}).call(this);
