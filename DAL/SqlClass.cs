using System;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;
using System.Data.SqlClient;

namespace DAL
{
    public class SqlClass
    {
        public static SqlCommand ExecuteTransaction(string Query, SqlParameter[] param,
                                    SqlConnection con, SqlTransaction Tran)
        {
            string Q = Query;
            SqlCommand cmd = new SqlCommand(Query, con, Tran);
            if (param != null)
            {
                foreach (SqlParameter p in param)
                {
                    cmd.Parameters.Add(p);
                }
            }
            return cmd;
        }

        public static List<T> ExecuteNonQuery<T> (string Query, List<T> list, Func<SqlConnection, List<T>> fun, SqlParameter[] param) where T: class
        {
            string CS = ConfigurationManager.ConnectionStrings["TestDB"].ConnectionString;
            using (SqlConnection con = new SqlConnection(CS))
            {
                string Q = Query;
                SqlCommand cmd = new SqlCommand(Query, con);
                if (param != null)
                {
                    foreach (SqlParameter p in param)
                    {
                        cmd.Parameters.Add(p);
                    }
                }
                con.Open();
                cmd.ExecuteNonQuery();
                list.Clear();
                return fun(con);
            }
        }

        public static List<T> ExecuteNonQuery<T>(List<T> list, Func<SqlConnection, List<T>> fun, SqlConnection con) where T : class
        {
            list.Clear();
            return fun(con);         
        }

        public static DataSet ReturnDataSet(string Query)
        {
            DataSet ds = new DataSet();
            string CS = ConfigurationManager.ConnectionStrings["TestDB"].ConnectionString;
            using (SqlConnection con = new SqlConnection(CS))
            {
                using (SqlDataAdapter da = new SqlDataAdapter(Query, con))
                {
                    da.Fill(ds);
                }
            }
            return ds;
        }

        public static void ExecuteNonQuery(string Query, SqlParameter[] param)
        {
            string CS = ConfigurationManager.ConnectionStrings["TestDB"].ConnectionString;
            using (SqlConnection con = new SqlConnection(CS))
            {
                string Q = Query;
                SqlCommand cmd = new SqlCommand(Query, con);
                if (param != null)
                {
                    foreach (SqlParameter p in param)
                    {
                        cmd.Parameters.Add(p);
                    }
                }
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }
}
