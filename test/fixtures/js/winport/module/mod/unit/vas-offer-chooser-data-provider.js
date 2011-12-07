/**
 * 产品选择组件VAS数据源
 * @author qijun.weiqj
 */
(function($, WP) {

var Util = WP.Util;

var VasOfferChooserDataProvider = new WP.Class({

	init: function(config) {
		this.config = config || {};
	},

	/**
	 * 载入类目信息
	 * @param {function(array<{id: {integer}, name: {string}}>)} callback 数据回调方法
	 * @param {function} error 错误回调方法
	 */
	loadCategories: function(callback, error) {
		if (this.config.useMock) {
			return callback(this._getMockCats());
		}
		this._load(this.config.loadCategoriesUrl, null, '_filterCats', callback, error);	
	},

	_filterCats: function(data) {
		return data;
	},

	/**
	 * 载入offer信息
	 * @param {array<integer>} ids offer id
	 * @param {function} callback 数据回调方法
	 * @param {function} error 出错回调方法
	 */
	loadOffers: function(ids, callback, error) {
		if (this.config.useMock) {
			return callback(this._getMockOffers({ ids: ids }));
		}

		var ids = ids.join(',');
		this._load(this.config.loadOffersUrl, { ids: ids }, '_filterLoadOffers', callback, error);	
	},

	/**
	 * 查询offer信息
	 * @param {object} params 查询参数
	 * @param {function} callback 数据回调方法
	 * @param {function } error 出错回调方法
	 */
	searchOffers: function(params, callback, error) {
		if (this.config.useMock) {
			return callback(this._getMockOffers(params));
		}

		var cat = params.category || {},
			data = {
				isSysCat: cat.type !== 'userDefine',
				pageNum: params.pageIndex,
				privateFilter: this.config.privateFilter || 'none'
			};

		cat.id && (data.categoryId = cat.id);
		params.keywords && (data.keywords = params.keywords);

		data = $.paramSpecial(data);
		this._load(this.config.searchOffersUrl, data, '_filterSearchOffers', callback, error);
	},

	_filterSearchOffers: function(data) {
		var offers = this._filterOffers(data.offers);
		return { offers: offers, pageCount: data.totalPage, pageIndex: data.currentPage };
	},

	_filterLoadOffers: function(data) {
		var offers = this._filterOffers(data);
		return { offers: offers, pageCount: 1, pageIndex: 1 };
	},

	_filterOffers: function(offers) {
		return $.map(offers || [], function(offer) {
			return $.extendIf({
				price: offer.priceStr,
				image: offer.summImg,
				detailUrl: offer.offerDetailUrl, 
				date: offer.gmtExpire
			}, offer);
		});	
	},

	_load: function(url, data, filter, callback, error) {
		var self = this,
			filter = $.proxy(this, filter);
		if (!url) {
			$.error('url is not specified');
		}

		$.ajax(url, {
			dataType: 'jsonp',
			cache: false,
			data: data || {},
			success: function(ret) {
				ret.success ? callback(filter(ret.data)) : 
					error ? error() : false;
			},
			error: error
		});	
	},

	_getMockCats: function() {
		return [
			{ id: 1, name: '1234567890' },
			{ id: 2, name: '一二三四五六七八九十一二三四' },
			{ id: 123, name: '神品3', 
				children: [
					{ id: 456, name: '下一级１' },
					{ id: 567, name: '最佳啊啊一二三四五六七' }
				]
			},
			{ id: 123, name: '神品4' },
			{ id: 123, name: '一二三四五六七八九十一二三四' },
			{ id: 123, name: '神品6' },
			{ id: 123, name: '神品7' },
			{ id: 123, name: '1234567890' },
			{ id: 123, name: '一二三四五六七八九十一二三四' },
			{ id: 123, name: '神品3', 
				children: [
					{ id: 456, name: '下一级１' },
					{ id: 567, name: '最佳啊啊一二三四五六七' }
				]
			},
			{ id: 123, name: '神品4' },
			{ id: 123, name: '一二三四五六七八九十一二三四' },
			{ id: 123, name: '神品6' },
			{ id: 123, name: '神品7' },
			{ id: 123, name: '1234567890' },
			{ id: 123, name: '一二三四五六七八九十一二三四' },
			{ id: 123, name: '神品3', 
				children: [
					{ id: 456, name: '下一级１' },
					{ id: 567, name: '最佳啊啊一二三四五六七' }
				]
			},
			{ id: 123, name: '神品4' },
			{ id: 123, name: '一二三四五六七八九十一二三四' },
			{ id: 123, name: '神品6' },
			{ id: 123, name: '神品7' },
			{ id: 123, name: '1234567890' },
			{ id: 123, name: '一二三四五六七八九十一二三四' },
			{ id: 123, name: '神品3', 
				children: [
					{ id: 456, name: '下一级１' },
					{ id: 567, name: '最佳啊啊一二三四五六七' }
				]
			},
			{ id: 123, name: '神品4' },
			{ id: 123, name: '一二三四五六七八九十一二三四' },
			{ id: 123, name: '神品6' },
			{ id: 123, name: '神品7' }
		];
	},

	_getMockOffers: function(params) {
		var ids = params.ids,
			pageIndex = params.pageIndex,
			pageSize = params.pageSize;
		if (!ids) {
			ids = [];
			for (var i = 0; i < pageSize; i++) {
				ids.push(pageIndex  * 5 + i);
			}
		}

		var offers = $.map(ids, function(id) {
			return {
				id: id,
				title: '神品' + id + '号一二<script> &&">script><&*&^"";\'三四五六七八九十十二三四五六七八九十十一',
				price: Math.random() > 0.8 ? parseInt(Math.random() * 100000) + '元' : '',
				image: 'http://fd.aliued.cn/i/50x50.png',
				detailUrl: 'http://detail.china.alibaba.com/buyer/offerdetail/926553205.html', 
				date: '2011.12.13'
			}
		});

		return {
			offers: offers,
			pageSize: 5,
			pageIndex: pageIndex,
			pageCount: 100
		};
	}
});


WP.unit.VasOfferChooserDataProvider = VasOfferChooserDataProvider;
$.add('wp-vas-offer-chooser-data-provider');

})(jQuery, Platform.winport)
