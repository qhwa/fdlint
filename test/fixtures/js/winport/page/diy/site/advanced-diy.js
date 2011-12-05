/**
 * 高级装修
 * @author qijun.weiqj
 */
(function($, WP) {


var PagingSwitcher = WP.widget.PagingSwitcher,
	Dialog = WP.widget.Dialog,
	ModBox = WP.diy.ModBox,
	Component = WP.diy.Component,
	Diy = WP.diy.Diy,
	Msg = WP.diy.Msg;


var AdvancedDiy = {

	init: function() {
		var self = this,
			link = $('div.setting-bar a.advanced-diy', '#header');
		
		this.url = link.data('url');
		this.tpl = FE.util.sweet(this.template);

		link.click(function(e) {
			e.preventDefault();
			self.open();
		});
	},

	open: function() {
		this.dialog = Dialog.open({
			header: '高级装修',
			draggable: true,
			content: $.proxy(this, 'loadContent'),
			className: 'advanced-diy-dialog',
			contentSuccess: $.proxy(this, 'contentSuccess')
		});
	},

	loadContent: function(success) {
		var self = this,
			error = function() {
				success('<div class="d-error">网络繁忙，请稍候重试！</div>');
			};

		$.ajax(this.url, {
			dataType: 'jsonp',
			success: function(ret) {
				if (!ret.success) {
					return error();
				}

				var data = self.filterData(ret.data),
					html = self.tpl.applyData(data);
				success(html);
			},
			error: error
		});
	},

	filterData: function(data) {
		var self = this,
			settingList = [],
			lists = [];

		$.each(data, function(index, app) {
			var listIndex = Math.floor(index / 6),
				list = lists[listIndex] = lists[listIndex] || [];

			list[index % 6] = app;
			if (self.canAppEdit(app)) {
				app.eidtIndex = app.editIndex || 100000 + index;
				settingList.push(app);
			}
		});	

		settingList.sort(function(left, right) {
			return left.editIndex - right.editIndex;
		});

		return {
			lists: lists,
			settingList: settingList
		};
	},

	canAppEdit: function(app) {
		if (!app.editable || !app.purchased) {
			return false;
		}
		if (app.modId && this.isDetailPage()) {
			return false;
		}

		return true;
	},

	isDetailPage: function() {
		return $('div.mod.wp-offerdetail', '#winport-content').length > 0;
	},

	contentSuccess: function(dialog) {
		this.panel = $('div.advanced-diy-panel', dialog.node);
		this.initSettingPart();
		this.initPurchasePart();
	},

	initSettingPart: function() {
		var self = this,
			part = $('div.setting-part', this.panel);
		part.delegate('a.setting', 'click', function(e) {
			var link = $(this),
				modId = link.data('modId');

			if (!modId) {
				return;
			}

			e.preventDefault();
			if (link.data('running')) {
				return;
			}
			link.data('running', true);
			Editor[modId].edit(function(success) {
				link.data('running', false);
				success && self.dialog.close();
			});
		});	
	},

	initPurchasePart: function() {
		var part = $('div.purchase-part', this.panel);
		this.initPagingNav(part);
		this.handlePurchased(part);
	},

	initPagingNav: function(part) {
		var links = $('ul.paging-nav li', part),
			items = $('ul.items-list', part);

		new PagingSwitcher(links, items);
	},

	handlePurchased: function(part) {
		part.delegate('a.purchased', 'click', function(e) {
			e.preventDefault();
		});
	},

	template: 
'<div class="advanced-diy-panel">\
	<% if (settingList.length) { %>\
	<div class="setting-part">\
		<h3>您可以设置</h3>\
		<ul class="items-list">\
		<% foreach (settingList as app) { %>\
			<li>\
				<div class="image" title="<%= app.name %>"><img src="<%= app.iconUrl %>" alt="<%= app.name %>" /></div>\
				<div class="wrap">\
					<h4><span><%= app.name %></span> <a href="<%= app.demoUrl %>" target="_blank">查看示例</a></h4>\
					<p class="desc"><%= app.desc %></p>\
					<div><a href="<% if (app.editUrl) { %><%= app.editUrl %><% } else { %>#<% } %>" <% if (app.modId) { %>data-mod-id="<%= app.modId %>"<% } %> class="setting wp-btn-01" target="_blank"><span>设置</span></a></div>\
				</div>\
			</li>\
		<% } %>\
		</ul>\
	</div>\
	<% } %>\
	<div class="purchase-part">\
		<h3>通过高级装修，可为旺铺加入公司视频、大图轮播橱窗等特色板块，并可以制作个性化的招牌和主题，让您可好地展示产品信息，提升企业形象。<a href="http://view.china.alibaba.com/cms/itbu/chengganli.html?tracelog=wp_advlink" target="_blank">查看完整示例&gt;&gt;</a></h3>\
		<% foreach (lists as list) { %>\
		<ul class="items-list" style="display: none;">\
			<% foreach (list as app) { %>\
			<li class="<% if (app.purchased) { %>is-purchased<% } %>">\
				<div class="image" title="<%= app.name %>"><img src="<%= app.iconUrl %>" alt="<%= app.name %>" /></div>\
				<div class="wrap">\
					<h4><span><%= app.name %></span> <a href="<%= app.demoUrl %>" target="_blank">查看示例</a></h4>\
					<p class="desc"><%= app.desc %></p>\
					<div class="op">\
						<% if (app.needRenew) { %>\
							<a href="<%= app.purchaseUrl %>" class="renew wp-btn-01" target="_blank"><span>续费</span></a>\
						<% } else if (app.purchased) { %>\
							<a href="#" class="purchased wp-btn-01-disabled"><span>已购买</span></a>\
							<% if (app.helpUrl) { %><a href="<%= app.helpUrl %>" class="help" target="_blank">查看帮助</a><% } %>\
						<% } else { %>\
							<a href="<%= app.purchaseUrl %>" class="purchase wp-btn-01" target="_blank"><span>购买</span></a>\
							<% if (app.tryUrl) { %><a href="<%= app.tryUrl  %>" class="try" target="_blank">马上试用</a><% } %>\
						<% } %>\
					</div>\
				</div>\
			</li>\
			<% } %>\
		</ul>\
		<% } %>\
		<div class="part-footer">\
			<ul class="paging-nav">\
				<% for (var i = 0; i < lists.length; i++) { %>\
				<li data-paging="<%= i %>"><a href="#"><%= i + 1 %></a></li>\
				<% } %>\
			</ul>\
		</div>\
	</div>\
	<div class="banner-area"><iframe frameborder="0" scrolling="no" src="http://view.china.alibaba.com/cms/itbu/mkword.html"></iframe></div>\
</div>'

};


var Editor = {};


/**
 * 营销海报编辑
 */
Editor['vas-marketingPoster'] = {
	cid: 'vas.winport:marketingPoster',

	edit: function(callback) {
		this.prepareRegion($.proxy(this, 'doEdit', callback));
	},

	doEdit: function(callback, region) {
		var mod = $('div.vas-marketingPoster', region),
			box = null;

		if (mod.length) {
			box = mod.closest('div.mod-box');
			callback(true);
			ModBox.edit(box);
		} else {
			this.create(region, callback);
		}
	},

	create: function(region, callback) {
		var index = $('div.mod', region).length;
		ModBox.add({
			cid: this.cid,
			region: region,
			index: index,
			success: function() {
				callback(true);
			},
			error: function(message) {
				Msg.error(message);
				callback(false);
			}
		});
	},

	/**
	 * 保证fly区域有相应的layout
	 */
	prepareRegion: function(callback) {
		var fly = $('#winport-fly'),
			region = $('div.region:first', fly);
		if (region.length) {
			callback(region);
			return;
		}

		fly.prepend($(this.template));
		this.saveLayout(function() {
			region = $('div.region:first', fly);
			callback(region);
		}, function() {
			Msg.error('编辑板块失败，请刷新后重试！');
		});
	},

	saveLayout: function(success, error) {
		var	contentCfg = Component.getContentConfig(),
			url = contentCfg.saveLayoutUrl,
			data = {
				_csrf_token: Component.getDocConfig()._csrf_token,
				version: contentCfg.version,
				pageSid: contentCfg.sid,
				pageContent: Component.getPageLayout(),
				delList: '[]'
			};

		Diy.authAjax(url, {
			type: 'POST',
			data: data,
			dataType: 'json',
			success: function(o) {
				if (o.success) {
					++contentCfg.version;
					success();
				} else {
					error();
				}
			}
		});
	},

	/**
	 * fly区layout模板
	 */
	template: 
'<div class="layout-box" data-box-config=\'{"sid":0,"cid":"layout:p32-m0"}\'>\
	<div class="layout p32-m0">\
		<div class="grid-main">\
			<div class="main-wrap region"  data-region-config=\'{"cid":"MAIN"}\' ></div>\
		</div>\
	</div>\
</div>'


};



WP.PageContext.register('~AdvancedDiy', AdvancedDiy);


})(jQuery, Platform.winport);
