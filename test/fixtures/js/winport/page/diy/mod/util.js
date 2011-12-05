/**
 * @fileoverview 板块操作工具方法
 * @author long.fanl
 */
(function($,WP){
		
		var PATH_MAP = {
			"winport-header .p32-m0":["main-wrap"], // header 通栏布局(inuse)
			"winport-content .p32-m0":["main-wrap"], // content 通栏布局(inuse)
			"winport-content .p32-s5m0":["grid-sub","main-wrap"], // content 1:4布局(inuse)
			"winport-content .p32-m0s5":["main-wrap","grid-sub"], // content 4:1布局(inuse)
			"winport-footer .p32-m0":["main-wrap"] // footer 通栏布局
		}
		var BoxUtil = {
			/**
			 * 获取box的上一个兄弟节点
			 * @param {Object} box
			 */
			prevBox : function(box){
				var prevBox = $(box).prev("div.mod-box:not(.ui-portlets-placeholder)");
				// 恶心逻辑 处理一期TP中空的广告位板块
				if ($('div.mod', prevBox).length === 0) {
					prevBox = prevBox.prev("div.mod-box:not(.ui-portlets-placeholder)");
				}
				return prevBox;
			},
			
			/**
			 * 获取box的下一个兄弟节点
			 * @param {Object} box
			 */
			nextBox : function(box){
				var nextBox = $(box).next("div.mod-box:not(.ui-portlets-placeholder)");
				// 恶心逻辑 处理一期TP中空的广告位板块
				if ($('div.mod', nextBox).length === 0) {
					nextBox = nextBox.next("div.mod-box:not(.ui-portlets-placeholder)");
				}
				return nextBox;
			},
			
			/**
			 * 根据direction获取box的目标区域（一般用于移动操作）
			 * @param {Object} box
			 * @param {String} direction
			 */
			getDstRegion : function(box,direction){
				var dstRegion = null,region = this.getComponentArea(box.closest("div.region")), layout = this.getComponentArea(box.closest("div.layout")),segment = this.getComponentArea(box.closest("div.segment")),
				layoutPath = segment+" ."+layout,
				regions = PATH_MAP[layoutPath];
				if($.isArray(regions) && regions.length > 0){
					var pos = $.inArray(region,regions);
					len = regions.length;
					if(direction === "right" && pos < len-1){
						dstRegion = regions[pos+1];
					}else if(direction==="left" && pos >0){
						dstRegion = regions[pos-1];
					}
				}else{
					$.log(box+" is illegal!","error");
				}
				return {
					name : dstRegion,
					obj : $("#"+layoutPath+" ."+dstRegion)
				};
			},
			
			/**
			 * 获取component aear的具体名称，eg: grid-sub, main-wrap
			 * @param {Object} component
			 */
			getComponentArea : function(component){
				var area,
				cmptName = " "+component[0].className+" ";
				if(component.hasClass("region")){
					return /.*\s(main-wrap|grid-sub|extra)\s.*/i.exec(cmptName)[1];
				}else if(component.hasClass("layout")){
					return /.*\s(p32-s5m0|p32-m0s5|p32-m0)\s.*/i.exec(cmptName)[1];
				}else if(component.hasClass("segment")){
					return /(winport-header|winport-content|winport-footer|winport-fly)/i.exec(component[0].id)[1];
				}else{
					return null;
				}
			},
			
			/**
			 * 板块是否在视觉的左边
			 * 特别的, 类似1:2:1 或 1:1:2 这样的三栏, 只有 左边那列算作左边,其余全部右边
			 * @param {Object} box
			 */
			boxInLeft : function(box){
				var inleft = box.data("inleft");
				if(typeof inleft === "undefined"){
					inleft = _boxInLeft(box);
				}
				return inleft;
			}
		};
		
		function _boxInLeft(box){
			var inleft,region = BoxUtil.getComponentArea(box.closest("div.region")), layout = BoxUtil.getComponentArea(box.closest("div.layout")),segment = BoxUtil.getComponentArea(box.closest("div.segment")),
			layoutPath = PATH_MAP[segment+" ."+layout];
			if($.isArray(layoutPath) && layoutPath.length > 0){
				inleft = layoutPath[0] === region;
				box.data("inleft",inleft);
			}else{
				$.error(box+" is illegal!","error");
				return;
			}
			return inleft;
		}
		
		if(!WP.diy.BoxUtil){
			WP.diy.BoxUtil = BoxUtil;
		}
})(jQuery,Platform.winport);
