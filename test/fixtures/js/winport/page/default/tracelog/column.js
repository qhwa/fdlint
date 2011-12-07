/**
 * @fileoverview 旺铺前台打点-二级栏目页
 * @see http://b2b-doc.alibaba-inc.com/pages/viewpage.action?pageId=49835940
 * @author qijun.weiqj
 */
(function($, WP) {
	
var Util = WP.Util,
	TraceLog = WP.widget.TraceLog;

var ColumnModTraceLog = {
	init: function() {
		this.name = 'ColumnModTraceLog';
		Util.initParts(this);
	}
};

ColumnModTraceLog.Parts = {};


/**
 * 供应产品栏目页
 */
ColumnModTraceLog.Parts.AllOfferColumn = {
	init: function() {
		var mod = $('div.wp-all-offer-column');
		if (!mod.length) {
			return;
		}
		
		// 自定义分类区域的伸缩按钮
		new TraceLog([
			[$('a.offer-list-folding', mod), 'wp_page_offerlist_flexico'],
			[$('div.wp-search-in-site-unit input.search-btn', mod), 'wp_page_offerlist_mainsearch']
		]);
		
		// 各自定义分类链接文本
		new TraceLog('li a', 'wp_page_offerlist_selfcate', 
			{ delegate: $('div.wp-category-nav-unit', mod) });
		
		new TraceLog([
			// 橱窗展示
			['a.windows,a.windows-select', 'wp_page_offerlist_windowshow'],
			// 图文展示
			['a.catalogs,a.catalogs-select', 'wp_page_offerlist_listshow'],
			// 时间排序
			['a.time-down,a.time-down-select,a.time-up-select', 'wp_page_offerlist_timequeue'],
			// 价格排序
			['a.price-up,a.price-up-select,a.price-down-select', 'wp_page_offerlist_pricequeue'],
			// 标价筛选
			['input.price-filter', 'wp_page_offerlist_pricefilter'],
			// 混批筛选
			['input.mix-filter', 'wp_page_offerlist_mixfilter'],
			// 授权产品
			['input.private-filter', 'wp_page_offerlist_privatefilter'],
			// 团批筛选
			['input.group-filter', 'wp_page_offerlist_groupfilter']
		], { delegate: $('div.wp-offerlist-view-setting', mod) });
		
		new TraceLog([
			// 产品缩略图
			['li div.image', 'wp_page_offerlist_offerpic'],
			// 产品标题
			['li div.title', 'wp_page_offerlist_offertitle']
		], { delegate: mod });
		
		
		// 翻页
		new TraceLog('a', 'wp_page_offerlist_pagenav', 
			{ delegate: $('div.wp-offer-paging', mod) });
	}
};
//~ AllOfferColumn


/**
 * 公司介绍栏目页
 */
ColumnModTraceLog.Parts.CompanyInfoColumn = {
	init: function() {
		var mod = $('div.wp-company-info-column');
		if (!mod.length) {
			return;
		}
		
		// 详细信息
		new TraceLog([
			// 主营产品或服务
			['th.th-mainprod', 'wp_page_compintro_detail_mainprod'],
			
			// 工商注册信息	
			['th.th-auth', 'wp_page_compintro_detail_auth'],
			
			// 详细信息-证书及荣誉
			['th.th-cert', 'wp_page_compintro_detail_cert'],
			
			// 买家评价数
			['th.th-remark', 'wp_page_compintro_detail_remark'],
			
			// 资信参考人
			['th.th-referman', 'wp_page_compintro_detail_referman']
			
		], { delegate: $('div.info-detail', mod) });
		
		// 主要设备
		new TraceLog([
			// 设备名称
			['li div.image', 'wp_page_compintro_equipment_pic'],
			
			// 设备图片	
			['li div.name a', 'wp_page_compintro_equipment_name']
			
		], { delegate: $('div.info-equip', mod) });
	}
};
//~ CompanyInfoColumn


/**
 * 公司相册栏目页
 */
ColumnModTraceLog.Parts.AlbumColumn = {
	init: function() {
		var mod = $('div.wp-albums-column');
		if (!mod.length) {
			return;
		}
		
 		new TraceLog([
			// 相册封面图
			['li div.cover', 'wp_page_album_pic'],
			// 相册名称
			['li div.title', 'wp_page_album_title'],
			// 翻页
			['div.wp-album-paging a', 'wp_page_album_pagenav']
		], { delegate: mod });
	}
};
//~ AlbumColumn


/**
 * 联系方式栏目页
 */
ColumnModTraceLog.Parts.ContactInfoColumn = {
	init: function() {
		var mod = $('div.wp-contact-info-column');
		if (!mod.length) {
			return;
		}
		
		// 旺旺洽谈ICON
		new TraceLog($('a.alitalk', mod), 'wp_page_contact_alitalk');
		
		// 主区域
		new TraceLog([
			// 联系人
			['a.membername', 'wp_page_contact_membername'],
			// 顶级域名
			['a.topdomain', 'wp_page_contact_siteurl_topdomain'],
			// 二级域名
			['a.subdomain', 'wp_page_contact_siteurl_subdomain'],
			// 查看信用情况
			['a.show-integrity', 'wp_page_contact_trust'],
			// 外站
			['a.outsite', 'wp_page_contact_siteurl_outsite']
		], { delegate: mod });
	}
};
//~ ContactInfoColumn


/**
 * 会员专区栏目页
 */
ColumnModTraceLog.Parts.PrivateOfferColumn = {
	init: function() {
		var mod = $('div.wp-private-offer-column');
		if (!mod.length) {
			return;
		}
		
		// 自定义分类区域的伸缩按钮
		new TraceLog([
			[$('div.tips a.login', mod), 'wp_page_private_login'],
			[$('a.offer-list-folding', mod), 'wp_page_private_flexico']
		]);
		
		// 各自定义分类链接文本
		new TraceLog('li a', 'wp_page_private_selfcate', 
			{ delegate: $('div.wp-category-nav-unit', mod) });
		
		new TraceLog([
			// 橱窗展示
			['a.windows,a.windows-select', 'wp_page_private_windowshow'],
			// 图文展示
			['a.catalogs,a.catalogs-select', 'wp_page_private_listshow'],
			// 时间排序
			['a.time-down,a.time-down-select,a.time-up-select', 'wp_page_private_timequeue'],
			// 价格排序
			['a.price-up,a.price-up-select,a.price-down-select', 'wp_page_private_pricequeue'],
			// 标价筛选
			['input.price-filter', 'wp_page_private_pricefilter'],
			// 混批筛选
			['input.mix-filter', 'wp_page_private_mixfilter']
			
		], { delegate: $('div.wp-offerlist-view-setting', mod) });
		
		new TraceLog([
			// 产品缩略图
			['li div.image', 'wp_page_private_offerpic'],
			// 产品标题
			['li div.title', 'wp_page_private_offertitle']
		], { delegate: mod });
		
		
		// 翻页
		new TraceLog('a', 'wp_page_private_pagenav', 
			{ delegate: $('div.wp-offer-paging', mod) });
	}
};
//~ PrivateOfferColumn



WP.PageContext.register('~ColumnModTraceLog', ColumnModTraceLog);

	
})(jQuery, Platform.winport);

