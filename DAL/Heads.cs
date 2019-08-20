using System;
namespace DAL
{
    public class MainHeads
    {
        public int MainCode { get; set; }
        public string MainName { get; set; }
    }

    public class GeneralHeads
    {
        public int GeneralCode { get; set; }
        public int MainCode { get; set; }
        public string GeneralName { get; set; }
    }

    public class ControlHeads
    {
        public int ControlCode { get; set; }
        public int GeneralCode { get; set; }
        public int MainCode { get; set; }
        public string ControlName { get; set; }
    }

    public class SubHeads
    {
        public int SubCode { get; set; }
        public int ControlCode { get; set; }
        public string Head { get; set; }
    }

    public class FixedAssets
    {
        public int CCode { get; set; }
        public int ItemCode { get; set; }
        public double DepreciationRate { get; set; }
        public string ItemName { get; set; }
        public string Description { get; set; }
    }

    public class FixedAssetsItem
    {
        public DateTime Date { get; set; }
        public int CCode { get; set; }
        public int ItemCode { get; set; }
        public double QtyIn { get; set; }
        public double QtyOut { get; set; }
        public double AmountIn { get; set; }
        public double AmountOut { get; set; }
        public double AmountSold { get; set; }
        public int LotNo { get; set; }
        public long AIN { get; set; }
        public int PartyId { get; set; }
    }
    public class MainProduct
    {
        public int MainId { get; set; }
        public int InventoryCode { get; set; }
        public string MainName { get; set; }
    }

    public class GeneralProduct
    {
        public int GeneralId { get; set; }
        public int MainId { get; set; }
        public int InventoryCode { get; set; }
        public string GeneralName { get; set; }
        public double LooseConversionFactor { get; set; }
    }

    public class Departments
    {
        public int DeptId { get; set; }
        public string DeptName { get; set; }
    }

    public class Employees
    {
        public int EmpId { get; set; }
        public int DeptId { get; set; }
        public string Designation { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        public string ContactNo { get; set; }
        public double Salary { get; set; }
    }

    public class Customers
    {
        public int CustId { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        public string ContactNo { get; set; }
    }

    public class Suppliers
    {
        public int SupId { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        public string ContactNo { get; set; }
    }

    public class Owners
    {
        public int OwnId { get; set; }
        public int ControlCode { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        public string ContactNo { get; set; }
    }

    public class Banks
    {
        public int BankId { get; set; }
        public string Name { get; set; }
        public string Branch { get; set; }
        public string AccountType { get; set; }
        public string AccountNo { get; set; }
        public string Head { get; set; }
    }

    public class Others
    {
        public int OthersId { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        public string ContactNo { get; set; }
    }

    public class Government
    {
        public int GovtId { get; set; }
        public string Department { get; set; }
        public string Zone { get; set; }
        public string AccountNo { get; set; }
    }

    public class List4Grid
    {
        public int ItemNo { get; set; }
        public string Serial { get; set; }
        public string Group { get; set; }
        public string Category { get; set; }
        public string Item { get; set; }
        public string Qty { get; set; }
        public string Measure { get; set; }
        public int Voucher { get; set; }
        public string Amount { get; set; }
        public string DirectCost { get; set; }
    }

    public class List4Entry
    {
        public int ItemNo { get; set; }
        public int ControlAccount { get; set; }
        public int Voucher { get; set; }
        public double Amount { get; set; }
        public int LotNo { get; set; }
        public double Quantity { get; set; }
        public string Challan { get; set; }
        public int PartyCode { get; set; }
        public int ControlProductId { get; set; }
    }

    public class List4InventoryOnSale
    {
        public int ItemNo { get; set; }
        public double Amount { get; set; }
        public int LotNo { get; set; }
        public double Quantity { get; set; }
        public string Measure { get; set; }
        public string Challan { get; set; }
        public int ControlProductId { get; set; }
    }

    public class Products4SubLedger
    {
        public int ControlCode { get; set; }
        public int ProductCode { get; set; }
        public string ProductName { get; set; }
    }

    public class Parties4SubLedger
    {
        public int ControlCode { get; set; }
        public int PartyId { get; set; }
        public string PartyName { get; set; }
    }

    public class GeneralEntry4Grid
    {
        public string Serial { get; set; }
        public string TransType { get; set; }
        public string Mode { get; set; }
        public string Voucher { get; set; }
        public string Head { get; set; }
        public string Party { get; set; }
        public string Amount { get; set; }
    }

