SET NOCOUNT ON
GO
set nocount    on

USE master
GO
	if exists (select * from sysdatabases where name='Test1')
	BEGIN
		DROP DATABASE Test1
	END
GO
CHECKPOINT
go

CREATE DATABASE Test1
CHECKPOINT
go

Use Test1
GO

-- Main Heads
CREATE TABLE MHeads (
	MCODE tinyint not null UNIQUE,
	MHOA nvarchar(50) not null,
	[DESCRIPTION] nvarchar(50) null,

PRIMARY KEY (MCODE)
)

-- General Ledger
CREATE TABLE GHeads (
	GCODE smallint not null UNIQUE,
	MCODE tinyint not null,
	GHOA nvarchar(50) not null,
	[DESCRIPTION] nvarchar(75) null,

PRIMARY KEY (GCODE),
FOREIGN KEY (MCODE) REFERENCES MHeads(MCODE)
)

-- Control Ledger
CREATE TABLE CHeads (
	CCODE int not null UNIQUE,
	GCODE smallint not null,
	MCODE tinyint not null,
	CHOA nvarchar(50) not null,
	[DESCRIPTION] nvarchar(75) null,

PRIMARY KEY (CCODE),
FOREIGN KEY (MCODE) REFERENCES MHeads(MCODE),
FOREIGN KEY (GCODE) REFERENCES GHeads(GCODE)
)

CREATE TABLE MProducts (
	MId int not null UNIQUE,
	InvCCode int not null,
	MName nvarchar(25) not null,
	[Description] nvarchar(50) null,

PRIMARY KEY (MId),
FOREIGN KEY (InvCCode) REFERENCES CHeads(CCODE)
)

CREATE TABLE GProducts (
	GId int not null UNIQUE,
	MId int not null,
	InvCCode int not null,
	GName nvarchar(25) not null,
	ConToLoose float null,
	[Description] nvarchar(50) null,

PRIMARY KEY (GId),
FOREIGN KEY (MId) REFERENCES MProducts(MId),
FOREIGN KEY (InvCCode) REFERENCES CHeads(CCODE)
)

CREATE TABLE Departments(
	DeptId int not null,
	DeptName nvarchar(50) not null,

PRIMARY KEY(DeptId)
)

CREATE TABLE Employees(
	EmpId int not null,
	DeptId int not null,
	Designation nvarchar(50) not null,
	Name nvarchar(75) not null,
	[Address] nvarchar (150) not null,
	ContactNo nvarchar(15) not null,
	Salary int not null,

PRIMARY KEY(EmpId), 
FOREIGN KEY(DeptId) REFERENCES Departments(DeptId)
)

CREATE TABLE Customers(
	CustId int not null,
	Name nvarchar(75) not null,
	[Address] nvarchar (150) not null,
	ContactNo nvarchar(15) not null

PRIMARY KEY(CustId)
)

CREATE TABLE Suppliers(
	SupId int not null,
	Name nvarchar(75) not null,
	[Address] nvarchar (150) not null,
	ContactNo nvarchar(15) not null

PRIMARY KEY(SupId)
)

CREATE TABLE Owners(
	OwnId int not null,
	CCode int not null,
	Name nvarchar(75) not null,
	[Address] nvarchar (150) not null,
	ContactNo nvarchar(15) not null

PRIMARY KEY(OwnId)
FOREIGN KEY (CCode) REFERENCES CHeads(CCode)
)

CREATE TABLE Others(
	OthId int not null,
	Name nvarchar(75) not null,
	[Address] nvarchar (150) not null,
	ContactNo nvarchar(15) not null

PRIMARY KEY(OthId)
)

CREATE TABLE Banks(
	BankId int not null,
	Name nvarchar(75) not null,
	Branch nvarchar(75) not null,
	AccountType nvarchar(50) not null,
	AccountNo nvarchar(50) not null

PRIMARY KEY(BankId)
)

CREATE TABLE Govt(
	GovtId int not null,
	DeptName nvarchar(75) not null,
	Zone nvarchar(75) not null,
	AccountNo nvarchar(75) not null

PRIMARY KEY(GovtId)
)

CREATE TABLE Inventories(	
	Id int not null UNIQUE IDENTITY(1,1),
	[Date] date not null,
	VcNo int not null,
	UnitQtyRec float null,
	UnitQtyIss float null,
	UnitQtyRecAmt money null,
	UnitQtyIssAmt money null,
	KGQtyRec float null,
	KGQtyIss float null,
	KGQtyRecAmt money null,
	KGQtyIssAmt money null,
	LotNo int null,
	LooseLotNo int null,
	Challan nvarchar(50) null,
	GenProId int null,
	PartyId int null

FOREIGN KEY (GenProId) REFERENCES GProducts(GId)
)

CREATE TABLE OtherNotes(
	Id int not null UNIQUE,
	CCode int not null,
	SubHeads varchar(50) not null

FOREIGN KEY (CCode) REFERENCES CHeads(CCode)
)

