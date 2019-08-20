using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Controls;

namespace DAL
{
    public class BindCombos
    {
        public void BindMainAccountCombo(ComboBox mainCombo, List<MainHeads> mainList)
        {
            mainCombo.ItemsSource = mainList;
            mainCombo.DisplayMemberPath = "MainName";
            mainCombo.SelectedValuePath = "MainCode";
            mainCombo.SelectedIndex = 0;
        }

        public void BindGeneralAccountCombo(ComboBox mainCombo, ComboBox generalCombo, List<GeneralHeads> generalList)
        {
            generalCombo.ItemsSource = generalList.Where(x => x.MainCode == Convert.ToInt32(mainCombo.SelectedValue)).ToList();
            generalCombo.DisplayMemberPath = "GeneralName";
            generalCombo.SelectedValuePath = "GeneralCode";
            generalCombo.SelectedIndex = 0;
        }

        public void BindControlAccountCombo(ComboBox generalCombo, ComboBox controlCombo, ComboBox generalProductCombo, ComboBox cboProductMain,
                                                List<ControlHeads> controlList, List<MainProduct> mainProductList, List<GeneralProduct> generalProductList)
        {
            controlCombo.ItemsSource = controlList.Where(x => x.GeneralCode == Convert.ToInt32(generalCombo.SelectedValue)).ToList();
            controlCombo.DisplayMemberPath = "ControlName";
            controlCombo.SelectedValuePath = "ControlCode";
            controlCombo.SelectedIndex = 0;
            BindMainProductCombo(generalCombo, controlCombo, cboProductMain, generalProductCombo, controlList, mainProductList, generalProductList);
        }

        public void BindControlAccountCombo(ComboBox generalCombo, ComboBox controlCombo, List<ControlHeads> controlList)
        {
            controlCombo.ItemsSource = controlList.Where(x => x.GeneralCode == Convert.ToInt32(generalCombo.SelectedValue)).ToList();
            controlCombo.DisplayMemberPath = "ControlName";
            controlCombo.SelectedValuePath = "ControlCode";
            controlCombo.SelectedIndex = 0;
            //BindMainProductCombo(generalCombo, controlCombo, cboProductMain, generalProductCombo, controlList, mainProductList, generalProductList);
        }

        public void BindMainProductCombo(ComboBox generalCombo, ComboBox controlCombo, ComboBox mainProductCombo, ComboBox generalProductCombo,
                                            List<ControlHeads> controlList, List<MainProduct> mainProductList, List<GeneralProduct> generalProductList)
        {
            int generalCode = Convert.ToInt32(generalCombo.SelectedValue);
            int controlCode = Convert.ToInt32(controlCombo.SelectedValue);
            if (generalCode == 201 || generalCode == 707 || generalCode == 706 || generalCode == 601)
            {
                string a = controlList.Where(x => x.ControlCode == controlCode).Select(x => x.ControlName).FirstOrDefault();
                int b = controlList.Where(x => x.ControlName == a && x.GeneralCode == 201).Select(x => x.ControlCode).FirstOrDefault();
                List<MainProduct> mp = mainProductList.Where(x => x.InventoryCode == b).ToList();
                if(mp.Count != 0)
                {
                    mainProductCombo.IsEnabled = true;
                    mainProductCombo.ItemsSource = mp;
                    mainProductCombo.DisplayMemberPath = "MainName";
                    mainProductCombo.SelectedValuePath = "MainId";
                    mainProductCombo.SelectedIndex = 0;
                }
                else
                {
                    mainProductCombo.SelectedItem = null;
                    mainProductCombo.IsEnabled = false;
                }     
            }
            else
            {
                mainProductCombo.SelectedItem = null;
                mainProductCombo.IsEnabled = false;
            }
            BindGeneralProductCombo(mainProductCombo, generalProductCombo, generalProductList);
        }

