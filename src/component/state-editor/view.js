// Generated by CoffeeScript 1.6.3
var StateEditorView;

StateEditorView = Backbone.View.extend({
  el: '#state-editor',
  model: new StateEditorModel(),
  editorHTML: $('#state-template-main').html(),
  paraListHTML: $('#state-template-para-list').html(),
  paraDictListHTML: $('#state-template-para-dict-item').html(),
  events: {
    'keyup .parameter-item.dict .parameter-value': 'onDictInputChange',
    'blur .parameter-item.dict .parameter-value': 'onDictInputBlur'
  },
  initialize: function() {
    this.compileTpl();
    return this.render();
  },
  render: function() {
    return this.refreshStateList();
  },
  compileTpl: function() {
    this.editorTpl = Handlebars.compile(this.editorHTML);
    Handlebars.registerPartial('state-template-para-list', this.paraListHTML);
    Handlebars.registerPartial('state-template-para-dict-item', this.paraDictListHTML);
    this.paraListTpl = Handlebars.compile(this.paraListHTML);
    return this.paraDictListTpl = Handlebars.compile(this.paraDictListHTML);
  },
  refreshStateList: function() {
    var cmdName, cmdParaAry, cmdParaMap, stateListObj, that;
    that = this;
    cmdName = 'apt pkg';
    cmdParaMap = that.model.get('cmdParaMap');
    cmdParaAry = cmdParaMap[cmdName];
    stateListObj = {
      state_list: [
        {
          cmd_name: cmdName,
          parameter_list: cmdParaAry
        }
      ]
    };
    that.$el.html(this.editorTpl(stateListObj));
    return that.bindCommandEvent();
  },
  refreshParaList: function(cmdName) {
    var cmdParaAry, cmdParaMap, that;
    that = this;
    if (!cmdName) {
      $('.parameter-list').html('');
      return;
    }
    cmdParaMap = that.model.get('cmdParaMap');
    cmdParaAry = cmdParaMap[cmdName];
    $('.parameter-list').html(that.paraListTpl({
      parameter_list: cmdParaAry
    }));
    return that.bindParaListEvent(cmdName);
  },
  bindCommandEvent: function() {
    var $cmdValueInput, cmdNameAry, cmdParaMap, that;
    that = this;
    cmdParaMap = that.model.get('cmdParaMap');
    cmdNameAry = _.keys(cmdParaMap);
    cmdNameAry = $.map(cmdNameAry, function(value, i) {
      return {
        'name': value
      };
    });
    $cmdValueInput = $('.editable-area.command-value');
    $cmdValueInput.atwho({
      at: '',
      tpl: '<li data-value="${atwho-at}${name}">${name}</li>',
      data: cmdNameAry,
      onSelected: function(value) {
        $cmdValueInput.attr('data-value', value);
        return that.refreshParaList(value);
      }
    });
    return that.refreshParaList();
  },
  bindParaListEvent: function(cmdName) {
    var atValueAry, cmdParaMap, that;
    that = this;
    cmdParaMap = that.model.get('cmdParaMap');
    atValueAry = cmdParaMap[cmdName];
    return $('.parameter-list .editable-area.line, .editable-area.text').atwho({
      at: '@',
      tpl: '<li data-value="${atwho-at}${name}">${name}</li>',
      data: atValueAry
    });
  },
  bindDictInputEvent: function($dictItem) {
    var $paraInputElem, atValueAry, cmdName, cmdParaMap, that;
    that = this;
    cmdName = that.getCurrentCommand($dictItem);
    cmdParaMap = that.model.get('cmdParaMap');
    atValueAry = cmdParaMap[cmdName];
    $paraInputElem = $dictItem.find('.parameter-value');
    return $paraInputElem.atwho({
      at: '@',
      tpl: '<li data-value="${atwho-at}${name}">${name}</li>',
      data: atValueAry
    });
  },
  onDictInputChange: function(event) {
    var $currentDictItemContainer, $currentDictItemElem, $currentInputElem, $leftInputElem, $newDictItem, $rightInputElem, leftInputValue, newDictItemHTML, nextDictItemElemAry, nextInputAry, prevInputAry, rightInputValue, that;
    that = this;
    $currentInputElem = $(event.currentTarget);
    $currentDictItemElem = $currentInputElem.parents('.parameter-dict-item');
    nextDictItemElemAry = $currentDictItemElem.next();
    if (!nextDictItemElemAry.length) {
      $currentDictItemContainer = $currentDictItemElem.parents('.parameter-container');
      prevInputAry = $currentInputElem.prev();
      nextInputAry = $currentInputElem.next();
      $leftInputElem = null;
      $rightInputElem = null;
      if (nextInputAry.length) {
        $leftInputElem = $currentInputElem;
        $rightInputElem = $(nextInputAry[0]);
      } else if (prevInputAry.length) {
        $leftInputElem = $(prevInputAry[0]);
        $rightInputElem = $currentInputElem;
      }
      leftInputValue = $leftInputElem.text();
      rightInputValue = $rightInputElem.text();
      if (leftInputValue || rightInputValue) {
        newDictItemHTML = that.paraDictListTpl({});
        $newDictItem = $(newDictItemHTML).appendTo($currentDictItemContainer);
        return that.bindDictInputEvent($newDictItem);
      }
    }
  },
  onDictInputBlur: function(event) {
    var $currentDictItemContainer, $currentInputElem, allInputElemAry;
    $currentInputElem = $(event.currentTarget);
    $currentDictItemContainer = $currentInputElem.parents('.parameter-container');
    allInputElemAry = $currentDictItemContainer.find('.parameter-dict-item');
    return _.each(allInputElemAry, function(itemElem, idx) {
      var inputElemAry, isAllInputEmpty;
      inputElemAry = $(itemElem).find('.parameter-value');
      isAllInputEmpty = true;
      _.each(inputElemAry, function(inputElem) {
        if ($(inputElem).text()) {
          isAllInputEmpty = false;
        }
        return null;
      });
      if (isAllInputEmpty && idx !== allInputElemAry.length - 1) {
        $(itemElem).remove();
      }
      return null;
    });
  },
  getCurrentCommand: function($subElem) {
    var $cmdValue, $stateItem;
    $stateItem = $subElem.parents('state-item');
    $cmdValue = $stateItem.find('.command-value');
    return $cmdValue.text();
  }
});

StateEditorView;
