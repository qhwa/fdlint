/**
 * @fileoverview 表单处理类接口文档
 * @author qijun.weiqj
 */
(function($, WP) {

/**
 * 表单处理类名称需要和文件名相对应, 如 my-form-hander -> MyFormHandler
 * 并且需要挂接在 WP.diy.form文件空间下
 * 普通的保存设置表单 mixin BaseHandler
 */
var MyFormHandler = {
	
	/**
	 * 初始化方法, 由FormDialog自动调用
	 * @param {element} form 指向编辑页面中的form表单
	 * @param {object} config 如果表单有相应的配置信息 data-form-config, 则会被解析成config参数
	 * @param {element} box 当前编辑的box
	 * @this.dialog 指向当前打开的FormDialog实例
	 */
	init: function(form, config, box) {
		var dialog = this.dialog;  // this.dialog指向当前打开的FormDialog实例
	},
	
	/**
	 * 表单验证方法, 当表单提交时自动调用
	 * @return {boolean} 是否验证成功, 如果验证失败,将阻止表单提光
	 */
	validate: function(form) {
		return true;
	},
	
	/**
	 * 当表单提交时自动调用(在validate成功后) 
	 */
	submit: function(form) {
		
	},
	
	/**
	 * 当表单取消编辑时自动调用
	 */
	cancel: function(form) {
		
	},
	
	/**
	 * 当表单关闭前自动调用, 包括submit和cancel两种情况
	 * @return {boolean} 返回false按阻止表单关闭
	 */
	beforeClose: function(form) {
		
	}
	
};
//~ MyFormHandler


/**
 * 需要挂接在WP.diy.form名字空间下，以便被FormDialog引用
 */
WP.diy.form.MyFormHandler = MyFormHandler;

	
})(jQuery, Platform.winport)
//~


