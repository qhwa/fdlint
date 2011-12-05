/**
 * @fileoverview 删除板块
 * @author long.fanl
 */
(function($,WP){
	var RequestHandler = WP.diy.RequestHandler,
		Dialog = WP.widget.Dialog,
		BaseOperateHandler = WP.diy.BaseOperateHandler;
		
		/**
		 * 删除Box确认框
		 */
		var BoxDelDialog = {
			
			operate : function(box,ev){
				
				var editConfig = box.data('editConfig'),
					boxTitle = editConfig.widgetName;
				
				Dialog.open({
					header: '删除板块',
					className: 'operate-delete-box-dialog',
					buttons: [
						{
							'class': 'd-confirm',
							value: '确定删除'
						},
						{
							'class': 'd-cancel',
							value: '取消'
						}
					],
					draggable: true,
					
					content : '<p class="d-msg"><span class="warn">确定要删除板块"'+boxTitle+'"吗?</span></p>',
					
					confirm : function(dialog){
						dialog.close();
						BoxDelHandler.operate(box);
					}
				});
			}
		};
		
		/**
		 * 删除Box
		 */
		var BoxDelHandler = $.extend({},BaseOperateHandler,{
				operation : "del",
				
				// 更新DOM
				_handleUI : function(save){
					var src = this.src;
					$("div.m-content,div.m-footer",src).css("opacity",0.2);
					BaseOperateHandler.bgiframe("open");
					src.animate({
						height : 0
					},500,function(){
						src.remove();
						BaseOperateHandler.bgiframe("close");
						save();
					});
				},
				// 删除操作 即时通知后台保存
				_save : function(){
					var boxCfg = this.src.data("box-config"),
						sid = boxCfg.sid,
						cid = boxCfg.cid;
					RequestHandler.delBox(sid,cid);
				}
			}
		);
		
	WP.diy.BoxOperateHandler.del = BoxDelDialog;
	
})(jQuery,Platform.winport);
