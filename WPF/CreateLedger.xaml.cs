using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
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
using System.Data.SqlClient;

namespace WPF
{
    public partial class CreateLedger : UserControl
    {
        
        public CreateLedger()
        {
            InitializeComponent();
            Storyboard sb = FindResource("ComeIn") as Storyboard;
            sb.Begin();

            PopulateComboBox();
            btnCreateGeneral.Click += (s, e) => CreateGeneralLedger();
            btnCreateControl.Click += (s, e) => CreateControlLedger();
            BindCombos combo = new BindCombos();
            cboMainHead2.DropDownClosed += (s, e) => combo.BindGeneralAccountCombo(cboMainHead2, cboGeneralHead, MainWindow.listGeneral);
            cboMainHead2.SelectionChanged += (s, e) => combo.BindGeneralAccountCombo(cboMainHead2, cboGeneralHead, MainWindow.listGeneral);
        }

        public void PopulateComboBox()
        {
            BindCombos combo = new BindCombos();
            combo.BindMainAccountCombo(cboMainHead1, MainWindow.listMain);
            combo.BindMainAccountCombo(cboMainHead2, MainWindow.listMain);
            combo.BindGeneralAccountCombo(cboMainHead2, cboGeneralHead, MainWindow.listGeneral);
        }

        public void CreateGeneralLedger()
        {
            string genName = txtNameGeneral.Text;
            string genDes = txtDescribeGeneral.Text;
            if (genName == string.Empty || genDes == string.Empty)
            {
                Message.ShowMessage("Check field");
            }
            else if (genName.Length > 50 || genDes.Length > 75)
            {
                Message.ShowMessage("Unexpected Length!");
            }
            else
            {
                int mainCode = Convert.ToInt32(cboMainHead1.SelectedValue);
                int maxGenCode;
                List<GeneralHeads> listGen = MainWindow.listGeneral.Where(x => x.MainCode == mainCode).ToList();
                if (listGen.Count != 0)
                {
                    List<GeneralHeads> lst = listGen.Where(x => x.GeneralName == genName && x.MainCode == mainCode).ToList();
                    if (lst.Count != 0)
                    {
                        Message.ShowMessage("It exists!");
                        return;
                    }
                    else
                    {
                        maxGenCode = listGen.Max(x => x.GeneralCode);
                        if (maxGenCode == mainCode * 100 + 99)
                        {
                            Message.ShowMessage("99 General Ledgers are there!");
                            return;
                        }
                        else
                        {
                            maxGenCode++;
                        }
                    }
                }
                else
                {
                    maxGenCode = mainCode * 100 + 1;
                }

                string Query = "INSERT INTO GHeads VALUES(@GCODE, @MCODE, @GHOA, @DESCRIPTION)";
                SqlParameter[] para =
                {
                    new SqlParameter("@GCODE", maxGenCode),
                    new SqlParameter("@MCODE", mainCode),
                    new SqlParameter("@GHOA", genName),
                    new SqlParameter("@DESCRIPTION", genDes)
                };

                try
                {
                    ListClass lc = new ListClass();
                    MainWindow.listGeneral = SqlClass.ExecuteNonQuery(Query, MainWindow.listGeneral, lc.GeneralList, para);
                    Message.ShowMessage("General ledger has been added to List");
                    int cbo1Index = cboMainHead1.SelectedIndex;
                    PopulateComboBox();
                    cboMainHead1.SelectedIndex = cboMainHead2.SelectedIndex = cbo1Index;
                    cbo1Index = cboGeneralHead.Items.Count - 1;
                    cboGeneralHead.SelectedIndex = cbo1Index;
                    txtNameGeneral.Text = txtDescribeGeneral.Text = string.Empty;
                }
                catch (Exception ex)
                {
                    Message.ShowMessage(ex.ToString());
                }
            }
        }

        public void CreateControlLedger()
        {
            var a = cboGeneralHead.SelectedItem;
            string controlName = txtNameControl.Text;
            string controlDes = txtDescribeControl.Text;
            if (a == null)
            {
                Message.ShowMessage("Create General Ledger");
            }
            else if (controlName == string.Empty || controlDes == string.Empty)
            {
                Message.ShowMessage("Check field");
            }
            else if (controlName.Length > 50 || controlDes.Length > 75)
            {
                Message.ShowMessage("Length of text is not supported");
            }
            else
            {
                int generalCode = Convert.ToInt32(cboGeneralHead.SelectedValue);
                int mainCode, maxControlCode;
                mainCode = maxControlCode = 0;
                List<ControlHeads> lst = MainWindow.listControl.Where(x => x.ControlName == controlName && x.GeneralCode == generalCode).ToList();
                if (lst.Count != 0)
                {
                    Message.ShowMessage("It exists");
                    return;
                }
                else
                {
                    List<ControlHeads> listControlheads = MainWindow.listControl.Where(x => x.GeneralCode == generalCode).ToList();
                    mainCode = Convert.ToInt32(cboMainHead2.SelectedValue);
                    if (listControlheads.Count == 0)
                    {
                        maxControlCode = generalCode * 100 + 1;
                    }
                    else
                    {
                        maxControlCode = listControlheads.Max(x => x.ControlCode);
                        if (maxControlCode == generalCode * 100 + 99)
                        {
                            Message.ShowMessage("99 Ledgers already added");
                            return;
                        }
                        else
                        {
                            maxControlCode++;
                        }
                    }
                }

                string Query = "INSERT INTO CHeads VALUES(@CCODE, @GCODE, @MCODE, @CHOA, @DESCRIPTION)";
                SqlParameter[] para =
                {
                    new SqlParameter("@CCODE", maxControlCode),
                    new SqlParameter("@GCODE", generalCode),
                    new SqlParameter("@MCODE", mainCode),
                    new SqlParameter("@CHOA", controlName),
                    new SqlParameter("@DESCRIPTION", controlDes)
                };

                try
                {
                    ListClass lc = new ListClass();
                    MainWindow.listControl = SqlClass.ExecuteNonQuery(Query, MainWindow.listControl, lc.ControlList, para);
                    Message.ShowMessage("Control ledger has been added to List");
                    txtNameControl.Text = txtDescribeControl.Text = string.Empty;
                }
                catch (Exception ex)
                {
                    Message.ShowMessage(ex.ToString());
                }
            }
        }
    }
}