CREATE TABLE TransTable(
	Id int not null UNIQUE IDENTITY(1,1),
	[Date] date not null,
	DCCode int not null,
	CCCode int not null,
	Amount money null,
	VcNo int not null,
	DPartyId int null,
	CPartyId int null,
	DProId int null,
	CProId int null,
	SubHeads int null,
	OtherSpec varchar(100) null
	
FOREIGN KEY (DCCode) REFERENCES CHeads(CCODE),
FOREIGN KEY (CCCode) REFERENCES CHeads(CCODE),
FOREIGN KEY (DProId) REFERENCES GProducts(GId),
FOREIGN KEY (CProId) REFERENCES GProducts(GId)
)

CREATE TABLE FixedAssetsItem(		
	CCode int not null,
	ItemCode int not null,
	Depreciation float null,
	ItemName varchar(100) not null,
	[Description] varchar(150) not null

PRIMARY KEY (ItemCode),
FOREIGN KEY (CCode) REFERENCES CHeads(CCode)
)

CREATE TABLE FixedAssets(	
	Id int not null UNIQUE IDENTITY(1,1),
	[Date] date not null,
	VcNo int not null,
	QtyIn float null,
	QtyOut float null,
	QtyInAmt money null,
	QtyOutAmt money null,
	AmountSold money null,
	LotNo int null,
	Tag varchar(50) null,
	Challan nvarchar(50) null,
	CCode int not null,
	ItemCode int not null,
	AIN bigint not null,
	PartyId int null

FOREIGN KEY (ItemCode) REFERENCES FixedAssetsItem(ItemCode),
FOREIGN KEY (CCode) REFERENCES CHeads(CCode)
)

INSERT INTO MHeads VALUES
	(1, 'Non-Current Assets', 'Asset'),
	(2, 'Current Assets', 'Asset'),
	(3, 'Non-Current Liabilities', 'Liability and Equity'),
	(4, 'Current Liabilities', 'Liability and Equity'),
	(5, 'Equity', 'Liability and Equity'),
	(6, 'Income', 'Liability and Equity'),
	(7, 'Expense', 'Liability and Equity'),
	(8, 'Appropriation', 'Liability and Equity')

INSERT INTO GHeads VALUES
	(101, 1, 'Fixed Assets', 'Non-Current Assets'),

	(201, 2, 'Inventories', 'Current Assets'),
	(202, 2, 'Advance', 'Current Assets'),
	(203, 2, 'Accounts Receivable', 'Current Assets'),
	(204, 2, 'Transactions for Fixed Assets', 'Current Assets'),
	(205, 2, 'Cash and Bank', 'Current Assets'),

	(301, 3, 'Long-term Loan', 'Non-Current Liabilities'),

	(401, 4, 'Accounts Payable', 'Current Liabilities'),
	(402, 4, 'Advance', 'Current Liabilities'),
	(403, 4, 'Short-term Loan', 'Current Liabilities'),
	(404, 4, 'Transactions for Fixed Assets', 'Current Liabilities'),

	(501, 5, 'Ordinary Share', 'Equity'),
	(502, 5, '5% Preferred Share', 'Equity'),
	(503, 5, 'Dividend Payable', 'Equity'),
	(504, 5, 'Reserve', 'Equity'),
	(505, 5, 'Accumulated Depreciation', 'Equity'),

	(601, 6, 'Sales', 'Income'),
	(602, 6, 'Sales Return', 'Income'),
	(603, 6, 'Other Income', 'Income'),

	(701, 7, 'Cost of Goods Sold', 'Expense'),
	(702, 7, 'Remuneration, Salary and Wages', 'Expense'),
	(703, 7, 'Entertainment', 'Expense'),
	(704, 7, 'Other Expenses', 'Expense'),
	(705, 7, 'Weight Loss', 'Expense'),
	(706, 7, 'Sales Return Adjustment', 'Expense'),
	(707, 7, 'Purchase Return', 'Expense'),	
	(708, 7, 'Weight Gain', 'Expense'),
	(709, 7, 'Depreciation', 'Expense'),

	(801, 8, 'Appropriation', 'Appropriation')
	