        public void BindGeneralProductCombo(ComboBox mainProductCombo, ComboBox generalProductCombo, List<GeneralProduct> generalProductList)
        {
            if (mainProductCombo.SelectedItem != null)
            {
                List<GeneralProduct> genPro = generalProductList.Where(x => x.MainId == Convert.ToInt32(mainProductCombo.SelectedValue)).ToList();
                if(genPro.Count > 0)
                {
                    generalProductCombo.IsEnabled = true;
                    generalProductCombo.ItemsSource = genPro;
                    generalProductCombo.DisplayMemberPath = "GeneralName";
                    generalProductCombo.SelectedValuePath = "GeneralId";
                    generalProductCombo.SelectedIndex = 0;
                }
                else
                {
                    generalProductCombo.SelectedItem = null;
                    generalProductCombo.IsEnabled = false;
                } 
            }
            else
            {
                generalProductCombo.SelectedItem = null;
                generalProductCombo.IsEnabled = false;
            }
        }


        public void BindMainProductCombo(ComboBox mainProductCombo, List<ControlHeads> controlList)
        {
            List<ControlHeads> source = controlList.Where(x => x.GeneralCode == 201).ToList();
            if(source.Count > 0)
            {
                mainProductCombo.IsEnabled = true;
                mainProductCombo.ItemsSource = source;
                mainProductCombo.DisplayMemberPath = "ControlName";
                mainProductCombo.SelectedValuePath = "ControlCode";
                mainProductCombo.SelectedIndex = 0;
            }
            else
            {
                mainProductCombo.SelectedItem = null;
                mainProductCombo.IsEnabled = false;
            }
            
        }

        public void BindGeneralProductCombo(ComboBox mainProductCombo, ComboBox generalCombo, ComboBox controlCombo, ComboBox qtyCombo,
                                            List<MainProduct> mainProductList, List<GeneralProduct> genProList)
        {
            List<MainProduct> source = mainProductList.Where(x => x.InventoryCode == Convert.ToInt32(mainProductCombo.SelectedValue)).ToList();
            if (source.Count > 0)
            {
                generalCombo.IsEnabled = true;
                generalCombo.ItemsSource = source;
                generalCombo.DisplayMemberPath = "MainName";
                generalCombo.SelectedValuePath = "MainId";
                generalCombo.SelectedIndex = 0;
            }
            else
            {
                generalCombo.SelectedItem = null;
                generalCombo.IsEnabled = false;
            }
            BindControlProductCombo(generalCombo, controlCombo, qtyCombo, genProList);
        }

        public void BindControlProductCombo(ComboBox generalCombo, ComboBox controlCombo, ComboBox qtyCombo, List<GeneralProduct> genProList)
        {
            if (generalCombo.SelectedItem != null && generalCombo.IsEnabled != false)
            {
                List<GeneralProduct> source = genProList.Where(x => x.MainId == Convert.ToInt32(generalCombo.SelectedValue)).ToList();
                if (source.Count > 0)
                {
                    controlCombo.IsEnabled = true;
                    controlCombo.ItemsSource = source;
                    controlCombo.DisplayMemberPath = "GeneralName";
                    controlCombo.SelectedValuePath = "GeneralId";
                    controlCombo.SelectedIndex = 0;
                }
                else
                {
                    controlCombo.SelectedItem = null;
                    controlCombo.IsEnabled = false;
                }
            }
            else
            {
                controlCombo.SelectedItem = null;
                controlCombo.IsEnabled = false;
            }
            BindQtyTypeCombo(controlCombo, qtyCombo, genProList);
        }

        public void BindQtyTypeCombo(ComboBox controlCombo, ComboBox qtyCombo, List<GeneralProduct> genProList)
        {
            qtyCombo.Items.Clear();
            if (controlCombo.IsEnabled != false)
            {
                double source = genProList.Where(x => x.GeneralId == Convert.ToInt32(controlCombo.SelectedValue)).Select(x => x.LooseConversionFactor).FirstOrDefault();
                if (source > 0)
                {
                    qtyCombo.IsEnabled = true;
                    qtyCombo.Items.Add("Unit");
                    qtyCombo.Items.Add("Kg");
                    qtyCombo.SelectedIndex = 0;
                }
                else
                {
                    qtyCombo.IsEnabled = false;
                    qtyCombo.Items.Add("Unit");
                    qtyCombo.SelectedIndex = 0;
                }
            }
            else
            {
                qtyCombo.SelectedItem = null;
                qtyCombo.IsEnabled = false;
            }
        }

