/**
 * @fileoverview DIY后台打点 - 全局
 * @see http://b2b-doc.alibaba-inc.com/pages/viewpage.action?pageId=49835940
 * @author qijun.weiqj
 */
(function($, WP) {
	
var Util = WP.Util,
	TraceLog = WP.widget.TraceLog;

var DiySiteTraceLog = {
	init: function() {
		this.name = 'DiySiteTraceLog';
		Util.initParts(this);
	}
};

DiySiteTraceLog.Parts = {};

/**
 * 全局
 */
DiySiteTraceLog.Parts.Site = {
	init: function() {
		var header = $('#header'),
			help = $('ul.help-topics li', header),
			tabs = $('ul.setting-tabs li', header);

		new TraceLog([
			// 发布
			[$('a.publish', header), 'wp_design_post'],

			// 高级装修
			[$('a.advanced-diy', header), 'wp_pt_adv'],
			
			// 帮助-装修向导
			[help.eq(0), 'wp_design_help_guide'],
			// 帮助--帮助中心
			[help.eq(1), 'wp_design_help_kf'],
			// 帮助--阿里在线
			[help.eq(2), 'wp_design_help_aniu'],
			// 帮助--关于旺铺
			[help.eq(3), 'wp_design_help_about'],
			
			//布局模式
			['#view-mode-switch', function() {
				return $('#winport-content').hasClass('mini-mode') ?
						'wp_design_layoutmode_unfold' : 'wp_design_layoutmode_fold';
			}],
			
			//TOPBAR收缩按钮
			[$('div.collapse-bar a.handle', header), 'wp_design_topbar_fold'],
			
			// TOPBAR展开
			[$('div.expand-bar a.handle', header), 'wp_design_topbar_unfold'],
			
			//区域底部的板块添加横条
			['div.box-adder', 'wp_design_addwidget'],
			
			// 切换到风格管理TAB
			[tabs.eq(0), 'wp_design_tab_theme'],
			
			// 切换到页面管理TAB
			[tabs.eq(1), 'wp_design_tab_page']
		]);
		
		// 板块添加ICON
		new TraceLog('a.box-fly-adder', 'wp_design_widget_add', { delegate: true });
		
		new TraceLog([
			// 板块移动ICON
			['div.box-bar a.left,div.box-bar a.up,div.box-bar a.down,div.box-bar a.right', 
					'wp_design_widget_move_icon'],
			// 板块编辑ICON
			['div.box-bar a.edit', 'wp_design_widget_config'],
			// 板块删除ICON
			['div.box-bar a.del', 'wp_design_widget_delete']
		], { delegate: true });
		
		// 板块拖拽
		new TraceLog('div.mod-box', 'wp_design_widget_move_draw', { delegate: true, event: 'ddstop' });
		
		// 切换到页面管理TAB--基础页面二级TAB
		// 切换到页面管理TAB--详情页面二级TAB
		new TraceLog('div.diy-pages ul.pages-tabs li', function() {
			return $(this).index() === 0 ? 'wp_design_tab_page_basepage' : 
					'wp_design_tab_page_offerdetail';
		}, { delegate: '#header div.setting-panel' });
	}
};
//~ Site


/**
 * 风格库
 */
DiySiteTraceLog.Parts.Skins = {
	
	init: function() {
		new TraceLog('div.diy-skins div.cats-body a', function() {
			var map = [ 'all', 'red', 'purple', 'blue',
				'green', 'black', 'orange', 'yellow', 
				'white', 'other'
			], 
			tracelog = map[$(this).data('paging')];
			return tracelog ? 'wp_design_theme_' + tracelog : false;
		}, { delegate: '#header div.setting-panel' });
	}
	
};
//~ Skins


/**
 * 页面管理
 */
DiySiteTraceLog.Parts.Pages = {
	init: function() {
		new TraceLog(window, function(e, data) {
			var type = data.type,
				map = {
					// 页面顺序移动按钮
					'update-page-list-updown': 'wp_design_page_move_icon',
					// 页面顺序拖拽操作
					'update-page-list-drag': 'wp_design_page_move_draw',
					// 点击选中或取消选中显示在导航的checkbox
					'update-page-nav-status': 'wp_design_page_nav',
					// 修改页面名称的保存按钮
					'update-page-name': 'wp_design_page_savename'
				};
			return map[type] || false;
		}, { event: 'diychanged' });
		
		// 页面管理按扭
		new TraceLog('div.diy-pages a.diypage', function() {
			var tr = $(this).closest('tr'),
				map = {
					// 首页
					'sy': 'wp_design_page_go_index',
					// 供应信息
					'gy': 'wp_design_page_go_prod',
					// 诚信档案
					'zs': 'wp_design_page_go_trust',
					// 公司介绍
					'js': 'wp_design_page_go_comp',
					// 相册
					'xc': 'wp_design_page_go_album',
					// 公司动态
					'dt': 'wp_design_page_go_news',
					// 联系方式
					'lx': 'wp_design_page_go_contact',
					// 会员专区
					'hy': 'wp_design_page_go_private',
					// offerdetail
					'od': 'wp_design_page_go_offerdetail',
					// 自定义页面
					'c1': 'wp_design_page_go_diypage',
					'c2': 'wp_design_page_go_diypage'
				},
				type = (tr.data('page') || {}).type;
			return map[type] || false;
		}, { delegate: '#header div.setting-panel' });
	}
}
//~ Pages


/**
 * 板块容器(普通板块)
 */
DiySiteTraceLog.Parts.ListPanel = {
	init: function() {
		this.initBaseMod();
		this.initAdvMod();
	},

	/**
	 * 普通板块
	 */
	initBaseMod: function() {
		var map = {
			// 供应产品（自动）
			'offer.list:autoRecOffers': 'wp_design_widgetbox_add_prodlistauto',		
			// 产品分类
			'wp.categorynav:categoryNav': 'wp_design_widgetbox_add_prodcate',		
			// 产品搜索
			'wp.searchinsite:searchInSite': 'wp_design_widgetbox_add_search',		
			// 最新产品
			'offer.list:newSupplyOffers': 'wp_design_widgetbox_add_prodnew',
			// 公司介绍
			'company.profile:companyInfo': 'wp_design_widgetbox_add_compintro',		
			// 公司动态
			'wp.misc:newsList': 'wp_design_widgetbox_add_news',						
			// 联系方式
			'member.contact:contactInfo': 'wp_design_widgetbox_add_contact',		
			// 友情链接
			'wp.friendlink:friendLink': 'wp_design_widgetbox_add_friendlink',		
			// 公司相册
			'album:albumList': 'wp_design_widgetbox_add_albumlistauto',				
			// 推荐相册
			'album:recAlbum': 'wp_design_widgetbox_add_albumlistmanual',							
			// 供应产品(手动)
			'vas.winport:selfRecOffers': 'wp_design_widgetbox_add_prodlisthand'
		};

		new TraceLog('div.mod-list-panel a.add-mod', function() {
			var li = $(this).closest('li'),
				cid = li.data('addConfig').cid;
			return map[cid];
		}, { delegate: true });
	},

	/**
	 * 高级板块
	 */
	initAdvMod: function() {
		var map = {
			// 智能橱窗
			'vas.winport:recOfferIntelligent': ['wp_pt_buy_zn', 'wp_pt_zn_do'],
			// 公司风采
			'vas.winport:companyAppearance': ['wp_pt_buy_fc', 'wp_pt_fc_do'],
			// 大图轮播
			'vas.winport:recOfferImageRoll': ['wp_pt_buy_lb', 'wp_pt_lb_do'],
			// 滚动展示
			'vas.winport:recOfferRoll': ['wp_pt_buy_gd', 'wp_pt_gd_do'],
			// 专业列表
			'vas.winport:recOfferFeatureList': ['wp_pt_buy_list', 'wp_pt_list_do'],
			// 公司视频
			'vas.winport:companyVideo': ['wp_pt_buy_sp', 'wp_pt_sp_do']
		};

		new TraceLog('div.mod-list-panel a.add-mod', function() {
			var li = $(this).closest('li'),
				cid = li.data('addConfig').cid;
			return (map[cid] || {})[1];
		}, { delegate: true });

		new TraceLog('div.mod-list-panel a.purchase-mod', function() {
			var li = $(this).closest('li'),
				cid = li.data('addConfig').cid;
			return (map[cid] || {})[0];
		}, { delegate: true });

	}
};

//~ ListPanel


/**
 * 新旧版切换
 */
DiySiteTraceLog.Parts.SwitchVersion = {
	init: function() {
		new TraceLog([
			// 提意见
			['#header a.switch-advice', 'wp_design_switch_advise'],
			// 新版公告区回旧版的链接
			['#header a.switch-version', 'wp_design_switch_toold_link'],
			// 新版回旧版的强引导浮出框--返回旧版按钮
			['div.switch-version-dialog a.d-confirm', 'wp_design_switch_toold_button_toold'],
			// 新版会旧版的强引导浮出框--继续试用新版的按钮
			['div.switch-version-dialog a.d-cancel', 'wp_design_switch_toold_button_remainnew']
		], { delegate: true });
	}
};
//~ SwitchVersion


/**
 * 装修向导
 */
DiySiteTraceLog.Parts.Guide = {
	init: function() {
		new TraceLog('div.diy-guide', function(e, data) {
			return data.action === 'next' ? 
				'wp_design_guide_nextbutton_' + (data.step + 1) : false;
		}, { event: 'diyguide', delegate: true });
	}
};
//~ Guide


WP.PageContext.register('~DiySiteTraceLog', DiySiteTraceLog);

	
})(jQuery, Platform.winport);
