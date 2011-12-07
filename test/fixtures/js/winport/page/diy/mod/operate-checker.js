/**
 * @fileoverview 板块操作检查
 * @author long.fanl
 */
(function($, WP){
    var BoxUtil = WP.diy.BoxUtil, 
	MOVE_EXPR = /move|up|down|left|right/i;
    
    // WARN 主题图片板块,初始化default_page_config要初始化每个page
    var BoxOperateChecker = {
        /**
         * 检查box是否可以进行operation操作(同时可用于box-bar的初始化)
         * @param {Object} box
         * @param {Object} operation
         */
        check: function(box, operation, isDetact){
            var result;
            if (operation === "edit") {
                result = editCheck(box);
            }
            else 
                if (operation === "del" || operation === "delConfirm") {
                    result = delCheck(box);
                }
                else 
                    if (operation.match(MOVE_EXPR)) {
                        result = moveCheck(box, operation, isDetact);
                    }
            if (!result.pass) {
                result.resultCode = "warn";
            }
            return result;
        },
        /**
         * 检查box是否可以存在dst区域,主要用于拖拽操作
         * @param {Object} box
         * @param {Object} dst
         */
        ddCheck: function(box, dst){
            if (!box.data("box-config")["movable"]) {
                return false;
            }
            return canIn(box, dst);
        }
    };
    
    // 编辑操作 检查该板块能否编辑
    function editCheck(box){
        var result = {};
        result.pass = box.data("box-config")["editable"];
        return result;
    }
    
    // 删除操作 检查该板块能否删除
    function delCheck(box){
        var result = {};
        result.pass = box.data("box-config")["deletable"];
        return result;
    }
    // 移动操作
    function moveCheck(box, moveOperation, isDetact){
        var result = {}, canMove = false, mo = moveOperation, config = box.data("box-config");
		isDetact = isDetact || false;
        result.pass = false;
        result.message = "抱歉，该区域不支持移入板块";
        if (config && !config.movable) {
            return result;
        }
        if (mo === "move") {
            canMove = true;
        }
        else 
            if (mo === "up") {
                canMove = _upMoveCheck(box);
            }
            else 
                if (mo === "down") {
                    canMove = _downMoveCheck(box);
                }
                else 
                    if (mo === "left" || mo === "right") {
                        var dstRegion = BoxUtil.getDstRegion(box, mo), dstRegionName = dstRegion.name, dstRegionObj = dstRegion.obj;
                        
                        if (typeof dstRegionName !== "undefined") {
                            if (!dstRegionName || !canIn(box, dstRegionName)) {
                                return result;
                            }
                            if (!isDetact && exceedMaxCountInRegion(box, dstRegionObj)) {
                                result.message = "抱歉，该区域已有相同板块，不能再次移入";
                                return result;
                            }
                            canMove = true;
                        }
                    }
        result.pass = canMove;
        return result;
    }
    
    function _upMoveCheck(box){
        var prevBox = BoxUtil.prevBox(box);
        return prevBox.length > 0 && prevBox.data("box-config")["movable"];
    }
    
    function _downMoveCheck(box){
        var nextBox = BoxUtil.nextBox(box);
        return nextBox.length > 0 && nextBox.data("box-config")["movable"];
    }
    
    /**
     * 根据规则判断，该box能否在于dstRegion中
     *
     * 示例 : "canIn" : "winport-content.p32-m0s5.*,winport-content.p32-s5m0.*"
     * 示例 : "canIn" : "winport-content.*.grid-sub"
     *           "canIn" : "winport-content.*.*"
     *           "canIn" : "winport-header.p32-m0.*"
     * 			 "canNotIn" : "winport-content.*.main-wrap"
     * 示例 : "canNotIn" : "*.p32-m0.*,*.p32-m0s5.main-wrap,*.p32-s5m0.main-wrap"
     * @param {Object} box
     * @param {Object} dstRegion
     */
    function canIn(box, dstRegion){
        var layout = BoxUtil.getComponentArea(box.closest("div.layout")), 
			segment = BoxUtil.getComponentArea(box.closest("div.segment")), 
			locationRule = box.data("location-rule") || initLocationRule(box);
        
        return matchCanIn(locationRule.canIn, segment, layout, dstRegion) && !matchCanNotIn(locationRule.canNotIn, segment, layout, dstRegion);
        
    }
    
    /**
     * 初始化box的canIn 和 canNotIn 配置
     * @param {Object} box
     */
    function initLocationRule(box){
        var config = box.data("box-config"), canNotIn = config.canNotIn, canIn = config.canIn, locationRule = {
            canIn: parseLocationRule(canIn),
            canNotIn: parseLocationRule(canNotIn)
        };
        
        box.data("location-rule", locationRule);
        return locationRule;
    }
    
    /**
     * 解析规则
     * @param {Object} originalRule
     */
    function parseLocationRule(originalRule){
        var originalRuleList, transferredRuleList = [], transferredRule;
        if (typeof originalRule === "undefined" || originalRule === "") {
            return transferredRuleList;
        }
        
        originalRuleList = originalRule.split(",");
        
        for (var i = 0; i < originalRuleList.length; i++) {
        
            originalRule = originalRuleList[i].split(".");
            transferredRule = {};
            
            for (var j = 0; j < originalRule.length; j++) {
                var area = j === 0 ? "segment" : (j === 1 ? "layout" : "region");
                transferredRule[area] = originalRule[j];
            }
            
            transferredRuleList.push(transferredRule);
        }
        return transferredRuleList;
    }
    
    /**
     * 根据segment-layout-region判断是否匹配canIn规则
     */
    function matchCanIn(rule, segment, layout, region){
        if (rule === []) { //如果rule为空，返回false
            return false;
        }
        return matchRule(rule, segment, layout, region);
    }
    
    /**
     * 根据segment-layout-region判断是否匹配canNotIn规则
     */
    function matchCanNotIn(rule, segment, layout, region){
        if (rule === []) { // 如果rule为空，返回true
            return true;
        }
        return matchRule(rule, segment, layout, region);
    }
    
    /**
     * 根据segment-layout-region判断是否匹配rule规则
     * @param {Array} rule
     * @param {String} segment
     * @param {String} layout
     * @param {String} region
     */
    function matchRule(rule, segment, layout, region){
        var segmentMatch = false, layoutMatch = false, regionMatch = false, match = false;
        $.each(rule, function(i, ruleItem){
        
            segmentMatch = (ruleItem.segment === "*" || ruleItem.segment === segment);
            layoutMatch = (ruleItem.layout === "*" || ruleItem.layout === layout);
            regionMatch = (ruleItem.region === "*" || ruleItem.region === region);
            
            if (segmentMatch && layoutMatch && regionMatch) {
                match = true;
                return false;
            }
        });
        return match;
    }
    
    /**
     * 在dstRegion中同类型(cid)box的数量是否超出了限制(根据是否单例来判断）
     * @param {Object} box
     * @param {Object} dstRegion
     */
    function exceedMaxCountInRegion(box, dstRegion){
        var config = box.data("box-config"), cid = config.cid, singletonInRegion = config.singletonInRegion, dstCount = 0, exceed = false;
        $("div.mod-box", dstRegion).each(function(i, b){
            if (cid === $(b).data("box-config")["cid"] && singletonInRegion) {
                exceed = true;
                return false;
            }
        });
        return exceed;
    }
    
    WP.diy.BoxOperateChecker = BoxOperateChecker;
	
})(jQuery, Platform.winport);
