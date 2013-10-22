(function() {
  define(['MC'], function(MC) {
    var getDeviceName;
    getDeviceName = function(uid, volume_id) {
      var ami_info, comp_data, device_list, device_name, image_id, region;
      comp_data = MC.canvas.data.get("component")[uid];
      region = MC.canvas.data.get("region");
      image_id = (comp_data ? comp_data.resource.ImageId : "");
      ami_info = (MC.data.config[region].ami ? MC.data.config[region].ami[image_id] : null);
      device_list = [];
      device_name = null;
      if (ami_info && ami_info.virtualizationType !== 'hvm') {
        device_list = ['f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'];
      } else {
        device_list = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p'];
      }
      $.each(ami_info.blockDeviceMapping, function(key, value) {
        var index, k;
        if (key.slice(0, 4) === "/dev/") {
          k = key.slice(-1);
          index = device_list.indexOf(k);
          if (index >= 0) {
            return device_list.splice(index, 1);
          }
        }
      });
      if (comp_data.type === 'AWS.EC2.Instance') {
        $.each(comp_data.resource.BlockDeviceMapping, function(key, value) {
          var index, k, volume_uid;
          volume_uid = value.slice(1);
          k = MC.canvas_data.component[volume_uid].name.slice(-1);
          index = device_list.indexOf(k);
          if (index >= 0) {
            return device_list.splice(index, 1);
          }
        });
      } else if (comp_data.type === 'AWS.AutoScaling.LaunchConfiguration') {
        $.each(comp_data.resource.BlockDeviceMapping, function(key, value) {
          var index;
          index = device_list.indexOf(value.DeviceName.substr(-1, 1));
          if (index >= 0) {
            return device_list.splice(index, 1);
          }
        });
      }
      if (device_list.length === 0) {
        device_name = null;
      } else {
        if (ami_info.virtualizationType !== "hvm") {
          device_name = "/dev/sd" + device_list[0];
        } else {
          device_name = "xvd" + device_list[0];
        }
      }
      return device_name;
    };
    return {
      getDeviceName: getDeviceName
    };
  });

}).call(this);
