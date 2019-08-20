using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using DAL;
using System.Configuration;
using System.Data.SqlClient;

namespace WPF
{
    public partial class AddProduct : UserControl
    {
        public AddProduct()
        {
            InitializeComponent();
            Storyboard sb = FindResource("ComeInProduct") as Storyboard;
            sb.Begin();

            PopulateComboBox();
            btnCreateMainCategory.Click += (s, e) => CreateControlLedgers();
            btnCreateSubCategory.Click += (s, e) => CreateMainProduct();
            btnCreateItem.Click += (s, e) => CreateGeneralProduct();

            BindCombos combo = new BindCombos();
            cboMainCategory2.DropDownClosed += (s, e) => combo.BindGeneralProductComboOfAddProduct(cboMainCategory2, cboSubCategory, MainWindow.mainProducts);
            cboMainCategory2.SelectionChanged += (s, e) => combo.BindGeneralProductComboOfAddProduct(cboMainCategory2, cboSubCategory, MainWindow.mainProducts);
        }

        public void PopulateComboBox()
        {
            BindCombos combo = new BindCombos();
            combo.BindMainProductComboOfAddProduct(cboMainCategory1, cboSubCategory, MainWindow.listControl, MainWindow.mainProducts);
            combo.BindMainProductComboOfAddProduct(cboMainCategory2, cboSubCategory, MainWindow.listControl, MainWindow.mainProducts);
        }

        public void CreateGeneralProduct()
        {
            string genProdName = txtNameItem.Text;
            string genProdDes = txtDescribeItem.Text;
            var Code = cboMainCategory2.SelectedValue;

            if (Code == null) Message.ShowMessage("Create Main Sector First!");
            else if (cboSubCategory.SelectedValue == null) Message.ShowMessage("Create a Category First!");
            else if (genProdName == string.Empty) Message.ShowMessage("Check field!");
            else if (genProdName.Length > 25) Message.ShowMessage("More than 25 Ccharacter is not supported!");
            else if (genProdDes.Length > 50) Message.ShowMessage("More than 50 Ccharacter is not supported!");
            else
            {
                List<GeneralProduct> genList = MainWindow.generalProducts.Where(x => x.GeneralName == genProdName && x.MainId == Convert.ToInt32(cboSubCategory.SelectedValue)).ToList();
                if (genList.Count != 0)
                {
                    Message.ShowMessage("Item exists!");
                    return;
                }
                else
                {
                    int invCode, mainCode, generalCode, maxGeneralCode;
                    generalCode = maxGeneralCode = 0;
                    invCode = Convert.ToInt32(Code);
                    mainCode = Convert.ToInt32(cboSubCategory.SelectedValue);
                    List<GeneralProduct> geneList = MainWindow.generalProducts.Where(x => x.MainId == mainCode).ToList();
                    if (geneList.Count != 0)
                    {
                        maxGeneralCode = geneList.Max(x => x.GeneralId);
                        if (maxGeneralCode == mainCode * 100 + 99)
                        {
                            Message.ShowMessage("99 Products have alreadey been added!");
                            return;
                        }
                        else
                        {
                            generalCode = maxGeneralCode + 1;
                        }
                    }
                    else
                    {
                        generalCode = mainCode * 100 + 1;
                    }

                    double conversionFact;
                    SqlParameter conFact;
                    if (txtConvertItem.Text != string.Empty)
                    {
                        double.TryParse(txtConvertItem.Text, out conversionFact);
                        if (conversionFact == 0)
                        {
                            Message.ShowMessage("Unexpected Factor!");
                            return;
                        }
                        else if (conversionFact < 0)
                        {
                            Message.ShowMessage("Negative Factor!");
                            return;
                        }
                        else
                        {
                            conFact = new SqlParameter("@ConToLoose", conversionFact);
                        }
                    }
                    else
                    {
                        conFact = new SqlParameter("@ConToLoose", DBNull.Value);
                    }
                    string Query = "INSERT INTO GProducts VALUES(@GId, @MId, @InvCCode, @GName, @ConToLoose, @Description)";
                    SqlParameter[] para =
                        {
                            new SqlParameter("@GId", generalCode),
                                    new SqlParameter("@MId", mainCode),
                                    new SqlParameter("@InvCCode", invCode),
                                    new SqlParameter("@GName", txtNameItem.Text),
                                    conFact,
                                    new SqlParameter("@Description", txtDescribeItem.Text)
                        };

                    try
                    {
                        ListClass lc = new ListClass();
                        MainWindow.generalProducts = SqlClass.ExecuteNonQuery(Query, MainWindow.generalProducts, lc.GeneralProductList, para);
                        Message.ShowMessage("Item has been added to List");
                        txtNameItem.Text = txtDescribeItem.Text = txtConvertItem.Text = string.Empty;
                    }
                    catch (Exception ex)
                    {
                        Message.ShowMessage(ex.ToString());
                    }
                }
            }
        }

