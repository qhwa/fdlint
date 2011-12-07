(function(d,b){var g=b.Util,e=b.UI;var f={init:function(k,j){this.div=k;this.config=j;var h=this,i=j.certificateQueryUrl;d.ajax(i,{data:{memberId:b.Component.getDocConfig().uid,pageSize:j.displayCount},dataType:"jsonp",success:function(l){l.success&&h.render(l.data||[])}})},render:function(j){var h=this,i=d("div.m-content",this.div);this.filterData(j);e.sweetTemplate(i,this.template,{certs:j,moreUrl:this.config.moreUrl},function(){h.afterRender&&h.afterRender()})},filterData:function(j){var i=this,h=this.config.creditDetailBaseUrl,k=b.Component.getDocConfig().imageServer+"/img/certify/";d.each(j,function(){var l=this;l.name=d.util.escapeHTML(l.name);l.origin=d.util.escapeHTML(l.origin);l.detailUrl=h+"/"+l.certifyInfoId+".html";l.smallImg=k+l.tnImgPath;l.dateDesc=i.formatDateDesc(l)})},formatDateDesc:function(h){return h.dateStart+(h.dateEnd?" �� "+h.dateEnd:" ��")}};var a=g.mkclass(f,{template:'<% if (certs.length) { %>		<table>			<tr>				<th class="img">֤��ͼƬ</th>				<th class="name">֤������</th>				<th class="origin">��֤����</th>				<th class="date">��Ч��</th>			</tr>			<% jQuery.each(certs, function(index, cert) { %>			<tr>				<td class="img"><a href="<%= cert.detailUrl %>" target="_blank"><img src="<%= cert.smallImg %>" alt="<%= cert.name %>" /></a></td>				<td class="name"><a href="<%= cert.detailUrl %>" target="_blank"><%= cert.name %></a></td>				<td class="origin"><%= cert.origin %></td>				<td class="date"><%= cert.dateDesc %></td>			</tr>			<% }); %>		</table>		<div class="m-content-footer"><a href="<%= moreUrl %>" target="_blank" class="more">���� &gt;&gt;</a></div>		<% } else { %>		<div class="no-content">����֤������</div>		<% } %>'});var c=g.mkclass(f,{template:'<% if (certs.length) { %>		<ul>			<% jQuery.each(certs, function(index, cert) { %>			<li>				<div class="img"><a href="<%= cert.detailUrl %>" target="_blank"><img src="<%= cert.smallImg %>" alt="<%= cert.name %>" /></a></div>				<div class="name"><a href="<%= cert.detailUrl %>" target="_blank"><%= cert.name %></a></div>				<div class="date"><%= cert.dateDesc %></div>			</li>			<% }); %>		</ul>		<div class="m-content-footer"><a href="<%= moreUrl %>" target="_blank" class="more">���� &gt;&gt;</a></div>		<% } else { %>		<div class="no-content">����֤������</div>		<% } %>',afterRender:function(){var h=d("div.img img",this.div);e.resizeImage(h,64)}});b.ModContext.register("wp-certification-info-main",a);b.ModContext.register("wp-certification-info-sub",c)})(jQuery,Platform.winport);