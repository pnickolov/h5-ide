(function() {
  define(['MC', 'constant', 'jquery', 'underscore'], function(MC, constant) {
    var addCacheMap, addProcess, addSEList, addSENameUIDList, addUnmanaged, addUnmanagedVpc, cacheIDMap, canvasData, convertUID, createUID, delCacheMap, delUnmanaged, deleteProcess, filterProcess, filterStateData, getCacheMap, getProcess, getUnmanagedVpc, initDataProcess, initSEList, initSENameUIDList, initUnmanaged, isCurrentTab, isResultRight, listCacheMap, listSE, listSENameUID, listUnmanaged, listUnmanagedVpc, processType, searchCacheMap, searchStackAppById, setCacheMap, setCurrentTabId, state_editor_list, state_editor_name_list, unmanaged_resource_list, unmanaged_vpc_list, verify500;
    canvasData = {
      init: function(data) {
        console.log('canvasData:init');
        return MC.canvas_data = $.extend(true, {}, data);
      },
      initSet: function(key, value) {
        console.log('canvasData:initSet', key, value);
        return MC.canvas_data[key] = value;
      },
      data: function(is_origin) {
        var data;
        if (is_origin == null) {
          is_origin = false;
        }
        console.log('canvasData:data', is_origin);
        if (is_origin) {
          data = $.extend(true, {}, MC.canvas_data);
        } else {
          if (!_.isEmpty(Design.instance())) {
            data = Design.instance().serialize();
          }
        }
        return data;
      },
      save: function(data) {
        console.log('canvasData:save', data);
        if (!_.isEmpty(Design.instance())) {
          return Design.instance().save(data);
        }
      },
      set: function(key, value) {
        console.log('canvasData:set', key, value);
        if (!_.isEmpty(Design.instance())) {
          return Design.instance().set(key, value);
        }
      },
      get: function(key) {
        console.log('canvasData:get', key);
        if (!_.isEmpty(Design.instance())) {
          return Design.instance().get(key);
        }
      },
      isModified: function() {
        console.log('canvasData:isModified');
        if (!_.isEmpty(Design.instance())) {
          return Design.instance().isModified();
        }
      },
      origin: function(origin_data) {
        if (_.isEmpty(origin_data)) {
          console.log('canvasData:get origin', MC.data.origin_canvas_data);
          return $.extend(true, {}, MC.data.origin_canvas_data);
        } else {
          console.log('canvasData:set origin', origin_data);
          return MC.data.origin_canvas_data = $.extend(true, {}, origin_data);
        }
      }
    };
    createUID = function(length) {
      var chars, i, str;
      if (length == null) {
        length = 8;
      }
      chars = void 0;
      str = void 0;
      chars = "0123456789abcdefghiklmnopqrstuvwxyz".split("");
      if (!length) {
        length = Math.floor(Math.random() * chars.length);
      }
      str = "";
      i = 0;
      while (i < length) {
        str += chars[Math.floor(Math.random() * chars.length)];
        i++;
      }
      return str;
    };
    isCurrentTab = function(tab_id) {
      console.log('isCurrentTab', tab_id);
      if (MC.data.current_tab_id === tab_id) {
        return true;
      } else {
        return false;
      }
    };
    setCurrentTabId = function(tab_id) {
      console.log('setCurrentTabId', tab_id);
      MC.data.current_tab_id = tab_id;
      return null;
    };
    searchStackAppById = function(id) {
      var error, obj, prefix, temp, value;
      console.log('searchStackAppById', id);
      value = null;
      try {
        prefix = id.split('-')[0];
        if (prefix === 'appview') {
          obj = searchCacheMap({
            key: 'id',
            value: id.replace('appview', 'process')
          });
          value = obj;
        } else if (prefix === 'new') {
          value = MC.data.nav_new_stack_list[id];
        } else if (prefix === 'stack' || prefix === 'app') {
          temp = id.split('-')[0] === 'stack' ? MC.data.nav_stack_list : MC.data.nav_app_list;
          _.each(temp, function(obj) {
            return _.each(obj.region_name_group, function(item) {
              if (item.id === id) {
                value = item;
              }
              return true;
            });
          });
        } else {
          console.error('unknown tab type ' + tab_id);
        }
      } catch (_error) {
        error = _error;
        console.log('searchStackAppById error, id is ' + id);
        console.log(error);
      }
      return value;
    };
    isResultRight = function(result) {
      console.log('isResultRight');
      if (result && !result.is_error && result.resolved_data && result.resolved_data.length > 0) {
        return true;
      } else if (!result) {
        return 'result_empty';
      } else if (result && result.is_error) {
        return 'result_error';
      } else if (result && !result.is_error && !result.resolved_data) {
        return 'resolved_data_empty';
      } else if (result && !result.is_error && result.resolved_data && (result.resolved_data.length = 0)) {
        return 'resolved_data_length';
      } else {
        return 'other_error';
      }
    };
    processType = function(id) {
      if (!_.isString(id)) {
        return void 0;
      } else if (id.indexOf('-') === -1) {
        return void 0;
      } else if (getCacheMap(id) && (id.split('-').length = 2)) {
        return 'appview';
      } else if (id.split('-')[0] === 'process' && id.split('-').length > 2) {
        return 'process';
      } else {
        return void 0;
      }
    };
    verify500 = function(result, is_test) {
      if (is_test == null) {
        is_test = false;
      }
      console.log('verify500', result, result.return_code);
      if (is_test) {
        result.is_error = true;
        result.return_code = -1;
      }
      if (result && result.return_code === -1) {
        window.location.href = "500.html";
      }
    };
    addProcess = function(id, data) {
      console.log('addProcess', id, data);
      MC.process[id] = data;
      return null;
    };
    deleteProcess = function(id) {
      console.log('deleteProcess', id);
      delete MC.process[id];
      delete MC.data.process[id];
      console.log(MC.process);
      return null;
    };
    getProcess = function(id) {
      console.log('getProcess', id);
      return MC.process[id];
    };
    filterProcess = function(id) {
      var obj, state, _ref;
      console.log('filterProcess', id);
      obj = this.searchStackAppById(id);
      state = null;
      if (obj && ((_ref = obj.state) === constant.APP_STATE.APP_STATE_STARTING || _ref === constant.APP_STATE.APP_STATE_STOPPING || _ref === constant.APP_STATE.APP_STATE_TERMINATING || _ref === constant.APP_STATE.APP_STATE_UPDATING)) {
        state = obj.state;
      }
      return state;
    };
    initDataProcess = function(id, type, data) {
      console.log('initDataProcess', id, type, data);
      MC.data.process = {};
      MC.data.process = $.extend(true, {}, data);
      if (MC.data.process && MC.data.process[id]) {
        MC.data.process[id].state = type;
      }
      console.log('current MC.data.process', MC.data.process);
      return MC.data.process;
    };
    cacheIDMap = {};
    listCacheMap = function() {
      console.log('listCacheMap');
      return cacheIDMap;
    };
    addCacheMap = function(uid, id, origin_id, region, type, state) {
      if (state == null) {
        state = 'OPEN';
      }
      console.log('addCacheMap', uid, id, origin_id, region, type, state);
      return cacheIDMap[id] = {
        'uid': uid,
        'id': id,
        'origin_id': origin_id,
        'region': region,
        'type': type,
        'state': state,
        'create_time': '',
        'origin_time': new Date()
      };
    };
    delCacheMap = function(id) {
      console.log('delCacheMap', id);
      if (id.split('-')[0] === 'appview') {
        id = id.replace('appview', 'process');
      }
      delete cacheIDMap[id];
      return cacheIDMap;
    };
    setCacheMap = function(vpc_id, data, state, type, create_time) {
      var obj;
      console.log('setCacheMap', vpc_id, data, state, type, create_time);
      obj = null;
      _.each(cacheIDMap, function(item) {
        if (item.origin_id === vpc_id) {
          if (data) {
            item.data = $.extend(true, {}, data);
          }
          if (state) {
            item.state = state;
          }
          if (type) {
            item.type = type;
          }
          if (create_time) {
            item.create_time = create_time;
          }
          return obj = item;
        }
      });
      return obj;
    };
    getCacheMap = function(id) {
      if (id.split('-')[0] === 'appview') {
        id = id.replace('appview', 'process');
      }
      return cacheIDMap[id];
    };
    searchCacheMap = function(conditions) {
      var obj;
      console.log('searchCacheMap', conditions);
      obj = null;
      _.each(cacheIDMap, function(item) {
        if (item[conditions.key] === conditions.value) {
          return obj = item;
        }
      });
      return obj;
    };
    unmanaged_resource_list = {};
    initUnmanaged = function() {
      console.log('initUnmanaged');
      return unmanaged_resource_list = {};
    };
    listUnmanaged = function() {
      console.log('listUnmanaged');
      return unmanaged_resource_list;
    };
    addUnmanaged = function(data) {
      console.log('addUnmanaged', data);
      return unmanaged_resource_list = data;
    };
    delUnmanaged = function(vpc_id) {
      var error;
      console.log('delUnmanaged', vpc_id);
      try {
        _.each(unmanaged_resource_list, function(item) {
          var delete_item;
          delete_item = {};
          _.each(item, function(vpc_item) {
            if (_.indexOf(_.keys(item), vpc_id) !== -1) {
              return delete_item = item[vpc_id];
            }
          });
          if (delete_item) {
            return delete item[vpc_id];
          }
        });
      } catch (_error) {
        error = _error;
        console.log('delUnmanaged', vpc_id, error);
      }
      return unmanaged_resource_list;
    };
    unmanaged_vpc_list = {};
    addUnmanagedVpc = function(key, value) {
      return unmanaged_vpc_list[key] = value;
    };
    getUnmanagedVpc = function(id) {
      console.log('getUnmanagedVpc', id);
      return unmanaged_vpc_list[id];
    };
    listUnmanagedVpc = function() {
      console.log('listUnmanagedVpc');
      return unmanaged_vpc_list;
    };
    state_editor_list = [];
    initSEList = function() {
      return state_editor_list = [];
    };
    listSE = function() {
      return state_editor_list;
    };
    addSEList = function(data) {
      var comp_list;
      console.log('addSEList', data);
      if (data && data.component) {
        addSENameUIDList(data);
        comp_list = _.values(data.component);
        if (comp_list && !_.isEmpty(comp_list) && _.isArray(comp_list)) {
          initSEList();
          _.each(comp_list, function(component) {
            var key_list, name;
            name = component.name;
            key_list = _.keys(component.resource);
            if (key_list && !_.isEmpty(key_list) && _.isArray(key_list) && !_.isEmpty(component.name)) {
              return _.each(key_list, function(item) {
                var str;
                str = '{' + name + '.' + item + '}';
                return state_editor_list.push({
                  'name': str,
                  'value': str
                });
              });
            }
          });
        }
      }
      console.log('state_editor_list', state_editor_list);
      MC.storage.set('state_editor_list', state_editor_list);
      return state_editor_list;
    };
    state_editor_name_list = {};
    initSENameUIDList = function() {
      return state_editor_name_list = {};
    };
    listSENameUID = function() {
      return state_editor_name_list;
    };
    addSENameUIDList = function(data) {
      console.log('addSENameUIDList', data);
      if (data && data.component) {
        initSENameUIDList();
        _.each(data.component, function(item) {
          return state_editor_name_list[item.name] = {
            uid: item.uid,
            type: item.type
          };
        });
      }
      console.log('state_editor_name_list', state_editor_name_list);
      MC.storage.set('state_editor_name_list', state_editor_name_list);
      return state_editor_name_list;
    };
    filterStateData = function(data) {
      var filter_data, reg;
      console.log('filterStateData', data);
      filter_data = $.extend(true, {}, data);
      reg = /[^@{][-\w\.]+[}]/igm;
      _.each(filter_data, function(item) {
        return item.parameter.verify_gpg = item.parameter.verify_gpg.replace(reg, function($0) {
          var obj, split_arr;
          console.log('sfasdfasdf', $0);
          split_arr = $0.split('.');
          obj = state_editor_name_list[split_arr[0]];
          if (obj && obj.uid && split_arr.length > 1) {
            return obj.uid + '.' + split_arr[1];
          } else {
            return $0;
          }
        });
      });
      return filter_data;
    };
    convertUID = function(str) {
      var new_str, reg;
      console.log('convertUID', str);
      reg = /[^@{][-\w\.]+[}]/igm;
      new_str = str.replace(reg, function($0) {
        var obj, split_arr;
        split_arr = $0.split('.');
        obj = state_editor_name_list[split_arr[0]];
        if (obj && obj.uid && split_arr.length > 1) {
          return obj.uid + '.' + split_arr[1];
        } else {
          return $0;
        }
      });
      return new_str;
    };
    return {
      canvasData: canvasData,
      isCurrentTab: isCurrentTab,
      isResultRight: isResultRight,
      setCurrentTabId: setCurrentTabId,
      searchStackAppById: searchStackAppById,
      processType: processType,
      verify500: verify500,
      addProcess: addProcess,
      getProcess: getProcess,
      deleteProcess: deleteProcess,
      filterProcess: filterProcess,
      initDataProcess: initDataProcess,
      createUID: createUID,
      addCacheMap: addCacheMap,
      delCacheMap: delCacheMap,
      setCacheMap: setCacheMap,
      getCacheMap: getCacheMap,
      searchCacheMap: searchCacheMap,
      listCacheMap: listCacheMap,
      initUnmanaged: initUnmanaged,
      listUnmanaged: listUnmanaged,
      addUnmanaged: addUnmanaged,
      delUnmanaged: delUnmanaged,
      addUnmanagedVpc: addUnmanagedVpc,
      getUnmanagedVpc: getUnmanagedVpc,
      listUnmanagedVpc: listUnmanagedVpc,
      initSEList: initSEList,
      listSE: listSE,
      addSEList: addSEList,
      initSENameUIDList: initSENameUIDList,
      listSENameUID: listSENameUID,
      addSENameUIDList: addSENameUIDList,
      filterStateData: filterStateData,
      convertUID: convertUID
    };
  });

}).call(this);
