/**
 * @fileoverview 板块操作逻辑
 * @author long.fanl
 */
(function($,WP){
	var WPD = WP.diy,
		BoxOperateChecker = WPD.BoxOperateChecker,
		Msg = WPD.Msg;
		
		/**
		 * BoxOperateHandler 负责管理所有基于Box的操作(toolbar面板)
		 * 其中 : 添加/删除/上移/下移/左移/右移 -> 影响页面布局(PageLayout)
		 *           设置 ->  影响板块自身数据(BoxData)
		 * 除了 mod,理论上 region , layout , segment都可以支持, 目前需求只有mod可操作
		 */
		var BaseOperateHandler = {
			// 操作类型,和box-config中对应
			operation : null,
			// 该操作对应的源box
			src : null,
			// 增加/删除/移动操作 处理逻辑
			operate : function(box){
				this.src = box;
				this._prepare();
				var checkResult = this._check();
				if(!checkResult.pass){
					Msg.warn(checkResult.message);
					return;
				}
				var save = $.proxy(this._save,this);
				this._handleUI(save);
			},
			// 钩子 : 在操作之前的准备工作
			_prepare:$.noop,
			// 验证板块是否可操作
			_check : function(box){
				return BoxOperateChecker.check(this.src,this.operation);
			},
			// 界面操作,完成后回调save方法
			_handleUI : function(save){
				save();
			},
			// UI操作之前需要做的,默认隐藏flyadder
			_beforeUI : $.noop,
			// UI操作完毕后的附加/追加操作,默认更新toolbar
			_afterUI : $.noop,
			// 异步通知后台保存
			_save : $.noop
		};
		
		BaseOperateHandler.base = BaseOperateHandler;
		
		BaseOperateHandler.bgiframe = function(op){
			if(op === "open"){
				$('body').bgiframe({
					zIndex : 199,
					force : true
				});
			}else if(op === "close"){
				$("body").bgiframe("close");
			}
		}
		
		
		WPD.BaseOperateHandler = BaseOperateHandler;
		WPD.BoxOperateHandler = {};
		
})(jQuery,Platform.winport);