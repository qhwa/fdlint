/**
 * @fileoverview DIY后台打点-板块编辑
 * @see http://b2b-doc.alibaba-inc.com/pages/viewpage.action?pageId=49835940
 * @author qijun.weiqj
 */
(function($, WP) {
	
var Util = WP.Util,
	TraceLog = WP.widget.TraceLog;

var DiyModTraceLog = {
	init: function() {
		this.name = 'DiyModTraceLog';
		Util.initParts(this);
	}
};

DiyModTraceLog.Parts = {};

/**
 * 导横板块
 */
DiyModTraceLog.Parts.TopNav = {
	init: function() {
		new TraceLog('div.wp-top-nav li', function() {
			var map = {
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
					'c1': 'wp_design_nav_go_diypage',
					'c2': 'wp_design_nav_go_diypage'
				},
				type = $(this).data('page-type');
			return map[type] || false;
		}, { delegate: true });
	}
};
//~ TopNav

/**
 * 招牌板块
 */
DiyModTraceLog.Parts.CompanyName = {
	
	init: function() {
		// 招牌图--上传
		new TraceLog('div.company-name-form-dialog',  
				'wp_design_widget_signboard_uploadboard', 
				{ event: 'topbanner-upload', delegate: true });
				
		// 公司标志--上传
		new TraceLog('div.company-name-form-dialog',  
				'wp_design_widget_signboard_uploadsign', 
				{ event: 'logo-upload', delegate: true });
				
		new TraceLog([
			// 公司标志--删除
			['div.company-name-form-dialog div.logo-part a.remove', 
					'wp_design_widget_signboard_deletesign'],
			
			// 中文名--取消选中显示中文名checkbox
			['div.company-name-form-dialog dl.zh-section input.show-zh', 
					'wp_design_widget_signboard_cnname_isdisplay'],
					
			// 中文名--设置字体
			['div.company-name-form-dialog dl.zh-section select.font-family', 
					'wp_design_widget_signboard_cnname_fontfamily'],
					
			// 中文名--设置字号
			['div.company-name-form-dialog dl.zh-section select.font-size', 
					'wp_design_widget_signboard_cnname_fontsize'],
					
			// 中文名--设置样式
			['div.company-name-form-dialog dl.zh-section a.setting', 
					'wp_design_widget_signboard_cnname_setstyle'],
					
			// 中文名--设置加粗
			['div.company-name-form-dialog dl.zh-section input.font-bold', 
					'wp_design_widget_signboard_cnname_bold'],
					
			// 中文名--设置斜体
			['div.company-name-form-dialog dl.zh-section input.font-italic', 
					'wp_design_widget_signboard_cnname_italic'],
					
			// 中文名--设置颜色
			['div.company-name-form-dialog dl.zh-section a.color-picker', 
					'wp_design_widget_signboard_cname_color'],
					
			// 英文名--取消选中显示中文名checkbox
			['div.company-name-form-dialog dl.en-section input.show-zh', 
					'wp_design_widget_signboard_enname_isdisplay'],
					
			// 英文名--设置字体	
			['div.company-name-form-dialog dl.en-section select.font-family', 
					'wp_design_widget_signboard_enname_fontfamily'],
					
			// 英文名--设置字号
			['div.company-name-form-dialog dl.en-section select.font-size', 
					'wp_design_widget_signboard_enname_fontsize'],
					
			// 英文名--设置样式
			['div.company-name-form-dialog dl.en-section a.setting', 
					'wp_design_widget_signboard_enname_setstyle'],
					
			// 英文名--设置加粗
			['div.company-name-form-dialog dl.en-section input.font-bold', 
					'wp_design_widget_signboard_enname_bold'],
					
			// 英文名--设置斜体
			['div.company-name-form-dialog dl.en-section input.font-italic', 
					'wp_design_widget_signboard_enname_italic'],
					
			// 英文名--设置颜色
			['div.company-name-form-dialog dl.en-section a.color-picker', 
					'wp_design_widget_signboard_ename_color'],
					
			// 英文名--确定
			['div.company-name-form-dialog a.d-confirm', 
					'wp_design_widget_signboard_confirm']

		], { delegate: true });
	}
	
};
//~ CompanyName

/**
 * 供应产品(自动)
 */
DiyModTraceLog.Parts.AutoRecOffers = {
	
	init: function() {
		// 侧边栏对话框
		this.initTraceLog('div.auto-rec-offers-main-form-dialog');
		// 主区域对话框
		this.initTraceLog('div.auto-rec-offers-sub-form-dialog');
	},
	
	
	initTraceLog: function(parent) {
		new TraceLog([
			// 设置产品分类
			[parent + ' select[name=catId]', 
					'wp_design_widget_prodlistauto_cate'],
			
			// 管理产品分类链接
			[parent + ' a.manage-category', 
					'wp_design_widget_prodlistauto_managecatelink'],
					
			// 选择信息类型
			[parent + ' input[name=filterType]', 
				function() {
					var map = {
						// 团批
						groupFilter: 'wp_design_widget_prodlistauto_type_group',
						// 授权
						privateFilter: 'wp_design_widget_prodlistauto_type_auth',
						// 混批
						mixFilter: 'wp_design_widget_prodlistauto_type_mix'
					};
					return map[this.value] || false;
				}
			],
			
			// 选中筛选价格范围
			[parent + ' input[name=priceFilter]',
				'wp_design_widget_prodlistauto_pricecheck'],
			
			// 预览筛选结果链接
			[parent + ' a.auto-offer-preview-a',
				'wp_design_widget_prodlistauto_previewlink'],
				
			// 设置产品分类
			[parent + ' select[name=sortType]', 
					'wp_design_widget_prodlistauto_order'],	
			
			// 设置显示数量
			[parent + ' select[name=count]', 
					'wp_design_widget_prodlistauto_num'],		
			
			// 确定
			[parent + ' a.d-confirm',
				'wp_design_widget_prodlistauto_ok']
				
		], { delegate: true });
		
		new TraceLog(parent + ' input.keywords', 
			'wp_design_widget_prodlistauto_keyword', 
			{ when: 'inputtext', delegate: true });
	}
	
};
//~ AutoRecOffers


/**
 * 基础板块
 */
DiyModTraceLog.Parts.Basic = {
	
	init: function() {
		new TraceLog([
			// 产品分类
			['div.category-nav-form-dialog a.manage-link', 
					'wp_design_widget_prodcate_managecatelink'],
			['div.category-nav-form-dialog a.d-confirm', 
					'wp_design_widget_prodcate_ok'],
			
			// 站内搜索
			['div.search-in-site-form-dialog input[name=isShowPrice][value=false]', 
					'wp_design_widget_search_pricesupport'],
					
			['div.search-in-site-form-dialog a.d-confirm', 
					'wp_design_widget_search_ok'],
					
					
			// 最新产品(主)
			['div.new-supply-offers-main-form-dialog select[name=maxNum]', 
					'wp_design_widget_prodnew_num'],
			['div.new-supply-offers-main-form-dialog a.d-confirm', 
					'wp_design_widget_prodnew_ok'],
					
			// 最新产品(侧)	
			['div.new-supply-offers-sub-form-dialog select[name=maxNum]', 
					'wp_design_widget_prodnew_num'],
			['div.new-supply-offers-sub-form-dialog a.d-confirm', 
					'wp_design_widget_prodnew_ok'],
					
			// 相册列表
			['div.albums-form-dialog select[name=maxNum]', 
					'wp_design_widget_albumlistauto_num'],
			['div.albums-form-dialog a.order-link', 
					'wp_design_widget_albumlistauto_orderlink'],
			['div.albums-form-dialog a.d-confirm', 
					'wp_design_widget_albumlistauto_ok'],
					
			// 推荐相册
			['div.recommend-albums-form-dialog a.manage-link', 
					'wp_design_widget_albumlistmanual_managelink'],
			['div.recommend-albums-form-dialog a.d-confirm', 
					'wp_design_widget_albumlistmanual_ok'],
					
			// 公司介绍
			['div.company-info-form-dialog a.manage-link', 
					'wp_design_widget_compintro_managelink'],
			['div.company-info-form-dialog a.d-confirm', 
					'wp_design_widget_compintro_ok'],
					
					
			// 公司动态
			['div.news-list-form-dialog select[name=maxNum]', 
					'wp_design_widget_news_num'],
			['div.news-list-form-dialog a.manage-link', 
					'wp_design_widget_news_managelink'],
			['div.news-list-form-dialog a.d-confirm', 
					'wp_design_widget_news_ok'],
					
			// 分类-马上启用
			['form.category-nav-form a.open', 'wp_design_widget_prodcate_start'],
					
					
			// 联系方式(主)
			['div.contact-info-main-form-dialog a.manage-link', 
					'wp_design_widget_contact_managelink'],
			['div.contact-info-main-form-dialog a.d-confirm', 
					'wp_design_widget_contact_ok'],
					
			// 联系方式(侧)
			['div.contact-info-sub-form-dialog a.manage-link', 
					'wp_design_widget_contact_managelink'],
			['div.contact-info-sub-form-dialog a.d-confirm', 
					'wp_design_widget_contact_ok'],
					
			// 友情链接
			['div.friend-link-form-dialog a.manage-link', 
					'wp_design_widget_friendlink_managelink'],
			['div.friend-link-form-dialog a.d-confirm', 
					'wp_design_widget_friendlink_ok']
		], { delegate: true });
	}
	
};
//~ Basic


/**
 * 自定义内容板块
 */
DiyModTraceLog.Parts.CustomContent = {
	
	init: function() {
		new TraceLog([
			// 确定
			['div.custom-content-form-dialog a.d-confirm', 
					'wp_design_widget_diypage_post'],
			// 取消
			['div.custom-content-form-dialog a.d-cancel', 
					'wp_design_widget_diypage_giveup']
		], { delegate: true });
		
		// 编辑
		new TraceLog('div.mod-box div.box-bar a.edit', function() {
			var box = $(this).closest('div.mod-box');
			return $('div.wp-custom-content', box).length ? 'wp_design_widget_diypage_manage' : false;
		}, { delegate: true });	
	}


};
//~ CustomContent

/**
 * 供应产品(手动)
 */
DiyModTraceLog.Parts.SelfRecOffers = {
	
	init: function() {
		new TraceLog([
			// 选择产品
			['div.selfRecOffers-form-dialog a.displayOfferList-b-selectPro', 
					'wp_design_widget_prodlisthand_choose'],
			// 确定
			['div.selfRecOffers-form-dialog a.d-confirm',
					'wp_design_widget_prodlisthand_ok']

		], { delegate: true });

		// 数量
		new TraceLog(
			'div.selfRecOffers-form-dialog input.wp_showcase_title', 
			'wp_design_widget_prodlisthand_num', 
			{ when: 'inputtext', delegate: true }
		);
	}

};



WP.PageContext.register('~DiyModTraceLog', DiyModTraceLog);

	
})(jQuery, Platform.winport);
