SET NOCOUNT ON
GO
set nocount    on

USE master
GO
	if exists (select * from sysdatabases where name='Working')
	BEGIN
		DROP DATABASE Working
	END
GO
CHECKPOINT
go

CREATE DATABASE Working
CHECKPOINT
go

Use [Working]
GO

-- Main Heads
CREATE TABLE MHeads (
	MCODE int not null UNIQUE,
	MHOA nvarchar(50) not null,
	[DESCRIPTION] nvarchar(max) null,

PRIMARY KEY (MCODE)
)

-- General Ledger
CREATE TABLE GHeads (
	GCODE int not null UNIQUE,
	MCODE int not null,
	GHOA nvarchar(50) not null,
	[DESCRIPTION] nvarchar(max) null,

PRIMARY KEY (GCODE),
FOREIGN KEY (MCODE) REFERENCES MHeads(MCODE)
)

-- Control Ledger
CREATE TABLE CHeads (
	CCODE int not null UNIQUE,
	GCODE int not null,
	MCODE int not null,
	CHOA nvarchar(50) not null,
	[DESCRIPTION] nvarchar(max) null,

PRIMARY KEY (CCODE),
FOREIGN KEY (MCODE) REFERENCES MHeads(MCODE),
FOREIGN KEY (GCODE) REFERENCES GHeads(GCODE)
)

-- Control Ledger
CREATE TABLE SHeads (
	SCODE int not null UNIQUE,
	CCODE int not null,
	GCODE int not null,
	MCODE int not null,
	MId int null,
	GId int null,
	SHOA nvarchar(50) not null,
	[DESCRIPTION] nvarchar(max) null,

PRIMARY KEY (SCODE),
FOREIGN KEY (CCODE) REFERENCES CHeads(CCODE),
FOREIGN KEY (MCODE) REFERENCES MHeads(MCODE),
FOREIGN KEY (GCODE) REFERENCES GHeads(GCODE)
)

CREATE TABLE MProducts (
	MId int not null UNIQUE,
	InvCCode int not null,
	MName nvarchar(50) not null,
	[Description] nvarchar(max) null,

PRIMARY KEY (MId),
FOREIGN KEY (InvCCode) REFERENCES CHeads(CCODE)
)

CREATE TABLE GProducts (
	GId int not null UNIQUE,
	MId int not null,
	InvCCode int not null,
	InvSCode int not null,
	GName nvarchar(50) not null,
	[Description] nvarchar(max) null,

PRIMARY KEY (GId),
FOREIGN KEY (MId) REFERENCES MProducts(MId),
FOREIGN KEY (InvCCode) REFERENCES CHeads(CCODE),
FOREIGN KEY (InvSCode) REFERENCES SHeads(SCODE)
)

CREATE TABLE CProducts (
	CId int not null UNIQUE,
	GId int not null,
	MId int not null,
	InvCCode int not null,
	InvSCode int not null,
	CName nvarchar(50) not null,
	ConToLoose float null,
	[Description] nvarchar(max) null,

PRIMARY KEY (CId),
FOREIGN KEY (MId) REFERENCES MProducts(MId),
FOREIGN KEY (GId) REFERENCES GProducts(GId),
FOREIGN KEY (InvCCode) REFERENCES CHeads(CCODE),
FOREIGN KEY (InvSCode) REFERENCES SHeads(SCODE)
)

CREATE TABLE Territories (
	TId int not null IDENTITY(1,1),
	TName nvarchar(50) not null,
	Division nvarchar(50) not null

PRIMARY KEY(TId)
)

CREATE TABLE MParties (
	MId int not null UNIQUE,
	MName nvarchar(50) not null,
	[Description] nvarchar(max) null,

PRIMARY KEY (Mid)
)

CREATE TABLE GParties (
	Id int not null IDENTITY(1,1),
	GId int not null,
	MId int not null,
	TId int not null,
	GName nvarchar(50) not null,
	[Address] nvarchar(max) not null,
	ContactNo nvarchar(20) null,

PRIMARY KEY(GId),
FOREIGN KEY (MId) REFERENCES Mparties (MId),
FOREIGN KEY (TId) REFERENCES Territories (TId)
)

CREATE TABLE TTable(
	Id int not null UNIQUE IDENTITY(1,1),
	[Date] date not null,
	DSCode int not null,
	CSCode int not null,
	Amount money not null,
	VcNo int not null,
	TransRefId int not null,
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
	DelChallan nvarchar(50) null,
	MRNo nvarchar(50) null,
	ChqNo nvarchar(50) null,
	Narration nvarchar(max),
	PartyId int null,
	DCPId int null,
	CCPId int null,


FOREIGN KEY (DSCode) REFERENCES SHeads(SCODE),
FOREIGN KEY (CSCode) REFERENCES SHeads(SCODE),
FOREIGN KEY (PartyId) REFERENCES GParties (GId),
FOREIGN KEY (DCPId) REFERENCES CProducts(CId),
FOREIGN KEY (CCPId) REFERENCES CProducts(CId)
)

