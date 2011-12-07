/**
 * @fileoverview 板块移动
 * @author long.fanl
 */
(function($,WP){
	var WPD = WP.diy,
		WPU = WP.Util,
		isIE6=WPU.isIE6,
		UI = WP.UI,
		BoxUtil = WPD.BoxUtil,
		RequestHandler = WPD.RequestHandler,
		BoxOperateChecker = WPD.BoxOperateChecker,
		BaseOperateHandler = WP.diy.BaseOperateHandler;
		
	/**
	 * 移动 Box, 基于 BoxOperateHandler
	 */
	var BoxMoveHandler = $.extend({},BaseOperateHandler,{
		operation : "move", 
		direction : "", // up | down | left | right
		// 新增目标板块,相对目标板块进行上下/左右移动
		_prepare : function(){
			this._setDst();
			this.__placeHolder = this.__initPlaceHolder();
		},
		
		_setDst : $.noop,
		
		// 生成box移动时的占位符
		__initPlaceHolder : function(){
			var placeHolder = $('<div class="box-move-placeholder"></div>');
			if(isIE6){
				placeHolder.css("padding-bottom",0).css("margin-bottom",0);
			}
			return placeHolder;
		},
		
		_beforeUI : function(src){
			src.trigger("movestart");
			BaseOperateHandler.bgiframe("open");
		},
		_afterUI : function(src){
			src.trigger("movestop");
			BaseOperateHandler.bgiframe("close");
		},
		// 移动操作 异步通知后台保存
		_save : function(){
			RequestHandler.savePageLayout(this.src,this.operation);
		}
	});
	
	BoxMoveHandler.base = BoxMoveHandler;
	
	/**
	 * 垂直移动Box, 基于BoxMove
	 */
	var BoxVerticalMoveHandler = $.extend({},BoxMoveHandler,{
		// 验证源和目标板块是否可操作
		_check : function(){
			// down被转换成了up
			return BoxOperateChecker.check(this.src,"up") && BoxOperateChecker.check(this.dst,"down");
		},
		
		_handleUI : function(save){
			var self = this,
			src = this.src,
			dst = this.dst,
			srcContent = $("div.m-content,div.m-footer",src),
			dstContent = $("div.m-content,div.m-footer",dst),
			dir = this.operation,
			base = this.base;
			
			if(dst.length < 1){
				return;
			}
			self._beforeUI(self._src);
			self._src.css("z-index",198);
			src.add(dst).wrapAll(this.__placeHolder);
			srcContent.css("opacity",0.2);
			dstContent.css("opacity",0.2);
			// src 上移
			src.animate({
				top:"-"+(dst.height()) // 保IE舍弃了FF的8px
			},500,function(){
				$(this).css("top",0);
				srcContent.css("opacity","");
			});
			// dst下移
			dst.animate({
				top:"+"+(src.height())
			},500,function(){
				$(this).css("top","");
				dstContent.css("opacity","");
				self._src.css("z-index","");
				src.insertBefore(dst);
				src.unwrap();
//				$.proxy(self._afterUI,self);
				self._afterUI(self._src);
				save();
			});
		}
		
	});
	/**
	 * 向上移动Box, 基于 BoxVerticalMoveHandler
	 * @param {Object} boxes
	 */
	var BoxMoveUpHandler = $.extend({},BoxVerticalMoveHandler,{
			operation : "up",
			
			_setDst : function(){
				this._src = this.src;
				this.dst = BoxUtil.prevBox(this.src);
			}
		});	
		
	/**
	 * 向下移动Box, 基于 BoxVerticalMoveHandler
	 */
	var BoxMoveDownHandler = $.extend({},BoxVerticalMoveHandler,{
			operation : "down",
			
			// 把下移转换成上移
			_setDst : function(){
				var src = (this._src = this.src);
				this.src = BoxUtil.nextBox(src);
				this.dst = src;
			}
		});
	
	/**
	 * 水平移动Box, 基于 BoxMoveHandler
	 */
	var BoxHorizontalMoveHandler = $.extend(BoxMoveHandler,{
		
		_setDst : function(){
			var src = this.src,
			dir = this.operation,
			dstRegion = BoxUtil.getDstRegion(src, dir);
			this.dst = $("div.box-adder",dstRegion.obj); // 水平移动的dst是“添加板块”按钮
		},
		
		// 注意水平移动的时候,没有check dst,是因为水平移动时,src都是insertBefore到box-adder(必然存在的dst)
		_handleUI : function(save){
			var self = this,
			src = this.src, srcContent = $("div.m-content,div.m-footer",src),
			dst = this.dst,
			srcOffset = src.offset(), dstOffset = dst.offset(),
			base = this.base;
			
			if(dst.length > 0){
				var placeHolder = this.__placeHolder;
				placeHolder.height(src.height());
				placeHolder.css("overflow","visible");
				
				src.wrap(placeHolder);
				self._beforeUI(src);
				// 避免主区域定宽的板块 移到侧边栏后撑开
				src.css("overflow", "hidden").css("z-index",198);
				srcContent.css("opacity",0.2);
				// 添加按钮淡出
				dst.fadeOut();
				// src板块开始移动
				src.animate({
					top: +(dstOffset.top - srcOffset.top),
					left: +(dstOffset.left - srcOffset.left),
					width : dst.width()
				},500,function(){
					src.unwrap();
					src.insertBefore(dst);
//					$.proxy(base._afterUI,base);
					self._afterUI(src);
					// src板块top和left都为0
					src.css("top","").css("left","");
					srcContent.css("opacity","");
					// "添加板块"渐入
					dst.fadeIn();
					// 滚屏
					var srcOffset = src.offset(),doc = $(document),docScrollTop = doc.scrollTop(),
					upScroll = (srcOffset.top < docScrollTop) , 
					downScroll = (srcOffset.top+src.height() > $(window).height()+docScrollTop);
					if(upScroll || downScroll){
						$(document).scrollTop(src.offset().top-43);
					}
					// 是否需要重新加载
					if(src.data('box-config').needReload){
						UI.showLoading($("div.m-content",src));
						RequestHandler.reloadBox(src);
					}
					// 清除移动动画给box加的内联样式
					src.css("width","").css("overflow","").css("z-index","");
					save();
				});
				// jq默认给context设了overflow:hidden(可能是为了防止动画时超出)，这里step每一步显式设置overflow:visible
				src.closest("div.box-move-placeholder").animate({
						height : 0
					},{
						duration : 500,
						step:function(){
							$(this).css("overflow","visible");
						}
					});
				}
			}
		});
		
	/**
	 * 向左移动Box, 基于 BoxHorizontalMoveHandler
	 * @param {Object} boxes
	 */
	var BoxMoveLeftHandler = $.extend({},BoxHorizontalMoveHandler,{
			operation : "left"
		}
	);
	/**
	 * 向右移动Box, 基于 BoxHorizontalMoveHandler
	 * @param {Object} boxes
	 */
	var BoxMoveRightHandler = $.extend({},BoxHorizontalMoveHandler,{
			operation : "right"
		}
	);
		
	WPD.BoxOperateHandler.up = BoxMoveUpHandler;
	WPD.BoxOperateHandler.down = BoxMoveDownHandler;
	WPD.BoxOperateHandler.right = BoxMoveRightHandler;
	WPD.BoxOperateHandler.left = BoxMoveLeftHandler;
		
})(jQuery,Platform.winport);