INSERT INTO CHeads VALUES

	(20201, 202, 2, 'Advance to Suppliers', 'List Advance to Suppliers'),
	(20202, 202, 2, 'Advance Salary', 'List Advance to Others'),
	(20203, 202, 2, 'Loan to Employees', 'List Advance to Others'),
	(20204, 202, 2, 'Advance to Others', 'List Advance to Suppliers'),
	(20301, 203, 2, 'Receivable from Customers', 'List Receivable from Customers'),
	(20302, 203, 2, 'Receivable from Suppliers', 'List Receivable from Others'),
	(20303, 203, 2, 'Receivable from Others', 'List Receivable from Others'),

	(20401, 204, 2, 'Advance to Suppliers', 'List Advance for Fixed Assets'),
	(20402, 204, 2, 'Advance to Others', 'List Advance for Fixed Assets'),
	(20403, 204, 2, 'Receivable for Sale of Fixed Assets', 'List Advance for Fixed Assets'),

	(20501, 205, 2, 'Cash', 'Lists Cash'),
	(20502, 205, 2, 'Bank', 'Lists Bank'),
	(30101, 301, 3, 'LTL from Owners','Loan from Owners'),

	(40101, 401, 4, 'Payable to Suppliers', 'List Payable to Suppliers'),
	(40102, 401, 4, 'Payable to Customers', 'List Payable to Customers'),
	(40103, 401, 4, 'Payable to Others', 'List Payable to Others'),
	(40104, 401, 4, 'Salary Payable', 'List Payable to Others'),
	(40105, 401, 4, 'TDS Payable', 'List Payable to Others'),
	(40106, 401, 4, 'Direct Cost Payable', 'List Payable to Others'),
	(40107, 401, 4, 'Indirect Expense Payable', 'List Payable to Others'),
	(40201, 402, 4, 'Advance from Customers', 'List unadjusted advance from customers'),
	(40301, 403, 4, 'STL from Owners', 'Loan'),

	(40401, 404, 4, 'Payable to Suppliers', 'List Payable for Fixed Assets'),
	(40402, 404, 4, 'Direct Cost Payable', 'List Payable for Fixed Assets'),
	(40403, 404, 4, 'Payable to Others', 'List Payable for Fixed Assets'),
	(40404, 404, 4, 'Advance against Sale of Fixed Assets', 'List Payable for Fixed Assets'),

	(50101, 501, 5, 'Directors', 'Ordinary Share'),
	(50102, 501, 5, 'General', 'Ordinary Share'),
	(50201, 502, 5, 'Directors', 'Ordinary Share'),
	(50202, 502, 5, 'General', 'Ordinary Share'),
	(50301, 503, 5, 'Ordinary Share', 'Dividend Payable'),
	(50302, 503, 5, '5% Preferred Share', 'Dividend Payable'),
	(50401, 504, 5, 'General Reserve', 'Reserve'),
	(50402, 504, 5, 'Revaluation Reserve', 'Reserve'),
	(50501, 505, 5, 'Accumulated Depreciation', 'Equity'),

	(70201, 702, 7, 'Remuneration', 'Expense'),
	(70202, 702, 7, 'Salary', 'Expense'),
	(70203, 702, 7, 'Wages', 'Expense'),
	(70401, 704, 7, 'Indirect Expense', 'Other Expense'),
	(70901, 709, 7, 'Depreciation', 'Expense'),

	(80101, 801, 8, 'Appropriation', 'Appropriation')

INSERT INTO Departments VALUES
	(4010, 'Administration'),
	(4020, 'Accounting'),
	(4030, 'Marketing'),
	(4040, 'Procurement')

INSERT INTO OtherNotes VALUES
	(4010601, 40106, 'Custom Duty'),
	(4010602, 40106, 'Carriage Inward'),
	(4010603, 40106, 'Loading'),
	(4010604, 40106, 'Unloading'),
	(4010701, 40107, 'Loading'),
	(4010702, 40107, 'Delivery'),
	(5030101, 50301, 'Cash'),
	(5030102, 50301, 'Scrip'),
	(5030201, 50302, 'Cash')


USE Test1
GO

CREATE PROCEDURE PartyList4SubLedger
AS
BEGIN
	WITH P AS(
			SELECT CustId AS ID, Name FROM Customers
			UNION ALL
			SELECT SupId AS ID, Name FROM Suppliers
			UNION ALL
			SELECT OwnId AS ID, Name FROM Owners
			UNION ALL
			SELECT EmpId AS ID, Name FROM Employees
			UNION ALL
			SELECT OthId AS ID, Name FROM Others
			UNION ALL
			SELECT BankId AS ID, Name FROM Banks
			UNION ALL
			SELECT GovtId AS ID, DeptName FROM Govt)
	SELECT * INTO #TempParty FROM P;
	WITH P AS(
		SELECT DCCode AS CCode, DPartyId AS PartyId FROM TransTable WHERE DPartyId IS NOT NULL
		UNION ALL
		SELECT CCCode AS CCode, CPartyId AS PartyId FROM TransTable WHERE CPartyId IS NOT NULL)
	SELECT DISTINCT CCode, PartyId, t.Name FROM P
	JOIN #TempParty t ON t.ID = P.PartyId  
END

GO
USE Test1
GO

CREATE PROCEDURE ProductList4SubLedger
AS
BEGIN
	WITH P AS(
		select DCCode AS CCode, DProId AS ProId From TransTable WHERE DProId IS NOT NULL
		UNION ALL
		select CCCode AS CCode, CProId AS ProId From TransTable WHERE CProId IS NOT NULL)
	SELECT DISTINCT CCode, ProId, g.GName FROM P
	JOIN GProducts g ON g.GId = P.ProId
END

GO

