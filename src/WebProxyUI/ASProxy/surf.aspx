<%@ Page Language="C#" meta:resourcekey="Page" Inherits="SalarSoft.ASProxy.PageInMasterLocale"%>
<%@ Import Namespace="SalarSoft.ASProxy.Exposed" %>
<%@ Import Namespace="SalarSoft.ASProxy" %>
<%@ Import Namespace="System.Threading" %>
<html>
<script runat="server">
	bool _HasError = true;
	string _ToDisplayUrl = "";
	string _ErrorMessage = "";
	string _ResponseContent = "";
	string _ExtraCodesForBody = "";
	UserOptions _userOptions;

	protected void Page_Load(object sender, EventArgs e)
	{
		Consts.FilesConsts.PageDefault_Dynamic = System.IO.Path.GetFileName(Request.Url.AbsolutePath).ToLower();
		_userOptions = UserOptions.ReadFromRequest();

		if (Configurations.Authentication.Enabled)
		{
			if (!Configurations.Authentication.HasPermission(User.Identity.Name, Configurations.AuthenticationConfig.UserPermission.Pages))
			{
				_ErrorMessage = "Access denied!";
				_ErrorMessage += "<br />You do not have access to browse pages. Ask site administrator to grant permission.";
				_HasError = true;
				return;
			}
		}

		ProccessRequest();
	}

	void ProccessRequest()
	{
		if (UrlProvider.IsASProxyAddressUrlIncluded(Request.QueryString))
		{
			using (IEngine engine = (IEngine)Providers.GetProvider(ProviderType.IEngine))
			{

				engine.UserOptions = _userOptions;
				engine.DataTypeToProcess = DataTypeToProcess.Html;
				engine.RequestInfo.SetContentType(MimeContentType.text_html);

				engine.Initialize(Request);
				engine.RequestInfo.RequestUrl = UrlProvider.CorrectInputUrl(engine.RequestInfo.RequestUrl);

				GetResults(engine);
			}
		}
	}

	void GetResults(IEngine engine)
	{
		_ToDisplayUrl = engine.RequestInfo.RequestUrl;
		try
		{
			MimeContentType pageContentType;
			if (!UrlProvider.IsFTPUrl(engine.RequestInfo.RequestUrl))
			{
				engine.ExecuteHandshake();

				if (engine.LastStatus == LastStatus.Error)
				{
					if (Systems.LogSystem.ErrorLogEnabled)
						Systems.LogSystem.LogError(engine.LastErrorMessage, engine.RequestInfo.RequestUrl);

					_ErrorMessage = engine.LastErrorMessage;
					if (string.IsNullOrEmpty(_ErrorMessage))
						_ErrorMessage = "Unknown error on requesting data";
					_HasError = true;
					return;
				}
				pageContentType = engine.ResponseInfo.ContentTypeMime;
			}
			else
				pageContentType = MimeContentType.application;

			switch (pageContentType)
			{
				case MimeContentType.application:
					if (WebMethods.IsMethod(engine.RequestInfo.RequestMethod, WebMethods.DefaultMethods.GET))
						Response.Redirect(UrlProvider.GetASProxyPageUrl(Consts.FilesConsts.PageDownload, engine.RequestInfo.RequestUrl, _userOptions.EncodeUrl), false);
					else
						Response.Redirect(UrlBuilder.AppendAntoherQueries(Consts.FilesConsts.PageDownload, engine.RequestInfo.PostDataString), false);
					return;
				case MimeContentType.image_gif:
				case MimeContentType.image_jpeg:
					_ResponseContent = HtmlTags.ImgTag(UrlProvider.GetASProxyPageUrl(Consts.FilesConsts.PageImages, engine.RequestInfo.RequestUrl, _userOptions.EncodeUrl));
					return;
			}

			// Don't process for these type in default page
			if (pageContentType == MimeContentType.text_css || pageContentType == MimeContentType.text_plain || pageContentType == MimeContentType.text_javascript)
				engine.DataTypeToProcess = DataTypeToProcess.None;

			// apply http compression
			SalarSoft.ASProxy.BuiltIn.HttpCompressor.ApplyCompression(engine.ResponseInfo.ContentTypeMime);
			
			// Execute the request
			_ResponseContent = engine.ExecuteToString();


			// Set response query
			_ToDisplayUrl = engine.ResponseInfo.ResponseUrl;

			// If content is text format
			if (pageContentType == MimeContentType.text_css || pageContentType == MimeContentType.text_plain || pageContentType == MimeContentType.text_javascript)
				_ResponseContent = "<pre>" + HttpUtility.HtmlEncode(_ResponseContent) + "</pre>";

			// Response charset
			Response.ContentEncoding = engine.ResponseInfo.ContentEncoding;
			Response.Charset = engine.ResponseInfo.ContentEncoding.BodyName;

			if (engine.LastStatus == LastStatus.Error)
			{
				if (Systems.LogSystem.ErrorLogEnabled)
					Systems.LogSystem.LogError(engine.LastErrorMessage, engine.RequestInfo.RequestUrl);

				_ErrorMessage = engine.LastErrorMessage;
				_HasError = true;
				_ResponseContent = "";
				return;
			}
			else if (engine.LastStatus == LastStatus.ContinueWithError)
			{
				if (Systems.LogSystem.ErrorLogEnabled)
					Systems.LogSystem.LogError(engine.LastErrorMessage, engine.RequestInfo.RequestUrl);

				// if has error but can continue
				_ErrorMessage = engine.LastErrorMessage;
				_HasError = true;
			}


			if (engine.UserOptions.DocType || !engine.ResponseInfo.HtmlIsFrameSet)
			{
				Response.Write(engine.ResponseInfo.HtmlDocType);
			}
			Response.Write(engine.ResponseInfo.ExtraCodesForPage);
			_ExtraCodesForBody = engine.ResponseInfo.ExtraCodesForBody;

			if (engine.UserOptions.PageTitle)
			{
				Page.Title = engine.ResponseInfo.HtmlPageTitle + " - [" + Consts.General.ASProxyName + "]";
			}
			if (engine.ResponseInfo.HtmlIsFrameSet)
			{
				ApplyFramesetResults(engine);
				return;
			}
		}
		catch (ThreadAbortException) { }
		catch (Exception ex)
		{
			if (Systems.LogSystem.ErrorLogEnabled)
				Systems.LogSystem.LogError(ex, ex.Message, engine.RequestInfo.RequestUrl);

			_ErrorMessage = ex.Message;
			_HasError = true;
		}
	}

	void ApplyFramesetResults(IEngine resutls)
	{
		if (resutls.ResponseInfo.HtmlIsFrameSet)
		{
			string result = "";
			if (WebMethods.IsMethod(resutls.RequestInfo.RequestMethod, WebMethods.DefaultMethods.GET))
				result = UrlProvider.GetASProxyPageUrl(Consts.FilesConsts.PageDirectHtml, resutls.RequestInfo.RequestUrl, true);
			else
				result = UrlBuilder.AppendAntoherQueries(Consts.FilesConsts.PageDirectHtml, resutls.RequestInfo.PostDataString);
			_ResponseContent = HtmlTags.IFrameTag(result, "100%", "600%");
		}
		// quit
		HttpContext.Current.ApplicationInstance.CompleteRequest();
	}
