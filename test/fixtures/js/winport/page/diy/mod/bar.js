/**
 * @fileoverview 板块浮层工具栏
 * @author long.fanl
 */
(function($,WP){
	var WPD = WP.diy,
		UI = WP.UI,
		isIE6=$.util.ua.ie6,
		isIE = $.util.ua.ie,
		isIE67 = $.util.ua.ie67,
		
		BoxOperateChecker = WPD.BoxOperateChecker,
		
		uniqBoxBar, // 全局唯一Toolbar,jQuery对象 
		
		lastBox, // 最近一次（上一次）boxBar所在的box容器
		
		operations = $(["left","up","down","right","edit","del"]),
		
		operate = {};
		
		/**
		 * 板块浮层工具栏(包含 上移/下移/左移/右移 ,编辑,删除按钮)
		 */
		var BoxBar = {
			
			init : function(){
				
				uniqBoxBar = genBoxBar();
			
				operations.each(function(i,op){
					operate[op] = $("a."+op,uniqBoxBar);
				});
				// fix IE67下，mod-box高度问题（处理刚打开页面时，若鼠标hover在链接或按钮上，可点的问题）
				if(isIE67){
					$("div.mod-box").each(function(i,box){
						fixIE67Hover(box);
					});
				}
				initBoxBarEvent();
				initBoxBarItemEvent();
				
				// ddstop movestop reloaded 后需要重新计算shim的高度
				$("div.mod-box:not(.ui-portlets-placeholder)").live("movestart",function(){
					hideBoxBar();
				}).live("ddstop movestop",function(ev){
					fixIE67Hover(this);
					isIE67 && $(this).mouseover();
					updateBoxBar(this);
				}).live("reloaded",function(ev){
					isIE67 && $(this).mouseover();
				});
				$('div.mod').live('afterinit', function() {
					isIE67 && $(this).mouseover();
				});
			}
		}
		
		function genBoxBar(){
			var boxToolbar = $("<div>",{
				"class" : "box-bar fd-hide"
			}),
			operationsHTML = [],
			operationTitles = ["左移","上移","下移","右移","设置","删除"];
			operations.each(function(i,op){
				operationsHTML.push('<a href="#" class="'+op+'" title="'+operationTitles[i]+'"></a>');
			});
			boxToolbar.html(operationsHTML.join(""));
			return boxToolbar;
		}
		
		/**
		 * 初始化toolbar的显示/隐藏逻辑
		 * @param {Object} b
		 * @param {Object} t
		 */
		function initBoxBarEvent(){
			var boxes = $("div.mod-box:not(.ui-portlets-placeholder)"),
				wpContent = $('#winport-content');
			
			// 鼠标移入box时,显示boxShim和boxBar
			boxes.live("mouseenter",function(ev){
				// 特殊逻辑 : 顶部导航栏,不显示toolbar
				if($("div.mod",this).hasClass("wp-top-nav")){
					showBoxBar(this);
					uniqBoxBar.css("visibility","hidden");
					operate["edit"].css("visibility","visible");
					return false;
				}else{
					uniqBoxBar.css("visibility","visible");
				}
				showBoxShim(this);
			});
			
			// 鼠标移出box时,隐藏boxShim和boxBar
			boxes.live("mouseleave",function(){
				hideBoxShim(this);
				hideBoxBar();
			});
			
			// 双击打开编辑表单
			boxes.live("dblclick",function(ev){
				var box = $(this);
				// toolbar不支持双击
				if ($("div.mod", this).hasClass("wp-top-nav")) {
					return;
				}
				try {
					WPD.BoxOperateHandler["edit"].operate(box, ev);
				}catch (e) {
					$.log("dbl edit error: " + e);
				}
				return false;
			});
		};
		
		// 显示toolbar
		function showBoxShim(box){
			// 如果不是上一个的box,首先隐藏上一个box的shim
			if(lastBox !== box){
				hideBoxShim(lastBox);
			}
			var boxShim = $("div.box-shim",box);
			boxShim.addClass("box-shim-in");
			fixIE67Hover(box);
			
			boxShim.stop();
			boxShim.animate({
				"opacity":0.5
			},200,function(){
				showBoxBar(box);
			});
			lastBox = box;
		}
		
		// 修复ie67的shim高度问题
		function fixIE67Hover(box){
			if(isIE67) {
				box = $(box);
				
				var boxShim = $("div.box-shim",box), 
					boxHeight=box.height();
					
				if($("div.m-body",box).length >0){
					boxShim.height(boxHeight - 8);
				}else{
					boxShim.height(boxHeight);
				}
	        }
		}
		
		// 显示boxBar
		function showBoxBar(box){
			updateBoxBar(box);
			uniqBoxBar.appendTo(box);
			uniqBoxBar.removeClass("fd-hide");
			uniqBoxBar.css("display","");
		}
		
		// 隐藏toolbar
		function hideBoxShim(box){
			var boxShim = $("div.box-shim",box);
			boxShim.removeClass("box-shim-in");
			boxShim.stop();
			boxShim.css("opacity",0);
		}
		
		// 隐藏boxBar
		function hideBoxBar(){
			uniqBoxBar.addClass("fd-hide");
		}
		
		/**
		 * 更新boxBar
		 * @param {Object} box
		 */
		function updateBoxBar(box){
			box = $(box);
			if(box.length === 0){
				box = uniqBoxBar.parents("div.mod-box");
			}
			operations.each(function(i,op){
				if(BoxOperateChecker.check(box,op,true).pass){
					operate[op].css("display","");
				}else{
					operate[op].css("display","none");
				}
			});
		}
		
		/**
		 * 初始化boxBar中的item事件（上下左右移动/设置/删除）
		 */
		function initBoxBarItemEvent(){
			$(".box-bar a").live("click",function(ev){
				var box = $(this).closest("div.mod-box"),
				operation = this.className;
				try {
					WPD.BoxOperateHandler[operation].operate(box,ev);
				}catch(e){
					$.log("Box Operate Error : "+e);
				}
				return false;
			});
		}
		
		WP.diy.BoxBar = BoxBar;
		WP.PageContext.register('~BoxBar', BoxBar);
		
})(jQuery,Platform.winport);
