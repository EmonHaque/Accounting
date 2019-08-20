CREATE PROCEDURE InventoriesProc
@fromDate date,
@toDate date,
@GenProdId int,
@unitSpec varchar(10)
AS
BEGIN
	WITH P AS(
		SELECT CustId AS ID, Name FROM Customers
		UNION ALL
		SELECT SupId AS ID, Name FROM Suppliers)
	SELECT * INTO #TempParty FROM P;

	WITH P AS(
		SELECT g.InvCCode, g.MId, g.GId, c.CHOA, m.MName, g.GName FROM GProducts g
		JOIN MProducts m ON m.MId = g.MId
		JOIN CHeads c ON c.CCODE = g.InvCCode)
	SELECT * INTO #TempProduct FROM P;
	--Filter here
	SELECT * INTO #TempInventory FROm Inventories WHERE GenProId = @GenProdId

	DECLARE @BQtyDebit float, @BQtyCredit float, @BQtyBalance float, 
			@BAmtDebit float, @BAmtCredit float, @BAmtBalance float, @Id int

	IF(@unitSpec = 'Unit')
	BEGIN
		WITH P(Id, [Date], Party, VcNo, Lot, QtyRec, QtyIss, AmtRec, AmtIss) AS(
		SELECT i.Id, i.Date, t.Name +SPACE(1)+ CONVERT(varchar(10),t.ID), i.VcNo, i.LotNo, 
		i.UnitQtyRec, i.UnitQtyIss, i.UnitQtyRecAmt, i.UnitQtyIssAmt
		FROM #TempInventory i
		JOIN #TempProduct tp ON tp.GId = i.GenProId
		JOIN #TempParty t ON t.ID = i.PartyId
		WHERE GenProId = @GenProdId 
				AND (i.UnitQtyRec IS NOT NULL OR i.UnitQtyIss IS NOT NULL)
				AND [Date] BETWEEN @fromDate AND @toDate)
		SELECT * INTO #TempInvUnit FROM P;

		SELECT @BQtyDebit = SUM(ISNULL(UnitQtyRec,0)) FROM #TempInventory WHERE [Date] < @fromDate
		SELECT @BQtyCredit = SUM(ISNULL(UnitQtyIss,0)) FROM #TempInventory WHERE [Date] < @fromDate
		SELECT @BAmtDebit = SUM(ISNULL(UnitQtyRecAmt,0)) FROM #TempInventory WHERE [Date] < @fromDate
		SELECT @BAmtCredit = SUM(ISNULL(UnitQtyIssAmt,0)) FROM #TempInventory WHERE [Date] < @fromDate

		SELECT @Id = ISNULL(MIN(Id),0) FROM #TempInvUnit
		SELECT @BQtyBalance = ISNULL(@BQtyDebit,0) - ISNULL(@BQtyCredit,0)
		SELECT @BAmtBalance = ISNULL(@BAmtDebit,0) - ISNULL(@BAmtCredit,0)

		INSERT INTO #TempInvUnit VALUES(@Id-1, @fromDate, 'Balance b/d',  0,0, ISNULL(@BQtyBalance,0), 0,ISNULL(@BQtyBalance,0),0)
		SELECT [Date], Party AS Particulars, VcNo, Lot, QtyRec, QtyIss, AmtRec, AmtIss
		FROM #TempInvUnit ORDER BY Id, [Date], VcNo
	END

	ELSE
	BEGIN
		WITH P(Id, [Date], Party, VcNo, Lot, QtyRec, QtyIss, AmtRec, AmtIss) AS(
		SELECT i.Id, i.Date, t.Name +SPACE(1)+ CONVERT(varchar(10),t.ID), i.VcNo, i.LooseLotNo,
		i.KGQtyRec, i.KGQtyIss, i.KGQtyRecAmt, i.KGQtyIssAmt 
		FROM #TempInventory i
		JOIN #TempProduct tp ON tp.GId = i.GenProId
		JOIN #TempParty t ON t.ID = i.PartyId
		WHERE GenProId = @GenProdId 
				AND (i.KGQtyRec IS NOT NULL OR i.KGQtyIss IS NOT NULL)
				AND [Date] BETWEEN @fromDate AND @toDate)
		SELECT * INTO #TempInvKg FROM P;

		SELECT @BQtyDebit = SUM(ISNULL(KGQtyRec,0)) FROM #TempInventory WHERE [Date] < @fromDate
		SELECT @BQtyCredit = SUM(ISNULL(KGQtyIss,0)) FROM #TempInventory WHERE [Date] < @fromDate
		SELECT @BAmtDebit = SUM(ISNULL(KGQtyRecAmt,0)) FROM #TempInventory WHERE [Date] < @fromDate
		SELECT @BAmtCredit = SUM(ISNULL(KGQtyIssAmt,0)) FROM #TempInventory WHERE [Date] < @fromDate

		SELECT @Id = ISNULL(MIN(Id),0) FROM #TempInvKg
		SELECT @BQtyBalance = ISNULL(@BQtyDebit,0) - ISNULL(@BQtyCredit,0)
		SELECT @BAmtBalance = ISNULL(@BAmtDebit,0) - ISNULL(@BAmtCredit,0)
		INSERT INTO #TempInvKg VALUES(@Id-1, @fromDate, 'Balance b/d',  0,0, ISNULL(@BQtyBalance,0), 0,ISNULL(@BQtyBalance,0),0)

		SELECT [Date], Party AS Particulars, VcNo, Lot, QtyRec, QtyIss, AmtRec, AmtIss
		FROM #TempInvKg ORDER BY Id, [Date], VcNo
	END
END

