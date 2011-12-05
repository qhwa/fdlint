/**
 * @fileoverview 旺铺前台打点-核心板块
 * @see http://b2b-doc.alibaba-inc.com/pages/viewpage.action?pageId=49835940
 * @author qijun.weiqj
 */
(function($, WP) {
	
var Util = WP.Util,
	TraceLog = WP.widget.TraceLog;

var CoreModTraceLog = {
	init: function() {
		this.name = 'CoreModTraceLog';
		Util.initParts(this);
	},
	
	gridMain: function(elm) {
		return $(elm).closest('div.grid-main').length > 0;
	}
};

CoreModTraceLog.Parts = {};

/**
 * 招牌
 */
CoreModTraceLog.Parts.CompanyName = {
	init: function() {
		new TraceLog([
			// 公司标志
			['div.logo a', 'wp_widget_signboard_sign'],
			// 公司中文名
			['a.chinaname', 'wp_widget_signboard_cnname'],
			// 公司英文名
			['a.enname', 'wp_widget_signboard_enname']
		], { delegate: 'div.wp-company-name' });
	}
};
//~ CompanyName

/**
 * 导横板块
 */
CoreModTraceLog.Parts.TopNav = {
	init: function() {
		new TraceLog('li', function() {
			var map = {
					// 首页
					'sy': 'wp_widget_nav_index',
					// 供应信息
					'gy': 'wp_widget_nav_prod',
					// 诚信档案
					'zs': 'wp_widget_nav_trust',
					// 公司介绍
					'js': 'wp_widget_nav_comp',
					// 相册
					'xc': 'wp_widget_nav_album',
					// 公司动态
					'dt': 'wp_widget_nav_news',
					// 联系方式
					'lx': 'wp_widget_nav_contact',
					// 会员专区
					'hy': 'wp_widget_nav_private',
					// offerdetail
					'od': 'wp_widget_nav_offerdetail',
					// 自定义页面
					'c1': 'wp_page_diypage',
					'c2': 'wp_page_diypage'
				},
				type = $(this).data('page-type');
			return map[type] || false;
		}, { delegate: 'div.wp-top-nav' });
	}
};

/**
 * 供应商信息板块
 */
CoreModTraceLog.Parts.SupplierInfo = {
	
	init: function() {
		var mod = $('div.wp-supplier-info');
		
		new TraceLog([
			// 公司名（个人TP时是姓名）
			['a.tplogo', 'wp_widget_supplierinfo_logo'],
			
			// 公司名（个人TP时是姓名）
			['div.companyname a', 'wp_widget_supplierinfo_compname'],
			
			// 诚信保障ICON
			['div.guarantee a.basic-trust', 'wp_widget_supplierinfo_trust_ico'],
			
			// 可用保障金
			['p.guarantee-money a', 'wp_widget_supplierinfo_trust_money'],
			
			// 先行赔付
			['div.guarantee p.compensate a', 'wp_widget_supplierinfo_trust_xxpf'],
			
			// 诚信通指数
			['dl.tp-score a.score-value', 'wp_widget_supplierinfo_trustindex'],
			
			// 证书荣誉
			['dl.tp-honor dd a', 'wp_widget_supplierinfo_cert'],
			
			// 商品满意率
			['dl.sat-rate a.rate-value', 'wp_widget_supplierinfo_remark'],
			
			// 工商注册信息ICON
			['a.certificate-etp', 'wp_widget_supplierinfo_auth'],
			
			// 加工能力的更多链接
			['div.process-panel a.more', 'wp_widget_supplierinfo_process_more'],
			
			// 特殊荣誉-普及版/限量版发起人
			['li.honor-founder a,li.honor-popular a', 'wp_widget_supplierinfo_sponsor'],
			
			// 特殊荣誉-品牌
			['li.honor-goldenbrand a', 'wp_widget_supplierinfo_goldenbrand'],
			
			// 特殊荣誉-创业先锋
			['li.honor-precursor a', 'wp_widget_supplierinfo_precursor'],

			// 特殊荣誉-拍卖先锋
			['li.honor-auction a', 'wp_widget_supplierinfo_auction'],
			
			// 特殊荣誉-推广明星
			['li.honor-p4p a', 'wp_widget_supplierinfo_p4p'],
			
			// 特殊荣誉-分销大使
			['li.honor-fx a', 'wp_widget_supplierinfo_fx'],
			
			// 收藏按钮
			['a.pagecollect', 'wp_widget_supplierinfo_favorite'],
			
			// 特色服务-预存款申请按钮
			['div.precharge-panel a.apply', 'wp_widget_supplierinfo_precharge_apply '],
			
			// 特色服务-预存款充值按钮
			['div.precharge-panel a.charge', 'wp_widget_supplierinfo_precharge_pay'],
			
			// 会员服务--申请授权
			['div.private-panel a.apply-btn', 'wp_widget_supplierinfo_private_apply'],
			
			// 会员服务--查看会员专区
			['div.private-panel a.view-link', 'wp_widget_supplierinfo_private_gotoprivatepage'],
			
			//实地认证icon
			['dd.authentication a', 'wp_infowidget_quotation']
		], { delegate: mod });
		
		// 旺旺洽谈ICON
		new TraceLog($('a.alitalk', mod), 'wp_widget_supplierinfo_alitalk');
		
		new TraceLog([
			// 加工能力
			['a.process-ability', 'wp_widget_supplierinfo_process_ico'],
						
			// 会员服务-折扣ICON
			['dl.member-service a.discount', 'wp_widget_supplierinfo_private_discountico'],
			
			// 会员服务-私密ICON
			['dl.member-service a.private', 'wp_widget_supplierinfo_private_privateico'],
			
			// 预存款
			['a.precharge', 'wp_widget_supplierinfo_precharge_ico']
				
		], { once: true, event: 'mouseenter', delegate: mod });
	}
	
};
//~ SupplierInfo


/**
 * 公司介绍
 */
CoreModTraceLog.Parts.CompanyInfo = {
	init: function() {
		new TraceLog('a.more', 'wp_widget_compintro_more', { delegate: 'div.wp-company-info' });
	}
};
//~ CompanyInfo


/**
 * 供应产品(供应产品-自动、最新产品)
 */
CoreModTraceLog.Parts.OfferList = {
	init: function() {
		var modMain = $('div.wp-auto-rec-offers-main,div.wp-new-supply-offers-main'),
			modSub = $('div.wp-auto-rec-offers-sub,div.wp-new-supply-offers-sub');
		
		// 主区域
		new TraceLog([
			['div.image', 'wp_widget_offer_main_pic'],
			['div.title a', 'wp_widget_offer_main_tile'],
			['a.more', 'wp_widget_offer_main_more']
		], { delegate: modMain });
		
		// 侧边框
		new TraceLog([
			['div.image', 'wp_widget_offer_side_pic'],
			['div.title a', 'wp_widget_offer_side_tile'],
			['a.more', 'wp_widget_offer_side_more']
		], { delegate: modSub });
	}
};
//~ OfferList


/**
 * 相册板块
 */
CoreModTraceLog.Parts.Albums = {
	init: function() {
		var self = this;
		new TraceLog([
			// 相册封面图
			['li div.cover', function() {
				return self.gridMain(this) ? 
						'wp_widget_album_main_pic' : 'wp_widget_album_side_pic';
			}],
			// 相册名称
			['li div.title a', function() {
				return self.gridMain(this) ? 
						'wp_widget_album_main_title' : 'wp_widget_album_side_title';
			}],
			// 更多
			['a.more', function() {
				return self.gridMain(this) ? 
						'wp_widget_album_main_more' : 'wp_widget_album_side_more';
			}]
		], { delegate: 'div.wp-albums,div.wp-recommend-albums' });
	}
};
//~ Albums

/**
 * 公司介绍
 */
CoreModTraceLog.Parts.CompanyInfo = {
	init: function() {
		var self = this;
		
		new TraceLog([
			['div.info-image a', function() {
				return self.gridMain(this) ? 
					'wp_widget_compintro_main_pic' : 
					'wp_widget_compintro_side_pic';
			}],
			['a.more', function() {
				return self.gridMain(this) ? 
					'wp_widget_compintro_main_more' : 
					'wp_widget_compintro_side_more';
			}]
		], { delegate: 'div.wp-company-info' });
	}
};
//~ CompanyInfo

/**
 * 公司动态
 */
CoreModTraceLog.Parts.NewsList = {
	init: function() {
		var self = this,
			isHomePage = $('#doc').data('doc-config').isHomepage;
		
		new TraceLog([
			// 文章标题
			['li a', function() {
				return !self.gridMain(this) ? 'wp_widget_news_side_title' :	// 侧边栏
						isHomePage ? 'wp_widget_news_main_title' : 			// 主区域板块
								'wp_page_news_title';						// 二级栏目页
			}],
			
			// 更多
			['a.more', function() {
				return !self.gridMain(this) ? 'wp_widget_news_side_more' : // 侧边栏
						isHomePage ? 'wp_widget_news_main_more' : 		   // 二级栏目页
								'wp_page_news_more';
			}]
		], { delegate: 'div.wp-news-list' });
	}
};
//~ NewsList

/**
 * 自定义分类
 */
CoreModTraceLog.Parts.CategoryNav = {
	init: function() {
		var modMain = $('div.wp-category-nav-main'),
			modSub = $('div.wp-category-nav-sub');
		
		// 主区域链接文本
		new TraceLog('a.name', 'wp_widget_prodcate_main_title', { delegate: modMain });
		
		// 侧边栏
		new TraceLog([
			// 侧边栏文本
			['a.name', 'wp_widget_prodcate_side_title'],
			// 侧边栏图片
			['a.image', 'wp_widget_prodcate_side_pic']
		], { delegate: modSub });
	}
};


/**
 * 联系方式
 */
CoreModTraceLog.Parts.ContactInfo = {
	init: function() {
		var modMain = $('div.wp-contact-info-main'),
			modSub = $('div.wp-contact-info-sub');
		
		// 主区域
		new TraceLog([
			// 联系人
			['a.membername', 'wp_widget_contact_main_membername'],
			// 顶级域名
			['a.topdomain', 'wp_widget_contact_main_siteurl_topdomain'],
			// 二级域名
			['a.subdomain', 'wp_widget_contact_main_siteurl_subdomain'],
			// 外站
			['a.outsite', 'wp_page_contact_siteurl_outsite'],
			// 更多
			['a.more', 'wp_widget_contact_main_more']
		], { delegate: modMain });
		
		// 旺旺洽谈ICON
		new TraceLog([
			[$('a.alitalk', modMain), 'wp_widget_contact_main_alitalk'],
			[$('a.alitalk', modSub), 'wp_widget_contact_side_alitalk']
		]);
		
		// 侧边栏
		new TraceLog([
			// 联系人
			['a.membername', 'wp_widget_contact_side_membername'],
			// 更多
			['a.more', 'wp_widget_contact_side_more']
		], { delegate: modSub });
	}
};
//~ FriendLink

/**
 * 友情链接
 */
CoreModTraceLog.Parts.FriendLink = {
	init: function() {
		var self = this;
		new TraceLog('li a', function() {
			return self.gridMain(this) ? 
					'wp_widget_friendlink_main_title' :
					'wp_widget_friendlink_side_title'
					
		}, { delegate: 'div.wp-friend-link' });
	}
};
//~ ContactInfo


/**
 * 供应产品(手动)
 */
CoreModTraceLog.Parts.SelfRecOffers = {
	init: function() {
		var self = this;
		new TraceLog([
			['div.image', function() {
				return self.gridMain(this) ? 'wp_widget_offer_main_pic': 'wp_widget_offer_side_pic'
			}],

			['div.title a', function() {
				return self.gridMain(this) ? 'wp_widget_offer_main_tile': 'wp_widget_offer_side_tile'
			}],

			['a.more', function() {
				return self.gridMain(this) ? 'wp_widget_offer_main_more': 'wp_widget_offer_side_more'
			}]

		], { delegate: 'div.vas-selfRecOffers' });
	}
};
//~


/**
 * Footer
 */
CoreModTraceLog.Parts.Footer = {
	init: function() {
		new TraceLog([
			// 技术支持-阿里巴巴
			['a.footer-alibaba', 'wp_footer_alibaba'],
			// 旺铺管理入口
			['a.footer-wpadmin', 'wp_footer_wpadmin'],
			// 免责声明
			['a.footer-inform', 'wp_footer_inform'],
			// 企业邮局
			['a.footer-postoffice', 'wp_footer_postoffice']
		], { delegate: '#footer' })
	}
};
//~ Footer



WP.PageContext.register('~CoreModTraceLog', CoreModTraceLog);

	
})(jQuery, Platform.winport);
