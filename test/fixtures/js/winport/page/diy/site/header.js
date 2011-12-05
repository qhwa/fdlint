/**
 * @fileoverview DIY设置面板
 * 
 * @author qijun.weiqj
 */

(function($, WP) {

var Util = WP.Util,
	UI = WP.UI,
	Tabs = WP.widget.Tabs,
	AjaxLink = WP.widget.AjaxLink,
	FloatPanel = WP.widget.FloatPanel,
	FloatTips = WP.widget.FloatTips;

var DiyHeader = {

	init: function(div) {
		this.docCfg = $('#doc').data('docConfig');
		
		this.bar = $('div.setting-bar', div);
		this.panel = $('div.setting-panel', div);
		this.tabs = $('ul.setting-tabs>li', this.bar);
		this.body = $('div.setting-panel-body', this.panel);

		UI.positionFixed(this.bar);
		this.initTabs();
		this.initContext();
		this.initHelpPanel();
		this.initCollapseBar();
		this.initHeaderState();
		this.initPublishTooltip();
	},
	
	/**
	 * 初始化设置Tabs
	 */
	initTabs: function() {
		var self = this;
			
		new AjaxLink(this.tabs, {
			cache: false,
			update: this.body,
			before: function() {
				self.tabsLinkBefore($(this));
			},
			confirm: function() {
				var loaded = $(this).data('panelLoaded');
				loaded && self.expandPanel(true);
				return !loaded;
			},
			success: function() {
				self.tabsLinkSuccess($(this));
			}
		});
	},
	//~ initTabsLink
	
	/**
	 * 占击tab时，载入内容前调用此方法
	 */
	tabsLinkBefore: function(tab) {
		var self = this;

		this.expandPanel(true);

		// 优化交互，一开始就让tab切换到选中状态
		// 否则需要等到载入后才会选中	
		this.tabs.removeClass('selected');
		tab.addClass('selected');
		
		clearTimeout(this.tabsTimer);
		this.tabsTimer = setTimeout(function() {
			self.body.html('<div class="setting-panel-loading">正在加载...</div>');
		}, 100);
	},
	
	/**
	 * 内容载入完毕时调用此方法
	 */
	tabsLinkSuccess: function(tab) {		
		clearTimeout(this.tabsTimer);
		
		// 由于异步返回时序可能和原先不一致,所以还需要设置一次selected样式
		if (!tab.hasClass('selected')) {
			this.tabs.removeClass('selected');
			tab.addClass('selected');
		}
		this.tabs.removeData('panelLoaded');
		tab.data('panelLoaded', true);
		
		var node = $('div.setting-node', this.body);
		if (node.length) {
			this.initSettingNodeTabs(node);
			// 可以由外界调用 SettingContext.loadPage来传递pageData
			// @see initContext & loadSettingPage
			WP.SettingContext.refresh(node, this.pageData);
			this.pageData = null;
		}
	},
	
	/**
	 * 如果有setting-node-tab, 则初始化
	 */
	initSettingNodeTabs: function(node) {
		var tabs = $('ul.setting-node-tabs>li', node),
			bodies = $('ul.setting-node-body>li', node);

		if (tabs.length && bodies.length) {
			new Tabs(tabs, bodies);
		}
	},


	/**
	 * 初始化SettingContext
	 */
	initContext: function() {
		WP.SettingContext.loadPage = $.proxy(this, 'loadSettingPage');
	},

	/**
	 * 载入SettingPage
	 * @param index tab索引
	 * @param data 额外参数, 传递给int方法第三个参数
	 * 		@see template/template.js
	 */
	loadSettingPage: function(index, data) {
		var tab = this.tabs.eq(index);

		// 数据保存在属性变量中, 在初始化时会使用到
		// @see tabsLinkSuccess
		this.pageData = data;
		AjaxLink.load(tab);
	},
	
	/**
	 * 初始化帮助面板
	 */
	initHelpPanel: function() {
		var panel = $('div.help-panel', this.bar),
			link = $('a.help-link', panel),
			floatPanel = null;
		floatPanel = new FloatPanel(panel, { 
			handler: link,
			toggle: true,
			show: function() {
				panel.addClass('selected');
			},
			hide: function() {
				panel.removeClass('selected');
			}
		});
		
		panel.delegate('ul.help-topics li', 'click', function() {
			floatPanel.hide();
		});
	},
	
	/**
	 * 初始化设置面板收缩条
	 */
	initCollapseBar: function() {
		var self = this,
			cHandle = $('div.collapse-bar a.handle', this.panel),
			eBar = $('div.expand-bar', this.bar),
			eHandle = $('a.handle', eBar),
			win = $(window),
			header = $('#header'),
			height = null;
			
		cHandle.click(function() {
			self.expandPanel(false);
			return false;
		});
		
		eHandle.click(function() {
			self.expandPanel(true);
			return false;
		})
		
		win.bind('scroll resize', function() {
			var top = win.scrollTop(),
				collapsed = header.hasClass('collapsed'),
				expanded = header.hasClass('expanded');
				
			height = height || $(self.panel).height() - eBar.height();
			// 如果没有载入过任何面板
			if (!collapsed && !expanded) {
				return;
			}
			
			header[top > height ? 'addClass' : 'removeClass']('panel-scrollout');
		});
	},
	//~ initCollapseBar
	
	/**
	 * 展开/收缩面板
	 * @param {boolean} expanded
	 */
	expandPanel: function(expanded) {
		var header = $('#header');
		header.toggleClass('expanded', expanded);
		header.toggleClass('collapsed', !expanded);
		window.scroll(0, 0);
	},
	
	/**
	 * 第一次DIY,默认展开第一页
	 */
	initHeaderState: function() {
		this.docCfg.showTutorialWizard && this.tabs.eq(0).click();
	},
	
	/**
	 * 初始化发布tips
	 */
	initPublishTooltip: function() {
		var self = this,
			flag = false,
			parent = $('#header div.setting-tools'),
			text = '点此发布可应用您的修改到旺铺';
		
		$(window).bind('diychanged', function() {
			if (flag) {
				return;
			}
			new FloatTips(parent, text, { className: 'publish-tips' });
			flag = true;
		});
	}
	
};
//~ DiyHeader

WP.PageContext.register('#header', DiyHeader);

/**
 * 初始化SettingContext,以便让其他DIY面板接入
 */
WP.SettingContext = new WP.NodeContext('SettingContext', { 
	root: '#header'
});
	
})(jQuery, Platform.winport);
//~




