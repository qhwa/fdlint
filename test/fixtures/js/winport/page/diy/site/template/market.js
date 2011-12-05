/**
 * 模板市场
 * @author
 */
(function($, WP) {
var Util = WP.Util,
	Diy = WP.diy.Diy;
	
var TemplatePageMarket = {
	
	/**
	 * 初始化
	 */
	init: function(rootDiv, config, pageData){
		
		this.div = $(rootDiv);
		
		//切换tab页
		this.initTemplateTabs();
		
		//绑定颜色组选中事件
		this.initBindGroupClickEvents();
		
		//绑定应用到旺铺按钮的点击事件
		this.initBindButtonClickEvents();

	},
	
	/**
	 * 模板中心两个tab页切换
	 * @param {Object} templateTab
	 */
	initTemplateTabs: function() {
		var tabs = $('ul.template-page-tabs>li', this.div),
			bodies = $('div.template-page-body', this.div);
		new Tabs(tabs, bodies);
	},
	
	/**
	 * 绑定颜色组选中事件
	 * @param {Object} templateTab
	 */
	initBindGroupClickEvents: function() {
		this.div.delegate('ul.template-list-tabs li', 'click', function() {
			var group = $(this).data('group');	
			WP.TemplatePageContext.loadPage(1, { type: 'free', group: group });
		});
	},
	
	/**
	 * 绑定按钮点击事件
	 * @param {Object} templateTab
	 */
	initBindButtonClickEvents: function() {
		var self = this;
		this.div.delegate('div.template-list-bodies li a.apply', 'click', function() {
			var li = $(this).closest('li'),
				template = li.data('template');
			self.applyTemplateDialog(template);
		});
	},
	
	/**
	 * 弹出应用模板到旺铺的对话框
	 */
	applyTemplateDialog: function(template){
		var self = this;
		var applyTemplateDialog = Dialog.open({
			header: '温馨提示',
			className: 'apply-template-dialog',
			hasClose: true,
			buttons: [
					{
						'class': 'd-confirm',
						value: '是'
					},
					{
						'class': 'd-cancel',
						value: '不是'
					}
				],
			draggable: true,
			content: "您是否需要系统自动帮您备份当前旺铺?",
			confirm: function(dialog){
				WP.diy.Template.backup({
					success: function(){
						WP.diy.Template.apply(template);			   
					}
				});
				},
			cancel: function(dialog) {
				WP.diy.Template.apply(template);
			}
		});
	}
	
};


WP.TemplatePageContext.register('template-page-market', TemplatePageMarket);

	
})(jQuery, Platform.winport);
