(function() {
  define(['constant', 'MC'], function(constant, MC) {
    var add, del, getList;
    add = function(keypair_name) {
      var data;
      if (MC.canvas_property.kp_list.hasOwnProperty(keypair_name)) {
        return false;
      }
      data = $.extend(true, {}, MC.canvas.KP_JSON.data);
      data.uid = MC.guid();
      data.name = data.resource.KeyName = keypair_name;
      MC.canvas_data.component[data.uid] = data;
      MC.canvas_property.kp_list[keypair_name] = data.uid;
      return data.uid;
    };
    del = function(keypair_name) {
      var kp_id;
      kp_id = MC.canvas_property.kp_list[keypair_name];
      delete MC.canvas_data.component[kp_id];
      return delete MC.canvas_property.kp_list[keypair_name];
    };
    getList = function(check_uid) {
      var comp, comp_uid, kp, kp_uid, kps, name, res_type, using_kps, _ref, _ref1;
      res_type = constant.AWS_RESOURCE_TYPE;
      using_kps = {};
      _ref = MC.canvas_data.component;
      for (comp_uid in _ref) {
        comp = _ref[comp_uid];
        if (comp.type !== res_type.AWS_EC2_Instance && comp.type !== res_type.AWS_AutoScaling_LaunchConfiguration) {
          continue;
        }
        using_kps[comp.resource.KeyName] = true;
      }
      kps = [null];
      _ref1 = MC.canvas_property.kp_list;
      for (name in _ref1) {
        kp_uid = _ref1[name];
        kp = {
          name: name,
          using: using_kps.hasOwnProperty("@" + kp_uid + ".resource.KeyName"),
          selected: kp_uid === check_uid
        };
        if (name === "DefaultKP") {
          kps[0] = kp;
        } else {
          kps.push(kp);
        }
      }
      return kps;
    };
    return {
      add: add,
      del: del,
      getList: getList
    };
  });

}).call(this);