        public void BindMainProductComboOfAddProduct(ComboBox mainProductCombo, ComboBox cboSubCategory, List<ControlHeads> listControl, List<MainProduct> mainProducts)
        {
            mainProductCombo.ItemsSource = listControl.Where(x => x.GeneralCode == 201).ToList();
            
            mainProductCombo.DisplayMemberPath = "ControlName";
            mainProductCombo.SelectedValuePath = "ControlCode";
            mainProductCombo.SelectedIndex = 0;
            BindGeneralProductComboOfAddProduct(mainProductCombo, cboSubCategory, mainProducts);
        }

        public void BindGeneralProductComboOfAddProduct(ComboBox cboMainCategory, ComboBox cboSubCategory, List<MainProduct> mainProducts)
        {
            if(cboMainCategory.SelectedValue != null)
            {
                int a = Convert.ToInt32(cboMainCategory.SelectedValue);
                cboSubCategory.ItemsSource = mainProducts.Where(x => x.InventoryCode == a).ToList();
                cboSubCategory.DisplayMemberPath = "MainName";
                cboSubCategory.SelectedValuePath = "MainId";
                cboSubCategory.SelectedIndex = 0;
            } 
        }

        public void BindDepartmentNameCombo(ComboBox deptName, List<Departments> deptList)
        {
            deptName.ItemsSource = deptList;
            deptName.DisplayMemberPath = "DeptName";
            deptName.SelectedValuePath = "DeptId";
            deptName.SelectedIndex = 0;
        }

        public void BindPartyTypeCombo(ComboBox cboPartyType)
        {
            cboPartyType.Items.Add("Customer");
            cboPartyType.Items.Add("Supplier");
            cboPartyType.Items.Add("Employee");
            cboPartyType.Items.Add("Owner");
            cboPartyType.SelectedIndex = 0;
        }

        //public void BindPartyNameCombo(ComboBox cboPartyType, ComboBox cboPartyName, List<Customers> cust, List<Suppliers> sup, 
        //                    List<Employees> emp, List<Government> govt, List<Others> othe, List<Owners> own)
        //{
        //    string partyType = cboPartyType.SelectedValue.ToString();
        //    List<string> partyList = new List<string>();
        //    switch (partyType)
        //    {
        //        case "Customer":
        //            partyList = cust.Select(x => x.Name).Distinct().ToList();
        //            break;
        //        case "Supplier":
        //            partyList = sup.Select(x => x.Name).Distinct().ToList();
        //            break;
        //        case "Employee":
        //            partyList = emp.Select(x => x.Name).Distinct().ToList();
        //            break;
        //        case "Govt":
        //            partyList = govt.Select(x => x.Department).Distinct().ToList();
        //            break;
        //        case "Other":
        //            partyList = othe.Select(x => x.Name).Distinct().ToList();
        //            break;
        //        default:
        //            partyList = own.Select(x => x.Name).Distinct().ToList();
        //            break;
        //    }
        //    cboPartyName.ItemsSource = partyList;
        //    cboPartyName.SelectedIndex = 0;
        //    cboPartyName.IsEnabled = partyList.Count > 0 ? true : false;
        //}


        public void BindPartyNameCombo<T>(ComboBox cboPartyName, string partyType, List<T> list)
        {
            List<string> partyList = new List<string>();
            switch (partyType)
            {
                case "Customer":
                    List<Customers> cust = list as List<Customers>;
                    partyList = cust.Select(x => x.Name).Distinct().ToList();
                    break;
                case "Supplier":
                    List<Suppliers> sup = list as List<Suppliers>;
                    partyList = sup.Select(x => x.Name).Distinct().ToList();
                    break;
                case "Employee":
                    List<Employees> emp = list as List<Employees>;
                    partyList = emp.Select(x => x.Name).Distinct().ToList();
                    break;
                case "Govt":
                    List<Government> govt = list as List<Government>;
                    partyList = govt.Select(x => x.Department).Distinct().ToList();
                    break;
                case "Other":
                    List<Others> othe = list as List<Others>;
                    partyList = othe.Select(x => x.Name).Distinct().ToList();
                    break;
                case "Owner":
                    List<Owners> own = list as List<Owners>;
                    partyList = own.Select(x => x.Name).Distinct().ToList();
                    break;
            }
            cboPartyName.ItemsSource = partyList;
            cboPartyName.SelectedIndex = 0;
            cboPartyName.IsEnabled = partyList.Count > 0 ? true : false;
        }

