(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['i18n!nls/lang.js', 'MC', 'constant'], function(lang, MC, constant) {
    var addSGToProperty, convertMemberNameToReal, createNewSG, deleteRefInAllComp, getAllRefComp, getAllRule, getDefaultSG, getNextSGColor, getSGColor, getSgRuleDetail, updateSGColorLabel;
    getAllRefComp = function(sgUID) {
      var refCompAry, refNum, sgAry;
      refNum = 0;
      sgAry = [];
      refCompAry = [];
      _.each(MC.canvas_data.component, function(comp) {
        var compType, _sgAry;
        compType = comp.type;
        if (compType === 'AWS.ELB' || compType === 'AWS.AutoScaling.LaunchConfiguration') {
          sgAry = comp.resource.SecurityGroups;
          sgAry = _.map(sgAry, function(value) {
            var refSGUID;
            refSGUID = value.slice(1).split('.')[0];
            return refSGUID;
          });
          if (__indexOf.call(sgAry, sgUID) >= 0) {
            refCompAry.push(comp);
          }
        }
        if (compType === 'AWS.EC2.Instance') {
          sgAry = comp.resource.SecurityGroupId;
          sgAry = _.map(sgAry, function(value) {
            var refSGUID;
            refSGUID = value.slice(1).split('.')[0];
            return refSGUID;
          });
          if (__indexOf.call(sgAry, sgUID) >= 0) {
            refCompAry.push(comp);
          }
        }
        if (compType === 'AWS.VPC.NetworkInterface') {
          _sgAry = [];
          _.each(comp.resource.GroupSet, function(sgObj) {
            _sgAry.push(sgObj.GroupId);
            return null;
          });
          sgAry = _sgAry;
          sgAry = _.map(sgAry, function(value) {
            var refSGUID;
            refSGUID = value.slice(1).split('.')[0];
            return refSGUID;
          });
          if (__indexOf.call(sgAry, sgUID) >= 0) {
            refCompAry.push(comp);
          }
        }
        return null;
      });
      return refCompAry;
    };
    deleteRefInAllComp = function(sgUID) {
      var defaultSGComp, defaultSGUID, refCompAry, refNum, sgAry;
      refNum = 0;
      sgAry = [];
      refCompAry = [];
      defaultSGComp = MC.aws.sg.getDefaultSG();
      defaultSGUID = defaultSGComp.uid;
      _.each(MC.canvas_data.component, function(comp) {
        var compType, compUID, eniComp, eniSgAry, sgNameAry;
        compType = comp.type;
        compUID = comp.uid;
        if (compType === 'AWS.ELB' || compType === 'AWS.AutoScaling.LaunchConfiguration') {
          sgAry = comp.resource.SecurityGroups;
          sgAry = _.filter(sgAry, function(value) {
            var refSGUID;
            refSGUID = value.slice(1).split('.')[0];
            if (sgUID === refSGUID) {
              return false;
            } else {
              return true;
            }
          });
          if (sgAry.length === 0) {
            sgAry.push('@' + defaultSGUID + '.resource.GroupId');
          }
          MC.canvas_data.component[compUID].resource.SecurityGroups = sgAry;
          MC.aws.sg.updateSGColorLabel(compUID);
        }
        if (compType === 'AWS.EC2.Instance') {
          eniComp = MC.aws.eni.getInstanceDefaultENI(compUID);
          if (eniComp) {
            eniSgAry = eniComp.resource.GroupSet;
            eniSgAry = _.filter(eniSgAry, function(sgObj) {
              var refSGUID;
              refSGUID = sgObj.GroupId.slice(1).split('.')[0];
              if (sgUID === refSGUID) {
                return false;
              } else {
                return true;
              }
            });
            if (eniSgAry.length === 0) {
              eniSgAry.push({
                'GroupId': '@' + defaultSGUID + '.resource.GroupId',
                'GroupName': '@' + defaultSGUID + '.resource.GroupName'
              });
            }
            MC.canvas_data.component[eniComp.uid].resource.GroupSet = eniSgAry;
          }
          if (!eniComp) {
            sgAry = comp.resource.SecurityGroupId;
            sgAry = _.filter(sgAry, function(value) {
              var refSGUID;
              refSGUID = value.slice(1).split('.')[0];
              if (sgUID === refSGUID) {
                return false;
              } else {
                return true;
              }
            });
            if (sgAry.length === 0) {
              sgAry.push('@' + defaultSGUID + '.resource.GroupId');
            }
            sgNameAry = comp.resource.SecurityGroup;
            sgNameAry = _.filter(sgNameAry, function(value) {
              var refSGUID;
              refSGUID = value.slice(1).split('.')[0];
              if (sgUID === refSGUID) {
                return false;
              } else {
                return true;
              }
            });
            if (sgNameAry.length === 0) {
              sgNameAry.push('@' + defaultSGUID + '.resource.GroupName');
            }
            MC.canvas_data.component[compUID].resource.SecurityGroupId = sgAry;
            MC.canvas_data.component[compUID].resource.SecurityGroup = sgNameAry;
          }
          MC.aws.sg.updateSGColorLabel(compUID);
        }
        if (compType === 'AWS.VPC.NetworkInterface') {
          sgAry = comp.resource.GroupSet;
          sgAry = _.filter(sgAry, function(sgObj) {
            var refSGUID;
            refSGUID = sgObj.GroupId.slice(1).split('.')[0];
            if (sgUID === refSGUID) {
              return false;
            } else {
              return true;
            }
          });
          if (sgAry.length === 0) {
            sgAry.push({
              'GroupId': '@' + defaultSGUID + '.resource.GroupId',
              'GroupName': '@' + defaultSGUID + '.resource.GroupName'
            });
          }
          MC.canvas_data.component[compUID].resource.GroupSet = sgAry;
          MC.aws.sg.updateSGColorLabel(compUID);
        }
        return null;
      });
      return refCompAry;
    };
    getAllRule = function(sgRes) {
      var allDispRuleAry, allRuleAry, inboundRule, outboundRule;
      outboundRule = [];
      if (sgRes.ipPermissionsEgress) {
        outboundRule = sgRes.ipPermissionsEgress.item;
      }
      inboundRule = [];
      if (sgRes.ipPermissions) {
        inboundRule = sgRes.ipPermissions.item;
      }
      inboundRule = _.map(inboundRule, function(ruleObj) {
        ruleObj.direction = 'inbound';
        return ruleObj;
      });
      outboundRule = _.map(outboundRule, function(ruleObj) {
        ruleObj.direction = 'outbound';
        return ruleObj;
      });
      allRuleAry = inboundRule.concat(outboundRule);
      allDispRuleAry = [];
      _.each(allRuleAry, function(originRuleObj) {
        var dispPort, dispSGObj, ipRanges, partType, ruleObj, _ref, _ref1;
        ruleObj = _.clone(originRuleObj);
        ipRanges = '';
        if (ruleObj.ipRanges) {
          ipRanges = ruleObj.ipRanges['item'][0]['cidrIp'];
        } else {
          ipRanges = ruleObj.groups.item[0].groupId;
        }
        if ((_ref = ruleObj.ipProtocol) === (-1) || _ref === '-1') {
          ruleObj.ipProtocol = 'all';
          ruleObj.fromPort = 0;
          ruleObj.toPort = 65535;
        } else if ((_ref1 = ruleObj.ipProtocol) !== 'tcp' && _ref1 !== 'udp' && _ref1 !== 'icmp' && _ref1 !== 'all' && _ref1 !== (-1) && _ref1 !== '-1') {
          ruleObj.ipProtocol = "custom(" + ruleObj.ipProtocol + ")";
        }
        partType = '';
        if (ruleObj.ipProtocol === 'icmp') {
          partType = '/';
        } else {
          partType = '-';
        }
        dispPort = ruleObj.fromPort + partType + ruleObj.toPort;
        if (Number(ruleObj.fromPort) === Number(ruleObj.toPort) && ruleObj.ipProtocol !== 'icmp') {
          dispPort = ruleObj.toPort;
        }
        if (!ruleObj.fromPort || !ruleObj.toPort) {
          dispPort = '-';
        }
        dispSGObj = {
          fromPort: ruleObj.fromPort,
          toPort: ruleObj.toPort,
          ipProtocol: ruleObj.ipProtocol,
          ipRanges: ipRanges,
          direction: ruleObj.direction,
          partType: partType,
          dispPort: dispPort
        };
        allDispRuleAry.push(dispSGObj);
        return null;
      });
      return allDispRuleAry;
    };
    getSgRuleDetail = function(line_id_or_target) {
      var both_side, options;
      both_side = [];
      options = null;
      if ($.type(line_id_or_target) === "string") {
        options = MC.canvas.lineTarget(line_id_or_target);
      } else {
        options = line_id_or_target;
      }
      $.each(options, function(i, connection_obj) {
        var sg, side_sg;
        switch (MC.canvas_data.component[connection_obj.uid].type) {
          case constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance:
            if (MC.canvas_data.platform === MC.canvas.PLATFORM_TYPE.EC2_CLASSIC) {
              side_sg = {};
              side_sg.name = MC.canvas_data.component[connection_obj.uid].name;
              side_sg.sg = (function() {
                var _i, _len, _ref, _results;
                _ref = MC.canvas_data.component[connection_obj.uid].resource.SecurityGroupId;
                _results = [];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  sg = _ref[_i];
                  _results.push({
                    uid: sg.split('.')[0].slice(1),
                    name: MC.canvas_data.component[sg.split('.')[0].slice(1)].name,
                    color: MC.aws.sg.getSGColor(sg.split('.')[0].slice(1))
                  });
                }
                return _results;
              })();
              return both_side.push(side_sg);
            } else {
              return $.each(MC.canvas_data.component, function(comp_uid, comp) {
                if (comp.type === constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface && (comp.resource.Attachment.InstanceId.split("."))[0].slice(1) === connection_obj.uid && comp.resource.Attachment.DeviceIndex === '0') {
                  side_sg = {};
                  side_sg.name = MC.canvas_data.component[connection_obj.uid].name;
                  side_sg.sg = (function() {
                    var _i, _len, _ref, _results;
                    _ref = comp.resource.GroupSet;
                    _results = [];
                    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                      sg = _ref[_i];
                      _results.push({
                        name: MC.canvas_data.component[sg.GroupId.split('.')[0].slice(1)].name,
                        uid: sg.GroupId.split('.')[0].slice(1),
                        color: MC.aws.sg.getSGColor(sg.GroupId.split('.')[0].slice(1))
                      });
                    }
                    return _results;
                  })();
                  both_side.push(side_sg);
                  return false;
                }
              });
            }
            break;
          case constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface:
            side_sg = {};
            side_sg.name = MC.canvas_data.component[connection_obj.uid].name;
            side_sg.sg = (function() {
              var _i, _len, _ref, _results;
              _ref = MC.canvas_data.component[connection_obj.uid].resource.GroupSet;
              _results = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                sg = _ref[_i];
                _results.push({
                  uid: sg.GroupId.split('.')[0].slice(1),
                  name: MC.canvas_data.component[sg.GroupId.split('.')[0].slice(1)].name,
                  color: MC.aws.sg.getSGColor(sg.GroupId.split('.')[0].slice(1))
                });
              }
              return _results;
            })();
            return both_side.push(side_sg);
          case constant.AWS_RESOURCE_TYPE.AWS_ELB:
          case constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration:
            side_sg = {};
            side_sg.name = MC.canvas_data.component[connection_obj.uid].name;
            side_sg.sg = (function() {
              var _i, _len, _ref, _results;
              _ref = MC.canvas_data.component[connection_obj.uid].resource.SecurityGroups;
              _results = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                sg = _ref[_i];
                _results.push({
                  uid: sg.split('.')[0].slice(1),
                  name: MC.canvas_data.component[sg.split('.')[0].slice(1)].name,
                  color: MC.aws.sg.getSGColor(sg.split('.')[0].slice(1))
                });
              }
              return _results;
            })();
            return both_side.push(side_sg);
        }
      });
      return both_side;
    };
    createNewSG = function() {
      var component_data, data, sg_name, uid, vpcUID;
      uid = MC.guid();
      component_data = $.extend(true, {}, MC.canvas.SG_JSON.data);
      component_data.uid = uid;
      sg_name = MC.aws.aws.getNewName(constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup);
      component_data.name = sg_name;
      component_data.resource.GroupName = sg_name;
      vpcUID = MC.aws.vpc.getVPCUID();
      if (vpcUID) {
        component_data.resource.VpcId = '@' + vpcUID + '.resource.VpcId';
      }
      component_data.resource.GroupDescription = lang.ide.PROP_TEXT_CUSTOM_SG_DESC;
      component_data.resource.IpPermissions = [];
      component_data.resource.IpPermissionsEgress.push({
        "IpProtocol": "-1",
        "IpRanges": "0.0.0.0/0",
        "FromPort": "0",
        "ToPort": "65535",
        "Groups": []
      });
      data = MC.canvas.data.get('component');
      data[uid] = component_data;
      MC.canvas.data.set('component', data);
      addSGToProperty(component_data);
      return uid;
    };
    addSGToProperty = function(sg) {
      var found, prop;
      found = false;
      prop = MC.canvas_property;
      if (!prop) {
        console.log('[addSGToProperty] no canvas_property found');
      } else {
        $.each(prop.sg_list, function(i, item) {
          if (sg.id === item.uid) {
            found = true;
            return false;
          }
          return null;
        });
        if (!found) {
          prop.sg_list.push({
            color: getNextSGColor(),
            member: 0,
            name: sg.name,
            uid: sg.uid
          });
        }
      }
      return null;
    };
    getSGColor = function(uid) {
      var color;
      color = null;
      if (MC.canvas_property && MC.canvas_property.sg_list) {
        $.each(MC.canvas_property.sg_list, function(i, value) {
          if (value.color && value.uid === uid) {
            color = value.color;
            return false;
          }
        });
      }
      if (!color) {
        color = Math.floor(Math.random() * 0xFFFFFF).toString(16);
        while (color.length < 6) {
          color = '0' + color;
        }
      }
      return '#' + color;
    };
    getNextSGColor = function() {
      var next_color;
      next_color = null;
      if (MC.canvas_property && MC.canvas_property.sg_list) {
        $.each(MC.canvas.SG_COLORS, function(i, color) {
          var found;
          found = false;
          $.each(MC.canvas_property.sg_list, function(j, sg) {
            if (sg.color === color) {
              found = true;
              return false;
            }
          });
          if (!found) {
            next_color = color;
            return false;
          }
        });
      }
      if (!next_color) {
        next_color = Math.floor(Math.random() * 0xFFFFFF).toString(16);
        while (next_color.length < 6) {
          next_color = '0' + next_color;
        }
      }
      return next_color;
    };
    updateSGColorLabel = function(uid) {
      if (uid) {
        MC.canvas.updateSG(uid);
      } else {

      }
      return null;
    };
    getDefaultSG = function() {
      var deafaultSGComp;
      deafaultSGComp = null;
      _.each(MC.canvas_data.component, function(sgComp) {
        if (sgComp.name === 'DefaultSG') {
          deafaultSGComp = sgComp;
        }
        return null;
      });
      return deafaultSGComp;
    };
    convertMemberNameToReal = function(memberAry) {
      var newMemberAry;
      newMemberAry = [];
      newMemberAry = _.map(memberAry, function(compObj) {
        var instanceComp, instanceRef, instanceUID;
        if (compObj.type === 'AWS.VPC.NetworkInterface' && compObj.name === 'eni0') {
          instanceRef = compObj.resource.Attachment.InstanceId;
          instanceUID = instanceRef.split('.')[0].slice(1);
          instanceComp = MC.canvas_data.component[instanceUID];
          return instanceComp;
        } else {
          return compObj;
        }
      });
      return newMemberAry;
    };
    return {
      getAllRefComp: getAllRefComp,
      getAllRule: getAllRule,
      getSgRuleDetail: getSgRuleDetail,
      createNewSG: createNewSG,
      addSGToProperty: addSGToProperty,
      getSGColor: getSGColor,
      updateSGColorLabel: updateSGColorLabel,
      deleteRefInAllComp: deleteRefInAllComp,
      getDefaultSG: getDefaultSG,
      convertMemberNameToReal: convertMemberNameToReal
    };
  });

}).call(this);