INSERT INTO MHeads VALUES
	(10000000, 'Non-Current Assets', 'Asset'),
	(20000000, 'Current Assets', 'Asset'),
	(30000000, 'Non-Current Liabilities', 'Liability and Equity'),
	(40000000, 'Current Liabilities', 'Liability and Equity'),
	(50000000, 'Equity', 'Liability and Equity')

INSERT INTO GHeads VALUES
	(10100000, 10000000, 'Immovable Assets', 'Lists Immovable Non-Current Asssets'),
	(10200000, 10000000, 'Movable Assets', 'Lists Movable Non-Current Asssets'),
	(20100000, 20000000, 'Inventories', 'Lists Inventories'),
	(20200000, 20000000, 'Advance', 'Lists Advances'),
	(20300000, 20000000, 'Accounts Receivable', 'Lists Accounts Receivable'),
	(20400000, 20000000, 'Cash and Bank', 'Lists Cash and Bank'),
	(30100000, 30000000, 'Long-term Loan', 'Term Loan'),
	(40100000, 40000000, 'Accounts Payable', 'Lists Accounts Payable'),
	(40200000, 40000000, 'Advance', 'Lists Advances to be adjusted'),
	(40300000, 40000000, 'Short-term Loan', 'Loan'),
	(50100000, 50000000, 'Capital', 'Lists Proprietors Capital'),
	(50200000, 50000000, 'Profit and Loss', 'Lists Profit and Loss Accounts'),
	(50300000, 50000000, 'Dividend Payable', 'Lists Profit and Loss Accounts')

INSERT INTO CHeads VALUES
	(10201000, 10200000, 10000000, 'Transports', 'List Transports'),
	(10202000, 10200000, 10000000, 'Furniture', 'List Furnitures'),
	(10203000, 10200000, 10000000, 'Electronic Equipments', 'List Electronic Equipments'),
	(20201000, 20200000, 20000000, 'Advance to Suppliers', 'List Advance to Suppliers'),
	(20202000, 20200000, 20000000, 'Advance Salary', 'List Advance to Others'),

	(20301000, 20300000, 20000000, 'Receivable from Customers', 'List Receivable from Customers'),
	(20302000, 20300000, 20000000, 'Receivable from Suppliers', 'List Receivable from Others'),
	(20303000, 20300000, 20000000, 'Receivable from Others', 'List Receivable from Others'),
	(20401000, 20400000, 20000000, 'Cash', 'Lists Cash'),
	(20402000, 20400000, 20000000, 'Bank', 'Lists Bank'),
	(30101000, 30100000, 30000000, 'LTL from Owners','Loan from Owners'),
	(40101000, 40100000, 40000000, 'Payable to Suppliers', 'List Payable to Suppliers'),
	(40102000, 40100000, 40000000, 'Payable to Customers', 'List Payable to Customers'),
	(40103000, 40100000, 40000000, 'Payable to Others', 'List Payable to Others'),
	(40104000, 40100000, 40000000, 'Salary Payable', 'List Payable to Others'),

	(40301000, 40300000, 40000000, 'STL from Owners', 'Loan'),
	(40201000, 40200000, 40000000, 'Advance from Customers', 'List unadjusted advance from customers'),
	(50101000, 50100000, 50000000, 'Cash Capital', 'List Cash Capital'),

	(50201000, 50200000, 50000000, 'Sales', 'Income'),
	(50202000, 50200000, 50000000, 'Sales Return', 'Income'),
	(50203000, 50200000, 50000000, 'Cost of Goods Sold', 'Expense'),
	(50204000, 50200000, 50000000, 'Weight Loss', 'Expense'),
	(50205000, 50200000, 50000000, 'Sales Return Adjustment', 'Expense'),
	(50206000, 50200000, 50000000, 'Purchase Return', 'Expense'),
	(50207000, 50200000, 50000000, 'Weight Gain', 'Expense'),

	(50208000, 50200000, 50000000, 'Salaries', 'Expense'),
	(50209000, 50200000, 50000000, 'Conveyance', 'Expense'),
	(50210000, 50200000, 50000000, 'Carriage Inwards', 'Expense'),
	(50211000, 50200000, 50000000, 'Carriage Outwards', 'Expense'),
	(50212000, 50200000, 50000000, 'Lunch', 'Expense'),
	(50213000, 50200000, 50000000, 'Printing and Stationary', 'Expense'),
	(50214000, 50200000, 50000000, 'Entertainment', 'Expense'),
	(50301000, 50300000, 50000000, 'Final Dividend Payable', 'Lists Profit and Loss Accounts')

INSERT INTO SHeads VALUES
	(20401001, 20401000, 20400000, 20000000, null, null, 'Cash in Hand', 'Lists Cash in Hand'),
	(20401002, 20401000, 20400000, 20000000, null, null, 'Cash at Bank', 'Lists Cash in Hand')

INSERT INTO MParties VALUES
	(10000, 'Owner', 'General Customers'),
	(20000, 'Customer', 'General Customers'),
	(30000, 'Supplier', 'General Suppliers'),
	(40000, 'Employee', 'General Customers')

INSERT INTO Territories VALUES
	('Tangail', 'Dhaka'),
	('Bandarban', 'Chittagong')
