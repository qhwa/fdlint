/**
 * 模板页面框架
 * @author qijun.weiqj
 */ 
(function($, WP) {


var AjaxLink = WP.widget.AjaxLink;
	

var TemplatePage = {
	
	/**
	 * @param {object} pageData 当SettingContext.loadPage调用时，传递的额外参数
	 */
	init: function(div, config, pageData) {
		this.div = div;

		this.pageData = pageData;

		this.tabs = $('ul.setting-node-tabs li', this.div),
		this.body = $('div.setting-node-body', this.div);

		this.initTabs();
		this.initContext();
	},

	/**
	 * 初始化tab, 以ajax方式载入页面到body区
	 */
	initTabs: function() {
		var self = this;

		new AjaxLink(this.tabs, {
			cache: false,
			update: this.body,
			before: function() {
				self.beforeTabSelect($(this));	
			},
			confirm: function() {
				return !$(this).data('tabSelect');
			},
			success: function() {
				self.onTabSelect($(this))
			}	
		});

		
		this.tabs.eq(0).click();
	},

	beforeTabSelect: function(tab) {
		var self = this;
		clearTimeout(this.tabTimer);
		this.tabTimer = setTimeout(function() {
			self.body.html('<div class="template-page-loading"> 正在加载...</div>');
		}, 100);
	},

	onTabSelect: function(tab) {
		clearTimeout(this.tabTimer);

		this.tabs.removeClass('selected').removeData('tabSelect');
		tab.addClass('selected').data('tabSelect', true);

		var node = $('>div', this.body);
		if (node.length) {
			WP.TemplatePageContext.refresh(node, this.pageData);
			this.pageData = null;	
		}
	},

	initContext: function() {
		WP.TemplatePageContext.loadPage = $.proxy(this, 'loadTemplatePage');
	},

	loadTemplatePage: function(index, data, params) {
		this.pageData = data;
		AjaxLink.load(this.tabs.eq(index), params)
	}
		
};


WP.SettingContext.register('diy-template-page', TemplatePage );

/**
 * 初始化TemplatePageContext,以便让其他TemplatePage面板接入
 */
WP.TemplatePageContext = new WP.NodeContext('TemplatePageContext', { 
	root: '#header', // 明确的话应该使用 '#header div.diy-template-page'， 现在为了加快选择器速度
	configField: 'templateConfig'
});


	
})(jQuery, Platform.winport);