        public void BindPartyIdCombo<T>(ComboBox cboPartyName, string partyType, ComboBox cboPartyId, List<T> list)
        {
            string partyName = Convert.ToString(cboPartyName.SelectedValue);
            List<int> idList = new List<int>();
            switch (partyType)
            {
                case "Customer":
                    List<Customers> cust = list as List<Customers>;
                    idList = cust.Where(x => x.Name == partyName).Select(x => x.CustId).ToList();
                    break;
                case "Supplier":
                    List<Suppliers> sup = list as List<Suppliers>;
                    idList = sup.Where(x => x.Name == partyName).Select(x => x.SupId).ToList();
                    break;
                case "Employee":
                    List<Employees> emp = list as List<Employees>;
                    idList = emp.Where(x => x.Name == partyName).Select(x => x.EmpId).ToList();
                    break;
                case "Govt":
                    List<Government> govt = list as List<Government>;
                    idList = govt.Where(x => x.Department == partyName).Select(x => x.GovtId).ToList();
                    break;
                case "Other":
                    List<Others> othe = list as List<Others>;
                    idList = othe.Where(x => x.Name == partyName).Select(x => x.OthersId).ToList();
                    break;
                case "Owner":
                    List<Owners> own = list as List<Owners>;
                    idList = own.Where(x => x.Name == partyName).Select(x => x.OwnId).ToList();
                    break;
            }
            cboPartyId.ItemsSource = idList;
            cboPartyId.SelectedIndex = 0;
            cboPartyId.IsEnabled = idList.Count > 1 ? true : false;
        }

        public void BindPartyAddressText<T>(ComboBox cboPartyId, TextBlock txtPartyContact, string partyType, List<T> list)
        {
            int partyId = Convert.ToInt32(cboPartyId.SelectedValue);
            switch (partyType)
            {
                case "Customer":
                    List<Customers> cust = list as List<Customers>;
                    txtPartyContact.Text = cust.Where(x => x.CustId == partyId).Select(x => x.Address).FirstOrDefault();
                    break;
                case "Supplier":
                    List<Suppliers> sup = list as List<Suppliers>;
                    txtPartyContact.Text = sup.Where(x => x.SupId == partyId).Select(x => x.Address).FirstOrDefault();
                    break;
                case "Employee":
                    List<Employees> emp = list as List<Employees>;
                    txtPartyContact.Text = emp.Where(x => x.EmpId == partyId).Select(x => x.Address).FirstOrDefault();
                    break;
                case "Govt":
                    List<Government> govt = list as List<Government>;
                    txtPartyContact.Text = govt.Where(x => x.GovtId == partyId).Select(x => x.Zone).FirstOrDefault();
                    break;
                case "Other":
                    List<Others> othe = list as List<Others>;
                    txtPartyContact.Text = othe.Where(x => x.OthersId == partyId).Select(x => x.Address).FirstOrDefault();
                    break;
                case "Owner":
                    List<Owners> own = list as List<Owners>;
                    txtPartyContact.Text = own.Where(x => x.OwnId == partyId).Select(x => x.Address).FirstOrDefault();
                    break;
            }
        }