    public class GeneralEntry4DB
    {
        public int DrCode { get; set; }
        public int CrCode { get; set; }
        public double Amount { get; set; }
        public int Voucher { get; set; }
        public int DPartyId { get; set; }
        public int CPartyId { get; set; }
    }

    public class Employees4Grid
    {
        public string Serial { get; set; }
        public string Name { get; set; }
        public string Designation { get; set; }
        public string Department { get; set; }
        public string Salary { get; set; }
        public string ITDeduction { get; set; }
        public string AdvanceSalaryAdj { get; set; }
        public string Losn2EmployeesAdj { get; set; }
    }

    public class Employees4Entry
    {
        public int EmpId { get; set; }
        public double Salary { get; set; }
        public double ITDeduction { get; set; }
        public double AdvanceSalaryAdj { get; set; }
        public double Losn2EmployeesAdj { get; set; }
        public int ITZoneCode { get; set; }
    }

    public class YearMonth
    {
        public int Year { get; set; }
        public int MonthNumber { get; set; }
        public string Month { get; set; }
    }

    public class Payable
    {
        public int PartyId { get; set; }
        public double AmountPayable { get; set; }
    }

    public class Paid
    {
        public int PartyId { get; set; }
        public double AmountPaid { get; set; }
    }

    public class DividendPayable
    {
        public int ControlCode { get; set; }
        public int PartyId { get; set; }
        public double AmountPayable { get; set; }
        public int SubHead { get; set; }
        public string OtherSpec { get; set; }
    }

    public class DividendPaid
    {
        public int ControlCode { get; set; }
        public int PartyId { get; set; }
        public double AmountPaid { get; set; }
        public int SubHead { get; set; }
        public string OtherSpec { get; set; }
    }

    public class SalaryPayment4Grid
    {
        public string Serial { get; set; }
        public string Name { get; set; }
        public string Designation { get; set; }
        public string Department { get; set; }
        public string Salary { get; set; }
        public string Cash { get; set; }
        public string Bank { get; set; }
    }

    public class SalaryPayment4DB
    {
        public int EmpId { get; set; }
        public double Payable { get; set; }
        public double PaidInCash { get; set; }
        public double PaidThroughBank { get; set; }
        public int BankCode { get; set; }
    }

    public class DirectCost4DBTemp
    {
        public string PaymentMode { get; set; }
        public double Amount { get; set; }
        public int PartyCode { get; set; }
        public int SubCode { get; set; }
        public int BankCode { get; set; }
    }

    public class DirectCost4DB
    {
        public int ItemNo { get; set; }
        public double Amount { get; set; }
        public int PartyCode { get; set; }
        public int SubCode { get; set; }
        public string PaymentMode { get; set; }
        public int BankCode { get; set; }
    }

    public class DirectCost4Grid
    {
        public string Serial { get; set; }
        public string CostItem { get; set; }
        public string Party { get; set; }
        public string PaymentMode { get; set; }
        public string Amount { get; set; }
    }

    public class Capital
    {
        public int Debit { get; set; }
        public int Credit { get; set; }
        public double Amount { get; set; }
        public int DrParty { get; set; }
        public int CrParty { get; set; }
    }

    public class GLTransactions
    {
        public int Id { get; set; }
        public DateTime Date { get; set; }
        public int DGode { get; set; }
        public int DCode { get; set; }
        public int CGode { get; set; }
        public int CCode { get; set; }
        public int Voucher { get; set; }
        public double Amount { get; set; }

    }

    public class CLTransactions
    {
        public int Id { get; set; }
        public DateTime Date { get; set; }
        public int DGode { get; set; }
        public int DCode { get; set; }
        public int CGode { get; set; }
        public int CCode { get; set; }
        public int Voucher { get; set; }
        public double Amount { get; set; }
        public int DParty { get; set; }
        public int CParty { get; set; }
        public int DProduct { get; set; }
        public int CProduct { get; set; }
        public int SubHead { get; set; }

    }

    public class AllParty
    {
        public int Code { get; set; }
        public string Name { get; set; }
    }

    public class ListInventories
    {
        public int Id { get; set; }
        public DateTime Date { get; set; }
        public int VcNo { get; set; }
        public double QtyRec { get; set; }
        public double QtyIss { get; set; }
        public double QtyRecAmt { get; set; }
        public double QtyIssAmt { get; set; }
        public int Lot { get; set; }
        public int GenProdId { get; set; }
        public int PartyId { get; set; }
    }
}