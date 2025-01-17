﻿using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


using TCG.Utils;
using TCG.Release;

namespace TCG.CMS.WebUi
{

    public partial class Manage_Version_Ver : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                string action = objectHandlers.Get("action");
                switch (action)
                {
                    case "IsHaveHigherVer":
                        this.IsHigherVer();
                        break;
                }
            }
        }

        private void IsHigherVer()
        {
            string txt = string.Empty;
            if (Versions.HigherVersion == null)
            {
                txt = "{state:false}";
            }
            else
            {
                txt = "{state:true,version:'" + Versions.GetVerStr(Versions.HigherVersion.Ver) + "',logurl:'" +
                    Versions.HigherVersion.LogUrl + "'}";
            }

            base.AjaxErch(txt);
        }
    }
}