        //public void BindPartyNameCombo(ComboBox cboPartyName, string partyType, List<Customers> cust = null,
        //                                List<Suppliers> sup = null, List<Employees> emp = null, List<Owners> own = null,
        //                                List<Government> govt = null, List<Others> othe = null)
        //{
        //    List<string> partyList = new List<string>();
        //    switch (partyType)
        //    {
        //        case "Customer":
        //            partyList = cust.Select(x => x.Name).Distinct().ToList();
        //            break;
        //        case "Supplier":
        //            partyList = sup.Select(x => x.Name).Distinct().ToList();
        //            break;
        //        case "Employee":
        //            partyList = emp.Select(x => x.Name).Distinct().ToList();
        //            break;
        //        case "Govt":
        //            partyList = govt.Select(x => x.Department).Distinct().ToList();
        //            break;
        //        case "Other":
        //            partyList = othe.Select(x => x.Name).Distinct().ToList();
        //            break;
        //        case "Owner":
        //            partyList = own.Select(x => x.Name).Distinct().ToList();
        //            break;
        //    }
        //    cboPartyName.ItemsSource = partyList;
        //    cboPartyName.SelectedIndex = 0;
        //    cboPartyName.IsEnabled = partyList.Count > 0 ? true : false;
        //}
        //public void BindPartyIdCombo(ComboBox cboPartyName, string partyType, ComboBox cboPartyId, List<Customers> cust = null,
        //                                    List<Suppliers> sup = null, List<Employees> emp = null, List<Owners> own = null,
        //                                    List<Government> govt = null, List<Others> othe = null)
        //{
        //    string partyName = Convert.ToString(cboPartyName.SelectedValue);
        //    List<int> idList = new List<int>();
        //    switch (partyType)
        //    {
        //        case "Customer":
        //            idList = cust.Where(x => x.Name == partyName).Select(x => x.CustId).ToList();
        //            break;
        //        case "Supplier":
        //            idList = sup.Where(x => x.Name == partyName).Select(x => x.SupId).ToList();
        //            break;
        //        case "Employee":
        //            idList = emp.Where(x => x.Name == partyName).Select(x => x.EmpId).ToList();
        //            break;
        //        case "Govt":
        //            idList = govt.Where(x => x.Department == partyName).Select(x => x.GovtId).ToList();
        //            break;
        //        case "Other":
        //            idList = othe.Where(x => x.Name == partyName).Select(x => x.OthersId).ToList();
        //            break;
        //        case "Owner":
        //            idList = own.Where(x => x.Name == partyName).Select(x => x.OwnId).ToList();
        //            break;
        //    }
        //    cboPartyId.ItemsSource = idList;
        //    cboPartyId.SelectedIndex = 0;
        //    cboPartyId.IsEnabled = idList.Count > 1 ? true : false;
        //}

        //public void BindPartyAddressText(ComboBox cboPartyId, TextBox txtPartyContact, string partyType, List<Customers> cust = null,
        //                                    List<Suppliers> sup = null, List<Employees> emp = null, List<Owners> own = null,
        //                                    List<Government> govt = null, List<Others> othe = null)
        //{
        //    int partyId = Convert.ToInt32(cboPartyId.SelectedValue);
        //    switch (partyType)
        //    {
        //        case "Customer":
        //            txtPartyContact.Text = cust.Where(x => x.CustId == partyId).Select(x => x.Address).FirstOrDefault();
        //            break;
        //        case "Supplier":
        //            txtPartyContact.Text = sup.Where(x => x.SupId == partyId).Select(x => x.Address).FirstOrDefault();
        //            break;
        //        case "Employee":
        //            txtPartyContact.Text = emp.Where(x => x.EmpId == partyId).Select(x => x.Address).FirstOrDefault();
        //            break;
        //        case "Govt":
        //            txtPartyContact.Text = govt.Where(x => x.GovtId == partyId).Select(x => x.Zone).FirstOrDefault();
        //            break;
        //        case "Other":
        //            txtPartyContact.Text = othe.Where(x => x.OthersId == partyId).Select(x => x.Address).FirstOrDefault();
        //            break;
        //        default:
        //            txtPartyContact.Text = own.Where(x => x.OwnId == partyId).Select(x => x.Address).FirstOrDefault();
        //            break;
        //    }
        //}

        public void CheckBoxChecked(CheckBox chkCash, CheckBox chkBank, string name, CheckBox chkCredit = null, 
                                    ComboBox cboBankAccount = null, List<Banks> bankList = null)
        {
            switch (name)
            {
                case "Cash":
                    if (chkBank.IsChecked == true || chkCredit.IsChecked == true)
                    {
                        chkBank.IsChecked = false;
                        chkCredit.IsChecked = false;
                    }
                    break;

                case "Bank":
                    if (chkBank.IsChecked == true)
                    {
                        if (chkCash.IsChecked == true || chkCredit.IsChecked == true)
                        {
                            chkCash.IsChecked = false;
                            chkCredit.IsChecked = false;
                        }
                        cboBankAccount.IsEnabled = true;
                        cboBankAccount.ItemsSource = bankList;
                        cboBankAccount.DisplayMemberPath = "Head";
                        cboBankAccount.SelectedValuePath = "BankId";
                        cboBankAccount.SelectedIndex = 0;
                    }
                    break;

                default:
                    if (chkBank.IsChecked == true || chkCash.IsChecked == true)
                    {
                        chkCash.IsChecked = false;
                        chkBank.IsChecked = false;
                    }
                    break;
            }
        }

