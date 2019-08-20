using System;
using System.Collections.Generic;
using System.Drawing;
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

namespace WPF
{
    /// <summary>
    /// Interaction logic for ChartOfAccount.xaml
    /// </summary>
    public partial class ChartOfAccount : UserControl
    {
        public ChartOfAccount()
        {
            InitializeComponent();
            StringBuilder sb = new StringBuilder();
            
            foreach (var mainItem in MainWindow.listMain)
            {
                
                sb.Append(mainItem.MainCode + " - " + mainItem.MainName).AppendLine();
                foreach (var generalItem in MainWindow.listGeneral.Where(x=>x.MainCode == mainItem.MainCode).ToList())
                {
                    sb.Append("     " + generalItem.GeneralCode + " - " + generalItem.GeneralName).AppendLine();

                    foreach (var controlItem in MainWindow.listControl.Where(x=>x.GeneralCode == generalItem.GeneralCode).ToList())
                    {
                        sb.Append("          " + controlItem.ControlCode + " - " + controlItem.ControlName).AppendLine();
                    }
                }
                sb.AppendLine();
                sb.AppendLine();
            }

            CoA.Text = sb.ToString();
        }
    }
}