        public void CreateMainProduct()
        {
            string mainProName = txtNameSubCategory.Text;
            string manProDes = txtDescribeSubCategory.Text;
            var selectedItem = cboMainCategory1.SelectedValue;

            if (selectedItem == null) Message.ShowMessage("Create Main Sector First!");
            else if (mainProName == string.Empty) Message.ShowMessage("Check field!");
            else if (mainProName.Length > 25) Message.ShowMessage("More than 25 Character is not supported");
            else if (manProDes.Length > 50) Message.ShowMessage("More than 50 Character is not supported");
            else
            {
                int invCode = Convert.ToInt32(selectedItem);
                List<MainProduct> productName = MainWindow.mainProducts.Where(x => x.MainName == txtNameSubCategory.Text && x.InventoryCode == invCode).ToList();
                if (productName.Count != 0)
                {
                    Message.ShowMessage("It exists!");
                }
                else
                {
                    int mainProductCode, maxProductCode;
                    mainProductCode = maxProductCode = 0;
                    List<MainProduct> prod = MainWindow.mainProducts.Where(x => x.InventoryCode == invCode).ToList();
                    if (prod.Count != 0)
                    {
                        maxProductCode = prod.Max(x => x.MainId);
                        if (maxProductCode != invCode * 100 + 99)
                        {
                            mainProductCode = maxProductCode + 1;
                        }
                        else
                        {
                            Message.ShowMessage("99 Products have alreadey been added!");
                            return;
                        }
                    }
                    else
                    {
                        mainProductCode = invCode * 100 + 1;
                    }

                    string Query = "INSERT INTO MProducts VALUES(@MId, @InvCCode, @MName, @Description)";
                    SqlParameter[] para =
                    {
                        new SqlParameter("@MId", mainProductCode),
                        new SqlParameter("@InvCCode", invCode),
                        new SqlParameter("@MName", mainProName),
                        new SqlParameter("@Description", manProDes)
                    };

                    try
                    {
                        ListClass lc = new ListClass();
                        MainWindow.mainProducts = SqlClass.ExecuteNonQuery(Query, MainWindow.mainProducts, lc.MainProductList, para);
                        Message.ShowMessage("Product has been added to List");
                        int cbo1Index = cboMainCategory1.SelectedIndex;
                        PopulateComboBox();
                        cboMainCategory1.SelectedIndex = cboMainCategory2.SelectedIndex = cbo1Index;
                        int cbo2Index = cboSubCategory.Items.Count - 1;
                        cboSubCategory.SelectedIndex = cbo2Index;
                        txtNameSubCategory.Text = txtDescribeSubCategory.Text = string.Empty;
                    }
                    catch (Exception ex)
                    {
                        Message.ShowMessage(ex.ToString());
                    }
                }
            }
        }

