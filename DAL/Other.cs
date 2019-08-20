using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;

namespace DAL
{
    public class Other
    {
        public static void ChekboxChecked(string header, DataGrid datagrid)
        {
            foreach (DataGridColumn item in datagrid.Columns)
            {
                if (item.Header.ToString() == header)
                {
                    if (item.Visibility == Visibility.Hidden)
                        item.Visibility = Visibility.Visible;
                }
            }
        }

        public static void CheckboxUncheked(string header, DataGrid datagrid)
        {
            foreach (DataGridColumn item in datagrid.Columns)
            {
                if (item.Header.ToString() == header)
                {
                    if (item.Visibility == Visibility.Visible)
                        item.Visibility = Visibility.Hidden;
                }
            }
        }
    }
}
