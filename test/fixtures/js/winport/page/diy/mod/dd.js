/**
 * @fileoverview 板块拖拽
 * @author long.fanl
 */
(function($, WP){

    var WPD = WP.diy, 
		isIE6 = $.util.ua.ie6, 
		isIE = $.util.ua.ie, 
		isIE67 = $.util.ua.ie67, 
		UI = WP.UI,
		ModBox = WP.diy.ModBox,
		BoxUtil = WPD.BoxUtil, 
		BoxBar = WPD.BoxBar, 
		Msg = WPD.Msg, 
		RequestHandler = WPD.RequestHandler, 
		OperateChecker = WP.diy.BoxOperateChecker, 
		lastRegion, porletSort, 
		REGION_EXPR = /.*\s(main-wrap|grid-sub|extra)\s.*/i, 

	msgEnum = {
		"canNotIn" : "抱歉，该区域不支持移入板块",
		"notSingle" : "抱歉，该区域已有相同板块，不能再次移入"
	},
	currentMsgCode;
	
	var BoxDDHandler = {
        init: function(){
            disableUnmovableBox();
            initPortlets();
        }
    };
    
    // 给不能移动的box添加ui-portlets-disable样式
    function disableUnmovableBox(){
        $("div.mod-box").each(function(i, b){
            var box = $(b);
            if (!box.data("box-config").movable) {
                box.addClass("ui-portlets-disable");
            }
        });
    }
    
    // 初始化拖拽
    function initPortlets(){
        var wpContent = $('#winport-content'), configs = {
            items: " div.mod-box:not(.ui-portlets-disable)",
            columns: "div.region",
            placeholder: "box-dd-placeholder",
            helper: boxDDHelper,
            cursorAt: { "top": 14 },
            revert: 250,
			revertOuter: true,
            start: startHandler,
			dropOnEmpty: dropOnEmptyHandler,
            over: overHandler,
            stop: stopHandler
        };
        
        wpContent.portlets(configs);
    }
    // 生成拖动的对象
    function boxDDHelper(ev, item){
        var helper = $('<div class="box-dd-helper">\
			<div class="mod">\
				<div class="m-body"></div>\
			</div>\
			<div class="dd-helper-shim"></div>\
		</div>');
        $("div.m-body", helper).append($("div.m-header", item).clone());
        return helper;
    }
	
	
    function boxDDPlaceHolder(ev, ui){
        return $('<div class="box-dd-placeholder"></div>');
    }
    
    // 开始拖拽时事件处理
    function startHandler(event, ui){
        var box = ui.currentItem, helper = ui.helper, ph = ui.placeholder;
        
        reCalcPlaceHolderHeight(box, ph);
        // 开始拖拽时 trigger 一个事件，并加上排序状态data
        $('#winport-content').data('sorting', true);
		box.trigger('ddstart');
		
		$.each(ui.columns,function(i,column){
			var region = $(column.dom);
			// 如果是当前region,跳过
			if(region[0] === ui.originalColumn[0]){
				return;
			}
			// 当目标区域有相同板块且singletonInRegion为true时，标记不可移入
	        if (!isSingleBoxInRegion(ui.currentItem, region)) {
	            region.addClass("ui-portlets-unreceivable");
				currentMsgCode = "notSingle";
				return;
	        }
	        // 根据canIn/canNotIn判断板块是否可移动到目标区域
	        var regionMatch = REGION_EXPR.exec(" " + region[0].className + " "), regionName;
	        if (regionMatch && regionMatch[1]) {
	            regionName = regionMatch[1];
	        }
	        else {
	            $.log("box-dd : cannot match regionName : " + region);
	            return;
	        }
	        if (!OperateChecker.ddCheck(box, regionName)) {
				region.addClass("ui-portlets-unreceivable");
				currentMsgCode = "canNotIn";
	            return;
	        }
		});
    }
    
    // 重新计算placeHolder的高度（减去border-width）
    function reCalcPlaceHolderHeight(box, ph){
		//noformat
        var phBorderTopHeight = parseFloat(ph.css("border-top-width")), 
			phBorderBottomHeight = parseFloat(ph.css("border-bottom-width")), 
			phBorderHeight = phBorderTopHeight + phBorderBottomHeight, 
			phMarginBottom = parseFloat(ph.css("margin-bottom")), 
			boxHeight = box.height();
		// FF下本不应减去phMarginBottom，但是实际测试减去反而稳定
        phHeight = isIE67 ? boxHeight - phBorderHeight - phMarginBottom : boxHeight - phBorderHeight - phMarginBottom;
        // 解决IE下max-height失效的问题
        ph.height(phHeight);
    }
	
	// 为空region特殊做的优化，将板块插入到该region中box-adder的前面（因为可能有固定的板块 如供应商信息板块)
	function dropOnEmptyHandler(ev,ui){
		$("div.box-adder", ui.currentColumn).before(ui.placeholder);
		return false;
	}
	
    // 判断该region中是否只有一个（cid）相同的box
    function isSingleBoxInRegion(box, region){
        var boxCfg = box.data("box-config"), isSingleBox = true;
        
        if (boxCfg.singletonInRegion) {
            $("div.mod-box:not(.ui-portlets-placeholder)", region).each(function(i, b){
                var b = $(b);
                if (b.data("box-config")["cid"] === boxCfg["cid"]) {
                    isSingleBox = false;
                    return false;
                }
            });
        }
        return isSingleBox;
    }
	
	// 进入region时，若不可被移入，根据currentMsgCode进行提示
	function overHandler(ev, ui){
        if (ui.currentColumn.hasClass("ui-portlets-unreceivable")) {
            Msg.warn(msgEnum[currentMsgCode]);
        }
    }
	
    // 拖拽结束时事件处理
    function stopHandler(event, ui){
		
        var box = ui.currentItem, boxCfg = box.data("box-config"),
		triggerFlag = false;
		
		// 更新box位置cache
        updateBoxLocation(box);
        //移除排序状态data
        $("#winport-content").removeData('sorting');
        WPD.RequestHandler.savePageLayout();
        if (boxCfg.needReload && ui.currentColumn[0] !== ui.originalColumn[0]) {
			UI.showLoading($("div.m-content",box));
			// 在reload之前先行fire ddstop事件
			box.trigger("ddstop");
			triggerFlag = true;
			ModBox.reload(box);
        }
		!triggerFlag && box.trigger("ddstop");
		$("div.region",this).removeClass("ui-portlets-unreceivable");
    }
    
    // 更新box位置
    function updateBoxLocation(box){
        var region = box.parents("div.region");
        box.data("region", BoxUtil.getComponentArea(region));
        var layout = region.parents("div.layout");
        box.data("layout", BoxUtil.getComponentArea(layout));
        var segment = layout.parents("div.segment");
        box.data("segment", segment[0].id);
    }
    
    WP.diy.BoxDDHandler = BoxDDHandler;
    WP.PageContext.register('~BoxDDHandler', BoxDDHandler);
	
})(jQuery, Platform.winport);