</script>
<head runat="server"><title runat="server">Surf the web with ASProxy</title>
<script src="scripts/base64encoder.js" type="text/javascript" asproxydone="2"></script>
<!-- Surf the web invisibly using ASProxy power. A Powerfull web proxy is in your hands. -->
<style type="text/css" asproxydone="2">
.ASPXBlock,.AddrBar,.FastOpts,#MoreOpts{background-color:#f8f8f8;height:auto !important;margin:0 2px;padding:0;float:inherit;display:inherit;color:black;font: normal normal normal 100% Tahoma;font-family:Tahoma,sans-serif;font-size:10pt;}
.ASPXBlock{background-color:white;width:99.5%;display: block;padding:1px;margin:0;border:2px solid #000000;height:auto !important;float:none;}
.ASPXMain{color:black;padding:2px;margin:0;border:1px solid #C0C0C0;background-color:#f8f8f8;background-image:none;font-weight:normal;font-style:normal;line-height:normal;visibility:visible;table-layout:auto;white-space:normal;word-spacing:normal;float:none;}
.ASPXMain a,.ASPXMain a:link,.ASPXMain a:hover,.ASPXMain a:visited,.ASPXMain a:active{font:normal normal normal 100% Tahoma;font-family:Tahoma,sans-serif;color:#000099;text-decoration:underline;}
.AddrBar{margin:3px 1px;}
.AddrBar input{width:auto;height:auto;border:solid 1px silver;font:inherit;color:Black;}
.AddrBar .Button{width:auto;height:25px;color:black;float:none;width:auto !important;margin:0;background-color:#ECE9D8;border:outset 2px;vertical-align:bottom;font-size:10pt;padding:2px 5px;}
.AddrBar .TextBox{width:auto !important;height:auto;color:black;background-color:white;margin:0;float:none;font-size:10pt;border:solid 1px silver;padding:3px;text-align:left;}
.ASPXOpt{background-color:#f8f8f8;height: auto !important;margin:0 1px;padding:0;float:none;color:black;font:normal normal normal 100% Tahoma;font-family:Tahoma,sans-serif;font-size:8pt;display:inline;border-width:0;text-align:center;}
.ASPXOpt input{width:auto;height:auto !important;margin:0;background-color:#F8F8F8;display:inline;border-width:0;float: none;}
.ASPXOpt label{width:auto;height:auto !important;margin:0 2px;padding:0;vertical-align:baseline;float:none;color:Black;font:normal normal normal 100% Tahoma;display:inline;border-width:0;background-color:#F8F8F8;}
</style>
</head><body>
<script asproxydone="2" type="text/javascript">
var _ASProxyVersion="<%=Consts.General.ASProxyVersion %>";
function toggleOpt(lnk){var trMoreOpt=document.getElementById('MoreOpts'); if (trMoreOpt.style.display=='none'){trMoreOpt.style.display='';lnk.innerHTML='<%=this.GetLocalResourceObject("lnkMoreOptions")%>...<small>&lt;</small>';
}else{trMoreOpt.style.display='none';lnk.innerHTML='<%=this.GetLocalResourceObject("lnkMoreOptions")%>...<small>&gt;</small>';}}
</script>
<script asproxydone="2" src="scripts/surfoptions.js" type="text/javascript"></script>
<script asproxydone="2" type="text/javascript">
var _Page_B64Unknowner = "<%=Consts.Query.Base64Unknowner%>";
var _Page_CookieName = "<%=Consts.FrontEndPresentation.UserOptionsCookieName%>";
var _Page_UrlIsEmpty = '<%=this.GetLocalResourceObject("UrlIsEmpty")%>';
var _Page_XNav = '<%=Consts.FilesConsts.PageDefault_Dynamic%>';
function _Page_SetOptions(){
_XPage.ProcessLinks.checked =<%=_userOptions.Links.ToString().ToLower() %>;
_XPage.DisplayImages.checked =<%=_userOptions.Images.ToString().ToLower() %>;
_XPage.Forms.checked =<%=_userOptions.SubmitForms.ToString().ToLower() %>;
_XPage.Compression.checked =<%=_userOptions.HttpCompression.ToString().ToLower() %>;
_XPage.ImgCompressor.checked =<%=_userOptions.ImageCompressor.ToString().ToLower() %>;
_XPage.Cookies.checked =<%=_userOptions.Cookies.ToString().ToLower() %>;
_XPage.TempCookies.checked =<%=_userOptions.TempCookies.ToString().ToLower() %>;
_XPage.OrginalUrl.checked =<%=_userOptions.OrginalUrl.ToString().ToLower() %>;
_XPage.Frames.checked =<%=_userOptions.Frames.ToString().ToLower() %>;
_XPage.PageTitle.checked =<%=_userOptions.PageTitle.ToString().ToLower() %>;
_XPage.UTF8.checked =<%=_userOptions.ForceEncoding.ToString().ToLower() %>;
_XPage.RemoveScripts.checked =<%=_userOptions.RemoveScripts.ToString().ToLower() %>;
_XPage.RemoveObjects.checked =<%=_userOptions.RemoveObjects.ToString().ToLower() %>;
_XPage.EncodeUrl.checked=<%=_userOptions.EncodeUrl.ToString().ToLower() %>;
}
</script>

<div id="ASProxyFormBlock" class="ASPXBlock" dir="<%=Resources.Languages.TextDirection%>">
<div class="ASPXMain" style="text-align:<%=Resources.Languages.TextAlign%>"><div class="AddrBar">
<a href="." asproxydone="2" style="font-weight:bold;text-decoration:none">ASProxy <%=Consts.General.ASProxyVersion %></a>
<!--This is ASProxy powered by SalarSoft. -->
<input name="url" type="text" size="80" id="txtUrl" dir="ltr" style="width:550px;" class="TextBox" onkeyup="_Page_HandleTextKey(event)" value="<%=HttpUtility.HtmlEncode(_ToDisplayUrl)%>" />
<input type="button" onclick="_Page_SubmitForm()" value="<%=this.GetLocalResourceObject("btnDisplay")%>" id="btnASProxyDisplayButton" class="Button" />
<a href="cookieman.aspx" target="_blank" asproxydone="2"><%=this.GetLocalResourceObject("CookieManager")%></a>
<a href="download.aspx" target="_blank" asproxydone="2"><%=this.GetLocalResourceObject("DownloadTool")%></a>
</div>
<div class="FastOpts">
<%if (Configurations.UserOptions.ForceEncoding.Changeable){ %><span class="ASPXOpt"><input id="chkUTF8" type="checkbox" onclick="_Page_SaveOptions()" /><label for="chkUTF8"><%=this.GetLocalResourceObject("chkUTF8")%></label></span> <%} %>
<%if (Configurations.UserOptions.OrginalUrl.Changeable){ %><span class="ASPXOpt"><input id="chkOrginalUrl" type="checkbox" checked="checked" onclick="_Page_SaveOptions()" /><label for="chkOrginalUrl"><%=this.GetLocalResourceObject("chkOrginalUrl")%></label></span> <%} %>
<%if (Configurations.UserOptions.RemoveScripts.Changeable){ %><span class="ASPXOpt"><input id="chkRemoveScripts" type="checkbox" onclick="_Page_SaveOptions()" /><label for="chkRemoveScripts"><%=this.GetLocalResourceObject("chkRemoveScripts")%></label></span> <%} %>
<%if (Configurations.UserOptions.Cookies.Changeable){ %><span class="ASPXOpt"><input id="chkCookies" type="checkbox" checked="checked" onclick="_Page_SaveOptions()" /><label for="chkCookies"><%=this.GetLocalResourceObject("chkCookies")%></label></span> <%} %>
<%if (Configurations.UserOptions.HttpCompression.Changeable){ %><span class="ASPXOpt"><input id="chkCompression" type="checkbox" onclick="_Page_SaveOptions()" /><label for="chkCompression"><%=this.GetLocalResourceObject("chkCompression")%></label></span> <%} %>
<%if (Configurations.UserOptions.ImageCompressor.Changeable&&Configurations.ImageCompressor.Enabled){ %><span class="ASPXOpt"><input id="chkImgCompressor" type="checkbox" onclick="_Page_SaveOptions()" /><label for="chkImgCompressor"><%=this.GetLocalResourceObject("chkImgCompressor")%></label></span> <%} %>
<a asproxydone="2" id="lnkMoreOpt" href="javascript:void(0);" onclick="toggleOpt(this);"><%=this.GetLocalResourceObject("lnkMoreOptions")%>...<small>&gt;</small></a>
</div>
<div id="MoreOpts" style="display:none;">
<%if (Configurations.UserOptions.EncodeUrl.Changeable){ %><span class="ASPXOpt"><input id="chkEncodeUrl" type="checkbox" checked="checked" onclick="_Page_SaveOptions()"/><label for="chkEncodeUrl"><%=this.GetLocalResourceObject("chkEncodeUrl")%></label></span> <%} %>
<%if (Configurations.UserOptions.Frames.Changeable){ %><span class="ASPXOpt"><input id="chkFrames" type="checkbox" checked="checked" onclick="_Page_SaveOptions()"/><label for="chkFrames"><%=this.GetLocalResourceObject("chkFrames")%></label></span> <%} %>
<%if (Configurations.UserOptions.PageTitle.Changeable){ %><span class="ASPXOpt"><input id="chkPageTitle" type="checkbox" checked="checked" onclick="_Page_SaveOptions()" /><label for="chkPageTitle"><%=this.GetLocalResourceObject("chkPageTitle")%></label></span> <%} %>
<%if (Configurations.UserOptions.SubmitForms.Changeable){ %><span class="ASPXOpt"><input id="chkForms" type="checkbox" checked="checked" onclick="_Page_SaveOptions()" /><label for="chkForms"><%=this.GetLocalResourceObject("chkForms")%></label></span> <%} %>
<%if (Configurations.UserOptions.RemoveObjects.Changeable){ %><span class="ASPXOpt"><input id="chkRemoveObjects" type="checkbox" checked="checked" onclick="_Page_SaveOptions()" /><label for="chkRemoveObjects"><%=this.GetLocalResourceObject("chkRemoveObjects")%></label></span> <%} %>
<%if (Configurations.UserOptions.Links.Changeable){ %><span class="ASPXOpt"><input id="chkProcessLinks" type="checkbox" checked="checked" onclick="_Page_SaveOptions()" /><label for="chkProcessLinks"><%=this.GetLocalResourceObject("chkProcessLinks")%></label></span> <%} %>
<%if (Configurations.UserOptions.Images.Changeable){ %><span class="ASPXOpt"><input id="chkDisplayImages" type="checkbox" checked="checked" onclick="_Page_SaveOptions()" /><label for="chkDisplayImages"><%=this.GetLocalResourceObject("chkDisplayImages")%></label></span> <%} %>
<%if (Configurations.UserOptions.TempCookies.Changeable){ %><span class="ASPXOpt"><input id="chkTempCookies" type="checkbox" checked="checked" onclick="_Page_SaveOptions()" /><label for="chkTempCookies"><%=this.GetLocalResourceObject("chkTempCookies")%></label></span> <%} %>
</div>

<script type="text/javascript"><!--
    google_ad_client = "ca-pub-0958480561228656";
    /* web����4 */
    google_ad_slot = "9261729192";
    google_ad_width = 728;
    google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>

<script type="text/javascript"><!--
    google_ad_client = "ca-pub-0958480561228656";
    /* web����5 */
    google_ad_slot = "1010984999";
    google_ad_width = 200;
    google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
</div>
<script type="text/javascript" asproxydone="2">
_Page_Initialize();
_Page_SetOptions();
// iframed, hide the form
if(window.self != window.top)document.getElementById('ASProxyFormBlock').style.display='none';
</script>

<%if (_HasError){ %>
<div title="Error message" style="text-align:center;color:Red;font-weight:bold;font-family:Tahoma;font-size:10pt;">
<%=_ErrorMessage%></div>
<%} %>
<noscript style="color:Maroon;font-weight:bold;font-family:Tahoma;font-size:10pt;"><%=this.GetLocalResourceObject("JsIsDisabled")%></noscript>
</div></body>
</html>

<div style="position: relative; left: 0px; top: 5px; width: 100%; height: auto;">
<%=_ExtraCodesForBody%>
<%=_ResponseContent%>
</div>
