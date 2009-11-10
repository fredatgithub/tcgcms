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
using TCG.Pages;

using TCG.Data;
using TCG.Handlers;
using TCG.Entity;

using TCG.KeyWordSplit;

public partial class resources_resourceshandlers : adminMain
{

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            string newsid = objectHandlers.Get("newsid");
            string categorieid = objectHandlers.Get("iClassId");

            if (string.IsNullOrEmpty(newsid) || string.IsNullOrEmpty(categorieid))
            {
                this.iClassId.Value = categorieid;
                this.iSpeciality.Value = "0";
                return;
            }

            Resources item = base.handlerService.resourcsService.resourcesHandlers.GetResourcesById(newsid);
            this.iClassId.Value = item.Categorie.Id.ToString();

            this.iTitle.Value = item.vcTitle;
            this.iUrl.Value = item.vcUrl;
            this.iKeyWords.Value = item.vcKeyWord;
            this.iContent.Value = item.vcContent;
            this.iAuthor.Value = item.vcAuthor;
            this.work.Value = "MdyNews";
            this.iNewsId.Value = item.Id.ToString();
            this.iSpeciality.Value = item.vcSpeciality;
            this.iSmallImg.Value = item.vcSmallImg;
            this.iBigImg.Value = item.vcBigImg;
            this.iTitleColor.Value = item.vcTitleColor;
            this.iStrong.Checked = (item.cStrong == "Y") ? true : false;
            this.isContent.Value = item.vcShortContent;
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
                case "KeyWordLoad":
                    this.KeyWordLoad();
                    break;
            }

            this.NewsManage(ismdy);
        }
    }

    private void KeyWordLoad()
    {
        if (KeyWordTree.Root.ChildList.Count == 0)
        {
            string path = objectHandlers.MapPath(ConfigurationManager.ConnectionStrings["CKeyWordsFile"].ToString());
            if (File.Exists(path))
            {
                StreamReader Reader = new StreamReader(path, Encoding.Default);
                List<KeyWordTreeNode> tmpRoot = KeyWordTree.Root.ChildList;

                while (Reader.Peek() != -1)
                {
                    string[] tmp = Reader.ReadLine().ToLower().Split('|');
                    KeyWordTree.AddKeyWord(tmp[0]);

                }

                Reader.Close();
                Reader.Dispose();

                if (KeyWordTree.Root.ChildList.Count == 0)
                {
                    base.Finish();
                    base.AjaxErch("-1000000070");
                    return;
                }
            }
            else
            {
                base.Finish();
                base.AjaxErch("-1000000070");
                return;
            }
        }

        base.Finish();
        base.AjaxErch("加载关键词成功！");
    }

    private void NewsManage(bool ismdy)
    {
        string categorieid = objectHandlers.Post("iClassId");
        Resources item = base.handlerService.resourcsService.resourcesHandlers.GetResourcesById(objectHandlers.Post("iNewsId"));
        item.vcTitle = objectHandlers.Post("iTitle");
        item.vcUrl = objectHandlers.Post("iUrl");
        item.vcContent = objectHandlers.Post("iContent$content");
        item.vcAuthor = objectHandlers.Post("iAuthor");
        item.vcKeyWord = objectHandlers.Post("iKeyWords");
        item.Categorie = base.handlerService.skinService.categoriesHandlers.GetCategoriesById(categorieid);
      
        item.vcSpeciality = objectHandlers.Post("iSpeciality");
        item.vcBigImg = objectHandlers.Post("iBigImg");
        item.vcSmallImg = objectHandlers.Post("iSmallImg");
        item.vcTitleColor = objectHandlers.Post("sTitleColor");
        item.cStrong = objectHandlers.Post("iStrong");
        item.vcShortContent = objectHandlers.Post("isContent");

        if (string.IsNullOrEmpty(item.vcTitle))
        {
            base.AjaxErch("-1000000039");
            base.Finish();
            return;
        }

        if (string.IsNullOrEmpty(item.vcKeyWord))
        {
            base.AjaxErch("-1000000043");
            base.Finish();
            return;
        }


        if (string.IsNullOrEmpty(item.Categorie.Id))
        {
            base.AjaxErch("-1000000056");
            base.Finish();
            return;
        }

        item.cChecked = "Y";
        item.cCreated = "Y";
        item.vcEditor = base.adminInfo.vcAdminName;
        int newid = 0; string filepath = "";
        int rtn = 0;
        if (!ismdy)
        {
            rtn = base.handlerService.resourcsService.resourcesHandlers.CreateResources(item);
        }
        else
        {
            rtn = base.handlerService.resourcsService.resourcesHandlers.UpdateResources(item);
        }

        filepath = Server.MapPath("~" + item.vcFilePath);
        if (rtn == 1)
        {
            if (base.configService.baseConfig["IsReWrite"] != "True")
            {
                TCGTagHandlers tcgth = base.tagService.TCGTagHandlers;
                tcgth.Template = item.Categorie.ResourceTemplate.Content.Replace("_$Id$_", item.Id.ToString());
                tcgth.FilePath = filepath;
                tcgth.Replace(base.conn, base.configService.baseConfig);
            }

        }
        base.AjaxErch(rtn.ToString());
        base.Finish();
    }
}