/**
 * @fileoverview 表单默认处理类
 * 
 * @author long.fanl
 */
(function($, WP){

	
var FormUtil = WP.widget.FormUtil,
	Msg = WP.diy.Msg,
	BaseHandler = WP.diy.form.BaseHandler;


/**
 * SimpleHandler 可以mixin到其它form handler中
 * 主要提供:
 * 1. 标题验证
 * 2. 错误回显
 * 3. 成功后关闭对话框并刷新板块
 *  
 */
var SimpleHandler = $.extendIf({
	
	init: function() {
		BaseHandler.init.apply(this, arguments);
		
		this.__$titleInput = $('input[name=title]', this.form);
		this.__$titleInput.closest('dd').find('span.err').addClass('message'); // 兼容原编辑板块信息标签
		
		this.__$handleEvent();
	},
	
	__$handleEvent: function() {
		var self = this,
			title = this.__$titleInput;
			
		title.bind('input propertychange', function() {
			$.trim(title.val()) && self.__$showTitleError(false);
		});
		
		title.bind('blur',function(){
			self.__$validateTitle();
		});
	},
	
	__$validateTitle: function() {
		var value = $.trim(this.__$titleInput.val());
		if(!value) {
			this.__$showTitleError('标题不能为空');
			return false;
		}
		
		if (/[~'"@#$?&<>\/\\]/.test(value)) {
			this.__$showTitleError('标题含有非法字符请重新输入');
			return false;
		}
		
		return true;
	},
	
	validate: function() {
		return this.__$validateTitle();
	},
	
	__$showTitleError: function(message) {
		return FormUtil.showMessage(this.__$titleInput, message, 'error');
		return this.showError(this.__$titleInput, message);
	},

	_afterSubmit: function(result) {
		var dialog = this.dialog;

		if (result.success) {
			this._refreshBox();
			dialog.close();
			Msg.info("设置板块成功");
		} else {
			result.data && $.each(result.data, function(i, d) {
				var elm = $(':input[name="' + d.fieldName + '"]', dialog.node);
				FormUtil.showMessage(elm, d.message, 'error');
			});
			Msg.error("设置板块失败");
		}
	}

}, BaseHandler);


/**
 * 默认表单处理函数
 */
var DefaultHandler = SimpleHandler;



WP.diy.form.SimpleHandler = SimpleHandler;
WP.diy.form.DefaultHandler = DefaultHandler;

    
})(jQuery, Platform.winport);
//~
