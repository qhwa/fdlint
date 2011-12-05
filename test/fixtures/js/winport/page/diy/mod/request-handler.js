/**
 * @fileoverview 板块操作请求逻辑
 * @author long.fanl
 */
(function($,WP){
	var ModContext = WP.ModContext,
		Util = WP.Util,
		FormUtil = WP.widget.FormUtil,
		ModBox = WP.diy.ModBox,
		WPD = WP.diy,
		Diy = WPD.Diy,
		Util = WP.Util,
		Component = WPD.Component,
		Msg = WPD.Msg,
		
		// doc级 config，包含_csrf_token等
		docCfg,
		_csrf_token,
		
		// page级 config，包含 pageSid,pageCid等
		content,
		contentCfg,
		pageSid,
		pageCid,
		editFormUrl, // 获取“设置”表单url
		getBoxUrl, // 获取一个板块(box)的url
		saveLayoutUrl, // 保存“布局”url
		
		// regionMap 传给后台需要做一次映射
		regionMap = {
			"main-wrap":"MAIN",
			"grid-sub":"SIDE",
			"grid-extra":"EXTRA"
		},
		
		//页面布局自动保存定时器
		lastPageLayout = null,
		
		pageLayoutChanged = false,
		
		pageLayoutTimer = null,
		
		pageLayoutSaveInterval = 2000,
		
		pageLayoutHasSaved = true,
		
		//自定义样式自动保存定时器
		customStyleTimer = null,
		
		customStyleSaveInterval = 500;
		
		
		/**
		 * RequestHandler负责DIY后台前端和后台之间交互的请求处理
		 * 本质为Util类,不处理业务逻辑
		 * @param {Object} box
		 */
		var RequestHandler = {
			
			init: function(){
				
				docCfg = $("#doc").data("doc-config");
				_csrf_token = docCfg._csrf_token;
				content = $("#content");
				contentCfg = content.data("content-config");
				pageSid = contentCfg.sid;
				pageCid = contentCfg.cid;
				
				// 获取“设置”form表单url, 参见 getEditFormUrl
				editFormUrl = contentCfg.editFormUrl;
				
				// 获取一个板块内容(box)的url
				getBoxUrl = contentCfg.getBoxUrl;

				// 保存“布局”url
				saveLayoutUrl = contentCfg.saveLayoutUrl;
				
				lastPageLayout = Component.getPageLayout();
			},
			
			/**
			 * 获取一个box内容
			 * @param {Object} box
			 */
			getBox: function(box){
				ModBox.reload(box);
			},
			
			/**
			 * 更新该box的内容(设置内容后更新)
			 * @param {Object} box
			 */
			updateBox : function(box){
				this.getBox(box);
			},
			
			/**
			 * 重新加载该box的内容(左右移动板块时使用)
			 * @param {Object} box
			 */
			reloadBox : function(box){
				this.getBox(box);
			},
			
			/**
			 * 获取板块设置表单的url
			 * @param {Object} box
			 */
			getEditFormUrl : function(box){
				return editFormUrl + "-" + pageSid + "-" + box.data("box-config").sid + ".htm?__envMode__=EDIT";
			},
			
						
			/**
			 * 删除一个板块,和页面布局一起保存
			 * @param {Object} boxId
			 */
			delBox : function(sid,cid){
				// 存入要删除的boxSid
//				delList.push(sid);
				// 由于删除操作 同时也会保存页面布局, 因此需要取消掉pageLayoutTimer
				if ( pageLayoutTimer ) {
		            clearTimeout(pageLayoutTimer);
		        }
				var pageLayout = Component.getPageLayout(),
				idObj = {}; idObj[sid] = cid;
				// 然后直接发送,即时保存
				Diy.authAjax(saveLayoutUrl,{
					type: "POST",
					data: {
						_csrf_token:_csrf_token,
						version : contentCfg.version,
						pageSid : contentCfg.sid,
						pageContent : pageLayout,
						delList : '[{'+sid+':"'+cid+'"}]'
					},
					dataType : "json",
					success : function(result){
						if(result.success){
							$(window).trigger('diychanged', { type: 'del-box' });
							++contentCfg.version;
							if(pageLayoutChanged){
								Msg.info("移动板块成功");
							}
							Msg.info("删除板块成功");
							
							pageLayoutChanged = false;
						}else{
							if(result.data && result.data === "VERSION_EXPIRED"){
								window.location.reload();
								return;
							}
							Msg.error("删除板块失败，请刷新后重试");
						}
					}
				});
			},
			/**
			 * 保存页面布局(延迟保存)
			 * @param {Object} box
			 * @param {Object} operation
			 */
			savePageLayout : function(){
		        sendPageLayout();
			}
			
		}
		
		function sendPageLayout(){
			// 5秒内又有操作,重新计时
	        if ( pageLayoutTimer ) {
				pageLayoutChanged = true;
	            clearTimeout(pageLayoutTimer);
	        }
	        pageLayoutTimer = setTimeout(function() {
				
				pageLayoutHasSaved = false;
				
				var pageLayout = Component.getPageLayout();
				if(pageLayout !== lastPageLayout){
					lastPageLayout = pageLayout;
					Diy.authAjax(saveLayoutUrl,{
						type: "POST",
						data: {
							_csrf_token:_csrf_token,
							version:contentCfg.version,
							pageSid : contentCfg.sid,
							pageContent : pageLayout,
							delList :  "[]"
						},
						dataType : "json",
						success : function(result){
							if(result.success){
								$(window).trigger('diychanged', { type: 'move-box' });
								++contentCfg.version;
								Msg.info("移动板块成功");
							}else{
								if(result.data && result.data === "VERSION_EXPIRED"){
									window.location.reload();
									return;
								}
								Msg.error("移动板块失败，请刷新后重试");
							}
							pageLayoutHasSaved = true;
						}
					});
				}
	        }, pageLayoutSaveInterval);
		}
		
		WPD.RequestHandler = RequestHandler;
		
		WP.PageContext.register('~RequestHandler', RequestHandler);
		
})(jQuery,Platform.winport);
