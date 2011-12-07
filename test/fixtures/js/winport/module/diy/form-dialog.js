/**
 * @fileoverview 旺铺DIY表单对话框
 * @author qijun.weiqj
 */
(function($, WP){


/**
 * 表单处理类所在名字空间
 */
$.namespace('Platform.winport.diy.form');


var FormDialog = new WP.Class(WP.widget.Dialog, {

	init: function(config) {
		if (!config.handler) {
			$.error('form handler is not speicified');
		}

		config = $.extend({ draggable: true }, config);
		
		config.contentSuccess = $.proxy(this, '__contentSuccess');
		config.confirm = $.proxy(this, '__confirm');
		config.close = config.cancel = $.proxy(this, '__cancel');
		config.beforeClose = $.proxy(this, '__beforeClose');
		
		this.handler = config.handler;
		this.handler.dialog = this;
		this.handlerName = config.handlerName;
		
		this.parent.init.call(this, config);	
	},
	
	
	/**
	 * 对话框内容载入成功后需要载入并初始化handler
	 */
	__contentSuccess: function() {
		var self = this;
		
		this.form = $('form:first', this.node);
		this.__handleDefaultSubmit();
		this.__initFormHandler();
	},
	
	/**
	 * 优化交互：在text中直接按回车, 提交表单
	 */
	__handleDefaultSubmit: function(){
		var self = this;
		this.node.delegate('input:text', 'keydown', function(e) {
			if(e.keyCode === 13){
				self.__confirm();
				return false;
			}
		});
	},
	
	/**
	 * 初始化FormHandler
	 */
	__initFormHandler: function() {
		var handler = this.handler,
			form = this.form,
			formCfg = form.data('formConfig') || {},
			formData = this.config.formData;

		handler.init(form, formCfg, formData, this);
		$.log((this.handlerName || 'FormHandler') + ' initialized');
	},
	
	__confirm: function() {
		var handler = this.handler;
		if (!handler) {
			return;
		}
		
		if (handler.validate && !handler.validate(this.form)) {
			return false;
		}
		
		if (handler.submit) {
			return handler.submit(this.form);
		}
	},
	
	__cancel: function() {
		var handler = this.handler;
		if (handler && handler.cancel && 
				handler.cancel(this.form) === false) {
			return;
		}
		this.close();
	},
	
	__beforeClose: function() {
		var handler = this.handler;
		if (handler && handler.beforeClose) {
			return handler.beforeClose(this.form);
		}
	}

});
//~ FormDialog


FormDialog.open = function(config) {
	return new FormDialog(config);
};

WP.diy.FormDialog = FormDialog;

    
})(jQuery, Platform.winport);
//~
