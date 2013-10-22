(function() {
  define(['constant', 'MC'], function(constant, MC) {
    var updateCount, updateStateIcon;
    updateCount = function(uid, count) {
      var attachment, c_uid, comp, eni, _ref;
      _ref = MC.canvas_data.component;
      for (c_uid in _ref) {
        comp = _ref[c_uid];
        if (comp.type === constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface) {
          attachment = comp.resource.Attachment;
          if (attachment && attachment.InstanceId && attachment.InstanceId.indexOf(uid) !== -1 && "" + attachment.DeviceIndex !== "0") {
            eni = c_uid;
            break;
          }
        }
      }
      if (count > 1) {
        MC.canvas.display(uid, 'instance-number-group', true);
        MC.canvas.display(uid, 'port-instance-rtb', false);
        MC.canvas.update(uid, 'text', 'instance-number', count);
        if (eni) {
          MC.canvas.display(eni, 'eni-number-group', true);
          MC.canvas.update(eni, 'text', 'eni-number', count);
          return MC.canvas.display(eni, 'port-eni-rtb', false);
        }
      } else {
        MC.canvas.display(uid, 'instance-number-group', false);
        MC.canvas.display(uid, 'port-instance-rtb', true);
        if (eni) {
          MC.canvas.display(eni, 'eni-number-group', false);
          return MC.canvas.display(eni, 'port-eni-rtb', true);
        }
      }
    };
    updateStateIcon = function(app_id) {
      if (MC.canvas.getState() === 'stack') {
        return null;
      }
      if (app_id && MC.canvas.data.get('id') === app_id) {
        MC.canvas.updateInstanceState();
      }
      return null;
    };
    return {
      updateCount: updateCount,
      updateStateIcon: updateStateIcon
    };
  });

}).call(this);