        public void CreateControlLedgers()
        {
            string controlName = MainWindow.listControl.Where(x => x.ControlName == txtNameMainCategory.Text).Select(x => x.ControlName).FirstOrDefault();

            if (controlName != null) Message.ShowMessage("It exists!");
            else
            {
                string mainCatName = txtNameMainCategory.Text;
                string mainCatDes = txtDescribeMainCategory.Text;

                if (mainCatName == string.Empty) Message.ShowMessage("Check field");
                else if (mainCatName.Length > 50) Message.ShowMessage("More than 50 Character is not supported");
                else if (mainCatDes.Length > 75) Message.ShowMessage("More than 75 Character is not supported");
                else
                {
                    int maxInvCode, maxSalesCode, maxSalesReturnCode, maxPurchaseReturnCode, maxCOGSCode, maxSalesReturnAdjCode, maxWeightLossCode, maxWeightGainCode;
                    int InvCode, SalesCode, SalesReturnCode, PurchaseReturnCode, COGSCode, SalesReturnAdjCode, WeightLossCode, WeightGainCode;
                    InvCode = SalesCode = SalesReturnCode = PurchaseReturnCode = COGSCode = SalesReturnAdjCode = WeightLossCode = WeightGainCode = 0;

                    maxInvCode = MainWindow.listControl.Where(x => x.GeneralCode == 201).Select(x => x.ControlCode).LastOrDefault();
                    if (maxInvCode != 0)
                    {
                        if (maxInvCode != 20199)
                        {
                            maxInvCode = MainWindow.listControl.Where(x => x.GeneralCode == 201).Max(x => x.ControlCode);
                            maxSalesCode = MainWindow.listControl.Where(x => x.GeneralCode == 601).Max(x => x.ControlCode);
                            maxSalesReturnCode = MainWindow.listControl.Where(x => x.GeneralCode == 602).Max(x => x.ControlCode);
                            maxPurchaseReturnCode = MainWindow.listControl.Where(x => x.GeneralCode == 707).Max(x => x.ControlCode);
                            maxCOGSCode = MainWindow.listControl.Where(x => x.GeneralCode == 701).Max(x => x.ControlCode);
                            maxSalesReturnAdjCode = MainWindow.listControl.Where(x => x.GeneralCode == 706).Max(x => x.ControlCode);
                            maxWeightLossCode = MainWindow.listControl.Where(x => x.GeneralCode == 705).Max(x => x.ControlCode);
                            maxWeightGainCode = MainWindow.listControl.Where(x => x.GeneralCode == 708).Max(x => x.ControlCode);

                            InvCode = maxInvCode + 1; SalesCode = maxSalesCode + 1; SalesReturnCode = maxSalesReturnCode + 1;
                            PurchaseReturnCode = maxPurchaseReturnCode + 1; COGSCode = maxCOGSCode + 1; SalesReturnAdjCode = maxSalesReturnAdjCode + 1;
                            WeightLossCode = maxWeightLossCode + 1; WeightGainCode = maxWeightGainCode + 1;
                        }
                        else
                        {
                            Message.ShowMessage("99 Product Sector has alreadey been added!");
                            return;
                        }
                    }
                    else
                    {
                        InvCode = 20101; SalesCode = 60101; SalesReturnCode = 60201; PurchaseReturnCode = 70701; COGSCode = 70101; SalesReturnAdjCode = 70601;
                        WeightLossCode = 70501; WeightGainCode = 70801;
                    }

                    string Query = "INSERT INTO CHeads VALUES(@CCODE, @GCODE, @MCODE, @CHOA, @DESCRIPTION)";
                    string CS = ConfigurationManager.ConnectionStrings["TestDB"].ConnectionString;
                    using (SqlConnection con = new SqlConnection(CS))
                    {
                        con.Open();
                        SqlTransaction Trans = con.BeginTransaction();
                        try
                        {
                            SqlClass.ExecuteTransaction(Query, Param(InvCode, 201, 2, mainCatName, "Inventories"), con, Trans).ExecuteNonQuery();
                            SqlClass.ExecuteTransaction(Query, Param(SalesCode, 601, 6, mainCatName, "Sales"), con, Trans).ExecuteNonQuery();
                            SqlClass.ExecuteTransaction(Query, Param(SalesReturnCode, 602, 6, mainCatName, "Sales return"), con, Trans).ExecuteNonQuery();
                            SqlClass.ExecuteTransaction(Query, Param(PurchaseReturnCode, 707, 7, mainCatName, "Purchase return"), con, Trans).ExecuteNonQuery();
                            SqlClass.ExecuteTransaction(Query, Param(COGSCode, 701, 7, mainCatName, "Cost of Goods Sold"), con, Trans).ExecuteNonQuery();
                            SqlClass.ExecuteTransaction(Query, Param(SalesReturnAdjCode, 706, 7, mainCatName, "Sales return adjustment"), con, Trans).ExecuteNonQuery();
                            SqlClass.ExecuteTransaction(Query, Param(WeightLossCode, 705, 7, mainCatName, "Weight Loss"), con, Trans).ExecuteNonQuery();
                            SqlClass.ExecuteTransaction(Query, Param(WeightGainCode, 708, 7, mainCatName, "Weight Gain"), con, Trans).ExecuteNonQuery();
                            Trans.Commit();
                            ListClass lc = new ListClass();
                            MainWindow.listControl.Clear();
                            MainWindow.listControl = lc.ControlList(con);
                            Message.ShowMessage("Necessary Ledgers have been created");
                            PopulateComboBox();
                            int cboIndex = cboMainCategory1.Items.Count - 1; cboMainCategory1.SelectedIndex = cboIndex;
                            cboMainCategory2.SelectedIndex = cboIndex;
                            txtNameMainCategory.Text = txtDescribeMainCategory.Text = string.Empty;
                        }
                        catch (Exception ex)
                        {
                            Trans.Rollback();
                            Message.ShowMessage(ex.ToString());
                        }
                    }
                }
            }
        }

        public SqlParameter[] Param(int CCode, int GCode, int MCode, string CHOA, string Description)
        {
            SqlParameter[] para =
                    {
                        new SqlParameter("@CCODE",CCode),
                        new SqlParameter("@GCODE",GCode),
                        new SqlParameter("@MCODE",MCode),
                        new SqlParameter("@CHOA",CHOA),
                        new SqlParameter("@DESCRIPTION",Description)
                    };
            return para;
        }
    }
}
