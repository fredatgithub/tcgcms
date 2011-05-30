﻿using System;
using System.Data;
using System.IO;
using System.Configuration;
using System.Collections.Generic;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using System.Text;
using System.Text.RegularExpressions;

using TCG.Utils;
using TCG.Controls.HtmlControls;


using TCG.Data;
using TCG.Handlers;
using TCG.Entity;


public partial class resources_resourceshandlers : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        //检测管理员登录
        base.handlerService.manageService.adminHandlers.CheckAdminLogin();
        this.ltfileclassid.Text = ConfigServiceEx.baseConfig["NewsFileClass"];

        string skinid = objectHandlers.Get("skinid");
        skinid = string.IsNullOrEmpty(skinid) ? ConfigServiceEx.DefaultSkinId : skinid;
        this.iSkinId.Value =  skinid;

        if (!Page.IsPostBack)
        {
            int newsid = objectHandlers.ToInt(objectHandlers.Get("newsid"));
            string categorieid = objectHandlers.Get("iClassId");

            this.scp.Items.Clear();
            this.scp.Items.Add(new ListItem("请选择属性分类", "0"));
            Dictionary<string, EntityBase> allpc = base.handlerService.skinService.propertiesHandlers.GetPropertiesCategoriesEntityBySkinId(skinid);
            if (allpc != null && allpc.Count != 0)
            {
                foreach (KeyValuePair<string, EntityBase> keyvalue in allpc)
                {
                    PropertiesCategorie template = (PropertiesCategorie)keyvalue.Value;
                    this.scp.Items.Add(new ListItem(template.CategoriePropertiesName, template.Id));
                }
            }

            if (newsid==0)
            {
                this.iClassId.Value = categorieid;
                this.iSpeciality.Value = "0";
                return;
            }

            Resources item = base.handlerService.resourcsService.resourcesHandlers.GetResourcesById(newsid);
            this.iClassId.Value = item.Categorie.Id.ToString();
            this.nid.Text = item.Id + "&t=" + DateTime.Now.ToString();

            this.iTitle.Value = item.vcTitle;
            this.iUrl.Value = item.vcUrl;
            this.iKeyWords.Value = item.vcKeyWord;
            this.taContent.Value = item.vcContent;
            this.iAuthor.Value = item.vcAuthor;
            this.work.Value = "MdyNews";
            this.iNewsId.Value = item.Id.ToString();
            this.iSpeciality.Value = item.vcSpeciality;
            this.iSmallImg.Value = item.vcSmallImg;
            this.iBigImg.Value = item.vcBigImg;
            this.iTitleColor.Value = item.vcTitleColor;
            this.iStrong.Checked = (item.cStrong == "Y") ? true : false;
            this.iShortContent.Value = item.vcShortContent;
            this.scp.Value = item.PropertiesCategorieId.ToString();
            this.cid.Text = item.PropertiesCategorieId.ToString() + "&t=" + DateTime.Now.ToString();
            item = null;
        }
        else
        {
            string work = objectHandlers.Post("work");
            bool ismdy = false;
            switch (work)
            {
                case "AddNew":
                    ismdy = false;
                    break;
                case "MdyNews":
                    ismdy = true;
                    break;
            }

            this.NewsManage(ismdy);
        }
   }

    private void NewsManage(bool ismdy)
    {
        string categorieid = objectHandlers.Post("iClassId");
        Resources item = new Resources();
        
        int pcid = objectHandlers.ToInt(objectHandlers.Post("scp"));
        bool delrpold = false;
        int oldrpoid = 0;
        if (ismdy)
        {
            item = base.handlerService.resourcsService.resourcesHandlers.GetResourcesById(objectHandlers.ToInt(objectHandlers.Post("iNewsId")));
            if (item.PropertiesCategorieId != pcid)
            {
                delrpold = true;
                oldrpoid = item.PropertiesCategorieId;
            }
        }
        else
        {
            item.cChecked = "N";
            item.cCreated = "N";
            item.Id = (base.handlerService.resourcsService.resourcesHandlers.GetMaxResourceId() + 1).ToString();
        }

        item.vcTitle = objectHandlers.Post("iTitle");
        item.vcUrl = objectHandlers.Post("iUrl");
        item.vcContent = objectHandlers.Post("taContent");
        item.vcAuthor = objectHandlers.Post("iAuthor");
        item.vcKeyWord = objectHandlers.Post("iKeyWords");

        if (item.Categorie.Id != categorieid)
        {
            item.Categorie = base.handlerService.skinService.categoriesHandlers.GetCategoriesById(categorieid);
        }

        item.vcSpeciality = objectHandlers.Post("iSpeciality");
        item.vcBigImg = objectHandlers.Post("iBigImg");
        item.vcSmallImg = objectHandlers.Post("iSmallImg");
        item.vcTitleColor = objectHandlers.Post("sTitleColor");
        item.cStrong = objectHandlers.Post("iStrong");
        string s = objectHandlers.Post("iShortContent");
        item.vcShortContent = string.IsNullOrEmpty(s)? objectHandlers.Left(objectHandlers.Post("iShortContent"),100):s;
        item.PropertiesCategorieId = pcid;

        if (string.IsNullOrEmpty(item.vcTitle))
        {
            base.AjaxErch(-1000000039,"");
            return;
        }

        if (string.IsNullOrEmpty(item.vcKeyWord))
        {
            base.AjaxErch(-1000000043,"");
            return;
        }


        if (string.IsNullOrEmpty(item.Categorie.Id))
        {
            base.AjaxErch(-1000000056,"");
            return;
        }

        item.vcEditor = base.adminInfo.vcAdminName;

        string filepath = "";
        string errText = string.Empty;
        int rtn = 0;

        try
        {
            if (!ismdy)
            {
                rtn = base.handlerService.resourcsService.resourcesHandlers.CreateResources(item);
            }
            else
            {
                rtn = base.handlerService.resourcsService.resourcesHandlers.UpdateResources(item);
                if (delrpold)
                {
                    rtn = base.handlerService.resourcsService.resourcesHandlers.DelResourcesProperties(item.Id);
                }
            }
            
            if (rtn == 1)
            {

                foreach (string key in Request.Form.AllKeys)
                {
                    if (key.IndexOf("rpvalue_") > -1 && !string.IsNullOrEmpty(objectHandlers.Post(key)))
                    {
                        string[] keys = key.Split('_');
                        ResourceProperties rps = new ResourceProperties();
                        rps.Id = objectHandlers.Post("rpid_" + keys[1]);
                        rps.PropertieName = objectHandlers.Post("ptname_" + keys[1]);
                        rps.ResourceId = item.Id;
                        rps.PropertieValue = objectHandlers.Post("rpvalue_" + keys[1]);
                        rps.PropertieId = objectHandlers.ToInt(objectHandlers.Post("cpid_" + keys[1]));
                        rps.iOrder = objectHandlers.ToInt(objectHandlers.Post("rporder_" + keys[1]));
                        rtn = base.handlerService.resourcsService.resourcesHandlers.ResourcePropertiesManage(base.adminInfo, rps);
                    }
                }
            }

            if (item.cChecked == "Y")
            {
                rtn = base.handlerService.tagService.CreateResourcHtmlById(ref errText, objectHandlers.ToInt(item.Id));
            }
        }
        catch (Exception ex)
        {
            base.ajaxdata = "{state:false,message:\"" + objectHandlers.JSEncode(ex.Message.ToString()) + "\"}";
            base.AjaxErch(base.ajaxdata);
            return;
        }

        if (ismdy)
        {
            base.AjaxErch(rtn, "文章修改成功！");
        }
        else
        {
            base.AjaxErch(rtn, "文章添加成功，请继续添加！", "NewsAddPostBack()");
        }
    }
}