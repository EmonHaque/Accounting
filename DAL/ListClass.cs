using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Reflection;

namespace DAL
{
    public class ListClass
    {
        public List<MainProduct> MainProductList(SqlConnection con)
        {
            List<MainProduct> MainL = new List<MainProduct>();

            string Query = "SELECT MId, InvCCode, MName FROM MProducts";
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    MainProduct mh = new MainProduct();
                    mh.MainId = Convert.ToInt32(rd["MId"]);
                    mh.InventoryCode = Convert.ToInt32(rd["InvCCode"]);
                    mh.MainName = rd["MName"].ToString();
                    MainL.Add(mh);
                }
                rd.Close();
            }
            return MainL;
        }

        public List<GeneralProduct> GeneralProductList(SqlConnection con)
        {
            List<GeneralProduct> MainL = new List<GeneralProduct>();

            string Query = "SELECT GId, MId, InvCCode, GName, ConToLoose FROM GProducts";
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    GeneralProduct mh = new GeneralProduct();
                    mh.GeneralId = Convert.ToInt32(rd["GId"]);
                    mh.MainId = Convert.ToInt32(rd["MId"]);
                    mh.InventoryCode = Convert.ToInt32(rd["InvCCode"]);
                    mh.GeneralName = rd["GName"].ToString();
                    mh.LooseConversionFactor = rd["ConToLoose"] == DBNull.Value ? 0 : Convert.ToDouble(rd["ConToLoose"]);
                    MainL.Add(mh);
                }
                rd.Close();
            }
            return MainL;
        }

        public List<MainHeads> MainList(SqlConnection con)
        {
            List<MainHeads> MainL = new List<MainHeads>();

            string Query = "SELECT MCODE, MHOA FROM MHeads";
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    MainHeads mh = new MainHeads();
                    mh.MainCode = Convert.ToInt32(rd["MCode"]);
                    mh.MainName = rd["MHOA"].ToString();
                    MainL.Add(mh);
                }
                rd.Close();
            }
            return MainL;
        }

        public List<GeneralHeads> GeneralList(SqlConnection con)
        {
            List<GeneralHeads> GeneralL = new List<GeneralHeads>();
            string Query = "SELECT GCODE, MCODE, GHOA FROM GHeads";
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    GeneralHeads gh = new GeneralHeads();
                    gh.GeneralCode = Convert.ToInt32(rd["GCode"]);
                    gh.MainCode = Convert.ToInt32(rd["MCode"]);
                    gh.GeneralName = rd["GHOA"].ToString();
                    GeneralL.Add(gh);
                }
                rd.Close();
            }
            return GeneralL;
        }

        public List<ControlHeads> ControlList(SqlConnection con)
        {
            List<ControlHeads> ControlL = new List<ControlHeads>();
            string Query = "SELECT CCode, GCODE, MCODE, CHOA FROM CHeads";
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    ControlHeads ch = new ControlHeads();
                    ch.ControlCode = Convert.ToInt32(rd["CCode"]);
                    ch.GeneralCode = Convert.ToInt32(rd["GCode"]);
                    ch.MainCode = Convert.ToInt32(rd["MCode"]);
                    ch.ControlName = rd["CHOA"].ToString();
                    ControlL.Add(ch);
                }
                rd.Close();
            }
            return ControlL;
        }

        public List<FixedAssets> FixedAssetsControlList(SqlConnection con)
        {
            List<FixedAssets> ControlL = new List<FixedAssets>();
            string Query = "SELECT CCode, ItemCode, Depreciation, ItemName, [Description] FROM FixedAssetsItem";
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    FixedAssets ch = new FixedAssets();
                    ch.CCode = Convert.ToInt32(rd["CCode"]);
                    ch.ItemCode = Convert.ToInt32(rd["ItemCode"]);
                    ch.DepreciationRate = rd["Depreciation"] == DBNull.Value ? 0 : Convert.ToDouble(rd["Depreciation"]);
                    ch.ItemName = rd["ItemName"].ToString();
                    ch.Description = rd["Description"].ToString();
                    ControlL.Add(ch);
                }
                rd.Close();
            }
            return ControlL;
        }

        public List<FixedAssetsItem> FixedAssetsItemList(SqlConnection con)
        {
            List<FixedAssetsItem> ControlL = new List<FixedAssetsItem>();
            string Query = "SELECT [Date], QtyIn, QtyOut, QtyInAmt, QtyOutAmt, AmountSold, LotNo, CCode, ItemCode, AIN, PartyId FROM FixedAssets";
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    FixedAssetsItem ch = new FixedAssetsItem();
                    ch.Date = Convert.ToDateTime(rd["Date"]);
                    ch.CCode = Convert.ToInt32(rd["CCode"]);
                    ch.ItemCode = Convert.ToInt32(rd["ItemCode"]);
                    ch.AIN = (long) (rd["AIN"]);
                    ch.QtyIn = rd["QtyIn"] == DBNull.Value ? 0 : Convert.ToDouble(rd["QtyIn"]);
                    ch.QtyOut = rd["QtyOut"] == DBNull.Value ? 0 : Convert.ToDouble(rd["QtyOut"]);
                    ch.AmountIn = rd["QtyInAmt"] == DBNull.Value ? 0 : Convert.ToDouble(rd["QtyInAmt"]);
                    ch.AmountOut = rd["QtyOutAmt"] == DBNull.Value ? 0 : Convert.ToDouble(rd["QtyOutAmt"]);
                    ch.AmountSold = rd["AmountSold"] == DBNull.Value ? 0 : Convert.ToDouble(rd["AmountSold"]);
                    ch.LotNo = Convert.ToInt32(rd["LotNo"]);
                    ch.PartyId = rd["PartyId"] == DBNull.Value ? 0 : Convert.ToInt32(rd["PartyId"]);
                    ControlL.Add(ch);
                }
                rd.Close();
            }
            return ControlL;
        }

        public List<SubHeads> SubHeadList(SqlConnection con)
        {
            List<SubHeads> ControlL = new List<SubHeads>();
            string Query = "SELECT Id, CCode, SubHeads FROM OtherNotes";
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    SubHeads ch = new SubHeads();
                    ch.SubCode = Convert.ToInt32(rd["Id"]);
                    ch.ControlCode = Convert.ToInt32(rd["CCode"]);
                    ch.Head = rd["SubHeads"].ToString();
                    ControlL.Add(ch);
                }
                rd.Close();
            }
            return ControlL;
        }

        public List<Departments> DepartmentList(SqlConnection con)
        {
            List<Departments> ControlL = new List<Departments>();
            string Query = "SELECT DeptId, DeptName FROM Departments";
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    Departments ch = new Departments();
                    ch.DeptId = Convert.ToInt32(rd["DeptId"]);
                    ch.DeptName = rd["DeptName"].ToString();
                    ControlL.Add(ch);
                }
                rd.Close();
            }
            return ControlL;
        }

        public List<Employees> EmployeeList(SqlConnection con)
        {
            List<Employees> ControlL = new List<Employees>();
            string Query = "SELECT EmpId, DeptId, Designation, Name, Address, ContactNo, Salary FROM Employees";
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    Employees ch = new Employees();
                    ch.EmpId = Convert.ToInt32(rd["EmpId"]);
                    ch.DeptId = Convert.ToInt32(rd["DeptId"]);
                    ch.Designation = rd["Designation"].ToString();
                    ch.Name = rd["Name"].ToString();
                    ch.Address = rd["Address"].ToString();
                    ch.ContactNo = rd["ContactNo"].ToString();
                    ch.Salary = Convert.ToInt32(rd["Salary"]);
                    ControlL.Add(ch);
                }
                rd.Close();
            }
            return ControlL;
        }

        public List<Customers> CustomerList(SqlConnection con)
        {
            List<Customers> ControlL = new List<Customers>();
            string Query = "SELECT CustId, Name, Address, ContactNo FROM Customers";
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    Customers ch = new Customers();
                    ch.CustId = Convert.ToInt32(rd["CustId"]);
                    ch.Name = rd["Name"].ToString();
                    ch.Address = rd["Address"].ToString();
                    ch.ContactNo = rd["ContactNo"].ToString();
                    ControlL.Add(ch);
                }
                rd.Close();
            }
            return ControlL;
        }

        public List<Suppliers> SupplierList(SqlConnection con)
        {
            List<Suppliers> ControlL = new List<Suppliers>();
            string Query = "SELECT SupId, Name, Address, ContactNo FROM Suppliers";
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    Suppliers ch = new Suppliers();
                    ch.SupId = Convert.ToInt32(rd["SupId"]);
                    ch.Name = rd["Name"].ToString();
                    ch.Address = rd["Address"].ToString();
                    ch.ContactNo = rd["ContactNo"].ToString();
                    ControlL.Add(ch);
                }
                rd.Close();
            }
            return ControlL;
        }

        public List<Owners> OwnerList(SqlConnection con)
        {
            List<Owners> ControlL = new List<Owners>();
            string Query = "SELECT OwnId, CCode, Name, Address, ContactNo FROM Owners";
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    Owners ch = new Owners();
                    ch.OwnId = Convert.ToInt32(rd["OwnId"]);
                    ch.ControlCode = Convert.ToInt32(rd["CCode"]);
                    ch.Name = rd["Name"].ToString();
                    ch.Address = rd["Address"].ToString();
                    ch.ContactNo = rd["ContactNo"].ToString();
                    ControlL.Add(ch);
                }
                rd.Close();
            }
            return ControlL;
        }

        public List<Others> OtherList(SqlConnection con)
        {
            List<Others> ControlL = new List<Others>();
            string Query = "SELECT OthId, Name, Address, ContactNo FROM Others";
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    Others ch = new Others();
                    ch.OthersId = Convert.ToInt32(rd["OthId"]);
                    ch.Name = rd["Name"].ToString();
                    ch.Address = rd["Address"].ToString();
                    ch.ContactNo = rd["ContactNo"].ToString();
                    ControlL.Add(ch);
                }
                rd.Close();
            }
            return ControlL;
        }

        public List<Banks> BankList(SqlConnection con)
        {
            List<Banks> ControlL = new List<Banks>();
            string Query = "SELECT BankId, Name, Branch, AccountType, AccountNo FROM Banks";
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    Banks ch = new Banks();
                    ch.BankId = Convert.ToInt32(rd["BankId"]);
                    ch.Name = rd["Name"].ToString();
                    ch.Branch = rd["Branch"].ToString();
                    ch.AccountType = rd["AccountType"].ToString();
                    ch.AccountNo = rd["AccountNo"].ToString();
                    ch.Head = rd["Name"].ToString() + " " + rd["AccountNo"].ToString();
                    ControlL.Add(ch);
                }
                rd.Close();
            }
            return ControlL;
        }

        public List<Government> GovtList(SqlConnection con)
        {
            List<Government> ControlL = new List<Government>();
            string Query = "SELECT GovtId, DeptName, Zone, AccountNo FROM Govt";
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    Government ch = new Government();
                    ch.GovtId = Convert.ToInt32(rd["GovtId"]);
                    ch.Department = rd["DeptName"].ToString();
                    ch.Zone = rd["Zone"].ToString();
                    ch.AccountNo = rd["AccountNo"].ToString();
                    ControlL.Add(ch);
                }
                rd.Close();
            }
            return ControlL;
        }

        public List<Parties4SubLedger> SubParties(SqlConnection con)
        {
            List<Parties4SubLedger> list = new List<Parties4SubLedger>();
            using (SqlCommand cmd = new SqlCommand("PartyList4SubLedger", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    Parties4SubLedger ch = new Parties4SubLedger();
                    ch.ControlCode = Convert.ToInt32(rd["CCode"]);
                    ch.PartyId = Convert.ToInt32(rd["PartyId"]);
                    ch.PartyName = rd["Name"].ToString();
                    list.Add(ch);
                }
                rd.Close();
            }
            return list;
        }

        public List<Products4SubLedger> SubProducts(SqlConnection con)
        {
            List<Products4SubLedger> list = new List<Products4SubLedger>();
            using (SqlCommand cmd = new SqlCommand("ProductList4SubLedger", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    Products4SubLedger ch = new Products4SubLedger();
                    ch.ControlCode = Convert.ToInt32(rd["CCode"]);
                    ch.ProductCode = Convert.ToInt32(rd["ProId"]);
                    ch.ProductName = rd["GName"].ToString();
                    list.Add(ch);
                }
                rd.Close();
            }    
            return list;
        }

        public List<YearMonth> MonthYear(SqlConnection con)
        {
            List<YearMonth> ControlL = new List<YearMonth>();
            string Query = "SELECT DISTINCT DATEPART(YEAR,[Date]) AS [Year], DATEPART(MONTH,[Date]) AS [Month] from TransTable";
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    YearMonth ch = new YearMonth();
                    ch.Year = Convert.ToInt32(rd["Year"]);
                    ch.MonthNumber = Convert.ToInt32(rd["Month"]);
                    ControlL.Add(ch);
                }
                rd.Close();
            }

            foreach (var item in ControlL)
            {
                switch (item.MonthNumber)
                {
                    case 1: item.Month = "January"; break;
                    case 2: item.Month = "February"; break;
                    case 3: item.Month = "March"; break;
                    case 4: item.Month = "April"; break;
                    case 5: item.Month = "May"; break;
                    case 6: item.Month = "June"; break;
                    case 7: item.Month = "July"; break;
                    case 8: item.Month = "August"; break;
                    case 9: item.Month = "September"; break;
                    case 10: item.Month = "October"; break;
                    case 11: item.Month = "November"; break;
                    default: item.Month = "December"; break;
                }
            }
            return ControlL;
        }

        public List<Payable> ReturnSalaryPayable(SqlConnection con, int month, int year)
        {
            string MonthYear = month.ToString() + "-" + year;
            List<Payable> ControlL = new List<Payable>();
            string Query = "SELECT CPartyId, Amount from TransTable "+
                           "WHERE OtherSpec = '" +MonthYear+ "' AND CCCode = 40104";
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    Payable ch = new Payable();
                    ch.PartyId = Convert.ToInt32(rd[0]);
                    ch.AmountPayable = Convert.ToDouble(rd[1]);
                    ControlL.Add(ch);
                }
                rd.Close();
            }
            return ControlL;
        }

        public List<Paid> ReturnSalaryPaid(SqlConnection con, int month, int year)
        {
            string MonthYear = month.ToString() + "-" + year;
            List<Paid> ControlL = new List<Paid>();
            string Query = "SELECT DPartyId, Amount from TransTable "+
                            "WHERE OtherSpec = '" + MonthYear + "' AND DCCode = 40104";
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    Paid ch = new Paid();
                    ch.PartyId = Convert.ToInt32(rd[0]);
                    ch.AmountPaid = Convert.ToDouble(rd[1]);
                    ControlL.Add(ch);
                }
                rd.Close();
            }
            return ControlL;
        }

        public List<DividendPayable> DividendPayable(SqlConnection con, int payableCode, string subCodes, string otherSpec)
        {
            List<DividendPayable> ControlL = new List<DividendPayable>();
            string Query = @"SELECT CCCode, CPartyId, Amount, SubHeads, OtherSpec from TransTable 
                           WHERE OtherSpec IN(" + otherSpec + ") AND CCCode = "+ payableCode +" AND SubHeads IN(" + subCodes + ")";
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    DividendPayable ch = new DividendPayable();
                    ch.ControlCode = Convert.ToInt32(rd[0]);
                    ch.PartyId = Convert.ToInt32(rd[1]);
                    ch.AmountPayable = Convert.ToDouble(rd[2]);
                    ch.SubHead = Convert.ToInt32(rd[3]);
                    ch.OtherSpec = rd[4].ToString();
                    ControlL.Add(ch);
                }
                rd.Close();
            }
            return ControlL;
        }

        public List<DividendPaid> DividendPaid(SqlConnection con, int payableCode, string subCodes, string otherSpec)
        {
            List<DividendPaid> ControlL = new List<DividendPaid>();
            string Query = @"SELECT DCCode, DPartyId, Amount, SubHeads, OtherSpec from TransTable 
                           WHERE OtherSpec IN(" + otherSpec + ") AND DCCode = " + payableCode + " AND SubHeads IN(" + subCodes + ")";
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    DividendPaid ch = new DividendPaid();
                    ch.ControlCode = Convert.ToInt32(rd[0]);
                    ch.PartyId = Convert.ToInt32(rd[1]);
                    ch.AmountPaid = Convert.ToDouble(rd[2]);
                    ch.SubHead = Convert.ToInt32(rd[3]);
                    ch.OtherSpec = rd[4].ToString();
                    ControlL.Add(ch);
                }
                rd.Close();
            }
            return ControlL;
        }

        public List<T> CreateList<T>(SqlConnection con, string Query, List<T> list) where T : class, new()
        {
            using (SqlCommand cmd = new SqlCommand(Query, con))
            {
                SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    var obj = new T();
                    PropertyInfo[] properties = typeof(T).GetProperties();
                    int i = 0;
                    foreach (var property in properties)
                    {
                        property.SetValue((T)obj, reader[i], null);
                        i++;
                    }
                    list.Add(obj);
                }
                reader.Close();
            }
            return list;
        }

        public class Months
        {
            public int MonthNo { get; set; }
            public string MonthName { get; set; }
            public List<Months> MonthLists { get { return GetList(); } }
            private List<Months> GetList()
            {
                List<Months> m = new List<Months>();
                for (int i = 1; i < 13; i++)
                {
                    Months item = new Months();
                    switch (i)
                    {
                        case 1: item.MonthName = "January"; item.MonthNo = i; break;
                        case 2: item.MonthName = "February"; item.MonthNo = i; break;
                        case 3: item.MonthName = "March"; item.MonthNo = i; break;
                        case 4: item.MonthName = "April"; item.MonthNo = i; break;
                        case 5: item.MonthName = "May"; item.MonthNo = i; break;
                        case 6: item.MonthName = "June"; item.MonthNo = i; break;
                        case 7: item.MonthName = "July"; item.MonthNo = i; break;
                        case 8: item.MonthName = "August"; item.MonthNo = i; break;
                        case 9: item.MonthName = "September"; item.MonthNo = i; break;
                        case 10: item.MonthName = "October"; item.MonthNo = i; break;
                        case 11: item.MonthName = "November"; item.MonthNo = i; break;
                        default: item.MonthName = "December"; item.MonthNo = i; break;
                    }
                    m.Add(item);
                }
                return m;
            }

        }
    }
}

