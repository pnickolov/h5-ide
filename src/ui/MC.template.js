define(['handlebars'], function(Handlebars){ var __TEMPLATE__, TEMPLATE={"notification":{}};

__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  
  return "<i class=\"notification_close\">&times;</i>";
  }

  buffer += "<div class=\"notification_item "
    + escapeExpression(((stack1 = (depth0 && depth0.type)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "_item\">\n	<span>"
    + escapeExpression(((stack1 = (depth0 && depth0.template)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</span>\n	";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.should_stay), {hash:{},inverse:self.noop,fn:self.program(1, program1, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n</div>";
  return buffer;
  };
TEMPLATE.notification.item=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div style=\"width: 520px\">\n    <div class=\"modal-header\">\n        <h3>"
    + escapeExpression(((stack1 = (depth0 && depth0.title)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</h3>\n        <i class=\"modal-close\">&times;</i>\n    </div>\n    <div class=\"modal-body\">\n        <p class=\"modal-text-minor\">"
    + escapeExpression(((stack1 = (depth0 && depth0['intro-1'])),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</p>\n        <p class=\"modal-text-minor\">"
    + escapeExpression(((stack1 = (depth0 && depth0['intro-2'])),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</p>\n        <div class=\"modal-center-align-helper\">\n            <div class=\"modal-control-group\">\n                <div id=\"replace_stack\" style=\"padding: 10px 0\">\n                    <div class=\"radio\">\n                        <input id=\"radio-replace-stack\" type=\"radio\" name=\"save-stack-type\" checked>\n                        <label for=\"radio-replace-stack\"></label>\n                    </div>\n                    <label class=\"modal-text-minor\" for=\"radio-replace-stack\">"
    + escapeExpression(((stack1 = (depth0 && depth0.replace)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</label>\n                    <div style=\"padding: 10px 22px\" class=\"radio-instruction\">\n                        "
    + escapeExpression(((stack1 = (depth0 && depth0['replace-info'])),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + " \""
    + escapeExpression(((stack1 = (depth0 && depth0.input)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" "
    + escapeExpression(((stack1 = (depth0 && depth0['replace-info-end'])),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n                    </div>\n                </div>\n                <div id=\"save_new_stack\">\n                   <div class=\"radio\">\n                       <input id=\"radio-new-stack\" type=\"radio\" name=\"save-stack-type\">\n                       <label for=\"radio-new-stack\"></label>\n                   </div>\n                   <label class=\"modal-text-minor\" for=\"radio-new-stack\">"
    + escapeExpression(((stack1 = (depth0 && depth0['save-new'])),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</label>\n                   <div style=\"padding: 10px 22px\" class=\"radio-instruction hide\">\n                       <p>"
    + escapeExpression(((stack1 = (depth0 && depth0.instruction)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</p>\n                       <input class=\"input\" id=\"modal-input-value\" value=\""
    + escapeExpression(((stack1 = (depth0 && depth0.input)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" type=\"text\" style=\"width: 400px\"/>\n                       <div id=\"stack-name-exist\" class=\"hide\" style=\"color: #ec3c38\">"
    + escapeExpression(((stack1 = (depth0 && depth0['error-message'])),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</div>\n                   </div>\n                </div>\n            </div>\n        </div>\n    </div>\n    <div class=\"modal-footer\">\n        <button id=\"btn-confirm\" class=\"btn btn-"
    + escapeExpression(((stack1 = (depth0 && depth0.color)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\">"
    + escapeExpression(((stack1 = (depth0 && depth0.confirm)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</button>\n        <button class=\"btn modal-close btn-silver\">Cancel</button>\n    </div>\n</div>";
  return buffer;
  };
TEMPLATE.modalAppToStack=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n			<div class=\"modal-text-wraper\">\n				<div class=\"modal-center-align-helper\">\n					";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.input), {hash:{},inverse:self.program(4, program4, data),fn:self.program(2, program2, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n				</div>\n			</div>\n		";
  return buffer;
  }
function program2(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n						<div class=\"modal-control-group\">\n							<label class=\"modal-text-major\">"
    + escapeExpression(((stack1 = (depth0 && depth0.body)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</label>\n							<input id=\"modal-input-value\" class=\"input\" type=\"text\" value=\""
    + escapeExpression(((stack1 = (depth0 && depth0.input)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" />\n						</div>\n					";
  return buffer;
  }

function program4(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n						<div class=\"modal-text-major\">\n							";
  stack1 = ((stack1 = (depth0 && depth0.body)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1);
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n						</div>\n						";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.is_asg), {hash:{},inverse:self.noop,fn:self.program(5, program5, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n					";
  return buffer;
  }
function program5(depth0,data) {
  
  var buffer = "";
  buffer += "\n							<div class=\"modal-text-minor\">"
    + escapeExpression(helpers.i18n.call(depth0, "POP_CONFIRM_STOP_ASG", {hash:{},data:data}))
    + "</div>\n						";
  return buffer;
  }

function program7(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n			<div class=\"terminate-pro-app-confirm\">\n				";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.is_stop), {hash:{},inverse:self.program(11, program11, data),fn:self.program(8, program8, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n				<p class=\"confirm-area\"><input class=\"input\" id=\"confirm-app-name\" data-confirm=\""
    + escapeExpression(((stack1 = (depth0 && depth0.app_name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\"/></p>\n			</div>\n		";
  return buffer;
  }
function program8(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n					<p><b>"
    + escapeExpression(((stack1 = (depth0 && depth0.app_name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + escapeExpression(helpers.i18n.call(depth0, "POP_CONFIRM_PROD_APP_WARNING_MSG", {hash:{},data:data}))
    + "</b>"
    + escapeExpression(helpers.i18n.call(depth0, "POP_CONFIRM_STOP_PROD_APP_MSG", {hash:{},data:data}))
    + "\n						";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.is_asg), {hash:{},inverse:self.noop,fn:self.program(9, program9, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n					</p>\n					<p>"
    + escapeExpression(helpers.i18n.call(depth0, "POP_CONFIRM_STOP_PROD_APP_INPUT_LBL", {hash:{},data:data}))
    + "</p>\n				";
  return buffer;
  }
function program9(depth0,data) {
  
  var buffer = "";
  buffer += "\n							"
    + escapeExpression(helpers.i18n.call(depth0, "POP_CONFIRM_STOP_ASG", {hash:{},data:data}))
    + "\n						";
  return buffer;
  }

function program11(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n					<p><b>"
    + escapeExpression(((stack1 = (depth0 && depth0.app_name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + " "
    + escapeExpression(helpers.i18n.call(depth0, "POP_CONFIRM_PROD_APP_WARNING_MSG", {hash:{},data:data}))
    + "</b>"
    + escapeExpression(helpers.i18n.call(depth0, "POP_CONFIRM_TERMINATE_PROD_APP_MSG", {hash:{},data:data}))
    + "</p>\n					<p>"
    + escapeExpression(helpers.i18n.call(depth0, "POP_CONFIRM_TERMINATE_PROD_APP_INPUT_LBL", {hash:{},data:data}))
    + "</p>\n				";
  return buffer;
  }

function program13(depth0,data) {
  
  
  return "disabled";
  }

  buffer += "<div style=\"width:420px\">\n	<div class=\"modal-header\">\n		<h3>"
    + escapeExpression(((stack1 = (depth0 && depth0.title)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</h3>\n		<i class=\"modal-close\">&times;</i>\n	</div>\n	<div class=\"modal-body\">\n		";
  stack1 = helpers.unless.call(depth0, (depth0 && depth0.is_production), {hash:{},inverse:self.program(7, program7, data),fn:self.program(1, program1, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n	</div>\n	<div class=\"modal-footer\">\n		<button id=\"btn-confirm\" class=\"btn btn-"
    + escapeExpression(((stack1 = (depth0 && depth0.color)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" ";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.is_production), {hash:{},inverse:self.noop,fn:self.program(13, program13, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += ">"
    + escapeExpression(((stack1 = (depth0 && depth0.confirm)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</button>\n		<button class=\"btn modal-close btn-silver\">"
    + escapeExpression(helpers.i18n.call(depth0, "TOOL_POP_BTN_CANCEL", {hash:{},data:data}))
    + "</button>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.modalApp=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div style=\"width:700px\">\n	<div class=\"modal-header\">\n		<h3>"
    + escapeExpression(((stack1 = (depth0 && depth0.title)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</h3>\n		<i class=\"modal-close\">&times;</i>\n	</div>\n	<div class=\"modal-body\">\n		<textarea id=\"json-content\"></textarea>\n	</div>\n	<div class=\"modal-footer\">\n		<a id=\"btn-confirm\" class=\"btn btn-"
    + escapeExpression(((stack1 = (depth0 && depth0.color)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" href=\"data://text/plain;, ";
  stack1 = ((stack1 = (depth0 && depth0.filecontent)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1);
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\" download=\""
    + escapeExpression(((stack1 = (depth0 && depth0.download)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\">"
    + escapeExpression(((stack1 = (depth0 && depth0.confirm)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</a>\n		<button class=\"btn modal-close btn-silver\">"
    + escapeExpression(helpers.i18n.call(depth0, "TOOL_POP_BTN_CANCEL", {hash:{},data:data}))
    + "</button>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.modalToolbar=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div class=\"modal-resource-instance-detail\" style=\"width:420px\">\n	<div class=\"modal-header\">\n		<h3>"
    + escapeExpression(((stack1 = (depth0 && depth0.title)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</h3>\n		<i class=\"modal-close\">&times;</i>\n	</div>\n\n	<div class=\"modal-body\">\n		<dl class=\"dl-horizontal\">\n			<dt>DnsName</dt>\n			<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.dnsName)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n			<dt>Architecture</dt>\n			<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.architecture)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n			<dt>EbsOptimized</dt>\n			<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.ebsOptimized)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n			<dt>GroupSet</dt>\n			<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.groupSet)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n			<dt>Hypervisor</dt>\n			<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.hypervisor)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n			<dt>ImageId</dt>\n			<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.imageId)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n			<dt>InstanceState</dt>\n			<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.instanceState)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n			<dt>InstanceType</dt>\n			<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.instanceType)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n			<dt>IpAddress</dt>\n			<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.ipAddress)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n			<dt>KernelId</dt>\n			<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.kernelId)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n			<dt>KeyName</dt>\n			<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.keyName)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n			<dt>LaunchTime</dt>\n			<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.launchTime)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n			<dt>Monitoring</dt>\n			<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.monitoring)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n			<dt>NetworkInterfaceSet</dt>\n			<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.networkInterfaceSet)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n			<dt>AvailabilityZone</dt>\n			<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.availabilityZone)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n			<dt>PrivateDnsName</dt>\n			<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.privateDnsName)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n			<dt>RootDeviceName</dt>\n			<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.rootDeviceName)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n			<dt>RootDeviceType</dt>\n			<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.rootDeviceType)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n		</dl>\n	</div>\n\n	<div class=\"modal-footer\">\n		<button class=\"btn modal-close btn-silver\">"
    + escapeExpression(helpers.i18n.call(depth0, "POP_BTN_CLOSE", {hash:{},data:data}))
    + "</button>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.modalResourceInstanceDetail=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div class=\"bubble-head\">"
    + escapeExpression(((stack1 = (depth0 && depth0.title)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</div>\n<div class=\"bubble-content\">\n	<dl class=\"dl-horizontal\">\n		<dt>Start Time:</dt>\n		<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0['start-time'])),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n		<dt>Stop Time:</dt>\n		<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0['end-time'])),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n		<dt>Estimated Cost:</dt>\n		<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.cost)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n	</dl>\n</div>";
  return buffer;
  };
TEMPLATE.bubbleTest=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div class=\"bubble-head alert\">"
    + escapeExpression(((stack1 = (depth0 && depth0.title)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</div>\n<div class=\"bubble-content\">\n	"
    + escapeExpression(((stack1 = (depth0 && depth0.description)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n</div>";
  return buffer;
  };
TEMPLATE.bubbleAlert=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div class=\"bubble-head suggest\">"
    + escapeExpression(((stack1 = (depth0 && depth0.title)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</div>\n<div class=\"bubble-content\">\n	"
    + escapeExpression(((stack1 = (depth0 && depth0.description)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n</div>";
  return buffer;
  };
TEMPLATE.bubbleSuggest=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div class=\"bubble-head\"><i class=\"status-"
    + escapeExpression(((stack1 = (depth0 && depth0.status)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + " icon-label\"></i>"
    + escapeExpression(((stack1 = (depth0 && depth0.title)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "-("
    + escapeExpression(((stack1 = (depth0 && depth0.id)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + ")</div>\n<div class=\"bubble-content\">\n	<dl class=\"dl-horizontal\">\n		<dt>Launch Time:</dt>\n		<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0['launch-time'])),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n		<dt>Availability Zone:</dt>\n		<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.az)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n		<dt>Instance Type:</dt>\n		<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0['instance-type'])),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n	</dl>\n</div>";
  return buffer;
  };
TEMPLATE.bubbleInstanceInfo=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div class=\"bubble-head\"></i>"
    + escapeExpression(((stack1 = (depth0 && depth0.snapshotId)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</div>\n<div class=\"bubble-content\">\n	<dl class=\"dl-horizontal\">\n		<dt>SnapshotId</dt>\n		<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.snapshotId)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n		<dt>StartTime</dt>\n		<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.startTime)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n		<dt>Status</dt>\n		<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.status)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n		<dt>Size</dt>\n		<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.size)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n		<dt>Encrypted</dt>\n		<dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.encrypted)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n	</dl>\n</div>";
  return buffer;
  };
TEMPLATE.bubbleSnapshotInfo=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, escapeExpression=this.escapeExpression, functionType="function", self=this;

function program1(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n    <dt>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_BUB_IMAGEOWNERALIAS", {hash:{},data:data}))
    + "</dt> <dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.imageOwnerAlias)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n    ";
  return buffer;
  }

function program3(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n    <dt>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_BUB_IMAGEOWNERID", {hash:{},data:data}))
    + "</dt> <dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.imageOwnerId)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n    ";
  return buffer;
  }

  buffer += "<div class=\"bubble-head\">"
    + escapeExpression(((stack1 = (depth0 && depth0.id)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</div>\n<div class=\"bubble-content\">\n	<dl class=\"dl-horizontal\">\n		<dt>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_BUB_NAME", {hash:{},data:data}))
    + "</dt>            <dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n		<dt>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_BUB_DESCRIPTION", {hash:{},data:data}))
    + "</dt>     <dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.description)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n		<dt>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_BUB_ARCHITECTURE", {hash:{},data:data}))
    + "</dt>    <dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.architecture)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n		<dt>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_BUB_IMAGELOCATION", {hash:{},data:data}))
    + "</dt>   <dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.imageLocation)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n\n    ";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.imageOwnerAlias), {hash:{},inverse:self.program(3, program3, data),fn:self.program(1, program1, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n\n    <dt>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_BUB_ISPUBLIC", {hash:{},data:data}))
    + "</dt>       <dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.isPublic)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n		<dt>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_BUB_KERNELID", {hash:{},data:data}))
    + "</dt>       <dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.kernelId)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n		<dt>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_BUB_ROOTDEVICENAME", {hash:{},data:data}))
    + "</dt> <dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.rootDeviceName)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n		<dt>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_BUB_ROOTDEVICETYPE", {hash:{},data:data}))
    + "</dt> <dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.rootDeviceType)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n    <dt>Image Size</dt>    <dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.imageSize)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n    <dt>Instance Type</dt> <dd>"
    + escapeExpression(((stack1 = (depth0 && depth0.instanceType)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</dd>\n	</dl>\n</div>";
  return buffer;
  };
TEMPLATE.bubbleAMIInfo=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", escapeExpression=this.escapeExpression;


  buffer += "<div style=\"width:660px\">\n	<div class=\"modal-header\">\n		<h3>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_POP_CREATE_STACK_CREATE_THIS_STACK_IN", {hash:{},data:data}))
    + ":</h3>\n		<i class=\"modal-close\">×</i>\n	</div>\n	<div class=\"modal-body\">\n		<div id=\"createNewStack_wrap\">\n			<ul class=\"clearfix\">\n				<li>\n					<a class=\"new-stack-dialog\" href=\"javascript:void(0)\" data-supported-platform=\"ec2-classic\">\n						<h4>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_POP_CREATE_STACK_CLASSIC", {hash:{},data:data}))
    + "</h4>\n						<p>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_POP_CREATE_STACK_CLASSIC_INTRO", {hash:{},data:data}))
    + ".</p>\n					</a>\n				</li>\n				<li>\n					<a class=\"new-stack-dialog\" href=\"javascript:void(0)\" data-supported-platform=\"ec2-vpc\">\n						<h4>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_POP_CREATE_STACK_VPC", {hash:{},data:data}))
    + "</h4>\n						<p>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_POP_CREATE_STACK_VPC_INTRO", {hash:{},data:data}))
    + ".</p>\n					</a>\n				</li>\n			</ul>\n		</div>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.createNewStackClassic=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", escapeExpression=this.escapeExpression;


  buffer += "<div style=\"width:400px\">\n	<div class=\"modal-header\">\n		<h3>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_POP_CREATE_STACK_CREATE_STACK_ERROR", {hash:{},data:data}))
    + "</h3>\n		<i class=\"modal-close\">×</i>\n	</div>\n	<div class=\"modal-body\">\n		<div id=\"createNewStack_wrap\" class=\"load-account-attr-error\">\n			<p>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_POP_FALE_LOAD_RESOURCE_PLEASE_RETRY", {hash:{},data:data}))
    + "</p>\n			<button class=\"btn btn-blue\" id=\"reload-account-attributes\">"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_POP_BTN_RETRY", {hash:{},data:data}))
    + "</button>\n		</div>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.createNewStackErrorAndReload=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", escapeExpression=this.escapeExpression;


  buffer += "<div style=\"width:660px\">\n	<div class=\"modal-header\">\n		<h3>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_POP_CREATE_STACK_CREATE_THIS_STACK_IN", {hash:{},data:data}))
    + ":</h3>\n		<i class=\"modal-close\">×</i>\n	</div>\n	<div class=\"modal-body\">\n		<div id=\"createNewStack_wrap\">\n			<ul class=\"clearfix\">\n				<li>\n					<a class=\"new-stack-dialog\" href=\"javascript:void(0)\" data-supported-platform=\"default-vpc\">\n						<h4>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_POP_CREATE_STACK_DEFAULT_VPC", {hash:{},data:data}))
    + "</h4>\n						<p>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_POP_CREATE_STACK_DEFAULT_VPC_INTRO", {hash:{},data:data}))
    + ".</p>\n					</a>\n				</li>\n				<li>\n					<a class=\"new-stack-dialog\" href=\"javascript:void(0)\" data-supported-platform=\"custom-vpc\">\n						<h4>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_POP_CREATE_STACK_CUSTOM_VPC", {hash:{},data:data}))
    + "</h4>\n						<p>"
    + escapeExpression(helpers.i18n.call(depth0, "DASH_POP_CREATE_STACK_VPC_INTRO", {hash:{},data:data}))
    + ".</p>\n					</a>\n				</li>\n			</ul>\n		</div>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.createNewStackVPC=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n\nIPSec Tunnel #"
    + escapeExpression(((stack1 = (depth0 && depth0.number)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n================================================================================\n#1: Internet Key Exchange Configuration\n\nConfigure the IKE SA as follows\n  - Authentication Method    : "
    + escapeExpression(((stack1 = (depth0 && depth0.ike_protocol_method)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n  - Pre-Shared Key           : "
    + escapeExpression(((stack1 = (depth0 && depth0.ike_pre_shared_key)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n  - Authentication Algorithm : "
    + escapeExpression(((stack1 = (depth0 && depth0.ike_authentication_protocol_algorithm)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n  - Encryption Algorithm     : "
    + escapeExpression(((stack1 = (depth0 && depth0.ike_encryption_protocol)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n  - Lifetime                 : "
    + escapeExpression(((stack1 = (depth0 && depth0.ike_lifetime)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + " seconds\n  - Phase 1 Negotiation Mode : "
    + escapeExpression(((stack1 = (depth0 && depth0.ike_mode)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n  - Perfect Forward Secrecy  : "
    + escapeExpression(((stack1 = (depth0 && depth0.ike_perfect_forward_secrecy)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n\n#2: IPSec Configuration\n\nConfigure the IPSec SA as follows:\n  - Protocol                 : "
    + escapeExpression(((stack1 = (depth0 && depth0.ipsec_protocol)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n  - Authentication Algorithm : "
    + escapeExpression(((stack1 = (depth0 && depth0.ipsec_authentication_protocol)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n  - Encryption Algorithm     : "
    + escapeExpression(((stack1 = (depth0 && depth0.ipsec_encryption_protocol)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n  - Lifetime                 : "
    + escapeExpression(((stack1 = (depth0 && depth0.ipsec_lifetime)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + " seconds\n  - Mode                     : "
    + escapeExpression(((stack1 = (depth0 && depth0.ipsec_mode)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n  - Perfect Forward Secrecy  : "
    + escapeExpression(((stack1 = (depth0 && depth0.ipsec_perfect_forward_secrecy)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n\nIPSec Dead Peer Detection (DPD) will be enabled on the AWS Endpoint. We\nrecommend configuring DPD on your endpoint as follows:\n  - DPD Interval             : "
    + escapeExpression(((stack1 = (depth0 && depth0.ipsec_interval)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n  - DPD Retries              : "
    + escapeExpression(((stack1 = (depth0 && depth0.ipsec_retries)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n\nIPSec ESP (Encapsulating Security Payload) inserts additional\nheaders to transmit packets. These headers require additional space,\nwhich reduces the amount of space available to transmit application data.\nTo limit the impact of this behavior, we recommend the following\nconfiguration on your Customer Gateway:\n  - TCP MSS Adjustment       : "
    + escapeExpression(((stack1 = (depth0 && depth0.tcp_mss_adjustment)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + " bytes\n  - Clear Don't Fragment Bit : "
    + escapeExpression(((stack1 = (depth0 && depth0.clear_df_bit)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n  - Fragmentation            : "
    + escapeExpression(((stack1 = (depth0 && depth0.fragmentation_before_encryption)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n\n#3: Tunnel Interface Configuration\n\nYour Customer Gateway must be configured with a tunnel interface that is\nassociated with the IPSec tunnel. All traffic transmitted to the tunnel\ninterface is encrypted and transmitted to the Virtual Private Gateway.\n\nThe Customer Gateway and Virtual Private Gateway each have two addresses that relate\nto this IPSec tunnel. Each contains an outside address, upon which encrypted\ntraffic is exchanged. Each also contain an inside address associated with\nthe tunnel interface.\n\nThe Customer Gateway outside IP address was provided when the Customer Gateway\nwas created. Changing the IP address requires the creation of a new\nCustomer Gateway.\n\nThe Customer Gateway inside IP address should be configured on your tunnel\ninterface.\n\nOutside IP Addresses:\n  - Customer Gateway 		        : "
    + escapeExpression(((stack1 = (depth0 && depth0.customer_gateway_outside_address)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n  - Virtual Private Gateway	        : "
    + escapeExpression(((stack1 = (depth0 && depth0.vpn_gateway_outside_address)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n\nInside IP Addresses\n  - Customer Gateway         		: "
    + escapeExpression(((stack1 = (depth0 && depth0.customer_gateway_inside_address)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n  - Virtual Private Gateway             : "
    + escapeExpression(((stack1 = (depth0 && depth0.vpn_gateway_inside_address)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n\nConfigure your tunnel to fragment at the optimal size:\n  - Tunnel interface MTU     : 1436 bytes\n\n";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.isStaticRouting), {hash:{},inverse:self.program(4, program4, data),fn:self.program(2, program2, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n";
  return buffer;
  }
function program2(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n#4: Static Routing Configuration:\n\nTo route traffic between your internal network and your VPC,\nyou will need a static route added to your router.\n\nStatic Route Configuration Options:\n\n  - Next hop                      : "
    + escapeExpression(((stack1 = (depth0 && depth0.next_hop)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n\nYou should add static routes towards your internal network on the VGW.\nThe VGW will then send traffic towards your internal network over\nhe tunnels.\n";
  return buffer;
  }

function program4(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n#4: Border Gateway Protocol (BGP) Configuration:\n\nThe Border Gateway Protocol (BGPv4) is used within the tunnel, between the inside\nIP addresses, to exchange routes from the VPC to your home network. Each\nBGP router has an Autonomous System Number (ASN). Your ASN was provided\nto AWS when the Customer Gateway was created.\n\nBGP Configuration Options:\n  - Customer Gateway ASN	          : "
    + escapeExpression(((stack1 = (depth0 && depth0.customer_gateway_bgp_asn)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n  - Virtual Private  Gateway ASN          : "
    + escapeExpression(((stack1 = (depth0 && depth0.vpn_gateway_bgp_asn)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n  - Neighbor IP Address     		  : "
    + escapeExpression(((stack1 = (depth0 && depth0.neighbor_ip_address)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n  - Neighbor Hold Time       : "
    + escapeExpression(((stack1 = (depth0 && depth0.customer_gateway_bgp_hold_time)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n\nConfigure BGP to announce routes to the Virtual Private Gateway. The gateway\nwill announce prefixes to your customer gateway based upon the prefix you\nassigned to the VPC at creation time.\n";
  return buffer;
  }

  buffer += "Amazon Web Services\nVirtual Private Cloud\n\nVPN Connection Configuration\n================================================================================\nAWS utilizes unique identifiers to manipulate the configuration of\na VPN Connection. Each VPN Connection is assigned a VPN Connection Identifier\nand is associated with two other identifiers, namely the\nCustomer Gateway Identifier and the Virtual Private Gateway Identifier.\n\nYour VPN Connection ID		         : "
    + escapeExpression(((stack1 = (depth0 && depth0.vpnConnectionId)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\nYour Virtual Private Gateway ID          : "
    + escapeExpression(((stack1 = (depth0 && depth0.vpnGatewayId)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\nYour Customer Gateway ID    		 : "
    + escapeExpression(((stack1 = (depth0 && depth0.customerGatewayId)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\n\nA VPN Connection consists of a pair of IPSec tunnel security associations (SAs).\nIt is important that both tunnel security associations be configured.\n\n";
  stack1 = helpers.each.call(depth0, (depth0 && depth0.tunnel), {hash:{},inverse:self.noop,fn:self.program(1, program1, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n\n\n\nAdditional Notes and Questions\n================================================================================\n\n  - Amazon Virtual Private Cloud Getting Started Guide:\n      http://docs.amazonwebservices.com/AmazonVPC/latest/GettingStartedGuide\n  - Amazon Virtual Private Cloud Network Administrator Guide:\n      http://docs.amazonwebservices.com/AmazonVPC/latest/NetworkAdminGuide\n  - XSL Version: 2009-07-15-1119716";
  return buffer;
  };
TEMPLATE.configurationDownload=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<section id=\"modal-run-stack\">\n	<div class=\"modal-control-group clearfix\" data-bind=\"true\">\n		<label class=\"label\" for=\"app-name\">App Name</label>\n		<input id=\"app-name\" class=\"input modal-input-value\" type=\"text\" value=\""
    + escapeExpression(((stack1 = (depth0 && depth0.name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" data-ignore=\"true\">\n		<div class=\"runtime-error\" id=\"runtime-error-appname\"></div>\n	</div>\n	<div class=\"modal-control-group default-kp-group clearfix\" style=\"display:none;\">\n		<label for=\"\">$DefaultKeyPair</label>\n		<div id=\"kp-runtime-placeholder\"></div>\n		<div class=\"runtime-error\" id=\"runtime-error-kp\"></div>\n	</div>\n	<div class=\"modal-control-group app-usage-group clearfix\">\n		<label for=\"\">App Usage</label>\n		<div id=\"app-usage-selectbox\" class=\"selectbox\">\n			<div class=\"selection\"><i class=\"icon-app-type-testing\"></i>Testing</div>\n			<ul class=\"dropdown\" tabindex=\"-1\">\n				<li class=\"selected item\" data-value=\"testing\"><i class=\"icon-app-type-testing\"></i>Testing</li>\n				<li class=\"item\" data-value=\"development\"><i class=\"icon-app-type-development\"></i>Development</li>\n				<li class=\"item\" data-value=\"production\"><i class=\"icon-app-type-production\"></i>Production</li>\n				<li class=\"item\" data-value=\"others\"><i class=\"icon-app-type-others\" data-value=\"testing\"></i>Others</li>\n			</ul>\n		</div>\n	</div>\n	<div class=\"stack-validation\">\n		<details open style=\"display:none;\">\n			<summary>Stack Validation</summary>\n			<div id=\"stack-run-validation-container\"></div>\n		</details>\n		<div class=\"nutshell\" style=\"display: none;\">:<label></label></div>\n		<div class=\"validating\">\n			<div class=\"loading-spinner loading-spinner-small\"></div>\n			<p>Validating your stack...</p>\n		</div>\n	</div>\n	<div class=\"estimate clearfix\">\n		<span class=\"title\">Estimated Cost</span>\n		<span class=\"price\" id=\"label-total-fee\"><b>$"
    + escapeExpression(((stack1 = (depth0 && depth0.total_fee)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</b> / month</span>\n	</div>\n</section>";
  return buffer;
  };
TEMPLATE.modalRunStack=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var stack1, functionType="function", escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data,depth1) {
  
  var buffer = "", stack1;
  buffer += "\n";
  stack1 = helpers['if'].call(depth0, (depth1 && depth1.deletable), {hash:{},inverse:self.program(4, program4, data),fn:self.program(2, program2, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n<div class=\"rule-list-row\">\n	<div class='rule-direction-icon tooltip icon-"
    + escapeExpression(((stack1 = (depth0 && depth0.direction)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "' data-tooltip='";
  stack1 = helpers.ifCond.call(depth0, (depth0 && depth0.direction), "inbound", {hash:{},inverse:self.program(8, program8, data),fn:self.program(6, program6, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "'></div>\n	<div class='rule-reference tooltip truncate' data-tooltip='";
  stack1 = helpers.ifCond.call(depth0, (depth0 && depth0.direction), "inbound", {hash:{},inverse:self.program(12, program12, data),fn:self.program(10, program10, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "'>";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.color), {hash:{},inverse:self.noop,fn:self.program(14, program14, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += escapeExpression(((stack1 = (depth0 && depth0.relation)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</div>\n</div>\n<div class=\"rule-list-row\">\n	<div><span class=\"rule-protocol tooltip\" data-tooltip='"
    + escapeExpression(helpers.i18n.call(depth0, "PROP_SG_TIP_PROTOCOL", {hash:{},data:data}))
    + "' >"
    + escapeExpression(((stack1 = (depth0 && depth0.protocol)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</span></div>\n	<div class='rule-port tooltip' data-tooltip='"
    + escapeExpression(helpers.i18n.call(depth0, "PROP_SG_TIP_PORT_CODE", {hash:{},data:data}))
    + "'>"
    + escapeExpression(((stack1 = (depth0 && depth0.port)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</div>\n</div>\n";
  stack1 = helpers['if'].call(depth0, (depth1 && depth1.deletable), {hash:{},inverse:self.noop,fn:self.program(16, program16, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n</li>";
  return buffer;
  }
function program2(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n<li data-uid=\""
    + escapeExpression(((stack1 = (depth0 && depth0.ruleSetId)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" data-protocol=\""
    + escapeExpression(((stack1 = (depth0 && depth0.protocol)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" data-port=\""
    + escapeExpression(((stack1 = (depth0 && depth0.port)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" data-relation=\""
    + escapeExpression(((stack1 = (depth0 && depth0.relation)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" data-relationid=\""
    + escapeExpression(((stack1 = (depth0 && depth0.relationId)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" data-direction=\""
    + escapeExpression(((stack1 = (depth0 && depth0.direction)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" class=\"pos-r sg-create-rule-item\">\n";
  return buffer;
  }

function program4(depth0,data) {
  
  
  return "\n<li class=\"sg-create-rule-item\">\n";
  }

function program6(depth0,data) {
  
  
  return escapeExpression(helpers.i18n.call(depth0, "PROP_SG_TIP_INBOUND", {hash:{},data:data}));
  }

function program8(depth0,data) {
  
  
  return escapeExpression(helpers.i18n.call(depth0, "PROP_SG_TIP_OUTBOUND", {hash:{},data:data}));
  }

function program10(depth0,data) {
  
  
  return "Source";
  }

function program12(depth0,data) {
  
  
  return "Destination";
  }

function program14(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "<span class=\"sg-color\" style=\"background-color:"
    + escapeExpression(((stack1 = (depth0 && depth0.color)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\"></span>";
  return buffer;
  }

function program16(depth0,data) {
  
  var buffer = "";
  buffer += "<a href=\"#\" class=\"sg-rule-delete icon-remove tooltip\" data-tooltip='"
    + escapeExpression(helpers.i18n.call(depth0, "PROP_SG_TIP_REMOVE_RULE", {hash:{},data:data}))
    + "'></a>";
  return buffer;
  }

  stack1 = helpers.each.call(depth0, depth0, {hash:{},inverse:self.noop,fn:self.programWithDepth(1, program1, data, depth0),data:data});
  if(stack1 || stack1 === 0) { return stack1; }
  else { return ''; }
  };
TEMPLATE.sgRuleList=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var stack1, functionType="function", escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n<h3 class=\"sg-create-group truncate\"><span class=\"sg-color sg-color-rule-header\" style=\"background-color:"
    + escapeExpression(((stack1 = (depth0 && depth0.ownerColor)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\"></span>"
    + escapeExpression(((stack1 = (depth0 && depth0.ownerName)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</h3>\n<ul class=\"sg-rule-list\">";
  stack1 = ((stack1 = (depth0 && depth0.content)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1);
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "</ul>\n";
  return buffer;
  }

  stack1 = helpers.each.call(depth0, (depth0 && depth0.groups), {hash:{},inverse:self.noop,fn:self.program(1, program1, data),data:data});
  if(stack1 || stack1 === 0) { return stack1; }
  else { return ''; }
  };
TEMPLATE.groupedSgRuleList=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n<h3 class=\"sg-create-group truncate\"><span class=\"sg-color sg-color-rule-header\" style=\"background-color:"
    + escapeExpression(((stack1 = (depth0 && depth0.ownerColor)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\"></span>"
    + escapeExpression(((stack1 = (depth0 && depth0.ownerName)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</h3>\n<ul class=\"sg-rule-list\">";
  stack1 = ((stack1 = (depth0 && depth0.content)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1);
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "</ul>\n";
  return buffer;
  }

  buffer += "Following rule(s) will be deleted from its(their) security group:</div>\n<article class=\"scroll-wrap delete-sgrule-dialog\">\n<div class=\"scrollbar-veritical-wrap\"><div class=\"scrollbar-veritical-thumb\"></div></div>\n<div class=\"scroll-content\">\n";
  stack1 = helpers.each.call(depth0, depth0, {hash:{},inverse:self.noop,fn:self.program(1, program1, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n</div>\n</article>";
  return buffer;
  };
TEMPLATE.groupedSgRuleListDelConfirm=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var stack1, escapeExpression=this.escapeExpression, self=this, functionType="function";

function program1(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n<li class=\"input-ip-item\">\n  <div class=\"name tooltip\" data-tooltip=\"";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.autoAssign), {hash:{},inverse:self.program(4, program4, data),fn:self.program(2, program2, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\">\n    <label class=\"input-ip-wrap\" for=\"propertyIpListItem-"
    + escapeExpression(((stack1 = (data == null || data === false ? data : data.index)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\"><span class=\"input-ip-prefix\">"
    + escapeExpression(((stack1 = (depth0 && depth0.prefix)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</span>\n    <input type=\"text\" class=\"input input-ip\"  id=\"propertyIpListItem-"
    + escapeExpression(((stack1 = (data == null || data === false ? data : data.index)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" value=\""
    + escapeExpression(((stack1 = (depth0 && depth0.suffix)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" ";
  stack1 = helpers.unless.call(depth0, (depth0 && depth0.editable), {hash:{},inverse:self.noop,fn:self.program(6, program6, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += " data-ignore=\"true\" data-ignore-regexp=\"^[0-9.x]*$\" data-required=\"true\">\n    </label>\n  </div>\n  <div class=\"input-ip-eip-btn tooltip toggle-eip";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.hasEip), {hash:{},inverse:self.noop,fn:self.program(8, program8, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\" data-tooltip=\"";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.hasEip), {hash:{},inverse:self.program(12, program12, data),fn:self.program(10, program10, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\"></div>\n  ";
  stack1 = helpers.unless.call(depth0, (depth0 && depth0.unDeletable), {hash:{},inverse:self.noop,fn:self.program(14, program14, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n</li>\n";
  return buffer;
  }
function program2(depth0,data) {
  
  
  return escapeExpression(helpers.i18n.call(depth0, "PROP_INSTANCE_IP_MSG_2", {hash:{},data:data}));
  }

function program4(depth0,data) {
  
  
  return escapeExpression(helpers.i18n.call(depth0, "PROP_INSTANCE_IP_MSG_1", {hash:{},data:data}));
  }

function program6(depth0,data) {
  
  
  return "disabled=\"disabled\"";
  }

function program8(depth0,data) {
  
  
  return " associated";
  }

function program10(depth0,data) {
  
  
  return escapeExpression(helpers.i18n.call(depth0, "PROP_INSTANCE_IP_MSG_4", {hash:{},data:data}));
  }

function program12(depth0,data) {
  
  
  return escapeExpression(helpers.i18n.call(depth0, "PROP_INSTANCE_IP_MSG_3", {hash:{},data:data}));
  }

function program14(depth0,data) {
  
  
  return "<div class=\"icon-remove\"></div>";
  }

  stack1 = helpers.each.call(depth0, depth0, {hash:{},inverse:self.noop,fn:self.program(1, program1, data),data:data});
  if(stack1 || stack1 === 0) { return stack1; }
  else { return ''; }
  };
TEMPLATE.propertyIpList=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, escapeExpression=this.escapeExpression, functionType="function", self=this;

function program1(depth0,data) {
  
  var buffer = "";
  buffer += "\n				<div class=\"modal-text-minor\" style=\"margin-top:10px;\"><i class=\"icon-inbound\"></i>"
    + escapeExpression(helpers.i18n.call(depth0, "POP_SGRULE_LBL_INBOUND", {hash:{},data:data}))
    + "</div>\n			";
  return buffer;
  }

function program3(depth0,data) {
  
  var buffer = "";
  buffer += "\n			<div class=\"radio-group-horizontal\">\n				<div class=\"radio\">\n					<input id=\"radio_inbound\" type=\"radio\" name=\"sg-direction\" checked=\"checked\" value=\"inbound\" />\n					<label for=\"radio_inbound\"></label>\n				</div>\n				<label for=\"radio_inbound\" ><i class=\"icon-inbound icon-label\"></i>"
    + escapeExpression(helpers.i18n.call(depth0, "POP_SGRULE_LBL_INBOUND", {hash:{},data:data}))
    + "</label>\n			</div>\n\n			<div class=\"radio-group-horizontal\">\n				<div class=\"radio\">\n					<input id=\"radio_outbound\" type=\"radio\" name=\"sg-direction\" value=\"outbound\"/>\n					<label for=\"radio_outbound\"></label>\n				</div>\n				<label for=\"radio_outbound\"><i class=\"icon-outbound icon-label\"></i>"
    + escapeExpression(helpers.i18n.call(depth0, "POP_SGRULE_LBL_OUTBOUND", {hash:{},data:data}))
    + "</label>\n			</div>\n			";
  return buffer;
  }

function program5(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n					<li class=\"item truncate\" data-id=\"sg\" data-uid=\""
    + escapeExpression(((stack1 = (depth0 && depth0.id)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\"><span class=\"sg-color\" style=\"background-color:"
    + escapeExpression(((stack1 = (depth0 && depth0.color)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\"></span>"
    + escapeExpression(((stack1 = (depth0 && depth0.name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</li>\n					";
  return buffer;
  }

function program7(depth0,data) {
  
  
  return "\n							";
  }

function program9(depth0,data) {
  
  var buffer = "";
  buffer += "\n							<li class=\"item\" data-id=\"custom\">"
    + escapeExpression(helpers.i18n.call(depth0, "POP_SGRULE_PROTOCOL_CUSTOM", {hash:{},data:data}))
    + "</li>\n							<li class=\"item\" data-id=\"all\">"
    + escapeExpression(helpers.i18n.call(depth0, "POP_SGRULE_PROTOCOL_ALL", {hash:{},data:data}))
    + "</li>\n							";
  return buffer;
  }

function program11(depth0,data) {
  
  
  return "\n					<div class=\"sg-protocol-option-input\" id=\"sg-protocol-custom\">\n						<input class=\"input\" name=\"protocol-custom-ranged\" placeholder=\"0-255\" data-ignore=\"true\" data-ignore-regexp=\"^[0-9]*$\" data-required=\"true\">\n					</div>\n					<div class=\"sg-protocol-option-input\" id=\"sg-protocol-all\">\n						Port Range:<span>0-65535</span>\n					</div>\n				";
  }

  buffer += "<div id=\"modal-sg-rule\" data-bind=\"true\">\n	<div class=\"modal-header\">\n		<h3>"
    + escapeExpression(helpers.i18n.call(depth0, "POP_SGRULE_TITLE_ADD", {hash:{},data:data}))
    + "</h3><i class=\"modal-close\">&times;</i>\n	</div>\n\n	<div class=\"modal-body\">\n		<div class=\"modal-control-group clearfix\">\n			<label class=\"label-short\">"
    + escapeExpression(helpers.i18n.call(depth0, "POP_SGRULE_LBL_DIRECTION", {hash:{},data:data}))
    + "</label>\n\n			<div id=\"sg-modal-direction\">\n			";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.isClassic), {hash:{},inverse:self.program(3, program3, data),fn:self.program(1, program1, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n			</div>\n		</div>\n\n		<div class=\"modal-control-group clearfix\">\n			<label class=\"label-short\" for=\"securitygroup-modal-description\" id=\"rule-modal-ip-range\">"
    + escapeExpression(helpers.i18n.call(depth0, "POP_SGRULE_LBL_SOURCE", {hash:{},data:data}))
    + "</label>\n			<div class=\"selectbox\" id=\"sg-add-model-source-select\">\n				<div class=\"selection\">IP...</div>\n				<ul class=\"dropdown\">\n					<li class=\"item selected\" data-id=\"custom\">IP...</li>\n					";
  stack1 = helpers.each.call(depth0, (depth0 && depth0.sgList), {hash:{},inverse:self.noop,fn:self.program(5, program5, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n				</ul>\n			</div>\n			<input class=\"input\" type=\"text\" id=\"securitygroup-modal-description\" data-ignore=\"true\" data-ignore-regexp=\"^[0-9./]*$\" data-required=\"true\" placeholder='"
    + escapeExpression(helpers.i18n.call(depth0, "POP_SGRULE_PLACEHOLD_SOURCE", {hash:{},data:data}))
    + "'>\n		</div>\n\n		<div class=\"modal-control-group clearfix\">\n			<label class=\"label-short\" >"
    + escapeExpression(helpers.i18n.call(depth0, "POP_SGRULE_LBL_PROTOCOL", {hash:{},data:data}))
    + "</label>\n				<div class=\"modal-protocol-select\">\n					<div class=\"selectbox\" id=\"modal-protocol-select\"  data-protocal-type=\"tcp\">\n						<div class=\"selection\">"
    + escapeExpression(helpers.i18n.call(depth0, "POP_SGRULE_PROTOCOL_TCP", {hash:{},data:data}))
    + "</div>\n						<ul class=\"dropdown\" tabindex=\"-1\">\n							<li class=\"selected item\" data-id=\"tcp\">"
    + escapeExpression(helpers.i18n.call(depth0, "POP_SGRULE_PROTOCOL_TCP", {hash:{},data:data}))
    + "</li>\n							<li class=\"item\" data-id=\"udp\">"
    + escapeExpression(helpers.i18n.call(depth0, "POP_SGRULE_PROTOCOL_UDP", {hash:{},data:data}))
    + "</li>\n							<li class=\"item\" data-id=\"icmp\">"
    + escapeExpression(helpers.i18n.call(depth0, "POP_SGRULE_PROTOCOL_ICMP", {hash:{},data:data}))
    + "</li>\n							";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.isClassic), {hash:{},inverse:self.program(9, program9, data),fn:self.program(7, program7, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n						</ul>\n					</div>\n				</div>\n			<div id=\"sg-protocol-select-result\">\n				<div class=\"sg-protocol-option-input show\" id=\"sg-protocol-tcp\">\n					<input class=\"input\" type=\"text\" placeholder='"
    + escapeExpression(helpers.i18n.call(depth0, "POP_SGRULE_PLACEHOLD_PORT_RANGE", {hash:{},data:data}))
    + "' data-ignore=\"true\" data-ignore-regexp=\"^[0-9-]*$\"  data-required=\"true\"/>\n				</div>\n				<div class=\"sg-protocol-option-input\" id=\"sg-protocol-udp\">\n					<input class=\"input\" type=\"text\" placeholder='"
    + escapeExpression(helpers.i18n.call(depth0, "POP_SGRULE_PLACEHOLD_PORT_RANGE", {hash:{},data:data}))
    + "' data-ignore=\"true\" data-ignore-regexp=\"^[0-9-]*$\" data-required=\"true\"/>\n				</div>\n\n				<div class=\"sg-protocol-option-input\" id=\"sg-protocol-icmp\">\n					<div class=\"selectbox\" id=\"protocol-icmp-main-select\" data-protocal-main=\"0\"  data-protocal-sub=\"-1\">\n					<div class=\"selection\">Echo Reply(0)</div>\n					<div class=\"dropdown scroll-wrap scrollbar-auto-hide context-wrap\" style=\"height:300px;\">\n						<div class=\"scrollbar-veritical-wrap\"><div class=\"scrollbar-veritical-thumb\"></div></div>\n						<ul tabindex=\"-1\" class=\"scroll-content\">\n							<li class=\"item selected\" data-id=\"0\">Echo Reply(0)</li>\n							<li class=\"item\" data-id=\"3\">Destination Unreachable(3) ...</li>\n							<li class=\"item\" data-id=\"4\">Source Quench(4)</li>\n							<li class=\"item\" data-id=\"5\">Redirect Message(5) ...</li>\n							<li class=\"item\" data-id=\"6\">Alternate Host Address(6)</li>\n							<li class=\"item\" data-id=\"8\">Echo Request(8)</li>\n							<li class=\"item\" data-id=\"9\">Router Advertisement(9)</li>\n							<li class=\"item\" data-id=\"10\">Router Solicitation(10)</li>\n							<li class=\"item\" data-id=\"11\">Time Exceeded(11) ...</li>\n							<li class=\"item\" data-id=\"12\">Parameter Problem: Bad IP header(12) ...</li>\n							<li class=\"item\" data-id=\"13\">Timestamp(13)</li>\n							<li class=\"item\" data-id=\"14\">Timestamp Reply(14)</li>\n							<li class=\"item\" data-id=\"15\">Information Request(15)</li>\n							<li class=\"item\" data-id=\"16\">Information Reply(16)</li>\n							<li class=\"item\" data-id=\"17\">Address Mask Request(17)</li>\n							<li class=\"item\" data-id=\"18\">Address Mask Reply(18)</li>\n							<li class=\"item\" data-id=\"30\">Traceroute(30)</li>\n							<li class=\"item\" data-id=\"31\">Datagram Conversion Error(31)</li>\n							<li class=\"item\" data-id=\"32\">Mobile Host Redirect(32)</li>\n							<li class=\"item\" data-id=\"33\">Where Are You(33)</li>\n							<li class=\"item\" data-id=\"34\">Here I Am(34)</li>\n							<li class=\"item\" data-id=\"35\">Mobile Registration Request(35)</li>\n							<li class=\"item\" data-id=\"36\">Mobile Registration Reply(36)</li>\n							<li class=\"item\" data-id=\"37\">Domain Name Request(37)</li>\n							<li class=\"item\" data-id=\"38\">Domain Name Reply(38)</li>\n							<li class=\"item\" data-id=\"39\">SKIP Algorithm Discovery Protocol(39)</li>\n							<li class=\"item\" data-id=\"40\">Photuris Security Failures(40)</li>\n							<li class=\"item\" data-id=\"-1\">All(-1)</li>\n						</ul>\n					</div>\n					</div>\n				</div>\n\n				<div class=\"selectbox protocol-icmp-sub-select\" id=\"protocol-icmp-sub-select-3\">\n					<div class=\"selection\">All(-1)</div>\n					<div class=\"dropdown scroll-wrap scrollbar-auto-hide context-wrap\" style=\"height:300px;\">\n						<div class=\"scrollbar-veritical-wrap\"><div class=\"scrollbar-veritical-thumb\"></div></div>\n						<ul class=\"scroll-content\" tabindex=\"-1\">\n							<li class=\"item selected\" data-id=\"-1\">All(-1)</li>\n							<li class=\"item\" data-id=\"0\">destination network unreachable(0)</li>\n							<li class=\"item\" data-id=\"1\">destination host unreachable(1)</li>\n							<li class=\"item\" data-id=\"2\">destination protocol unreachable(2)</li>\n							<li class=\"item\" data-id=\"3\">destination port unreachable(3)</li>\n							<li class=\"item\" data-id=\"4\">fragmentation required and DF flag set(4)</li>\n							<li class=\"item\" data-id=\"5\">source route failed(5)</li>\n							<li class=\"item\" data-id=\"6\">destination network unknown(6)</li>\n							<li class=\"item\" data-id=\"7\">destination host unknown(7)</li>\n							<li class=\"item\" data-id=\"8\">source host isolated(8)</li>\n							<li class=\"item\" data-id=\"9\">network administratively prohibited(9)</li>\n							<li class=\"item\" data-id=\"10\">host administratively prohibited(10)</li>\n							<li class=\"item\" data-id=\"11\">network unreachable for TOS(11)</li>\n							<li class=\"item\" data-id=\"12\">host unreachable for TOS(12)</li>\n							<li class=\"item\" data-id=\"13\">communication administratively prohibited(13)</li>\n						</ul>\n					</div>\n				</div>\n\n				<div class=\"selectbox protocol-icmp-sub-select\" id=\"protocol-icmp-sub-select-5\">\n					<div class=\"selection\">All(-1)</div>\n					<ul class=\"dropdown\" tabindex=\"-1\">\n						<li class=\"selected item\" data-id=\"-1\">All(-1)</li>\n						<li class=\"item\" data-id=\"0\">redirect datagram for the network(0)</li>\n						<li class=\"item\" data-id=\"1\">redirect datagram for the host(1)</li>\n						<li class=\"item\" data-id=\"2\">redirect datagram for the TOS & network(2)</li>\n						<li class=\"item\" data-id=\"3\">redirect datagram for the TOS & host(3)</li>\n					</ul>\n				</div>\n\n				<div class=\"selectbox protocol-icmp-sub-select\" id=\"protocol-icmp-sub-select-11\">\n					<div class=\"selection\">All(-1)</div>\n					<ul class=\"dropdown\" tabindex=\"-1\">\n						<li class=\"item selected\" data-id=\"-1\">All(-1)</li>\n						<li class=\"item\" data-id=\"0\">TTL expired transit(0)</li>\n						<li class=\"item\" data-id=\"1\">fragmentation reasembly time exceeded(1)</li>\n					</ul>\n				</div>\n\n				<div class=\"selectbox protocol-icmp-sub-select\" id=\"protocol-icmp-sub-select-12\">\n					<div class=\"selection\">All(-1)</div>\n					<ul class=\"dropdown\" role=\"menu\">\n						<li class=\"item selected\" data-id=\"-1\">All(-1)</li>\n						<li class=\"item\" data-id=\"0\">pointer indicates the error(0)</li>\n						<li class=\"item\" data-id=\"1\">missing a required option(1)</li>\n						<li class=\"item\" data-id=\"2\">bad length(2)</li>\n					</ul>\n				</div>\n\n				";
  stack1 = helpers.unless.call(depth0, (depth0 && depth0.isClassic), {hash:{},inverse:self.noop,fn:self.program(11, program11, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n			</div>\n		</div>\n	</div>\n	<div class=\"modal-footer\">\n		<button class=\"btn btn-blue\" id='sg-modal-save'>"
    + escapeExpression(helpers.i18n.call(depth0, "POP_SGRULE_BTN_SAVE", {hash:{},data:data}))
    + "</button>\n		<button class=\"btn btn-silver modal-close\">"
    + escapeExpression(helpers.i18n.call(depth0, "POP_SGRULE_BTN_CANCEL", {hash:{},data:data}))
    + "</button>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.modalSGRule=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div style=\"width:500px\">\n	<div class=\"modal-header\">\n		<h3>Get Windows Password</h3>\n		<i class=\"modal-close\">&times;</i>\n	</div>\n	<div class=\"modal-body\">\n		<section class=\"password-hint\">\n			<p class=\"modal-text-major\">This instance was associated with key pair: <span>"
    + escapeExpression(((stack1 = (depth0 && depth0.name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</span></p>\n			<p>To access this instance remotely (e.g. Remote Desktop Connection), you will need your Windows Administrator password. A default password was created when the instance was launched and is available encrypted in the system log.</p>\n		</section>\n		<section class=\"import-zone\">\n			<div id='keypair-loading' class=\"loading-spinner\"></div>\n		</section>\n		<section class=\"decrypt-action\" style=\"display: none;\">\n			<button class=\"btn btn-blue\" id=\"do-kp-decrypt\" disabled>Decrypt Password</button>\n			<input readonly class=\"input\" type=\"text\" id=\"keypair-pwd\" placeholder=\"Decripted password will appear here\">\n			<div class=\"change-pw-recommend icon-info tooltip\" data-tooltip=\"We recommend that you change your password to one that you will remember and know privately. Please note that passwords can persist through bundling phases and will not be retrievable through this tool. It is therefore important that you change your password to one that you will remember if you intend to bundle a new AMI from this instance.\" style=\"display: none;\">Change Password Recommendation from AWS</div>\n		</section>\n		<section class=\"no-password\" style=\"display: none;\">\n			<p>\n				Your password is not ready. Password generation can sometimes take more than 30 minutes. Please wait at least 15 minutes after launching an instance before trying to retrieve the generated password.\n			</p>\n\n			<p>\n				If you launched this instance from your own AMI, the password is the same as for the instance from which you created the AMI, unless this setting was modified in the EC2Config service settings.\n			</p>\n		</section>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.modalDecryptPassword=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  
  return "\n			<div id='keypair-loading' class=\"loading-spinner\"></div>\n		";
  }

function program3(depth0,data) {
  
  
  return "class=\"hide\"";
  }

function program5(depth0,data) {
  
  
  return "\n			<div class=\"keypair-download clearfix modal-control-group\">\n				<p class=\"modal-text-major left\">Key Pair data is ready</p>\n				<a href=\"#\" class=\"btn btn-blue right\" id=\"keypair-kp-download\">Download</a>\n			</div>\n			";
  }

function program7(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n			<div class=\"keypair-download clearfix modal-control-group\">\n				<p class=\"modal-text-major\">This instance was associated with key pair: "
    + escapeExpression(((stack1 = (depth0 && depth0.name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</p>\n			</div>\n			";
  return buffer;
  }

function program9(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n			<div id=\"keypair-remote\" class=\"modal-control-group clearfix\">\n				<label for=\"keypair-cmd\">Remote Access</label>\n				<input class=\"input\" id=\"keypair-cmd\" type=\"text\" readonly=\"readonly\" value=\""
    + escapeExpression(((stack1 = (depth0 && depth0.loginCmd)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\">\n			</div>\n			";
  return buffer;
  }

function program11(depth0,data) {
  
  
  return "\n			<div class=\"modal-control-group clearfix\">\n				<label style=\"width:100%;\">Windows Login Password</label>\n				<div id=\"keypair-login\">\n					<input type=\"password\" readonly=\"readonly\" id=\"keypair-pwd-old\" class=\"input\">\n					<a href=\"#\" class=\"btn btn-silver kp-copy-btn\" id=\"keypair-show\">Show password</a>\n				</div>\n				<div id=\"keypair-no-pwd\"></div>\n			</div>\n			";
  }

  buffer += "<div style=\"width:420px\">\n	<div class=\"modal-header\">\n		<h3 id='keypair-name'>"
    + escapeExpression(((stack1 = (depth0 && depth0.name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</h3>\n		<i class=\"modal-close\">&times;</i>\n	</div>\n	<div class=\"modal-body\">\n		";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.isOldKp), {hash:{},inverse:self.noop,fn:self.program(1, program1, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n		<section id=\"keypair-body\" ";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.isOldKp), {hash:{},inverse:self.noop,fn:self.program(3, program3, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += ">\n			";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.isOldKp), {hash:{},inverse:self.program(7, program7, data),fn:self.program(5, program5, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n			";
  stack1 = helpers.unless.call(depth0, (depth0 && depth0.windows), {hash:{},inverse:self.program(11, program11, data),fn:self.program(9, program9, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n\n		</section>\n	</div>\n\n	<div class=\"modal-footer\">\n		<button class=\"btn modal-close btn-silver\">Close</button>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.modalDownloadKP=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  


  return "<article>\n	<div class=\"property-control-group\">This resource is not available. It may have been deleted from other source or terminated in previous app editing.</div>\n</article>";
  };
TEMPLATE.missingPropertyPanel=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<article>\n	<div class=\"property-control-group\">"
    + escapeExpression(((stack1 = (depth0 && depth0.asgName)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + " is deleted in stopped app. The auto scaling group will be created when the app is started.</div>\n</article>";
  return buffer;
  };
TEMPLATE.missingAsgWhenStop=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "<li>\n			<a href=\"#\" id=\""
    + escapeExpression(((stack1 = (depth0 && depth0.id)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" data-instance=\""
    + escapeExpression(((stack1 = (depth0 && depth0.instance_id)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" class=\"";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.snapshotId), {hash:{},inverse:self.program(4, program4, data),fn:self.program(2, program2, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "_item "
    + escapeExpression(((stack1 = (depth0 && depth0.deleted)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\">\n				<span class=\"volume_name\">"
    + escapeExpression(((stack1 = (depth0 && depth0.name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</span>\n				<span class=\"volume_size\">"
    + escapeExpression(((stack1 = (depth0 && depth0.size)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "GB</span>\n			</a>\n		</li>";
  return buffer;
  }
function program2(depth0,data) {
  
  
  return "snapshot";
  }

function program4(depth0,data) {
  
  
  return "volume";
  }

  buffer += "<div class=\"bubble-head\">Attached Volume <span id=\"instance_volume_number\">"
    + escapeExpression(((stack1 = (depth0 && depth0.length)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</span></div>\n<div id=\"instance_volume_wrap\" class=\"scroll-wrap\">\n	<div class=\"scrollbar-veritical-wrap\"><div class=\"scrollbar-veritical-thumb\"></div></div>\n	<ul id=\"instance_volume_list\" class=\"clearfix bubble-content scroll-content\">\n		";
  stack1 = helpers.each.call(depth0, depth0, {hash:{},inverse:self.noop,fn:self.program(1, program1, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n	</ul>\n</div>";
  return buffer;
  };
TEMPLATE.instanceVolume=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data,depth1) {
  
  var buffer = "", stack1;
  buffer += "\n		<li>\n			<a href=\"#\" class=\"asgList-item\" id=\""
    + escapeExpression(((stack1 = (depth0 && depth0.id)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" data-id=\""
    + escapeExpression(((stack1 = (depth0 && depth0.id)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\">\n				<i class=\"asgList-item-status tooltip status status-"
    + escapeExpression(((stack1 = (depth0 && depth0.state)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" data-tooltip=\""
    + escapeExpression(((stack1 = (depth0 && depth0.state)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" ></i>\n				<span class=\"asgList-item-icon\" style=\"background-image:url('/assets/images/"
    + escapeExpression(((stack1 = (depth0 && depth0.background)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "')\"></span>\n				<div class=\"asgList-item-volume\" data-target-id="
    + escapeExpression(((stack1 = (depth0 && depth0.id)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + ">\n					<span class=\"asgList-item-number\">"
    + escapeExpression(((stack1 = (depth1 && depth1.volume)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</span>\n				</div>\n				<span class=\"asgList-item-label\">"
    + escapeExpression(((stack1 = (depth0 && depth0.id)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</span>\n			</a>\n		</li>\n		";
  return buffer;
  }

  buffer += "<div id=\"asgList-wrap\">\n	<div id=\"asgList-header\">\n		<span id=\"asgList-title\">"
    + escapeExpression(((stack1 = (depth0 && depth0.name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</span>\n		<a id=\"asgList-close\" href=\"javascript:void(0)\" onclick=\"MC.canvas.asgList.close()\">&times;</a>\n	</div>\n	<ul id=\"asgList\" class=\"clearfix\">\n		";
  stack1 = helpers.each.call(depth0, depth0, {hash:{},inverse:self.noop,fn:self.programWithDepth(1, program1, data, depth0),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n	</ul>\n</div>";
  return buffer;
  };
TEMPLATE.asgList=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data,depth1) {
  
  var buffer = "", stack1;
  buffer += "\n		<li>\n			<a href=\"#\" class='instanceList-item "
    + escapeExpression(((stack1 = (depth0 && depth0.deleted)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "' id=\""
    + escapeExpression(((stack1 = (depth0 && depth0.id)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "_"
    + escapeExpression(((stack1 = (data == null || data === false ? data : data.index)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" data-id=\""
    + escapeExpression(((stack1 = (depth0 && depth0.appId)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\">\n				<i class=\"instanceList-item-status tooltip status status-"
    + escapeExpression(((stack1 = (depth0 && depth0.state)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" data-tooltip=\""
    + escapeExpression(((stack1 = (depth0 && depth0.state)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\"></i>\n				<span class=\"instanceList-item-icon\" style=\"background-image:url('/assets/images/"
    + escapeExpression(((stack1 = (depth1 && depth1.background)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "')\"></span>\n				<div class=\"instanceList-item-volume\" data-target-id=\""
    + escapeExpression(((stack1 = (depth0 && depth0.id)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "_"
    + escapeExpression(((stack1 = (data == null || data === false ? data : data.index)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\">\n					<span class=\"instanceList-item-number\">"
    + escapeExpression(((stack1 = (depth1 && depth1.volume)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</span>\n				</div>\n				<span class=\"instanceList-item-label\">"
    + escapeExpression(((stack1 = (depth0 && depth0.name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "-"
    + escapeExpression(((stack1 = (data == null || data === false ? data : data.index)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</span>\n			</a>\n		</li>\n		";
  return buffer;
  }

  buffer += "<div id=\"instanceList-wrap\" data-id=\""
    + escapeExpression(((stack1 = ((stack1 = (depth0 && depth0[0])),stack1 == null || stack1 === false ? stack1 : stack1.id)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\">\n	<div id=\"instanceList-header\">\n		<span id=\"instanceList-title\">"
    + escapeExpression(((stack1 = (depth0 && depth0.name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</span>\n		<a id=\"instanceList-close\" href=\"javascript:void(0)\" onclick=\"MC.canvas.instanceList.close()\">&times;</a>\n	</div>\n	<ul id=\"instanceList\" class=\"clearfix\">\n		";
  stack1 = helpers.each.call(depth0, depth0, {hash:{},inverse:self.noop,fn:self.programWithDepth(1, program1, data, depth0),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n	</ul>\n</div>";
  return buffer;
  };
TEMPLATE.instanceList=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data,depth1) {
  
  var buffer = "", stack1;
  buffer += "\n		<li>\n			<a href=\"#\" class=\"eniList-item "
    + escapeExpression(((stack1 = (depth0 && depth0.deleted)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" id=\""
    + escapeExpression(((stack1 = (depth0 && depth0.id)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "_"
    + escapeExpression(((stack1 = (data == null || data === false ? data : data.index)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" data-id=\""
    + escapeExpression(((stack1 = (depth0 && depth0.appId)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\">\n				<i class=\"eniList-item-eip-status";
  stack1 = helpers['if'].call(depth0, (depth1 && depth1.eip), {hash:{},inverse:self.noop,fn:self.program(2, program2, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\"></i>\n				<span class=\"eniList-item-label\">"
    + escapeExpression(((stack1 = (depth0 && depth0.appId)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</span>\n			</a>\n		</li>\n		";
  return buffer;
  }
function program2(depth0,data) {
  
  
  return " on";
  }

  buffer += "<div id=\"eniList-wrap\">\n	<div id=\"eniList-header\">\n		<span id=\"eniList-title\">"
    + escapeExpression(((stack1 = (depth0 && depth0.name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</span>\n		<a id=\"eniList-close\" href=\"javascript:void(0)\" onclick=\"MC.canvas.eniList.close()\">&times;</a>\n	</div>\n	<ul id=\"eniList\" class=\"clearfix\">\n		";
  stack1 = helpers.each.call(depth0, depth0, {hash:{},inverse:self.noop,fn:self.programWithDepth(1, program1, data, depth0),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n	</ul>\n</div>";
  return buffer;
  };
TEMPLATE.eniList=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div style=\"width:420px\">\n	<div class=\"modal-header\"> <h3>Set up CIDR Block</h3><i class=\"modal-close\">&times;</i> </div>\n	<div class=\"modal-body\">\n		<div class=\"modal-text-wraper\"> <div class=\"modal-center-align-helper\">\n			<div class=\"modal-text-major\">"
    + escapeExpression(((stack1 = (depth0 && depth0.main_content)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</div>\n			<div class=\"modal-text-minor\">"
    + escapeExpression(((stack1 = (depth0 && depth0.desc_content)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</div>\n		</div> </div>\n	</div>\n	<div class=\"modal-footer\">\n		<a id=\"cidr-remove\" class=\"link-red left link-modal-danger\">"
    + escapeExpression(((stack1 = (depth0 && depth0.remove_content)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</a>\n		<button id=\"cidr-return\" class=\"btn modal-close btn-blue\">OK</button>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.setupCIDRConfirm=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div class=\"modal-header\"> <h3>Attach Network Interface to Instance</h3><i class=\"modal-close\">&times;</i> </div>\n<div class=\"modal-body\">\n	<div class=\"modal-center-align-helper\">\n		<p>"
    + escapeExpression(((stack1 = (depth0 && depth0.host)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + " has been automatically assigned Public IP.</p>\n		<p>If you want to attach the external network interface to "
    + escapeExpression(((stack1 = (depth0 && depth0.host)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + ", the Public IP must be removed.</p>\n		<p>Do you still want to attach "
    + escapeExpression(((stack1 = (depth0 && depth0.eni)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + " to "
    + escapeExpression(((stack1 = (depth0 && depth0.host)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + " and remove the Public IP?</p>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.modalAttachingEni=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div style=\"width:420px\">\n	";
  stack1 = ((stack1 = (depth0 && depth0.confirm)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1);
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n	<div class=\"modal-footer\">\n		<button class=\"btn modal-close btn-blue\" id=\"canvas-op-confirm\" style=\"width:200px;\">"
    + escapeExpression(((stack1 = (depth0 && depth0.action)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</button>\n		<button class=\"btn modal-close btn-silver\">Cancel</button>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.modalCanvasConfirm=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div style=\"width:420px\">\n	<div class=\"modal-header\"> <h3>Stack Name Already in Use</h3><i class=\"modal-close\">&times;</i> </div>\n	<div class=\"modal-body\" style=\"min-height:120px;\">\n		<div class=\"modal-text-wraper\">\n			<div class=\"modal-center-align-helper\">\n				<div class=\"modal-text-major\">Stack name <span class=\"resource-name-label\">"
    + escapeExpression(((stack1 = (depth0 && depth0.stack_name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</span> is already used by another stack. Please use a different name.</div>\n				<div class=\"modal-control-group\" data-bind=\"true\">\n					<label for=\"new-stack-name\">Stack Name</label>\n					<input id=\"new-stack-name\" class=\"input modal-input-value\" type=\"text\" value=\""
    + escapeExpression(((stack1 = (depth0 && depth0.stack_name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" data-ignore=\"true\">\n				</div>\n			</div>\n		</div>\n	</div>\n	<div class=\"modal-footer\">\n		<button id=\"rename-confirm\" class=\"btn btn-blue\">Save</button>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.modalReinputStackName=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div style=\"width:420px\">\n	<div class=\"modal-header\"> <h3>"
    + escapeExpression(((stack1 = (depth0 && depth0.title)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</h3><i class=\"modal-close\">&times;</i> </div>\n	<div class=\"modal-body\">\n		<div class=\"modal-text-wraper\">\n			 <div class=\"modal-center-align-helper\">\n				<div class=\"modal-text-major\">"
    + escapeExpression(((stack1 = (depth0 && depth0.main_content)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</div>\n				<div class=\"modal-text-minor\">"
    + escapeExpression(((stack1 = (depth0 && depth0.desc_content)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</div>\n			</div>\n		 </div>\n	</div>\n	<div class=\"modal-footer\">\n		<button id=\"modal-confirm-delete\" class=\"btn btn-red\">Delete</button>\n		<button id=\"modal-cancel\" class=\"btn modal-close btn-silver\">Cancel</button>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.modalDeleteSGOrACL=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  


  return "<div id=\"loading-modal-wrap\">\n	<div class=\"loading-modal\" id=\"modal-box\">\n		<div class=\"loading-spinner loading-spinner-mid\"></div>\n		<div>Refreshing resources...</div>\n	</div>\n</div>";
  };
TEMPLATE.loadingTransparent=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div style=\"width:420px\">\n	<div class=\"modal-header\"> <h3>"
    + escapeExpression(((stack1 = (depth0 && depth0.title)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</h3><i class=\"modal-close\">&times;</i> </div>\n	<div class=\"modal-body\">\n		<div class=\"modal-text-wraper\">\n			 <div class=\"modal-center-align-helper\">\n				<div class=\"modal-text-major\">"
    + escapeExpression(((stack1 = (depth0 && depth0.main_content)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</div>\n				<div class=\"modal-text-minor\">"
    + escapeExpression(((stack1 = (depth0 && depth0.desc_content)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</div>\n			</div>\n		 </div>\n	</div>\n	<div class=\"modal-footer\">\n		<button id=\"modal-confirm-delete\" class=\"btn btn-red\">Delete</button>\n		<button id=\"modal-cancel\" class=\"btn modal-close btn-silver\">Cancel</button>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.modalForceDeleteApp=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  


  return "<div>\n	<div class=\"info\">Last saved: <span class=\"stack-save-time\">-<span></div>\n	<ul class=\"statusbar-btn-list\">\n		<li class=\"statusbar-btn btn-state\">\n			<span class=\"state-success\"><i class=\"status status-green icon-label\"></i><b>0</b></span>\n			<span class=\"state-failed\"><i class=\"status status-red icon-label\"></i><b>0</b></span>\n		</li>\n		<li class=\"statusbar-btn btn-ta-valid\">Validate</li>\n	</ul>\n</div>";
  };
TEMPLATE.statusbar=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n				<li>"
    + escapeExpression(((stack1 = (depth0 && depth0.name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "( "
    + escapeExpression(((stack1 = (depth0 && depth0.instance_id)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + " )</li>\n				";
  return buffer;
  }

  buffer += "<div style=\"width:420px\">\n	<div class=\"modal-header\"><h3 class=\"truncate\" style=\"width: 380px;\">Need to Restart Instance</h3><i class=\"modal-close\">&times;</i> </div>\n	<div class=\"modal-body\" style=\"height:150px;\">\n		<div class=\"modal-text-wraper\">\n			<div class=\"modal-text-major\">To update the properties you have changed, following instances need to restart:</div>\n			<ul class=\"clearfix\">\n				";
  stack1 = helpers.each.call(depth0, (depth0 && depth0.instance_list), {hash:{},inverse:self.noop,fn:self.program(1, program1, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n			</ul>\n			<div id=\"instance-type\" class=\"modal-text-major\"></div>\n		</div>\n	</div>\n	<div class=\"modal-footer\">\n		<button id=\"confirm-update-app\" class=\"btn btn-blue\" style=\"width:160px;\">Continue to Update</button>\n		<button class=\"btn modal-close btn-silver\">Cancel</button>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.restartInstance=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  var buffer = "";
  buffer += "\n	<h3 class=\"modal-text-major\">"
    + escapeExpression(helpers.i18n.call(depth0, "POP_CONFIRM_UPDATE_MAJOR_TEXT_RUNNING", {hash:{},data:data}))
    + "</h3>\n	";
  return buffer;
  }

function program3(depth0,data) {
  
  var buffer = "";
  buffer += "\n	<h3 class=\"modal-text-major\">"
    + escapeExpression(helpers.i18n.call(depth0, "POP_CONFIRM_UPDATE_MAJOR_TEXT_STOPPED", {hash:{},data:data}))
    + "</h3>\n	<p class=\"modal-text-minor\" style=\"margin-top:10px;\">"
    + escapeExpression(helpers.i18n.call(depth0, "POP_CONFIRM_UPDATE_MINOR_TEXT_STOPPED", {hash:{},data:data}))
    + "</p>\n	";
  return buffer;
  }

  buffer += "<div id=\"app-apply-update\">\n    <div class=\"modal-control-group default-kp-group clearfix\" style=\"display: none;\">\n        <label for=\"kp-runtime-placeholder\">$DefaultKeyPair</label><div id=\"kp-runtime-placeholder\"></div>\n        <div class=\"runtime-error\" id=\"runtime-error-kp\"></div>\n    </div>\n	";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.isRunning), {hash:{},inverse:self.program(3, program3, data),fn:self.program(1, program1, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n	<div class=\"scroll-wrap\" style=\"max-height:256px;\">\n		<div class=\"scrollbar-veritical-wrap\"><div class=\"scrollbar-veritical-thumb\"></div></div>\n		<div class=\"scroll-content res_diff_tree\" id=\"app-update-summary-table\">\n		</div>\n	</div>\n	<div class=\"stack-validation\">\n		<details open style=\"display:none;\">\n			<summary>"
    + escapeExpression(helpers.i18n.call(depth0, "POP_CONFIRM_UPDATE_VALIDATION", {hash:{},data:data}))
    + "</summary>\n			<div id=\"stack-run-validation-container\"></div>\n		</details>\n		<div class=\"nutshell\" style=\"display: none;\">:<label></label></div>\n		<div class=\"validating\">\n			<div class=\"loading-spinner loading-spinner-small\"></div>\n			<p>"
    + escapeExpression(helpers.i18n.call(depth0, "POP_CONFIRM_UPDATE_VALIDATING", {hash:{},data:data}))
    + "</p>\n		</div>\n	</div>\n\n</div>";
  return buffer;
  };
TEMPLATE.updateApp=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div id=\"node-action-wrap\">\n	<div id=\"node-action-state\">\n		<div id=\"node-action-state-btn\">\n			<i id=\"node-state-icon\"></i>\n			<span id=\"node-state-number\">"
    + escapeExpression(((stack1 = (depth0 && depth0.state_num)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</span>\n		</div>\n		<div class=\"node-action-tooltip\">Edit State</div>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.nodeAction=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div id=\"modal-instance-sys-log\" style=\"width: 900px;\">\n	<div class=\"modal-header\"><h3>System Log: "
    + escapeExpression(((stack1 = (depth0 && depth0.instance_id)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</h3><i class=\"modal-close\">&times;</i> </div>\n	<div class=\"modal-body\">\n		<section class=\"instance-sys-log-loading loading-spinner\"></section>\n		<div class=\"instance-sys-log-content font-mono\">"
    + escapeExpression(((stack1 = (depth0 && depth0.log_content)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</div>\n		<div class=\"instance-sys-log-info modal-text-minor\">System log is not ready yet. Please try in a short while.</div>\n	</div>\n	<div class=\"modal-footer\">\n		<button id=\"modal-instance-sys-log-cancel\" class=\"btn modal-close btn-silver\">Close</button>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.modalInstanceSysLog=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "Are you sure you want to delete "
    + escapeExpression(((stack1 = (depth0 && depth0.name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "?</div>\n<div class=\"modal-text-minor\">Once deleted, the states of "
    + escapeExpression(((stack1 = (depth0 && depth0.name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "'s configuration will be lost.</div>";
  return buffer;
  };
TEMPLATE.NodeStateRemoveConfirmation=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "Are you sure you want to delete "
    + escapeExpression(((stack1 = (depth0 && depth0.name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "?</div>\n<div class=\"modal-text-minor\">The security group "
    + escapeExpression(((stack1 = (depth0 && depth0.sg)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + " will also be deleted. Other load balancer using this security group will be affected.</div>";
  return buffer;
  };
TEMPLATE.ElbRemoveConfirmation=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  


  return "<div style=\"width:420px\">\n	<div class=\"modal-header\"><h3>Confirm to Enable VisualOps</h3><i class=\"modal-close\">&times;</i></div>\n	<div class=\"modal-body\">\n		<div class=\"modal-text-wraper\">\n			<div class=\"modal-center-align-helper\">\n				<div class=\"modal-text-major\">Enable VisualOps will override your custom User Data. Are you sure to continue?</div>\n			</div>\n		</div>\n	</div>\n	<div class=\"modal-footer\">\n		<button id=\"modal-stack-agent-enable-confirm\" style=\"width:145px;\" class=\"btn modal-confirm btn-blue\">Enable VisualOps</button>\n		<button id=\"modal-stack-agent-enable-cancel\" class=\"btn modal-close btn-silver\">Cancel</button>\n	</div>\n</div>";
  };
TEMPLATE.modalStackAgentEnable=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", escapeExpression=this.escapeExpression;


  buffer += "<div style=\"width:640px\" id=\"modal-key-short\">\n	<div class=\"modal-header\"><h3>"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_MOD_TIT", {hash:{},data:data}))
    + "</h3><i class=\"modal-close\">&times;</i></div>\n	<div class=\"modal-body scroll-wrap\">\n		<div class=\"scrollbar-veritical-wrap\"><div class=\"scrollbar-veritical-thumb\"></div></div>\n		<div class=\"scroll-content\" style=\"height: 560px\">\n			<section class=\"key-stack-app\">\n				<h3 class=\"title\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_TIT_STACK_APP_OP", {hash:{},data:data}))
    + "</h3>\n				<ul class=\"keys\">\n					<li class=\"key-item\">\n						<div class=\"key font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_PROP_KEY", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_PROP_ACTION", {hash:{},data:data}))
    + "</div>\n					</li>\n					<li class=\"key-item\">\n						<div class=\"key font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_STAT_KEY", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_STAT_ACTION", {hash:{},data:data}))
    + "</div>\n					</li>\n					<li class=\"key-item\">\n						<div class=\"key mac font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_DUPL_KEY_MAC", {hash:{},data:data}))
    + "</div>\n						<div class=\"key pc font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_DUPL_KEY_PC", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_DUPL_ACTION", {hash:{},data:data}))
    + "\n						</div>\n					</li>\n					<li class=\"key-item\">\n						<div class=\"key mac font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_DEL_KEY_MAC", {hash:{},data:data}))
    + "</div>\n						<div class=\"key pc font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_DEL_KEY_PC", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_DEL_ACTION", {hash:{},data:data}))
    + "\n						</div>\n					</li>\n					<li class=\"key-item\">\n						<div class=\"key mac font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_SAVE_KEY_MAC", {hash:{},data:data}))
    + "</div>\n						<div class=\"key pc font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_SAVE_KEY_PC", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_SAVE_ACTION", {hash:{},data:data}))
    + "\n						</div>\n					</li>\n					<li class=\"key-item\">\n						<div class=\"key mac font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_SCRL_KEY_MAC", {hash:{},data:data}))
    + "</div>\n						<div class=\"key pc font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_SCRL_KEY_PC", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_SCRL_ACTION", {hash:{},data:data}))
    + "</div>\n					</li>\n				</ul>\n			</section>\n			<section class=\"key-state\">\n				<h3 class=\"title\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_TIT_STATE_GEN", {hash:{},data:data}))
    + "</h3>\n				<ul class=\"keys\">\n					<li class=\"key-item\">\n						<div class=\"key font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_FOCUS_KEY", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_FOCUS_ACTION", {hash:{},data:data}))
    + "</div>\n					</li>\n					<li class=\"key-item\">\n						<div class=\"key font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_SELECT_KEY", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_SELECT_ACTION", {hash:{},data:data}))
    + "</div>\n					</li>\n					<li class=\"key-item\">\n						<div class=\"key font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_EXPAND_KEY", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_EXPAND_ACTION", {hash:{},data:data}))
    + "</div>\n					</li>\n					<li class=\"key-item\">\n						<div class=\"key font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_COLLAPSE_KEY", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_COLLAPSE_ACTION", {hash:{},data:data}))
    + "</div>\n					</li>\n					<li class=\"key-item\">\n						<div class=\"key font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_NEXT_KEY", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_NEXT_ACTION", {hash:{},data:data}))
    + "</div>\n					</li>\n					<li class=\"key-item\">\n						<div class=\"key font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_PREV_KEY", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_PREV_ACTION", {hash:{},data:data}))
    + "\n						</div>\n					</li>\n					<li class=\"key-item\">\n						<div class=\"key mac font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_CONTENT_EDITOR_MAC", {hash:{},data:data}))
    + "</div>\n						<div class=\"key pc font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_CONTENT_EDITOR_PC", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_CONTENT_EDITOR_ACTION", {hash:{},data:data}))
    + "\n						</div>\n					</li>\n					<li class=\"key-item\">\n						<div class=\"key mac font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_INFO_KEY_MAC", {hash:{},data:data}))
    + "</div>\n						<div class=\"key pc font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_INFO_KEY_PC", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_INFO_ACTION", {hash:{},data:data}))
    + "</div>\n					</li>\n					<li class=\"key-item\">\n						<div class=\"key mac font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_LOG_KEY_MAC", {hash:{},data:data}))
    + "</div>\n						<div class=\"key pc font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_LOG_KEY_PC", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_LOG_ACTION", {hash:{},data:data}))
    + "\n						</div>\n					</li>\n				</ul>\n			</section>\n			<section class=\"key-state-edit\">\n				<h3 class=\"title\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_TIT_STATE_EDIT", {hash:{},data:data}))
    + "</h3>\n				<ul class=\"keys\">\n					<li class=\"key-item\">\n						<div class=\"key mac font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_SELECT_ALL_KEY_MAC", {hash:{},data:data}))
    + "</div>\n						<div class=\"key pc font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_SELECT_ALL_KEY_PC", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_SELECT_ALL_ACTION", {hash:{},data:data}))
    + "</div>\n					</li>\n					<li class=\"key-item\">\n						<div class=\"key mac font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_DESELECT_KEY_MAC", {hash:{},data:data}))
    + "</div>\n						<div class=\"key pc font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_DESELECT_KEY_PC", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_DESELECT_ACTION", {hash:{},data:data}))
    + "</div>\n					</li>\n					<li class=\"key-item\">\n						<div class=\"key mac font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_CREATE_KEY_MAC", {hash:{},data:data}))
    + "</div>\n						<div class=\"key pc font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_CREATE_KEY_PC", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_CREATE_ACTION", {hash:{},data:data}))
    + "</div>\n					</li>\n					<li class=\"key-item\">\n						<div class=\"key mac font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_DEL_STATE_KEY_MAC", {hash:{},data:data}))
    + "</div>\n						<div class=\"key pc font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_DEL_STATE_KEY_PC", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_DEL_STATE_ACTION", {hash:{},data:data}))
    + "</div>\n					</li>\n					<li class=\"key-item\">\n						<div class=\"key mac font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_MOVE_FOCUS_STATE_KEY_MAC", {hash:{},data:data}))
    + "</div>\n						<div class=\"key pc font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_MOVE_FOCUS_STATE_KEY_PC", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_MOVE_FOCUS_STATE_ACTION", {hash:{},data:data}))
    + "</div>\n					</li>\n					<li class=\"key-item\">\n						<div class=\"key mac font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_COPY_STATE_KEY_MAC", {hash:{},data:data}))
    + "</div>\n						<div class=\"key pc font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_COPY_STATE_KEY_PC", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_COPY_STATE_ACTION", {hash:{},data:data}))
    + "</div>\n					</li>\n					<li class=\"key-item\">\n						<div class=\"key mac font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_PASTE_STATE_KEY_MAC", {hash:{},data:data}))
    + "</div>\n						<div class=\"key pc font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_PASTE_STATE_KEY_PC", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_PASTE_STATE_ACTION", {hash:{},data:data}))
    + "</div>\n					</li>\n					<li class=\"key-item\">\n						<div class=\"key mac font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_UNDO_STATE_KEY_MAC", {hash:{},data:data}))
    + "</div>\n						<div class=\"key pc font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_UNDO_STATE_KEY_PC", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_UNDO_STATE_ACTION", {hash:{},data:data}))
    + "</div>\n					</li>\n					<li class=\"key-item\">\n						<div class=\"key mac font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_REDO_STATE_KEY_MAC", {hash:{},data:data}))
    + "</div>\n						<div class=\"key pc font-mono\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_REDO_STATE_KEY_PC", {hash:{},data:data}))
    + "</div>\n						<div class=\"action\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_REDO_STATE_ACTION", {hash:{},data:data}))
    + "</div>\n					</li>\n				</ul>\n			</section>\n		</div>\n	</div>\n	<div class=\"modal-footer\">\n		<button class=\"btn modal-close btn-silver\">"
    + escapeExpression(helpers.i18n.call(depth0, "KEY_MODAL_BTN_CLOSE", {hash:{},data:data}))
    + "</button>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.shortkey=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, escapeExpression=this.escapeExpression, functionType="function";


  buffer += "<div style=\"width:343px\" id=\"modal-ssl-cert-setting\">\n	<div class=\"modal-header\"><h3>Server Certificate</h3><i class=\"modal-close\">&times;</i> </div>\n	<div class=\"modal-body\" style=\"min-height:120px;\">\n		<div class=\"modal-ssl-cert-item clearfix\">\n			<label class=\"left\">"
    + escapeExpression(helpers.i18n.call(depth0, "PROP_ELB_LBL_LISTENER_NAME", {hash:{},data:data}))
    + "</label>\n			<input class=\"input\" value=\""
    + escapeExpression(((stack1 = ((stack1 = (depth0 && depth0.sslCert)),stack1 == null || stack1 === false ? stack1 : stack1.name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" type=\"text\" data-required=\"true\" data-ignore=\"true\" id=\"elb-ssl-cert-name-input\"/>\n		</div>\n		<div class=\"modal-ssl-cert-item clearfix\">\n			<label class=\"left\">"
    + escapeExpression(helpers.i18n.call(depth0, "PROP_ELB_LBL_LISTENER_PRIVATE_KEY", {hash:{},data:data}))
    + "</label>\n			<textarea class=\"input elb-ssl-cert-input tooltip\" data-tooltip=\""
    + escapeExpression(helpers.i18n.call(depth0, "POP_TIP_PEM_ENCODED", {hash:{},data:data}))
    + "\" data-required=\"true\" data-ignore=\"true\" id=\"elb-ssl-cert-privatekey-input\">"
    + escapeExpression(((stack1 = ((stack1 = (depth0 && depth0.sslCert)),stack1 == null || stack1 === false ? stack1 : stack1.key)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</textarea>\n		</div>\n		<div class=\"modal-ssl-cert-item clearfix\">\n			<label class=\"left\"  >"
    + escapeExpression(helpers.i18n.call(depth0, "PROP_ELB_LBL_LISTENER_PUBLIC_KEY", {hash:{},data:data}))
    + "</label>\n			<textarea class=\"input elb-ssl-cert-input tooltip\" data-tooltip=\""
    + escapeExpression(helpers.i18n.call(depth0, "POP_TIP_PEM_ENCODED", {hash:{},data:data}))
    + "\" data-required=\"true\" data-ignore=\"true\" id=\"elb-ssl-cert-publickey-input\">"
    + escapeExpression(((stack1 = ((stack1 = (depth0 && depth0.sslCert)),stack1 == null || stack1 === false ? stack1 : stack1.body)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</textarea>\n		</div>\n		<div class=\"modal-ssl-cert-item clearfix\">\n			<label class=\"left\"  >"
    + escapeExpression(helpers.i18n.call(depth0, "PROP_ELB_LBL_LISTENER_CERTIFICATE_CHAIN", {hash:{},data:data}))
    + "</label>\n			<textarea class=\"input elb-ssl-cert-input tooltip\" data-tooltip=\""
    + escapeExpression(helpers.i18n.call(depth0, "POP_TIP_PEM_ENCODED", {hash:{},data:data}))
    + "\" id=\"elb-ssl-cert-chain-input\">"
    + escapeExpression(((stack1 = ((stack1 = (depth0 && depth0.sslCert)),stack1 == null || stack1 === false ? stack1 : stack1.chain)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</textarea>\n		</div>\n	</div>\n	<div class=\"modal-footer\">\n		<button id=\"elb-ssl-cert-confirm\" class=\"btn btn-blue\">Save</button>\n		<button id=\"elb-ssl-cert-cancel\" class=\"btn modal-close btn-silver\">Cancel</button>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.modalSSLCertSetting=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", escapeExpression=this.escapeExpression;


  buffer += "<div style=\"width:623px\" id=\"experimental-modal\">\n	<div class=\"modal-header\">\n		<h3>"
    + escapeExpression(helpers.i18n.call(depth0, "INVITE_MOD_TIT", {hash:{},data:data}))
    + "</h3>\n		<i class=\"modal-close\">×</i>\n	</div>\n	<div class=\"modal-body\">\n		<h3 class=\"modal-body-header\">"
    + escapeExpression(helpers.i18n.call(depth0, "INVITE_MOD_INTRO", {hash:{},data:data}))
    + "</h3>\n		<div class=\"modal-body-content\">\n			<div class=\"modal-text-minor\">"
    + escapeExpression(helpers.i18n.call(depth0, "INVITE_MOD_INTRO_MORE", {hash:{},data:data}))
    + "</div>\n			<h4 class=\"request-invite-header\">"
    + escapeExpression(helpers.i18n.call(depth0, "INVITE_MOD_REQUEST_TIT", {hash:{},data:data}))
    + "</h4>\n			<div class=\"request-invite-content\">"
    + escapeExpression(helpers.i18n.call(depth0, "INVITE_MOD_REQUEST_CONTENT", {hash:{},data:data}))
    + "</div>\n			<textarea id=\"experimental-message\" class=\"input\" style=\"width:95%;height:120px;\" placeholder='"
    + escapeExpression(helpers.i18n.call(depth0, "INVITE_MOD_REQUEST_PLACEHOLDER", {hash:{},data:data}))
    + "' data-required=\"true\"></textarea>\n		</div>\n	</div>\n	<div class=\"modal-footer\">\n		<button id=\"experimental-visops-confirm\" class=\"btn btn-blue\">"
    + escapeExpression(helpers.i18n.call(depth0, "INVITE_MOD_BTN_REQUEST", {hash:{},data:data}))
    + "</button>\n		<button id=\"experimental-visops-cancel\" class=\"btn modal-close btn-silver\">"
    + escapeExpression(helpers.i18n.call(depth0, "INVITE_MOD_BTN_CANCEL", {hash:{},data:data}))
    + "</button>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.experimentalVisops=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", escapeExpression=this.escapeExpression;


  buffer += "<h3 class=\"modal-body-header\">"
    + escapeExpression(helpers.i18n.call(depth0, "INVITE_MOD_THANK_LBL", {hash:{},data:data}))
    + "</h3>\n<div class=\"modal-text-major tac\">"
    + escapeExpression(helpers.i18n.call(depth0, "INVITE_MOD_THANK_MORE", {hash:{},data:data}))
    + "</div>";
  return buffer;
  };
TEMPLATE.experimentalVisopsTrail=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  


  return "<div class=\"bubble-head\">A NAT instance must meet following requirements:</div>\n<div class=\"bubble-content\">\n	<ul class=\"bubble-NAT-req-list\">\n		<li>Should have a route targeting the instance itself with destination to 0.0.0.0/0.</li>\n		<li>Should belong to a subnet which routes traffic with destination 0.0.0.0/0 to Internet Gateway.</li>\n		<li>Should disable Source/Destination Checking in \"Network Interface Details\".</li>\n		<li>Should have public IP or Elastic IP.</li>\n		<li>Should have outbound rule to the outside.</li>\n		<li>Should have inbound rule from within the VPC.</li>\n	</ul>\n</div>";
  };
TEMPLATE.bubbleNATreq=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var escapeExpression=this.escapeExpression;


  return escapeExpression(helpers.nl2br.call(depth0, (depth0 && depth0.content), {hash:{},data:data}));
  };
TEMPLATE.covertNl2br=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var escapeExpression=this.escapeExpression;


  return escapeExpression(helpers.breaklines.call(depth0, (depth0 && depth0.content), {hash:{},data:data}));
  };
TEMPLATE.convertBreaklines=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, escapeExpression=this.escapeExpression, functionType="function";


  buffer += "<div style=\"width:420px\">\n	<div class=\"modal-header\"> <h3>"
    + escapeExpression(helpers.i18n.call(depth0, "PROP_ELB_CERT_REMOVE_CONFIRM_TITLE", {hash:{},data:data}))
    + "</h3><i class=\"modal-close\">&times;</i> </div>\n	<div class=\"modal-body\">\n		<div class=\"modal-text-wraper\">\n			 <div class=\"modal-center-align-helper\">\n				<div class=\"modal-text-major\">"
    + escapeExpression(helpers.i18n.call(depth0, "PROP_ELB_CERT_REMOVE_CONFIRM_MAIN", {hash:{},data:data}))
    + escapeExpression(((stack1 = (depth0 && depth0.cert_name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "?</div>\n				<div class=\"modal-text-minor\">"
    + escapeExpression(helpers.i18n.call(depth0, "PROP_ELB_CERT_REMOVE_CONFIRM_SUB", {hash:{},data:data}))
    + "</div>\n			</div>\n		 </div>\n	</div>\n	<div class=\"modal-footer\">\n		<button id=\"modal-confirm-elb-cert-delete\" class=\"btn btn-red\">Delete</button>\n		<button id=\"modal-cancel\" class=\"btn modal-close btn-silver\">Cancel</button>\n	</div>\n</div>";
  return buffer;
  };
TEMPLATE.modalDeleteELBCert=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  
  return " unread";
  }

function program3(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n      <i class=\"icon-error\"></i>\n      <div class=\"content\"><span class=\"resource-name-label\">"
    + escapeExpression(((stack1 = (depth0 && depth0.targetName)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</span> failed to "
    + escapeExpression(((stack1 = (depth0 && depth0.operation)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + " in "
    + escapeExpression(((stack1 = (depth0 && depth0.region)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + ".</div>\n    ";
  return buffer;
  }

function program5(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n      <i class=\"icon-pending\"></i>\n      <div class=\"content\">Sending request to "
    + escapeExpression(((stack1 = (depth0 && depth0.operation)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + " <span class=\"resource-name-label\">"
    + escapeExpression(((stack1 = (depth0 && depth0.targetName)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</span> in "
    + escapeExpression(((stack1 = (depth0 && depth0.region)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + ".</div>\n    ";
  return buffer;
  }

function program7(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n      <i class=\"icon-pending\"></i>\n      <div class=\"content\">Processing request to "
    + escapeExpression(((stack1 = (depth0 && depth0.operation)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + " <span class=\"resource-name-label\">"
    + escapeExpression(((stack1 = (depth0 && depth0.targetName)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</span> in "
    + escapeExpression(((stack1 = (depth0 && depth0.region)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + ".</div>\n    ";
  return buffer;
  }

function program9(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n      <i class=\"icon-success\"></i>\n      <div class=\"content\"><span class=\"resource-name-label\">"
    + escapeExpression(((stack1 = (depth0 && depth0.targetName)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + " </span>"
    + escapeExpression(((stack1 = (depth0 && depth0.operation)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + " successfully in "
    + escapeExpression(((stack1 = (depth0 && depth0.region)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + ".</div>\n    ";
  return buffer;
  }

function program11(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "<div class=\"notification-details\">"
    + escapeExpression(((stack1 = (depth0 && depth0.error)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</div>";
  return buffer;
  }

  buffer += "<li class=\"notification-item";
  stack1 = helpers.unless.call(depth0, (depth0 && depth0.readed), {hash:{},inverse:self.noop,fn:self.program(1, program1, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\">\n  <div class=\"notification-message\">\n    ";
  stack1 = helpers['if'].call(depth0, ((stack1 = (depth0 && depth0.state)),stack1 == null || stack1 === false ? stack1 : stack1.failed), {hash:{},inverse:self.noop,fn:self.program(3, program3, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n    ";
  stack1 = helpers['if'].call(depth0, ((stack1 = (depth0 && depth0.state)),stack1 == null || stack1 === false ? stack1 : stack1.pending), {hash:{},inverse:self.noop,fn:self.program(5, program5, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n    ";
  stack1 = helpers['if'].call(depth0, ((stack1 = (depth0 && depth0.state)),stack1 == null || stack1 === false ? stack1 : stack1.processing), {hash:{},inverse:self.noop,fn:self.program(7, program7, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n    ";
  stack1 = helpers['if'].call(depth0, ((stack1 = (depth0 && depth0.state)),stack1 == null || stack1 === false ? stack1 : stack1.completed), {hash:{},inverse:self.noop,fn:self.program(9, program9, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n  </div>\n\n  ";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.error), {hash:{},inverse:self.noop,fn:self.program(11, program11, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n\n  <div class=\"notification-duration left\">"
    + escapeExpression(((stack1 = (depth0 && depth0.duration)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</div>\n  <div class=\"timestamp\">"
    + escapeExpression(((stack1 = (depth0 && depth0.time)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</div>\n</li>";
  return buffer;
  };
TEMPLATE.headerNotifyItem=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var stack1, functionType="function", escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n<li>\n	<input class=\"tokenName input\" value=\""
    + escapeExpression(((stack1 = (depth0 && depth0.name)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" readonly/>\n	<span class=\"tokenToken click-select truncate tooltip\" data-tooltip=\""
    + escapeExpression(helpers.i18n.call(depth0, "PROP_ELB_TIP_CLICK_TO_SELECT_ALL", {hash:{},data:data}))
    + "\">"
    + escapeExpression(((stack1 = (depth0 && depth0.token)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</span>\n	<span class=\"tokenControl\">\n		<button class=\"tooltip icon-edit\" data-tooltip=\"\"></button>\n		<button class=\"tooltip icon-delete\" data-tooltip=\"\"></button>\n		<button class=\"btn btn-blue tokenDone\">"
    + escapeExpression(helpers.i18n.call(depth0, "HEAD_BTN_DONE", {hash:{},data:data}))
    + "</button>\n	</span>\n</li>\n";
  return buffer;
  }

  stack1 = helpers.each.call(depth0, depth0, {hash:{},inverse:self.noop,fn:self.program(1, program1, data),data:data});
  if(stack1 || stack1 === 0) { return stack1; }
  else { return ''; }
  };
TEMPLATE.accessTokenTable=Handlebars.template(__TEMPLATE__);


__TEMPLATE__ =function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, self=this, functionType="function", escapeExpression=this.escapeExpression;

function program1(depth0,data) {
  
  
  return "<i class=\"modal-close\">×</i>";
  }

function program3(depth0,data) {
  
  
  return " scroll-wrap scrollbar-auto-hide";
  }

function program5(depth0,data) {
  
  
  return "style=\"padding: 0;\"";
  }

function program7(depth0,data) {
  
  var stack1;
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.compact), {hash:{},inverse:self.noop,fn:self.program(8, program8, data),data:data});
  if(stack1 || stack1 === 0) { return stack1; }
  else { return ''; }
  }
function program8(depth0,data) {
  
  
  return " style=\"padding: 0;\"";
  }

function program10(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n            <div class=\"scrollbar-veritical-wrap\"><div class=\"scrollbar-veritical-thumb\"></div></div>\n                <div class=\"scroll-content\" ";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.compact), {hash:{},inverse:self.program(11, program11, data),fn:self.program(8, program8, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += ">\n                    ";
  stack1 = ((stack1 = (depth0 && depth0.template)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1);
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n                </div>\n            ";
  return buffer;
  }
function program11(depth0,data) {
  
  
  return "style=\"padding: 12px 15px\"";
  }

function program13(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n            ";
  stack1 = ((stack1 = (depth0 && depth0.template)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1);
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n            ";
  return buffer;
  }

function program15(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n        <div class=\"modal-footer\">\n            ";
  stack1 = helpers.unless.call(depth0, ((stack1 = (depth0 && depth0.confirm)),stack1 == null || stack1 === false ? stack1 : stack1.hide), {hash:{},inverse:self.noop,fn:self.program(16, program16, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n            ";
  stack1 = helpers.unless.call(depth0, ((stack1 = (depth0 && depth0.cancel)),stack1 == null || stack1 === false ? stack1 : stack1.hide), {hash:{},inverse:self.noop,fn:self.program(19, program19, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n        </div>\n        ";
  return buffer;
  }
function program16(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "<button class=\"btn modal-confirm btn-"
    + escapeExpression(((stack1 = ((stack1 = (depth0 && depth0.confirm)),stack1 == null || stack1 === false ? stack1 : stack1.color)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" ";
  stack1 = helpers['if'].call(depth0, ((stack1 = (depth0 && depth0.confirm)),stack1 == null || stack1 === false ? stack1 : stack1.disabled), {hash:{},inverse:self.noop,fn:self.program(17, program17, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += ">"
    + escapeExpression(((stack1 = ((stack1 = (depth0 && depth0.confirm)),stack1 == null || stack1 === false ? stack1 : stack1.text)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</button>";
  return buffer;
  }
function program17(depth0,data) {
  
  
  return " disabled ";
  }

function program19(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "<button class=\"btn modal-close btn-silver\">"
    + escapeExpression(((stack1 = ((stack1 = (depth0 && depth0.cancel)),stack1 == null || stack1 === false ? stack1 : stack1.text)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</button>";
  return buffer;
  }

  buffer += "<div class=\"modal-box\">\n    <div style=\"width: 520px\">\n        <div class=\"modal-header\">\n            <h3>"
    + escapeExpression(((stack1 = (depth0 && depth0.title)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "</h3>\n            ";
  stack1 = helpers.unless.call(depth0, (depth0 && depth0.hideClose), {hash:{},inverse:self.noop,fn:self.program(1, program1, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n        </div>\n        <div class=\"modal-body  context-wrap";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.hasScroll), {hash:{},inverse:self.noop,fn:self.program(3, program3, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\" ";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.hasScroll), {hash:{},inverse:self.program(7, program7, data),fn:self.program(5, program5, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += ">\n            ";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.hasScroll), {hash:{},inverse:self.program(13, program13, data),fn:self.program(10, program10, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n            </div>\n        ";
  stack1 = helpers['if'].call(depth0, (depth0 && depth0.hasFooter), {hash:{},inverse:self.noop,fn:self.program(15, program15, data),data:data});
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n    </div>\n</div>";
  return buffer;
  };
TEMPLATE.modalTemplate=Handlebars.template(__TEMPLATE__);


return TEMPLATE; });