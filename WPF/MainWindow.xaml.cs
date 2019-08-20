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
using System.Data.SqlClient;
using System.Configuration;
using DAL;
using System.Timers;
using System.Diagnostics;

namespace WPF
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public static List<MainHeads> listMain = new List<MainHeads>();
        public static List<GeneralHeads> listGeneral = new List<GeneralHeads>();
        public static List<ControlHeads> listControl = new List<ControlHeads>();
        public static List<SubHeads> listSubHead = new List<SubHeads>();
        public static List<FixedAssets> listFixedAssets = new List<FixedAssets>();
        public static List<MainProduct> mainProducts = new List<MainProduct>();
        public static List<GeneralProduct> generalProducts = new List<GeneralProduct>();
        public static List<Departments> departmentList = new List<Departments>();
        public static List<Employees> employeeList = new List<Employees>();
        public static List<Customers> customerList = new List<Customers>();
        public static List<Suppliers> supplierList = new List<Suppliers>();
        public static List<Owners> ownerList = new List<Owners>();
        public static List<Others> otherList = new List<Others>();
        public static List<Banks> bankList = new List<Banks>();
        public static List<Government> govtList = new List<Government>();
        public static List<YearMonth> yearMonthList = new List<YearMonth>();
        public MainWindow()
        {
            InitializeComponent();
            PopulateLists();

            AddLedger.Click += (s, e) => MainContent.Content = new CreateLedger();
            AddProduct.Click += (s, e) => MainContent.Content = new AddProduct();
            AddParty.Click += (s, e) => MainContent.Content = new Parties.WelcomeParty();
            PassEntry.Click += (s, e) => MainContent.Content = new Entries.WelcomeEntry();
            ViewReports.Click += (s, e) => MainContent.Content = new Reports.WelcomeReport();
            ChartAccount.Click += (s, e) => MainContent.Content = new ChartOfAccount();
            AddFixedAsset.Click += (s, e) => MainContent.Content = new AddFixedAssets();
            btnClose.Click += (s, e) => this.Close();
            btnMinimize.Click += (s, e) => this.WindowState = WindowState.Minimized;
            Timer aTimer = new Timer(5000);
            aTimer.Elapsed += new ElapsedEventHandler(GetMemory);
            aTimer.Enabled = true;
        }

        public void GetMemory(object o, ElapsedEventArgs e)
        {
            long k = GC.GetTotalMemory(true);
            var q = Process.GetCurrentProcess();
                
            Dispatcher.Invoke(()=> 
            {
                StringBuilder sb = new StringBuilder();
                sb.Append(q.ProcessName.ToString()).AppendLine();
                sb.Append((k/1024).ToString()).AppendLine();
                sb.Append((q.NonpagedSystemMemorySize64/1024).ToString()).AppendLine();
                sb.Append((q.PagedMemorySize64/1024).ToString()).AppendLine();
                sb.Append((q.PeakPagedMemorySize64/1024).ToString()).AppendLine();
                sb.Append((q.VirtualMemorySize64/1024).ToString()).AppendLine();
                sb.Append(q.Threads.Count.ToString()).AppendLine();
                sb.Append((q.WorkingSet64/1024).ToString()).AppendLine();
                txtmemory.Text = sb.ToString();
            });         
        }
        public void PopulateLists()
        {
            string CS = ConfigurationManager.ConnectionStrings["TestDB"].ConnectionString;
            using (SqlConnection con = new SqlConnection(CS))
            {
                ListClass lc = new ListClass();
                con.Open();
                listMain = lc.MainList(con);
                listGeneral = lc.GeneralList(con);
                listControl = lc.ControlList(con);
                listFixedAssets = lc.FixedAssetsControlList(con);
                listSubHead = lc.SubHeadList(con);
                mainProducts = lc.MainProductList(con);
                generalProducts = lc.GeneralProductList(con);
                departmentList = lc.DepartmentList(con);
                employeeList = lc.EmployeeList(con);
                customerList = lc.CustomerList(con);
                supplierList = lc.SupplierList(con);
                ownerList = lc.OwnerList(con);
                otherList = lc.OtherList(con);
                bankList = lc.BankList(con);
                govtList = lc.GovtList(con);
                yearMonthList = lc.MonthYear(con);
            }
        }
    }
}
