/**
 * 产品选择组件
 * @author qijun.weiqj
 */
(function($, WP) {


var Util = WP.Util,
	UI = WP.UI;


/**
 * 帮助工具方法
 */
var Helper = {
	/**
	 * 显示loading
	 */
	showLoading: function(div) {
		div.html('<div class="loading">正在加载...</div>');
	},

	/**
	 * 显示信息
	 */
	showMessage: function(div, message, callback) {
		var elm = $('<div class="message">' + message +'</div>');
		div.empty().append(elm);
		elm.delay(5000).fadeOut(function() {
			elm.remove();
			callback && callback();
		});
	},

	/**
	 * 对Offer数据结构进行变换,以便用于渲染
	 */
	filterOffer: function(offer) {
		var clone = $.extend({}, offer);

		clone.formatedTitle = offer.title.length > 20 ? offer.title.substr(0, 20) + '..' : offer.title;
		clone.formatedTitle = $.util.escapeHTML(clone.formatedTitle, true);

		clone.title = $.util.escapeHTML(offer.title, true);
		clone.image = offer.image || 'http://img.china.alibaba.com/images/app/platform/winport/mod/offers/nopic-64.png';
		clone.price = $.util.escapeHTML('' + offer.price, true).replace(/(\d+(?:\.\d+)?)/, '<em>$1</em>');
		return clone;
	},

	/**
	 * 处理Offer列表Hover事件
	 */
	handleOfferListHover: function(offerList) {
		offerList.delegate('li', 'mouseenter', function() {
			$('li', offerList).removeClass('hover');
			$(this).addClass('hover');
		});
	}
};

/**
 * 产品选择类
 * @see OfferChooser
 */
var OfferChooser = new WP.Class({
	/**
	 * @param {object} config 配置参数
	 *  - dataProvider {object} 数据源
	 *　- sourceOfferTitle {string} 左侧标题
	 *  - selectedOfferTitle {string} 右侧标题
	 *  - maxSelectedCount {int} 最大选择数目

	 *  - comback {object{ text: string, action: function }} 返回
	 */
	init: function(config) {
		this.config = config; 

		this.node = $(this._template);
		this.node.appendTo(config.appendTo);
		
		// 首先初始化selectedOfferPart, 因为SourceOfferPart会使用到getSelectedOffersId接口
		this.selectedOfferPart = new SelectedOfferPart(this);
		$.extend(this, Util.delegate(this.selectedOfferPart, 
				['getSelectedOffers', 'getSelectedOffersId']));

		this.sourceOfferPart = new SourceOfferPart(this);
	},


	/**
	 * 选择产品html模板
	 */
	_template:
'<div class="widget-offer-chooser">\
	<div class="source-offer-part">\
		<div class="w-header">\
			<h3></h3>\
		</div>\
		<div class="search-panel">\
			<div class="search-cats ui-combobox">\
				<input type="text" readonly="readonly" autocomplete="off" class="result">\
				<a hidefocus="true" href="javascript:;" class="trigger"></a>\
			</div>\
			<input type="text" class="search-text" maxlength="50" />\
			<a href="#" class="search-btn">搜索</a>\
		</div>\
		<div class="offer-list"></div>\
		<div class="paging-nav"></div>\
	</div>\
	<div class="selected-offer-part">\
		<div class="w-header"><h3></h3></div>\
		<div class="offer-list"></div>\
		<div class="expire-message">过期信息无法在旺铺中展示，请重发或更换信息！</div>\
	</div>\
</div>'	

});
//~ OfferChooser


/**
 * 左侧Offer列表部分
 */
var SourceOfferPart = new WP.Class({
	
	init: function(chooser) {
		this.Chooser = chooser;
		this.node = chooser.node;
		this.config = chooser.config;

		this.part = $('div.source-offer-part', this.node);

		this._offerList = $('div.offer-list', this.part);

		// 当前查询参数
		this._params = {
			category: this.config.selectedCategory,
			pageIndex: 1,
			pageSize: 5
		};
		
		this._renderHeader();
		this._handleOfferList();
		this._handleOfferAddRemove();

		new SearchPanel(this);
		new PagingNav(this);

		this.loadOffers();
	},

	_renderHeader: function() {
		var header = $('div.w-header', this.part),
			comeback = this.config.comeback;

		this._renderTitle(header);
		comeback && this._renderComeback(header, comeback);
	},

	_renderTitle: function(header) {
		$('h3', header).html(this.config.sourceOfferTitle || '我的供应信息');
	},

	/**
	 * 渲染返回链接
	 */
	_renderComeback: function(header, comeback) {
		comeback = typeof comeback === 'function' ? 
				{ text: '返回', action: comeback  } : comeback;

		var link = $($.util.substitute('<a href="#" class="comeback">{text}</a>', comeback));

		link.click(function(e) {
			e.preventDefault();
			comeback.action();
		});

		header.append(link);
	},

	/**
	 * 处理Offer选择事件
	 */
	_handleOfferList: function() {
		var self = this;

		this._offerList.delegate('a.select-btn', 'click', function(e) {
			e.preventDefault();

			var li = $(this).closest('li'),
				offer = li.data('offer');
			
			self.node.triggerHandler('offer.select', offer);
		});	
		
		// 处理OfferListHover事件
		Helper.handleOfferListHover(this._offerList);
	},

	/**
	 * 产品添加/移除后更新按扭状态
	 */
	_handleOfferAddRemove: function() {
		var self = this;
		this.node.bind('offer.remove', function(e, offer) {
			var li = self._getOfferItem(offer);
			li.removeClass('status-added');

			$(self._offerList).removeClass('status-full');
		});

		this.node.bind('offer.add', function(e, offer) {
			var li = self._getOfferItem(offer);
			li.addClass('status-added');
		})

		this.node.bind('offer.full', function() {
			$(self._offerList).addClass('status-full');
		});
	},

	/**
	 * 根据Offer取得OfferList中对应项
	 */
	_getOfferItem: function(offer) {
		return $('li', this._offerList).filter(function() {
			return $(this).data('offer').id === offer.id;
		});
	},

	/**
	 * 请求Offer列表
	 */
	loadOffers: function(params) {
		var self = this;
		
		params && $.extend(this._params, params);

		Helper.showLoading(this._offerList);
		this.config.dataProvider.searchOffers(this._params, function(data) {
			self._renderOfferList(data.offers);
			self.node.trigger('offer.load', data);
		}, function() {
			Helper.showMessage(self._offerList, '网络繁忙，请稍候重试');	
		});
	},

	/**
	 * 渲染源Offer列表
	 */
	_renderOfferList: function(offers) {
		var self = this,
			selectedOffers = this.Chooser.getSelectedOffersId(),
			ul = $('<ul>');

		$.each(offers, function(i, offer) {
			var html = $.util.substitute(self._template, 
					Helper.filterOffer(offer)),
				li = $(html);
			li.data('offer', offer);
			
			// 如果已选择的offer已载入,则selectedOffers不为空, 否则selectedOffers === undefined
			if (selectedOffers && $.inArray(offer.id, selectedOffers) !== -1) {
				li.addClass('status-added');
			}

			offer.price || $('dd.price', li).remove();

			ul.append(li);
		});

		this._offerList.empty().append(ul);
		UI.resizeImage($('li .image img', this._offerList), 50);
	},

	_template:
'<li>\
	<dl>\
		<dt class="image"><a href="{detailUrl}" class="wrap" title="{title}" target="_blank"><img src="{image}" alt="{title}" /></a></dt>\
		<dd class="title"><a href="{detailUrl}" title="{title}" target="_blank">{formatedTitle}</a></dd>\
		<dd class="price">{price}</dd>\
		<dd class="date">{date}</dd>\
	</dl>\
	<div class="op">\
		<a href="#" class="select-btn">选择</a>\
		<span class="offer-added">已选择</span>\
	</div>\
</li>'

});
//~ SourceOfferPart


/**
 * 搜索面板
 */
var SearchPanel = new WP.Class({
	
	init: function(part) {
		this.Part = part;
		this.node = part.node;
		this.part = part.part;
		this.config = part.config;

		this.searchPanel = $('div.search-panel', this.part);

		this._initSearchCats();
		this._handleSearchBtn();
	},

	/**
	 * 初始化类目下拉框
	 */
	_initSearchCats: function() {
		var self = this,
			div = $('div.search-cats', this.searchPanel),
			selectedCat = this.config.selectedCategory;
	
		// 有当前选择类目时, 则渲染到文本框，不需要下拉框
		if (selectedCat) {
			self._renderSelectedCat(div, selectedCat);
			this._selectedCat = selectedCat;
			return;
		}
		
		this.config.dataProvider.loadCategories(function(cats) {
			self._renderSearchCats(div, cats);
		});
	},

	_renderSelectedCat: function(div, cat) {
		var input = $('input.result', div);
		input.val(this._formatResult(cat.name));
		div.addClass('no-combobox');
	},

	/**
	 * 根据类目渲染select
	 */
	_renderSearchCats: function(div, cats) {
		$.use('ui-combobox', $.proxy(this, '__renderSearchCats', div, cats));
	},

	__renderSearchCats: function(div, cats) {
		var self = this,
			items = self._createItems(cats),
			btn = $('a.search-btn', this.searchPanel),
			nullCat = { id: '', name: '全部信息' };

		items.unshift({ text: nullCat.name, value: '0', cat: nullCat });

		div.empty().combobox({
			value: '0',
			data: items,
			resultTpl: function(item) {
				return self._formatResult(item.cat.name); 
			},
			change: function() {
				var elm = $('li.ui-combobox-selected', div);
				self._selectedCat = elm.data('item').cat;
				btn.click();
			}
		});

		this._renderSearchCatsSeparator(div, items);
	},

	/**
	 * 格式化类目名称, 以便显示在result上
	 */
	_formatResult: function(name) {
		return name.substr(0, 6);
	},

	/** 
	 * 渲染类目分隔样式
	 */
	_renderSearchCatsSeparator: function(div, items) {
		var lis = $('li.ui-combobox-item', div),
			type = null;

		lis.each(function(index) {
			var li = $(this),
				cat = items[index].cat, 
				nowType = cat.type;

			li.attr('title', $.util.escapeHTML(cat.name, true));
			
			if (!nowType) {
				return;
			}
			
			if (type && type !== nowType) { // 类目类型发生变化
				li.addClass('item-separator');
			}

			type = nowType;
		})
	},

	/**
	 * 根据类目创建渲染数据结构
	 * @param {array<object>} cats
	 * @param {int} level 层级, 用于缩进
	 */
	_createItems: function(cats, level) {
		var self = this,
			items = [];

		level = level || 0;
		$.each(cats, function(i, cat) {
			items.push({ text: self._formatCatName(cat.name, level), value: cat.id, cat: cat }); 
			if (cat.children) {
				items.push.apply(items, 
						self._createItems(cat.children, level + 1));
			}
		});

		return items;
	},

	/**
	 * 格式化
	 */
	_formatCatName: function(name, level) {
		var prefix = '';
		for (var i = 0; i < level; i++) {
			prefix += '&nbsp;&nbsp;&nbsp;';
		}
		name = name || '';
		name = name.length > 10 ? name.substr(0, 10) + '..' : name;
		return prefix + $.util.escapeHTML(name, true); 
	},

	/**
	 * 处理搜索事件
	 */
	_handleSearchBtn: function() {
		var self = this,
			panel = this.searchPanel,
			btn = $('a.search-btn', panel),
			searchText = $('input.search-text', panel);

		btn.click(function(e) {
			e.preventDefault();

			var params = { 
					pageIndex: 1,
					category: self._selectedCat,
					keywords: $('input.search-text', panel).val()
				};

			self.Part.loadOffers(params);
		});

		searchText.keydown(function(e) {
			if (e.keyCode === 13) {
				e.preventDefault();
				btn.click();
			}
		});
	}

});
//~ SearchPanel


/**
 * 分页条
 */
var PagingNav = new WP.Class({
	
	init: function(part) {
		this.Part = part;
		this.node = part.node;
		this.part = part.part;
		this.config = part.config;

		this.pagingNav = $('div.paging-nav', this.part);

		this._handleOffersLoad();
		this._handlePagingNav();
		this._handleJumpto();
	},

	/**
	 * offer载入后需要重新渲染分页条
	 */
	_handleOffersLoad: function() {
		var self = this;
		this.node.bind('offer.load', function(e, data) {
			self.paging = $.extend({
				pageIndex: 1,
				pageCount: 0
			}, data);
			
			self._render();
			self._handleJumptoTextValidate();
		});
	},

	/**
	 * 渲染分页条
	 */
	_render: function() {
		var paging = this.paging,
			pagingNav = this.pagingNav,
			pageIndex = paging.pageIndex,
			data = null,
			html = [],
			template = '<a href="page/{page}" class="{class}" data-page="{page}">{text}</a>';

		data = this._createData(paging);
		
		// prev
		html.push($.util.substitute(template, { 'class': 'page-prev', page: pageIndex - 1, text: '上一页' }));

		// num
		$.each(data, function(i, item) {
			html.push($.util.substitute(template, { 'class': item[2], page: item[0], text: item[1] }));
		});

		// next
		html.push($.util.substitute(template, { 'class': 'page-next', page: pageIndex + 1, text: '下一页' }));	

		// jump
		html.push('跳转至 <input type="text" class="jumpto-text" /> 页 <a href="#" class="jumpto-btn">确定</a>');
		
		pagingNav.empty().html(html.join('')).show();
		
		pageIndex <= 1 && $('a.page-prev', pagingNav).addClass('disabled');
		pageIndex >= paging.pageCount && $('a.page-next', pagingNav).addClass('disabled');
	},

	/**
	 * 创建分页条数据结构
	 */
	_createData: function(paging) {
		var result = [],
			pageIndex = paging.pageIndex,
			pageCount = paging.pageCount > 1 ? paging.pageCount : 1,

			size = 7,
			from = pageIndex - Math.floor((size - 4) / 2),
			to,
			now;
		
		// 产生除去头尾4个页码的中间页码
		from + size - 2 > pageCount && (from = pageCount - size + 3); 
		from < 3 && (from = 3);	// 最少从第3页开始
		to = from;
		for (var i = 0; i < size - 4; i++) {
			if (to > pageCount - 2) {
				break;
			}
			result.push([to, to, 'page-num']);
			to++;
		}
		to--;
		
		// 产生页码2
		if (pageCount > 1) {
			now = Math.floor((from + 1) / 2);
			result.unshift(from > now + 1 ? [now, '...', 'page-num omit'] : [now, now, 'page-num']); 
		}

		// 产生页码1
		if (pageCount > 0) {
			result.unshift([1, 1, 'page-num']);
		}

		// 产生最后第2个页码
		if (pageCount > 2) {
			now = Math.floor((pageCount + to + 1) / 2);
			result.push(to < now - 1 ? [now, '...', 'page-num omit'] : [now, now, 'page-num']);
		}

		// 产生最后1个页码
		if (pageCount > 3) {
			result.push([pageCount, pageCount, 'page-num'])
		}

		// 添加current
		$.each(result, function(i, item) {
			if (item[0] === pageIndex) {
				item[2] += ' current';
				return false; // break
			}
		});

		return result;
	},

	/**
	 * 处理页面输入框验证
	 */
	_handleJumptoTextValidate: function() {
		var self = this,
			input = $('input.jumpto-text', this.pagingNav);
		$.use('wp-instantvalidator', function() {
			WP.widget.InstantValidator.validate(input, 'pagenum'); 
		});
	},

	/**
	 * 处理分页事件
	 */
	_handlePagingNav: function() {
		var self = this;

		this.pagingNav.delegate('a[data-page]', 'click', function(e) {
			e.preventDefault();
			var link = $(this);
			if (link.hasClass('disabled') || link.hasClass('current')) {
				return;
			}
			self.Part.loadOffers({ pageIndex: $(this).data('page') });
		});
	},

	/**
	 * 处理跳转事件
	 */
	_handleJumpto: function() {
		var self = this;

		this.pagingNav.delegate('a.jumpto-btn', 'click', function(e) {
			e.preventDefault();

			var jumptoText = $('input.jumpto-text', self.pagingNav),
				page = parseInt(jumptoText.val()),
				pageCount = self.paging.pageCount;

			if (!page || page == self.paging.pageIndex) {
				return;
			}
			page = page < 1 ? 1 :
				page > pageCount ? pageCount : page;

			self.Part.loadOffers({ pageIndex: page })
		});

		this.pagingNav.delegate('input.jumpto-text', 'keydown', function(e) {
			if (e.keyCode === 13){
				$('a.jumpto-btn', self.pagingNav).click();
				return false;
			}
		});
	}

});
//~ PagingNav



/**
 * 右侧已选择Offer部分
 */
var SelectedOfferPart = new WP.Class({

	init: function(chooser) {
		this.Chooser = chooser;
		this.node = chooser.node;
		this.config = chooser.config;

		this.part = $('div.selected-offer-part', this.node);
		
		this.title = $('h3', this.part);
		this.offerList = $('div.offer-list', this.part);
		this.expireMessage = $('div.expire-message', this.part);

		this.maxSelectedCount = this.config.maxSelectedCount || 16;

		this._handleOfferSelect();
		this._handleOfferChange();
		
		this._initOfferList();
	},

	/**
	 * 初始化Offer列表
	 */
	_initOfferList: function() {
		this._loadSelectedOffers();
		Helper.handleOfferListHover(this.offerList);
		this._handleOfferListRemove();
		this._handleOfferListUpDown();
		this._initOfferListSortable();
	},
	
	/**
	 * 载入已选择的Offer(this.config.selectedOffers.length > 0)
	 */
	_loadSelectedOffers: function() {
		var self = this,
			selectedOffers = this.config.selectedOffers || [];
		// 没有数据
		if (selectedOffers.length === 0) {
			this._renderEmptyOfferList();	
			return;
		}
		// 有selectedOffers
		Helper.showLoading(this.offerList);
		this.config.dataProvider.loadOffers(selectedOffers, function(data) {
			self._renderOfferList(data.offers);

			if (data.offers.length === self.maxSelectedCount) {
				self.node.trigger('offer.full');
			}
			self.inited = true; // 标识为已初始化
		}, function() {
			Helper.showMessage(self.offerList, '网络繁忙，请稍候重试', 
					$.proxy(self, '_renderEmptyOfferList'));	
		});
	},

	_renderEmptyOfferList: function() {
		this.offerList.append($('<ul>'));
		this.inited = true; // 标识为已初始化, 用于getSelectedOffersId
		this._refreshStatus();
	},

	/**
	 * 渲染OfferList
	 */
	_renderOfferList: function(offers) {
		var self = this,
			ul = $('<ul>');

		$.each(offers, function(i, offer) {
			ul.append(self._createOfferItem(offer));
			self.node.trigger('offer.add', offer);
		});

		this.offerList.empty().append(ul);
		this._refreshStatus();
	},

	/**
	 * 创建一个OfferListItem项
	 */
	_createOfferItem: function(offer) {
		var html = $.util.substitute(this._template, Helper.filterOffer(offer)),
			li = $(html);
		li.data('offer', offer);
		UI.resizeImage($('.image img', li), 50);
		offer.price || $('dd.price', li).remove();
		offer.expire || $('dd.status-expire', li).remove();
		return li;
	},

	
	/**
	 * 处理移除操作
	 */
	_handleOfferListRemove: function() {
		var self = this;

		this.offerList.delegate('a.delete-btn', 'click', function(e) {
			e.preventDefault();
			var li = $(this).closest('li'),
				offer = li.data('offer');
			
			li.remove();
			self.node.trigger('offer.remove', offer);
		});
	},
	
	/**
	 * 处理上移下移
	 */
	_handleOfferListUpDown: function() {
		var self = this;

		this.offerList.delegate('a.up-btn,a.down-btn', 'click', function(e) {
			e.preventDefault();	
			var li = $(this).closest('li'),
				offer = li.data('offer'),
				up = $(this).hasClass('up-btn'),
				sli = li[up ? 'prev' : 'next']();

			self._swapOfferItem(li, sli, function() {
				self.node.trigger('offer.move', offer);
			});
		});
	},

	/**
	 * 动画效果,交换两个li
	 */
	_swapOfferItem: function(li, sli, callback) {
		var self = this,
			liPos = li.position(),
			sliPos = sli.position(),
			
			first = li.clone(),
			second = sli.clone(),

			times = 0,
			complete = null;

		this.offerList.addClass('status-animate');

		first.css({ 
			position: 'absolute', 
			left: liPos.left, 
			top: liPos.top,
			background: '#f6f6f6',
			opacity: 0.8
		}).insertAfter(li);

		second.css({ 
			position: 'absolute', 
			left: sliPos.left, 
			top: sliPos.top,
			background: '#f6f6f6',
			opacity: 0.8
		}).insertAfter(sli);
		
		complete = function() {
			if (++times < 2) {
				return;
			}
			first.remove();
			second.remove();
			
			li.index() < sli.index() ? sli.after(li) : 
					li.after(sli);
			li.css('visibility', 'visible');
			sli.css('visibility', 'visible');
			
			self.offerList.removeClass('status-animate');
			callback();
		};

		li.css('visibility', 'hidden');
		sli.css('visibility', 'hidden');
		
		first.animate({ top: sliPos.top }, complete);
		second.animate({ top: liPos.top }, complete);
	},
	//~ swapOfferItem

	_initOfferListSortable: function() {
		var self = this;
		$.use('ui-portlets', function() {
			$(self.offerList).portlets({
				items: 'li',
				axis: 'y',
				opacity: 0.8,
				stop: function(e, ui) {
					var offer = ui.currentItem.data('offer');
					self.node.trigger('offer.move', offer);	
				},
				revert: 200
			});
		});
	},

	/**
	 * 取得已选择的offer列表
	 */
	getSelectedOffers: function() {
		var offers = [];
		$('li', this.offerList).each(function() {
			offers.push($(this).data('offer'));
		});
		return offers;
	},

	/**
	 * 取得当前选择的Offerid列表
	 * 如果offer列表未载入, 则返回undefined
	 */
	getSelectedOffersId: function() {
		if (!this.inited) {
			return;
		}

		var offers = this.getSelectedOffers();
		return $.map(offers, function(offer) {
			return offer.id;
		});
	},


	/**
	 * 处理offer.select事件
	 */
	_handleOfferSelect: function() {
		var self = this;

		this.node.bind('offer.select', function(e, offer) {
			var selectedOffers = self.getSelectedOffersId(),
				ul = $('ul', self.offerList),
				item = null;
			
			if (!self.inited || $.inArray(offer.id, selectedOffers) !== -1) {
				return;
			}

			if (selectedOffers.length >= self.maxSelectedCount) {
				return;
			}

			item = self._createOfferItem(offer);
			ul.append(item);
			
			self.node.trigger('offer.add', offer);
			
			if (selectedOffers.length + 1 === self.maxSelectedCount) {
				self.node.trigger('offer.full');
			}
		});
	},

	/**
	 * 添加/移除/移动后　需要刷新标题和OfferList效果
	 */
	_handleOfferChange: function() {
		var self = this;
		this.node.bind('offer.add offer.remove offer.move', function() {
			self.inited && self._refreshStatus();
		});
	},

	_refreshStatus: function() {
		this._renderTitle();
		this._renderOfferListEffect();
		this._renderExpireMessage();
	},

	_renderTitle: function() {
		var title = this.config.selectedOfferTitle || 
				'已选择<em>{selectedCount}</em>条，您共可选择<em>{maxSelectedCount}</em>条',
			selectedCount = $('li', this.offerList).length;

		title = $.util.substitute(title, {
			selectedCount: selectedCount,
			maxSelectedCount: this.maxSelectedCount
		});

		this.title.html(title);
	},

	/**
	 * 当OfferList变动时需要调整first/last类
	 * faint,CSS3支持的话就不需要这个操作了
	 */
	_renderOfferListEffect: function() {
		var lis = $('li', this.offerList);
		lis.removeClass('first last');
		lis.first().addClass('first');
		lis.last().addClass('last');
	},

	/**
	 * 显示/隐藏过期提示信息
	 */
	_renderExpireMessage: function() {
		var self = this,
			offers = this.getSelectedOffers();

		this.expireMessage.hide();

		$.each(offers, function(index, offer) {
			if (offer.expire) {
				self.expireMessage.show();
				return false; // break
			}	
		});
	},

	_template: 
'<li>\
	<dl>\
		<dt class="image"><div class="wrap"><img src="{image}" alt="{title}" /></div></dt>\
		<dd class="title">{formatedTitle}</dd>\
		<dd class="price">{price}</dd>\
		<dd class="status-expire">已过期</dd>\
	</dl>\
	<a href="#" class="delete-btn">删除</a>\
	<a href="#" class="up-btn">上移</a>\
	<a href="#" class="down-btn">下移</a>\
</li>'

});
//~ SelectedOfferPart


/**
 * 产品选择对话框
 */
var OfferChooserDialog = new WP.Class(WP.widget.Dialog, {

	init: function(config) {
		var	params = $.extend({
				header: '选择产品',
				className: 'offer-chooser-dialog',
				draggable: true
			}, config, {
				contentSuccess: $.proxy(this, '_contentSuccess'),
				buttons: [
					{ 'class': 'd-confirm', 'value': '确定' },
					{ 'class': 'd-cancel', 'value': '取消' }
				]
			});

		this.parent.init.call(this, params);
	},

	_contentSuccess: function(dialog) {
		var container = dialog.getContainer(), 
			params = $.extend({
				appendTo: container
			}, this.config);
		
		container.empty();
		this.offerChooser = new OfferChooser(params);

		$.extend(this, Util.delegate(this.offerChooser, 
				['getSelectedOffers', 'getSelectedOffersId']));
	}

});
//~ OfferChooserDialog

WP.widget.OfferChooser = OfferChooser;
WP.widget.OfferChooserDialog = OfferChooserDialog;

$.add('wp-offer-chooser');


})(jQuery, Platform.winport);
