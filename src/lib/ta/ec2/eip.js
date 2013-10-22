(function() {
  define(['constant', 'MC'], function(constant, MC) {
    var isInstanceHaveEIPInClassic, updateAppTooltip, updateStackTooltip;
    updateStackTooltip = function(parentCompUID, isAssociate) {
      var tootipStr;
      tootipStr = 'Remove Elastic IP';
      if (isAssociate) {
        tootipStr = 'Associate Elastic IP';
      }
      return MC.canvas.update(parentCompUID, 'tooltip', 'eip_status', tootipStr);
    };
    updateAppTooltip = function(parentCompUID) {
      var appComp, eniId, instanceId, ipAddress, parentComp, parentCompType;
      parentComp = MC.canvas_data.component[parentCompUID];
      parentCompType = parentComp.type;
      ipAddress = '';
      if (parentCompType === constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance) {
        if (MC.canvas_data.component[parentCompUID]) {
          instanceId = MC.canvas_data.component[parentCompUID].resource.InstanceId;
          if (MC.data && MC.data.resource_list) {
            appComp = MC.data.resource_list[MC.canvas_data.region][instanceId];
            if (appComp) {
              ipAddress = appComp.ipAddress;
            }
          }
        }
      } else if (parentCompType === constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface) {
        if (MC.canvas_data.component[parentCompUID]) {
          eniId = MC.canvas_data.component[parentCompUID].resource.NetworkInterfaceId;
          if (MC.data && MC.data.resource_list) {
            appComp = MC.data.resource_list[MC.canvas_data.region][eniId];
            if (appComp && appComp.association) {
              ipAddress = appComp.association.publicIp;
            }
          }
        }
      }
      return MC.canvas.update(parentCompUID, 'tooltip', 'eip_status', ipAddress);
    };
    isInstanceHaveEIPInClassic = function(instanceUID) {
      var result;
      result = false;
      _.each(MC.canvas_data.component, function(compObj) {
        var currentInstanceUID, instanceUIDRef;
        if (compObj.type === 'AWS.EC2.EIP') {
          instanceUIDRef = compObj.resource.InstanceId;
          currentInstanceUID = '';
          if (instanceUIDRef) {
            currentInstanceUID = instanceUIDRef.split('.')[0].slice(1);
            if (currentInstanceUID === instanceUID) {
              result = true;
            }
          }
        }
        return null;
      });
      return result;
    };
    return {
      updateStackTooltip: updateStackTooltip,
      updateAppTooltip: updateAppTooltip,
      isInstanceHaveEIPInClassic: isInstanceHaveEIPInClassic
    };
  });

}).call(this);
