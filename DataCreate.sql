SET NOCOUNT ON
GO
set nocount    on

USE master
GO
	if exists (select * from sysdatabases where name='TEST3')
	BEGIN
		DROP DATABASE TEST3
	END
GO
CHECKPOINT
go

CREATE DATABASE TEST3

Use [TEST3]
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
	SHOA nvarchar(50) not null,
	[DESCRIPTION] nvarchar(max) null,

PRIMARY KEY (SCODE),
FOREIGN KEY (CCODE) REFERENCES CHeads(CCODE),
FOREIGN KEY (MCODE) REFERENCES MHeads(MCODE),
FOREIGN KEY (GCODE) REFERENCES GHeads(GCODE)
)

CREATE TABLE TTable(
	Id int not null UNIQUE IDENTITY(1,1),
	[Date] date not null,
	DMCode int not null,
	DGCode int not null,
	DCCode int not null,
	DSCode int not null,
	CMCode int not null,
	CGCode int not null,
	CCCode int not null,
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
	Narration nvarchar(max),

FOREIGN KEY (DMCode) REFERENCES MHeads(MCODE),
FOREIGN KEY (DGCode) REFERENCES GHeads(GCODE),
FOREIGN KEY (DCCode) REFERENCES CHeads(CCODE),
FOREIGN KEY (DSCode) REFERENCES SHeads(SCODE),
FOREIGN KEY (CMCode) REFERENCES MHeads(MCODE),
FOREIGN KEY (CGCode) REFERENCES GHeads(GCODE),
FOREIGN KEY (CCCode) REFERENCES CHeads(CCODE),
FOREIGN KEY (CSCode) REFERENCES SHeads(SCODE)
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
	(40100000, 40000000, 'Accounts Payable', 'Lists Accounts Payable'),
	(40200000, 40000000, 'Advance', 'Lists Advances to be adjusted'),
	(50100000, 50000000, 'Capital', 'Lists Proprietors Capital'),
	(50200000, 50000000, 'Profit and Loss', 'Lists Profit and Loss Accounts')

INSERT INTO CHeads VALUES
	(10201000, 10200000, 10000000, 'Transports', 'List Transports'),
	(10202000, 10200000, 10000000, 'Furniture', 'List Furnitures'),
	(10203000, 10200000, 10000000, 'Electronic Equipments', 'List Electronic Equipments'),
	(20101000, 20100000, 20000000, 'Inventory Cement', 'List Cements'),
	(20102000, 20100000, 20000000, 'Inventory Steel', 'List Steel'),
	(20201000, 20200000, 20000000, 'Advance to Suppliers', 'List Advance to Suppliers'),
	(20202000, 20200000, 20000000, 'Advance to Others', 'List Advance to Others'),
	(20301000, 20300000, 20000000, 'Receivable from Customers', 'List Receivable from Customers'),
	(20302000, 20300000, 20000000, 'Receivable from Others', 'List Receivable from Others'),

	(20401000, 20400000, 20000000, 'Cash', 'Lists Cash'),
	(20402000, 20400000, 20000000, 'Bank', 'Lists Bank'),

	(40101000, 40100000, 40000000, 'Payable to Suppliers', 'List Payable to Suppliers'),

	(40102000, 40100000, 40000000, 'Payable to Customers', 'List Payable to Customers'),

	(40103000, 40100000, 40000000, 'Payable to Others', 'List Payable to Others'),
	(40201000, 40200000, 40000000, 'Advance from Customers', 'List unadjusted advance from customers'),
	(50101000, 50100000, 50000000, 'Cash Capital', 'List Cash Capital'),
	(50102000, 50100000, 50000000, 'Capital in Kind', 'List Capital in Kind'),
	(50201000, 50200000, 50000000, 'Sales Cement', 'Income'),
	(50202000, 50200000, 50000000, 'Sales Steel', 'Income'),
	(50203000, 50200000, 50000000, 'Sales Other', 'Income'),
	(50204000, 50200000, 50000000, 'Cost of Goods Sold - Cement', 'Expense'),
	(50205000, 50200000, 50000000, 'Cost of Goods Sold - Steel', 'Expense'),
	(50206000, 50200000, 50000000, 'Salaries', 'Expense'),
	(50207000, 50200000, 50000000, 'Conveyance', 'Expense'),
	(50208000, 50200000, 50000000, 'Carriage Inwards', 'Expense'),
	(50209000, 50200000, 50000000, 'Carriage Outwards', 'Expense'),
	(50210000, 50200000, 50000000, 'Lunch', 'Expense'),
	(50211000, 50200000, 50000000, 'Printing and Stationary', 'Expense'),
	(50212000, 50200000, 50000000, 'Entertainment', 'Expense'),
	(50213000, 50200000, 50000000, 'Weight Adjustment', 'Expense'),

	(50214000, 50200000, 50000000, 'Sales Return Cement', 'Income'),
	(50215000, 50200000, 50000000, 'Sales Return Steel', 'Income'),

	(50216000, 50200000, 50000000, 'Adjustment - Sales Return Cement', 'Income'),
	(50217000, 50200000, 50000000, 'Adjustment - Sales Return Steel', 'Income')


INSERT INTO SHeads VALUES
	(20401001, 20401000, 20400000, 20000000, 'Cash in Hand', 'Lists Cash in Hand'),

	(50201001, 50201000, 50200000, 50000000, 'Premier','Sales of 50 kg Premier'),
	(50201002, 50201000, 50200000, 50000000, 'Shah Special','Sales of 50 kg Shah Special'),
	(50201003, 50201000, 50200000, 50000000, 'Shah Popular','Sales of 50 kg Shah Popular'),
	(50201004, 50201000, 50200000, 50000000, 'Diamond','Sales of 50 kg Diamond'),
	(50201005, 50201000, 50200000, 50000000, 'Holcim','Sales of 50 kg Holcim'),

	(20101001, 20101000, 20100000, 20000000, 'Premier','Inventory of 50 kg Premier'),
	(20101002, 20101000, 20100000, 20000000, 'Shah Special','Inventory of 50 kg Shah Special'),
	(20101003, 20101000, 20100000, 20000000, 'Shah Popular','Inventory of 50 kg Shah Popular'),
	(20101004, 20101000, 20100000, 20000000, 'Diamond','Inventory of 50 kg Diamond'),
	(20101005, 20101000, 20100000, 20000000, 'Holcim','Inventory of 50 kg Holcim'),

	(50204001, 50204000, 50200000, 50000000, 'Premier','Cost of Goods Sold 50 kg Premier'),
	(50204002, 50204000, 50200000, 50000000, 'Shah Special','Cost of Goods Sold 50 kg Shah Special'),
	(50204003, 50204000, 50200000, 50000000, 'Shah Popular','Cost of Goods Sold 50 kg Shah Popular'),
	(50204004, 50204000, 50200000, 50000000, 'Diamond','Cost of Goods Sold 50 kg Diamond'),
	(50204005, 50204000, 50200000, 50000000, 'Holcim','Cost of Goods Sold 50 kg Holcim'),

	(50202001, 50202000, 50200000, 50000000, 'AKS 12mm', 'Sales of AKS 12mm Steel'),
	(50202002, 50202000, 50200000, 50000000, 'AKS 10mm', 'Sales of AKS 10mm Steel'),

	(20102001, 20102000, 20100000, 20000000, 'AKS 12mm', 'Inventory of AKS 12mm'),
	(20102002, 20102000, 20100000, 20000000, 'AKS 10mm', 'Inventory of AKS 10mm'),

	(50205001, 50205000, 50200000, 50000000, 'AKS 12mm', 'Cost of Goods Sold AKS 12mm'),
	(50205002, 50205000, 50200000, 50000000, 'AKS 10mm', 'Cost of Goods Sold AKS 10mm'),

	(50213001, 50213000, 50200000, 50000000, 'Premier', 'Weight Adjustment for Loose Premier Cement'),
	(50213002, 50213000, 50200000, 50000000, 'Shah Special', 'Weight Adjustment for Loose Shah Special Cement'),
	(50213003, 50213000, 50200000, 50000000, 'Shah Popular', 'Weight Adjustment for Loose Shah Popular Cement'),
	(50213004, 50213000, 50200000, 50000000, 'Diamond', 'Weight Adjustment for Loose Diamond Cement'),
	(50213005, 50213000, 50200000, 50000000, 'Holcim', 'Weight Adjustment for Loose Holcim Cement'),

	(50214001, 50214000, 50200000, 50000000, 'Premier', 'Sales Return Premier Cement'),
	(50214002, 50214000, 50200000, 50000000, 'Shah Special', 'Sales Return Shah Special Cement'),
	(50214003, 50214000, 50200000, 50000000, 'Shah Popular', 'Sales Return Shah Popular Cement'),
	(50214004, 50214000, 50200000, 50000000, 'Diamond', 'Sales Return Diamond Cement'),
	(50214005, 50214000, 50200000, 50000000, 'Holcim', 'Sales Return Holcim Cement'),

	(50215001, 50215000, 50200000, 50000000, 'AKS 12mm', 'Sales Return AKS 12mm Steel'),
	(50215002, 50215000, 50200000, 50000000, 'AKS 10mm', 'Sales Return AKS 10mm Steel'),

	(50216001, 50216000, 50200000, 50000000, 'Premier', 'Adjustment - Sales Return Cement'),
	(50216002, 50216000, 50200000, 50000000, 'Shah Special', 'Adjustment - Sales Return Cement'),
	(50216003, 50216000, 50200000, 50000000, 'Shah Popular', 'Adjustment - Sales Return Cement'),
	(50216004, 50216000, 50200000, 50000000, 'Diamond', 'Adjustment - Sales Return Cement'),
	(50216005, 50216000, 50200000, 50000000, 'Holcim', 'Adjustment - Sales Return Cement'),

	(50217001, 50217000, 50200000, 50000000, 'AKS 12mm', 'Adjustment - Sales Return AKS 12mm'),
	(50217002, 50217000, 50200000, 50000000, 'AKS 10mm', 'Adjustment - Sales Return AKS 10mm')


-- for Control Ledger Balance
CREATE PROCEDURE Ledger
@CHeadNo int,
@BDate date,
@EDate date
AS
BEGIN
	DECLARE @BBalance money, @Deb money, @Cre money, @MCode int

	SELECT @Deb = SUM(Amount) FROM TTable WHERE DCCode = @CHeadNo AND [Date] < @BDate
	SELECT @Cre = SUM(Amount) FROM TTable WHERE CCCode = @CHeadNo AND [Date] < @BDate
	SELECT @MCode = MCODE FROM CHeads WHERE CCODE = @CHeadNo

	CREATE Table #Temp ([Date] date, CHOA nvarchar(50), SHOA nvarchar(50) null, VcNo int null, Debit money, Credit money)

	IF (@MCode = 10000000 OR @MCode = 20000000)
	BEGIN
		SELECT @BBalance = ISNULL(@Deb, 0) - ISNULL(@Cre, 0)
		INSERT INTO #Temp VALUES (@BDate, 'balance', 'b/d', null, @BBalance, 0);
	END

	ELSE
	BEGIN
		SELECT @BBalance = ISNULL(@Cre, 0) - ISNULL(@Deb, 0)
		INSERT INTO #Temp VALUES (@BDate, 'balance', 'b/d', null, 0, @BBalance);
	END;

	WITH T AS
	(
		SELECT [Date], CHOA, SHOA, VcNo, Debit, Credit FROM #Temp

		UNION ALL

		SELECT [Date], CHeads.CHOA, SHeads.SHOA, VcNo, Amount as Debit, 0 as Credit  FROM TTable
		JOIN SHeads ON
		SHeads.SCODE = TTable.CSCode
		JOIN CHeads ON
		CHeads.CCODE = TTable.CCCode
		WHERE DCCODE = @CHeadNo

		UNION ALL

		SELECT [Date], CHeads.CHOA, SHeads.SHOA, VcNo, 0 as DEBIT, Amount as Credit  FROM TTable
		JOIN SHeads ON
		SHeads.SCODE = TTable.DSCode
		JOIN CHeads ON
		CHeads.CCODE = TTable.DCCode
		WHERE CCCODE = @CHeadNo
	)
	SELECT [Date], (CHOA + SPACE(1) + SHOA) As Particulars, VcNo, Debit, Credit FROM T
	WHERE [Date] BETWEEN @BDate AND @EDate 
	ORDER BY VcNo
	
END