        public void CheckBoxChecked(CheckBox chkCash, CheckBox chkBank, string name,
                                    ComboBox cboBankAccount = null, List<Banks> bankList = null)
        {
            switch (name)
            {
                case "Cash":
                    if (chkBank.IsChecked == true)
                    {
                        chkBank.IsChecked = false;
                    }
                    break;

                default:
                    if (chkBank.IsChecked == true)
                    {
                        if (chkCash.IsChecked == true)
                        {
                            chkCash.IsChecked = false;
                        }
                        cboBankAccount.IsEnabled = true;
                        cboBankAccount.ItemsSource = bankList;
                        cboBankAccount.DisplayMemberPath = "Head";
                        cboBankAccount.SelectedValuePath = "BankId";
                        cboBankAccount.SelectedIndex = 0;
                    }
                    break;
            }
        }

        public void BindSubsidiaryCombo(ComboBox cboGeneral, ComboBox cboControl, ComboBox cboSubsidiary, 
                                        List<Parties4SubLedger> PartSL, List<Products4SubLedger> ProdSL)
        {
            if (cboControl.SelectedItem != null)
            {
                int generalAccountCode = Convert.ToInt32(cboGeneral.SelectedValue);
                int controlAccountCode = Convert.ToInt32(cboControl.SelectedValue);

                switch (generalAccountCode)
                {
                    case 201:
                    case 601:
                    case 602:
                    case 701:
                    case 705:
                    case 706:
                    case 707:
                    case 708:
                        List<string> Productlist = ProdSL.Where(x => x.ControlCode == controlAccountCode).Select(x => x.ProductName).Distinct().ToList();
                        cboSubsidiary.ItemsSource = Productlist;
                        cboSubsidiary.SelectedIndex = 0;
                        break;

                    default:
                        List<string> Partylist = PartSL.Where(x => x.ControlCode == controlAccountCode).Select(x => x.PartyName).Distinct().ToList();
                        cboSubsidiary.ItemsSource = Partylist;
                        cboSubsidiary.SelectedIndex = 0;
                        break;
                }
            }
            else
            {
                cboSubsidiary.ItemsSource = null;
                cboSubsidiary.SelectedItem = null;
            }
        }

        public void BindSubsidiaryCodeCombo(ComboBox cboGeneral, ComboBox cboControl, ComboBox cboSubsidiary, ComboBox cboCode,
                                            List<Parties4SubLedger> PartSL, List<Products4SubLedger> ProdSL)
        {
            if (cboSubsidiary.SelectedItem != null)
            {
                string subName = cboSubsidiary.SelectedItem.ToString();
                int generalAccountCode = Convert.ToInt32(cboGeneral.SelectedValue);
                int controlCode = Convert.ToInt32(cboControl.SelectedValue);
                switch (generalAccountCode)
                {
                    case 201:
                    case 601:
                    case 602:
                    case 701:
                    case 705:
                    case 706:
                    case 707:
                    case 708:
                        int ProductCode = ProdSL.Where(x => x.ProductName == subName && x.ControlCode == controlCode).Select(x => x.ProductCode).FirstOrDefault();
                        cboCode.Items.Clear();
                        cboCode.Items.Add(ProductCode);
                        cboCode.SelectedIndex = 0;
                        break;

                    default:
                        List<int> Partylist = PartSL.Where(x => x.PartyName == subName && x.ControlCode == controlCode).Select(x => x.PartyId).ToList();
                        if (cboCode.Items.Count > 0)
                        {
                            cboCode.ItemsSource = null;
                            cboCode.Items.Clear();
                        }
                        cboCode.ItemsSource = Partylist;
                        cboCode.SelectedIndex = 0;
                        break;
                }
            }
            else
            {
                cboCode.ItemsSource = null;
                cboCode.SelectedItem = null;
            }
        }
    }
}