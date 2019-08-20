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
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using DAL;
using System.Configuration;
using System.Data.SqlClient;

namespace WPF
{
    /// <summary>
    /// Interaction logic for AddFixedAssets.xaml
    /// </summary>
    public partial class AddFixedAssets : UserControl
    {
        public AddFixedAssets()
        {
            InitializeComponent();
            btnCreateControl.Click += (s, e) => CreateFAControlAccount();
            PopulateComboBox();
            chkDepreciation.Checked += (s, e) => txtDepreciation.IsEnabled = false;
            chkDepreciation.Unchecked += (s, e) => txtDepreciation.IsEnabled = true;
            btnCreateCategory.Click += (s, e) => CreateCategory();
        }

        private void CreateCategory()
        {
            if (cboControl1.SelectedItem == null)
            {
                Message.ShowMessage("Create Control Ledger");
                return;
            }
            bool notDepreciable = (bool)chkDepreciation.IsChecked;
            double depreciationRate = 0;
            string depreciation, categoryName, categoryDescription;

            categoryName = txtNameCategory.Text;
            categoryDescription = txtDescribeCategory.Text;
            depreciation = txtDepreciation.Text;

            if (categoryName == string.Empty || categoryDescription == string.Empty)
            {
                Message.ShowMessage("Check Text fields");
                return;
            }
            else if (categoryName.Length > 100 || categoryDescription.Length > 150)
            {
                Message.ShowMessage("Check Text fields length");
                return;
            }

            if (!notDepreciable)
            {
                if (depreciation == string.Empty)
                {
                    Message.ShowMessage("Check Depreciation");
                    return;
                }
                else
                {
                    double.TryParse(depreciation, out depreciationRate);
                    if (depreciationRate <= 0)
                    {
                        Message.ShowMessage("Check Depreciation rate");
                        return;
                    }
                }
            }

            int CCode, maxItemCode, uppreLimit, itemCode;
            CCode = Convert.ToInt32(cboControl1.SelectedValue);
            List<FixedAssets> FAlist = MainWindow.listFixedAssets.Where(x => x.CCode == CCode).ToList();
            maxItemCode = FAlist.Count == 0 ? 0 : FAlist.Max(x => x.ItemCode);
            uppreLimit = CCode * 1000 + 999;
            if (maxItemCode == uppreLimit)
            {
                Message.ShowMessage("999 Items added under control account");
                return;
            }
            else
            {
                itemCode = maxItemCode == 0 ? CCode * 1000 + 1 : maxItemCode + 1;
            }

            string Query = "INSERT INTO FixedAssetsItem VALUES(@CCode, @ItemCode, @Depreciation, @ItemName, @DESCRIPTION)";
            string CS = ConfigurationManager.ConnectionStrings["TestDB"].ConnectionString;
            using (SqlConnection con = new SqlConnection(CS))
            {
                SqlParameter Depre = depreciationRate == 0 ? new SqlParameter("@Depreciation", DBNull.Value) : new SqlParameter("@Depreciation", depreciationRate);
                SqlParameter[] para =
                {
                        new SqlParameter("@CCode", CCode),
                        new SqlParameter("@ItemCode", itemCode),
                        Depre,
                        new SqlParameter("@ItemName", categoryName),
                        new SqlParameter("@DESCRIPTION", categoryDescription)
                    };

                ListClass lc = new ListClass();
                try
                {
                    con.Open();
                    MainWindow.listFixedAssets = SqlClass.ExecuteNonQuery(Query, MainWindow.listFixedAssets, lc.FixedAssetsControlList, para);
                    Message.ShowMessage("Item added to List");
                   
                }
                catch (Exception ex)
                {
                    Message.ShowMessage(ex.ToString());
                }
            }
        }

       
        private void PopulateComboBox()
        {
            
            int FAGenCode = MainWindow.listGeneral.Where(x => x.GeneralName == "Fixed Assets").Select(x => x.GeneralCode).FirstOrDefault();
            List<ControlHeads> FAControl = MainWindow.listControl.Where(x => x.GeneralCode == FAGenCode).ToList();
            cboControl1.ItemsSource = FAControl;
            cboControl1.DisplayMemberPath = "ControlName";
            cboControl1.SelectedValuePath =  "ControlCode";
            cboControl1.SelectedIndex = 0;
            
        }

        private void CreateFAControlAccount()
        {
            string controlName, controlDescription;
            controlName = txtNameControl.Text; controlDescription = txtDescribeControl.Text;
            if(controlName == string.Empty || controlDescription == string.Empty)
            {
                Message.ShowMessage("Fill in the Text Boxes");
                return;
            }
            if (controlName.Length > 100 || controlDescription.Length > 150)
            {
                Message.ShowMessage("Unexpected Length");
                return;
            }

            List<GeneralHeads> FAGen = MainWindow.listGeneral.Where(x => x.GeneralName == "Fixed Assets").ToList();
            int FAGenCode = FAGen.Select(x => x.GeneralCode).FirstOrDefault();
            List<ControlHeads> FAControl = MainWindow.listControl.Where(x => x.GeneralCode == FAGenCode).ToList();
            List<ControlHeads> names = FAControl.Where(x => x.ControlName == controlName).ToList();

            if (names.Count != 0)
            {
                Message.ShowMessage("Head Exists");
                return;
            }

            int controlCode = 0;
            int maxControlCode = FAControl.Select(x => x.ControlCode).LastOrDefault();
            int upperLimit = FAGenCode * 100 + 99;
            if (maxControlCode != upperLimit)
                controlCode = maxControlCode == 0 ? FAGenCode * 100 + 1 : maxControlCode + 1;
            else
            {
                Message.ShowMessage("99 Items added");
                return;
            }

            int FAMainCode = FAGen.Select(x => x.MainCode).FirstOrDefault();

            string Query = "INSERT INTO CHeads VALUES(@CCODE, @GCODE, @MCODE, @CHOA, @DESCRIPTION)";
            string CS = ConfigurationManager.ConnectionStrings["TestDB"].ConnectionString;
            using (SqlConnection con = new SqlConnection(CS))
            {
                SqlParameter[] para =
                {
                    new SqlParameter("@CCODE", controlCode),
                    new SqlParameter("@GCODE", FAGenCode),
                    new SqlParameter("@MCODE", FAMainCode),
                    new SqlParameter("@CHOA", controlName),
                    new SqlParameter("@DESCRIPTION", controlDescription)
                };
                ListClass lc = new ListClass();
                try
                {
                    con.Open();
                    MainWindow.listControl = SqlClass.ExecuteNonQuery(Query, MainWindow.listControl, lc.ControlList, para);
                    Message.ShowMessage("Ledger Created");
                    PopulateComboBox();
                    cboControl1.SelectedIndex = MainWindow.listControl.FindIndex(x => x.ControlCode == controlCode);
                }
                catch(Exception ex)
                {
                    Message.ShowMessage(ex.ToString());
                }             
            }
        }
    }
}
