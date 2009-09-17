using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

using TCG.Utils;

namespace TCG.Data
{
    public class DBHandlers
    {

        /// <summary>
        /// 根据设定条件查找查询结果，并分页
        /// </summary>
        /// <param name="errText">错误信息</param>
        /// <param name="tableName">表名</param>
        /// <param name="arrShowField">需要返回显示的字段集</param>
        /// <param name="strConditionField">查询条件字段集(为满足in的查询，有hashtable改称string)</param>
        /// <param name="arrSortField">排序字段集</param>
        /// <param name="pageSize">每页显示的记录个数</param>
        /// <param name="page">要显示的页面编号</param>
        /// <param name="ads_out_Data">返回的结果数据集</param>
        /// <returns>成功返回1 失败小于0</returns>

        public static int GetPage(PageSearchItem sItem,Connection conn, ref int curPage, ref int pageCount, ref int counts, ref DataSet ads_out_Data)
        {
            //生成需要显示的字段集的SQL文
            StringBuilder strShowField = new StringBuilder();
            for (int i = 0; i < sItem.arrShowField.Count; i++)
            {
                if (i == 0)
                {
                    strShowField.Append(sItem.arrShowField[i]);
                }
                else
                {
                    strShowField.Append(", " + sItem.arrShowField[i]);
                }
            }


            //生成排序SQL文
            StringBuilder strSortField = new StringBuilder();
            for (int i = 0; i < sItem.arrSortField.Count; i++)
            {
                if (i == 0)
                {
                    strSortField.Append(sItem.arrSortField[i]);
                }
                else
                {
                    strSortField.Append(", " + sItem.arrSortField[i]);
                }
            }

            SqlParameter sp0 = new SqlParameter("@tblName", SqlDbType.NVarChar, 50); sp0.Value = sItem.tableName;
            SqlParameter sp1 = new SqlParameter("@fldName", SqlDbType.NVarChar, 500); sp1.Value = strShowField.ToString();
            SqlParameter sp2 = new SqlParameter("@fldSort", SqlDbType.NVarChar, 200); sp2.Value = strSortField.ToString();
            SqlParameter sp3 = new SqlParameter("@strCondition", SqlDbType.NVarChar, 1000); sp3.Value = sItem.strCondition;
            SqlParameter sp4 = new SqlParameter("@pageSize", SqlDbType.Int, 4); sp4.Value = sItem.pageSize.ToString();
            SqlParameter sp5 = new SqlParameter("@page", SqlDbType.Int, 4); sp5.Value = sItem.page.ToString();

            SqlParameter sp6 = new SqlParameter("@curpage", SqlDbType.Int, 4); sp6.Direction = ParameterDirection.Output;
            SqlParameter sp7 = new SqlParameter("@pageCount", SqlDbType.Int, 4); sp7.Direction = ParameterDirection.Output;
            SqlParameter sp8 = new SqlParameter("@counts", SqlDbType.Int, 4); sp8.Direction = ParameterDirection.Output;
            SqlParameter sp9 = new SqlParameter("@retval", SqlDbType.Int, 4); sp9.Direction = ParameterDirection.Output;

            string[] reValues = conn.GetDataSet("SP_TCG_GetPage", new SqlParameter[] { sp0, sp1, sp2, sp3, sp4, sp5, sp6, sp7, sp8, sp9 }, new int[] { 6, 7, 8, 9 }, ref ads_out_Data);
            if(reValues!=null)
            {
                //总记录数
                counts = Bases.ToInt(reValues[2]);
                //总页数
                pageCount = Bases.ToInt(reValues[1]);
                //当前页数
                curPage = Bases.ToInt(reValues[0]);

                return (int)Convert.ChangeType(reValues[3], typeof(int));
            }

            return -19000000;
        }
    }
}
