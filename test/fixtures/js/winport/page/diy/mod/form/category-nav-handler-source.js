/**
 * @fileoverview 旺铺产品分类编辑对话框处理类
 *
 * @author qijun.weiqj
 */
(function($, WP) {
	
var ModBox = WP.diy.ModBox,
	SimpleHandler = WP.diy.form.SimpleHandler;
	
	
var CategoryNavHandler = $.extendIf({

	init: function(form, config) {
		SimpleHandler.init.apply(this, arguments);
		
		this.managePart = $('p.manage-part', form);
		this.openCatPart = $('p.open-cat-part', form);
		
		this.initForm();
	},
	
	/**
	 * 根据是否启用了自定义类目，显示并初始化合适的内容
	 */
	initForm: function() {
		var self = this;
		
		$.ajax(this.config.offerUserDefCatUrl, {
			dataType: 'jsonp',
			
			success: function(o) {
				var data = o.data || {};
				if (o.success && 
						// 如果未开通自定义分类
						// 并且 满足开通条件
						!data.hasOpen && data.isShowTips) {
					
					// 显示开通引导
					self.openCatPart.show();
					self.initOpenCatPart();
				} else {
					self.showManagePart();
				}
			},
			
			error: function() {
				self.showManagePart();
			}
		});
	},
	
	/**
	 * 初始化开通链接事件
	 */
	initOpenCatPart: function() {
		var self = this,
			open = $('a.open', self.openCatPart);
		open.click(function() {
			self.openUserDefCat();
			return false;
		});
	},
	
	/**
	 * 启用自定义类目
	 */
	openUserDefCat: function() {
		var self = this,
			loading = $('p.open-cat-loading', this.form);
		loading.show();
		
		$.ajax(this.config.openUserDefCatUrl, {
			data: { open: 'true' },
			dataType: 'jsonp',
			success: function(o) {
				if (o.success) {
					self.showManagePart('您的旺铺已启用自定义分类！');
					loading.hide();
					
					self.openCatPart.hide();
					self.refreshModBox();
				}
			},
			complete: function() {
				loading.hide();
			}
		});
	},
	
	/**
	 * 显示管理自定义分类引导
	 */
	showManagePart: function(info) {
		var span = $('span.info', this.managePart);
		this.managePart.show();
		info && span.html(info);
	},
	
	/**
	 * 开通自定义类目成功后，需要刷新分类板块
	 */
	refreshModBox: function() {
		var modCat = $('div.wp-category-nav-main,div.wp-category-nav-sub');
		modCat.each(function() {
			var box = $(this).closest('div.mod-box');
			ModBox.reload(box);
		});
	}
	
}, SimpleHandler);

WP.diy.form.CategoryNavHandler = CategoryNavHandler;
	
})(jQuery, Platform.winport);
