﻿using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using TCG.Entity;
using TCG.Utils;

namespace TCG.Handlers
{
    public class FeedBackHandlers
    {
        public Dictionary<string, EntityBase> GeFeedBackListPager(ref int curPage, ref int pageCount, ref int count, int page, int pagesize, string order, string strCondition)
        {

            Dictionary<string, EntityBase> res = null;

            DataTable dt = DataBaseFactory.feedBackHandlers.GeFeedBackListPager(ref curPage, ref pageCount, ref count, page, pagesize, order, strCondition);

            if (dt != null && dt.Rows.Count > 0)
            {
                res = HandlersFactory.GetEntitysObjectFromTable(dt, typeof(FeedBack));
            }

            return res;
        }

        public int DelFeedBackById(Admin admininfo, string ids)
        {
            int rtn = HandlersFactory.adminHandlers.CheckAdminPower(admininfo);
            if (rtn < 0) return rtn;

            return DataBaseFactory.feedBackHandlers.DelFeedBackById(ids);
        }

        public int CreateFeedBack(FeedBack feedback)
        {

            if (string.IsNullOrEmpty(feedback.UserName))
            {
                return  -1000000901;
            }

            if (string.IsNullOrEmpty(feedback.SkinId))
            {
                return -1000000902;
            }

            if (string.IsNullOrEmpty(feedback.Tel))
            {
                return -1000000903;
            }

            if (string.IsNullOrEmpty(feedback.Content))
            {
                return -1000000904;
            }

            if (string.IsNullOrEmpty(feedback.Title))
            {
                return -1000000905;
            }

            if (string.IsNullOrEmpty(feedback.Email))
            {
                return -1000000906;
            }

            if (!objectHandlers.IsEmail(feedback.Email))
            {
                return -1000000907;
            }

            return DataBaseFactory.feedBackHandlers.CreateFeedBack(feedback);
        }
    }
}
