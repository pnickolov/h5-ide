(function() {
  define(['MC'], function(MC) {
    var getInstanceType, getOSType;
    getOSType = function(ami) {
      var found, osType, osTypeList;
      osTypeList = ['centos', 'redhat', 'redhat', 'ubuntu', 'debian', 'fedora', 'gentoo', 'opensus', 'suse', 'amazon', 'amazon'];
      osType = 'linux-other';
      found = [];
      if (ami.platform && ami.platform === 'windows') {
        found.push('win');
      } else {
        found = osTypeList.filter(function(word) {
          return ~ami.name.toLowerCase().indexOf(word);
        });
        if (found.length === 0) {
          found = osTypeList.filter(function(word) {
            return ~ami.description.toLowerCase().indexOf(word);
          });
        }
        if (found.length === 0) {
          found = osTypeList.filter(function(word) {
            return ~ami.imageLocation.toLowerCase().indexOf(word);
          });
        }
      }
      if (found.length === 0) {
        osType = 'unknown';
      } else {
        osType = found[0];
      }
      return osType;
    };
    getInstanceType = function(ami) {
      var instance_type, region;
      region = MC.canvas_data.region;
      instance_type = MC.data.config[region].ami_instance_type;
      if (!instance_type) {
        return [];
      }
      if (ami.virtualizationType === 'hvm') {
        instance_type = instance_type.windows;
      } else {
        instance_type = instance_type.linux;
      }
      if (ami.rootDeviceType === 'ebs') {
        instance_type = instance_type.ebs;
      } else {
        instance_type = instance_type['instance store'];
      }
      if (ami.architecture === 'x86_64') {
        instance_type = instance_type["64"];
      } else {
        instance_type = instance_type["32"];
      }
      instance_type = instance_type[ami.virtualizationType];
      return instance_type;
    };
    return {
      getOSType: getOSType,
      getInstanceType: getInstanceType
    };
  });

}).call(this);
