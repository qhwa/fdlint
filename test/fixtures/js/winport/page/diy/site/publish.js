/**
 * @fileoverview 发布
 * 
 * @author long.fanl
 */

(function($,WP){
	
var WPD = WP.diy,
	Diy = WPD.Diy,
	Util = WP.Util,
	Msg = WPD.Msg,
	Dialog = WP.widget.Dialog,
	
	docCfg,
	contentCfg,
	isHomepage, // 是否首页
	needSyncSide, // 是否同步发布其他页面
	publishDialogContent, // 发布对话框内容
	publishSuccessDialogContent, // 发布成功对话框内容
	publishFailedDialogContent; // 发布失败对话框内容


var SitePublish = {
	
	init:function(){
		var self = this;
		
		docCfg = $("#doc").data("doc-config");
		contentCfg = $("#content").data("content-config");
		isHomepage = contentCfg.isHomepage;
		$("#header div.setting-bar a.publish").click(function(e){
			e.preventDefault();
			self._openPublishDialog();
			return false;
		});
		
		$("#header div.setting-bar a.backup-tool-item").click(function(e){
			e.preventDefault();
			//调用框架 备份模板
			WP.diy.Template.backup({
				success:function(){
					//从新载入页面，切换到备份tab页
					Platform.winport.SettingContext.loadPage(2,{"showBackup":true});
				},
				error:function(message){
					Msg.error('备份模板失败，请刷新后重试。');
				}
			});
			return false;
		});
	},
	
	// 打开发布对话框
	_openPublishDialog:function(){
		publishDialogContent = publishDialogContent || 
				this._getPublishAreaContent("textarea.site-publish");
		
		var self = this;
		
		this.publishDialog = Dialog.open({
			header: '发布',
			className: 'publish-dialog',
			hasClose: false,
			buttons: [
				{
					'class': 'd-confirm',
					value: '确认发布'
				},
				{
					'class': 'd-cancel',
					value: '取消'
				}
			],
			draggable : true,
				
			content : publishDialogContent,
			
			contentSuccess : function(dialog){
				dialog = dialog.node;
				
				// checkbox勾中，显示“同步设置”
				$("#sync-page").change(function(){
					
					if($(this)[0].checked){
						$("a.sync-setting",dialog).css("display","inline-block");
						var syncSettingPanel = $("div.sync-setting-panel",dialog);
						// 如果已加载“同步列表”面板，勾选中所有的checkbox
						if(syncSettingPanel.length > 0){
							$(".input-checkbox",syncSettingPanel).each(function(i,checkbox){
								checkbox.checked = true;
							});
						}
					}else{ // 取消，隐藏“同步设置”和“同步列表”
						$("a.sync-setting",dialog).css("display","none");
						$("div.sync-setting-panel",dialog).css("display","none");
					}
				});
				
				//“同步设置”按钮，点击显示“同步列表”
				$("a.sync-setting",dialog).click(function(ev){
					ev.preventDefault();
					var settingWrap = $("div.sync-setting-wrap",dialog),
					syncPageList = $("div.sync-setting-panel",dialog);
					
					if(syncPageList.length === 0 && !settingWrap.data("hasPageList")){
						self._getSyncPageList(settingWrap);
					}
					
					$("div.sync-setting-panel",dialog).css("display","block");
				});
			},
			
			confirm : function(dialog){
				self._publish($("form", dialog.node));
			}
		});
	},
	
	/**
	 * 根据textarea selector获取发布[成功|失败]框内容
	 */
	_getPublishAreaContent: function(selector){
		var textarea = $(selector),
			content = textarea.val();
		textarea.remove();
		return content;
	},
	
	/**
	 * 获取可以同步的价格列表
	 */
	_getSyncPageList: function(settingWrap){
		var self = this,
			listSyncPageUrl = docCfg.listSyncPageUrl;
		
		settingWrap.data("hasPageList", true);
		
		$.ajax(listSyncPageUrl, {
			cache: false,
			success: function(result){
				self.syncPageList = $(result);
				$(result).insertAfter(settingWrap);
			},
			error: function(){
				Msg.warn("网络繁忙，请刷新后重试");
			}
		});
	},
	
	// 发送发布请求
	_publish: function(form){
		var self = this,
			publishSiteUrl = docCfg.publishSiteUrl+"?_input_charset=UTF-8",
			syncPageList = [],
			formData = form.serializeArray();
		
		self.publishDialog.showLoading("正在发布..");
		needSyncSide = $('input[name="is-sync-page-side"]', form).prop('checked');

		$(formData).each(function(i,v){
			if(v.name === "sync-page"){
				syncPageList.push(parseInt(v.value, 10));
			}
		});
		var syncSettingPanel = $("div.sync-setting-panel",form);
		// 如果选中了“同步侧边栏”，但是“同步列表”为空，则不需要同步
		if(needSyncSide && syncSettingPanel.length > 0 && syncPageList.length === 0){
			needSyncSide = false;
		}
		
		Diy.authAjax(publishSiteUrl, {
			type: "POST",
			data: {
				_csrf_token: docCfg._csrf_token,
				pageSid: contentCfg.sid,
				needSyncSide : needSyncSide,
				syncPageList : JSON.stringify(syncPageList)
			},
			
			dataType:"json",
			
			timeout: 20000,  // 当同步页面比较多，要同步的板块比较多时，后台处理会比较慢，这个超时设长20秒
			
			success : function(result){
				self.publishDialog.close();
				if (result.success){
					self._publishSuccess(result);
				} else {
					self._publishFailed();
				}
			},
			error : function(){
				self.publishDialog.showLoading(false);
				Msg.warn("网络繁忙，请刷新后重试");
			}
		});
	},
	
	// 打开发布成功对话框
	_publishSuccess:function(result){
		
		if(!publishSuccessDialogContent){
			publishSuccessDialogContent = this._getPublishAreaContent("textarea.site-publish-success");
		}
		
		Dialog.open({
			header: '发布',
			className: 'publish-success-dialog',
			
			content : publishSuccessDialogContent,
			draggable: true,
			contentSuccess : function(dialog){
				// 查看您的旺铺
				$("a.open-wp",dialog.node).click(function(e){
					dialog.close();
					if(!isHomepage && needSyncSide){
						window.location.reload();
					}
				});
				// 返回
				$("a.back-diy",dialog.node).click(function(e){
					e.preventDefault();
					dialog.close();
					// 如果不是首页 并且选了需要同步侧边栏 为了“同步更新“问题 重载当前页面
					if(!isHomepage && needSyncSide){
						window.location.reload();
					}
					return false;
				});
				
				var resultData = result.data,
					errList = null,msgList = "";
				// 超出20板块提示
				if (resultData && (errList = resultData.MAX_WIDGETS_ERR)) {
					if(errList.length > 0 ){
						msgList += "<li>"+errList.join("、")+errList.length+"个页面同步后超过20个板块，同步失败，请删除部分侧边栏板块后重试！</li>";
					}
				}
				// 其他错误提示
				if (resultData && (errList = resultData.OTHER_ERR)) {
					if(errList.length > 0 ){
						msgList += "<li>"+errList.join("、")+errList.length+"个页面同步失败！</li>";
					}
				}
				
				if(msgList !== ""){
					$("<ul>",{
						"class" : "pub-result-msg"
					}).html(msgList).insertAfter($("p.d-msg",dialog));
				}
			}
			
		});
	},
	// 打开发布失败对话框
	_publishFailed : function(){
		
		if(!publishFailedDialogContent){
			publishFailedDialogContent = this._getPublishAreaContent("textarea.site-publish-failed");
		}
		
		var self = this;
		
		Dialog.open({
			header: '发布',
			className: 'publish-failed-dialog',
		
			content : publishFailedDialogContent,
			
			contentSuccess : function(dialog){
				// 返回
				$("a.back-diy",dialog.node).click(function(e){
					e.preventDefault();
					dialog.close();
					return false;
				});
			}
			
		});
	}
};
	

WP.PageContext.register('~SitePublish', SitePublish);


})(jQuery,Platform.winport);
