/**
 * 类目选择组件
 * @author qijun.weiqj
 */
(function($, WP) {

/**
 * 类目选择面板, 可以渲染到指定节点
 */
var CategoryChooser = new WP.Class({
	
	/**
	 * config 配置参数
	 *  - appendTo {element} 类目选择面板会渲染到指定节点中
	 *  - dataProvider {loadCategories: function(cats)} 数据提供者, dataProvider需要实现loadCategories方法
	 *  - selectedCategoryId {integer} current selected category id
	 *  - select {function(cat)} 选择类目回方法
	 */
	init: function(config) {
		this.config = config;
		this.node = $(this._template);
		this.node.appendTo(config.appendTo);
	
		this._initCatsList();
		this._handleCatsEvent();
	},
	
	/**
	 * 载入类目并进行渲染
	 */
	_initCatsList: function() {
		var self = this,
			dp = this.config.dataProvider,
			selectedId = this.config.selectedCategory,
			content = $('div.w-content', this.node);

		dp.loadCategories(function(cats) {
			var html = [];
			$.each(cats, function(index, cat) {
				html.push($.util.substitute(self._itemTemplate, self._filterCat(cat)));
			});
			content.html('<ul>' + html.join('') + '</ul>');

			$('li', content).each(function(index) {
				var cat = cats[index],
					li = $(this);

				li.data('cat', cat);
				if (selectedId === cat.id) {
					li.addClass('selected');
					self._doSelect(cat, true);
				}
			});

		}, function() {
			content.html('<div class="message">网络繁忙，请稍候重试！</div>');	
		})
	},

	/**
	 * 处理cat数据,为显示前做准备
	 */
	_filterCat: function(cat) {
		var o = $.extend({}, cat);
		o.formatedName = cat.name.length > 6 ? cat.name.substr(0, 6) + '..' : cat.name;
		return o;
	},

	/**
	 * 处理类目选择事件
	 */
	_handleCatsEvent: function() {
		var self = this,
			select = this.config.select;
		this.node.delegate('a.name', 'click', function(e) {
			e.preventDefault();

			var li = $(this).closest('li'),
				cat = li.data('cat');

			li.siblings().removeClass('selected');
			li.addClass('selected');
			
			self._showError(false);
			self._doSelect(cat);	
		});
	},

	_doSelect: function(cat, sys) {
		var select = this.config.select,
			last = this._selectedCat;

		this._selectedCat = cat;
		select && select(cat, last, sys);
	},

	_showError: function(hide) {
		var elm = $('div.w-header div.message', this.node);
		if (hide === false) {
			elm.removeClass('error');
		} else {
			elm.addClass('error');
			setTimeout(function() {
				elm.removeClass('error');
			}, 3000);
		}
	},
	
	validate: function() {
		if (!this._selectedCat) {
			this._showError();
			return false;
		}
		return true;
	},

	/**
	 * 取得当前选中的类目
	 */
	getSelectedCategory: function() {
		return this._selectedCat; 
	},
	
	_template:
'<div class="widget-category-chooser">\
	<div class="w-header">\
		<h3>我的信息</h3>\
		<div class="message">请先选择一个类目</div>\
	</div>\
	<div class="w-content"><div class="loading">正在载入...</div></div>\
</div>',
	
	_itemTemplate: '<li><a href="#" title="{name}" class="name">{formatedName}</a> <span class="count">{offerCount}</span></li>'

});
//~ CategoryChooser


/**
 * 类目选择+产品选择面板
 */
var CategoryOfferChooserDialog = new WP.Class(WP.widget.Dialog, {
	
	init: function(config) {
		var	self = this,
			params = $.extend({
				header: '选择产品',
				className: 'category-offer-chooser-dialog',
				draggable: true
			}, config, {
				contentSuccess: function() {
					$.use('wp-offer-chooser', $.proxy(self, '_contentSuccess'));
				},
				buttons: [
					{ 'class': 'd-confirm', 'value': '确定' },
					{ 'class': 'd-cancel', 'value': '取消' }
				],
				confirm: $.proxy(this, '_confirm')
			});
		
		this.parent.init.call(this, params);	

		this._confirmHandler = config.confirm;
		this._cancelHandler = config.cancel;
	},

	/**
	 * 对话框打开后回调方法
	 */
	_contentSuccess: function() {
		this.setContent('');	// 清除原对话框内容
		this._showCategoryChooser();
	},

	/**
	 * 显示类目选择面板
	 */
	_showCategoryChooser: function() {
		var self = this,
			config = null,
			noSelectedOffers = (this.config.selectedOffers || []).length === 0;

		if (!this._categoryChooser) {
			config = $.extendIf({
				appendTo: this.getContainer(),
				dataProvider: this.config.dataProvider.cdp,
				select: function(cat, last, sys) {
					// 如果是系统触发select,并且当前没有offer选中, 则不知道跳转到offer选择页
					if (sys && noSelectedOffers) {
						return;
					}
					self._showOfferChooser(cat);
				}
			}, this.config);

			this._categoryChooser = new CategoryChooser(config);
		}

		this.node.removeClass('offer-chooser-active').addClass('category-chooser-active');
	},

	/**
	 * 显示offer选择面板
	 * @param {object} cat 当前选中的类目
	 */
	_showOfferChooser: function(cat) {
		var config = null;

		// 如果面板已创建
		if (this._offerChooser) {
			// 选择了新的类目, 则删除原OfferChooser, 并且创建的offerChooser(selectedOffer为空)
			if (this._selectedCat && this._selectedCat.id !== cat.id) {
				this._offerChooser.node.remove();
				
				config = this._getOfferChooserConfig(cat);
				config.selectedOffers = [];	
				this._offerChooser = new WP.widget.OfferChooser(config);
			}
		} else {
			config = this._getOfferChooserConfig(cat);
			this._offerChooser = new WP.widget.OfferChooser(config);	
		}
		
		this._selectedCat = cat;
		this.node.removeClass('category-chooser-active').addClass('offer-chooser-active');
	},
	
	_getOfferChooserConfig: function(cat) {
		var self = this;
		return $.extendIf({
			appendTo: this.getContainer(),
			dataProvider: this.config.dataProvider.odp,
			selectedCategory: cat,
			comeback: {
				text: '返回类目选择',
				action: function() {
					self._showCategoryChooser();
				}
			}
		}, this.config);
	},
	
	getData: function() {
		if (!this._offerChooser) {
			return;
		}

		var category = this._selectedCat,
			offers = this._offerChooser.getSelectedOffers();

		return {
			category: category,
			offers: offers
		};
	},

	_confirm: function() {
		// 当前面板为产品选择页
		if (this.node.hasClass('offer-chooser-active')) {
			this._confirmHandler ? this._confirmHandler(this) : this.close();	
			return;
		}
	
		if (this._selectedCat || this._categoryChooser.validate()) {
			this._showOfferChooser(this._selectedCat || this._categoryChooser.getSelectedCategory());
		}
	}

});
//~ CategoryOfferChooser 



WP.widget.CategoryChooser = CategoryChooser;
WP.widget.CategoryOfferChooserDialog = CategoryOfferChooserDialog;

$.add('wp-category-chooser');
$.add('wp-category-offer-chooser');

})(jQuery, Platform.winport);

