/**
 * @fileoverview DIY设置面板-页面管理
 * 
 * @author qijun.weiqj
 */
(function($, WP) {

var Util = WP.Util,
	UI = WP.UI,
	Msg = WP.diy.Msg,
	Diy = WP.diy.Diy,
	ModBox = WP.diy.ModBox;


/**
 * 页面管理
 */
var DiyPages = {
	
	init: function(div, config) {
		this.div = div;
		this.config = config;
		// 页面每一tab内容, 称之为part
		this.parts = $('div.pages-part', div);

		this._initPartEffect();
		
		this.name = 'DiyPages';
		Util.initParts(this);
	},
	
	/**
	 * 刷新页面导横条
	 */
	refreshPageNav: function() {
		var topNav = $('#winport-header div.wp-top-nav'),
			box = topNav.closest('div.mod-box');
		ModBox.reload(box);
	},
	
	/**
	 * 提交更改操作时, 需要使用此方法包装参数
	 * @param {Object} data
	 */
	wrapUpdateData: function(data) {
		return $.extend({
			 _csrf_token: $('#doc').data('doc-config')._csrf_token
		}, data);
	},
	
	/**
	 * 鼠标hover表格效果
	 */
	_initPartEffect: function() {
		$('tr', this.parts).live('mouseenter mouseleave', function(e) {
			$(this).toggleClass('hover', e.type === 'mouseenter');
		});
	}
	
};
//~ DiyPages

var Parts = (DiyPages.Parts = {});


/**
 * 页面排序
 */
Parts.PageSorter = {
	
	init: function() {
		var self = this;
		
		// 保存页面布局, 排序时需要使用, 判断是否需要提交请求， 以避免无效提交
		$(this.div).data('pagelist', this.getPageList());
		
		this.parts.each(function() {
			self.initPart($(this));
		});
		
		this.refresh();
	},
	
	initPart: function(part) {
		this.initUpDown(part);
		this.initSortable(part);
	},
	
	/**
	 * 初始化上下排序
	 */
	initUpDown: function(part) {
		var elms = $('a.sort-up,a.sort-down', part);
		this.initUpDownSort(elms);
		this.initUpDownEffect(elms);
	},
	
	/**
	 * 处理单击事件
	 */
	initUpDownSort: function(elms) {
		var self = this;
		elms.live('click', function() {
			var link = $(this),
				item = link.closest('tr.sortable'),
				up = link.hasClass('sort-up'),
				relative = item[up ? 'prev' : 'next']('.sortable');
			
			if (relative) {
				relative[up ? 'before' : 'after'](item);
				self.updateSort('updown');
			}
			
			return false;
		});
	},
	
	/**
	 * 处理上下按扭效果事件
	 * 正常情况下应该css hover伪类来实现, 但是在IE浏览器下，在频繁点击的情况下, hover状态不能正常恢复
	 * 所以这里无奈地使用js解决
	 */
	initUpDownEffect: function(elms) {
		elms.live('mouseenter', function() {
			var elm = $(this);
			elms.removeClass('sort-up-hover sort-down-hover');
			elm.addClass(elm.hasClass('sort-up') ? 'sort-up-hover' : 'sort-down-hover');
		});
		elms.live('mouseleave', function() {
			$(this).removeClass('sort-up-hover sort-down-hover');
		});
	},
	
	/**
	 * 拖动排序
	 */
	initSortable: function(part) {
		var self = this;
		
		$.use('ui-portlets', function() {
			$('tbody', part).portlets({
				items: 'tr.sortable',
				axis: 'y',
				opacity: 0.8,
				stop: function() {
					self.updateSort('drag');
				},
				revert: 200,
				// fixed ie6 bug
				helper: function(e, item) {
					return $('<table>').append(item.clone());
				},
				appendTo: part,
				capture: function(e, ui) {
					// fixed ie6 bug, checkbox选中状态不正确现象
					if ($.util.ua.ie6) {
						$('input.:checkbox', ui.currentItem).each(function() {
							this.defaultChecked = this.checked;
						});
					}
				},
				start: function(e, ui) {
					$(ui.placeholder).html('<td colspan="5">&nbsp;</td>');
				}
			});
		});
	},
	//~ initSortable
	
	/**
	 * 提交排序操作
	 */
	updateSort: function(op) {
		var self = this,
			url = this.config.updatePageListUrl,
			action = null;
			
		this.refresh();
		
		action = function() {
			var lastList = $(self.div).data('pagelist'),
				pageList = self.getPageList();
			
			// 导横顺序有更改时才提交
			if (lastList === pageList) {
				return;
			}
			
			Diy.authAjax(url, {
				type: 'POST',
				data: self.wrapUpdateData({ pageList: pageList }),
				dataType: 'json',
				success: function(ret) {
					if (ret.success) {
						$(self.div).data('pagelist', pageList);
						self.refreshPageNav();
						$(window).trigger('diychanged', { type: 'update-page-list-' + op });
						Msg.info('调整导航页顺序成功');
					} else {
						Msg.error('调整导航页顺序失败，请刷新后重试。');
					}
				}
			});
		};
		
		Util.schedule('update-pagelist', action);
	},
	//~ updateSort
	
	/**
	 * 取得导横条排序数据
	 * @return {string} '[sid1, sid2, sid3]'
	 */
	getPageList: function() {
		var elms = $('tr[data-page]:not(.ui-portlets-placeholder)', this.div),
			list = [];
			
		elms.each(function() {
			var config = $(this).data('page');
			list.push(config.sid);
		});
		
		return JSON.stringify(list);
	},
	
	/**
	 * 刷新上下移按扭状态
	 * 隐藏第1个上移及最后一个下移按扭
	 */
	refresh: function() {
		this.parts.each(function() {
			var part = $(this),
				ups = $('a.sort-up', part),
				downs = $('a.sort-down', part);
			
			ups.removeClass('sort-up-disabled');
			downs.removeClass('sort-down-disabled');
			ups.eq(0).addClass('sort-up-disabled');
			downs.eq(downs.length - 1).addClass('sort-down-disabled');
		});
	}
};
//~ PageSorter

/**
 * 页面名称编辑
 */
Parts.PageNameEditor = {
	
	init: function() {
		var self = this;
		$.use('wp-inplaceeditor', function() {
			self.parts.each(function() {
				self.initEditable($(this));
			});
		});
	},
	
	initEditable: function(part) {
		var self = this,
			restore = function() {
				var tr = $(this).closest('tr.editable');
				$('a.save,a.cancel', tr).hide();
				$('a.edit', tr).show();
			};
		
		$('tr.editable td.col-name', part).inplaceEditor({
			event: 'dblclick',
			autosubmit: false,
			attr: {
				maxlength: 4
			},
			validate: function(value, lastValue){
				if (/[~'"@#$?&<>\/\\]/.test(value)) {
					Msg.warn('页面名称含有非法字符，请重新输入');
					return false;
				}
				return true;
			},
			
			submit: function(value, callback) {
				self.doSubmit(value, callback, this);
			},
			
			onstart: function() {
				var tr = $(this).closest('tr.editable');
				$('a.edit', tr).hide();
				$('a.save,a.cancel', tr).show();
				$('a.save', tr).css('display', 'inline-block');
			},

			oncancel: function() {
				self.completeEdit(this);
			}
		});

		$('tr.editable', part).delegate('a.save,a.cancel,a.edit', 'click', function() {
			var elm = $(this),
				col = elm.closest('tr.editable').find('td.col-name'),
				op = elm.hasClass('save') ? 'submit' : 
						elm.hasClass('edit') ? 'start' : 'cancel';
						
			col.inplaceEditor(op);
			
			return false;
		});
	},
	//~ initEditable
	
	completeEdit: function(elm) {
		var tr = $(elm).closest('tr.editable');
		$('a.save,a.cancel', tr).hide();
		$('a.edit', tr).show();
	},
	
	doSubmit: function(value, callback, elm) {
		var self = this,
			url = this.config.updatePageNameUrl,
			config = $(elm).closest('tr.editable').data('page');

		Diy.authAjax(Util.formatUrl(url, '_input_charset=UTF-8'), {
			type: 'POST',
			data: this.wrapUpdateData({ pageSid: config.sid, pageName: value }),
			dataType: 'json',
			success: function(ret) {
				if (ret.success) {
					callback({ status: 'success' });
					Msg.info('修改名称成功');
					self.refreshPageNav();
					self.completeEdit(elm);
					$(window).trigger('diychanged', { type: 'update-page-name' });
				} else {
					var message = ret.data[0].message;
					callback({ status: 'error' });
					message && Msg.error(message);
				}
			},
			
			error: function() {
				callback({ status: 'error' });
			}
		});
	}
};
//~ PageNameEditor

/**
 * 是否显示在导航条上
 */
Parts.PageNavStatusUpdater = {
	
	init: function() {
		var self = this,
			url = this.config.updatePageNavStatusUrl;
		
		this.checks = $('input.pagenav-status', this.div);
		
		this.saveStatus();
		
		this.checks.live('click', function(e) {
			if (!self.validateStatus(this.checked)) {
				e.preventDefault();
				return;
			}
			action = function() {
				var data = self.getStatusData();
				if (!data) {
					return;
				}
				Diy.authAjax(url, {
					type: 'POST',
					data: self.wrapUpdateData(data),
					dataType: 'json',
					success: $.proxy(self, 'success')
				});
			};
			Util.schedule('update-pagenav-status', action);
		});
	},
	
	/**
	 * 保存当前页面显示状态, 以便合理地发送请求
	 */
	saveStatus: function() {
		this.checks.each(function() {
			var check = $(this);
			check.data('last-checked', this.checked);
		});
	},
	
	/**
	 * 验证当前页面显示状态
	 * 1. 显示在导横上的数量不超过maxPageNum
	 */
	validateStatus: function(show) {
		var count = this.checks.filter(':checked').length,
			maxCount = this.config.maxPageNum,
			message = '最多可显示{0}个导航页，设置导航页失败';
		if (show && maxCount && count > maxCount) {
			Msg.error($.util.substitute(message, [maxCount]));
			return false;
		}
		return true;
	},
	
	/**
	 * 取得导横条显示状态
	 * 
	 * 注： 要求pageNavList如下格式
	 * 		pageNavList = [{sid1:true},{sid2:false},{sid3:true}]
	 */
	getStatusData: function() {
		var list = [];
		this.checks.each(function() {
			var check = $(this),
				tr = null,
				config = null;
			if (check.data('last-checked') === this.checked) {
				return;
			}
			
			tr = check.closest('tr');
			config = tr.data('page');
			list.push("{" + config.sid + ":" + (this.checked ? 'true' : 'false') + "}");
		});
		
		return list.length ? { pageNavList: '[' + list.join(',') + ']' } : null;
	},
	
	success: function(ret) {
		if (ret.success) {
			this.saveStatus();
			$(window).trigger('diychanged', { type: 'update-page-nav-status' });
			Msg.info('设置导航页成功');
		} else {
			Msg.error('设置导航页失败');
		}
		this.refreshPageNav();
	}
};

WP.SettingContext.register('diy-pages', DiyPages, { configField: 'pagesConfig' });

})(jQuery, Platform.winport);
//~
