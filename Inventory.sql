
CREATE PROCEDURE Inv
 @BeDate date, 
 @EnDate date, 
 @InvCode int,
 @Specification nvarchar(10)
AS
BEGIN
	IF (@Specification = 'Unit')
	BEGIN
		--Calculates the Beginning Inventory
		WITH Q AS(
		SELECT S.SHOA AS D, SUM(ISNULL(UnitQtyRec,0)) AS QR, SUM(ISNULL(UnitQtyIss,0)) AS QI,
		SUM(ISNULL(UnitQtyRecAmt,0)) AS BR, SUM(ISNULL(UnitQtyIssAmt,0)) AS BI
		FROM TTable
		JOIN SHeads AS S ON S.SCODE = TTable.DSCode
		WHERE DCCode = @InvCode AND CCCode != @InvCode AND LotNo IS NOT null AND [Date] <  @BeDate
		GROUP BY S.SHOA
		UNION ALL
		SELECT SHeads.SHOA AS D, SUM(ISNULL(UnitQtyRec,0)) AS QR, SUM(ISNULL(UnitQtyIss,0)) AS QI,
		SUM(ISNULL(UnitQtyRecAmt,0)) AS BR, SUM(ISNULL(UnitQtyIssAmt,0)) AS BI
		FROM TTable
		JOIN SHeads ON SHeads.SCODE = TTable.CSCode
		WHERE CCCode = @InvCode AND DCCode != @InvCode AND LotNo IS NOT null AND [Date] < @BeDate
		GROUP BY SHeads.SHOA

		UNION ALL
		SELECT SHeads.SHOA AS D, SUM(ISNULL(UnitQtyRec,0)) AS QR, SUM(ISNULL(UnitQtyIss,0)) AS QI,
		SUM(ISNULL(UnitQtyRecAmt,0)) AS BR, SUM(ISNULL(UnitQtyIssAmt,0)) AS BI
		FROM TTable
		JOIN SHeads ON SHeads.SCODE = TTable.CSCode
		WHERE CCCode = @InvCode AND DCCode = @InvCode AND [Date] < @BeDate
		GROUP BY SHeads.SHOA
		) 

		SELECT D AS A, SUM(QR) AS B, SUM(QI) AS C, SUM(BR) AS D, SUM(BI) AS E INTO #Temp1 FROM Q GROUP BY D
		SELECT @BeDate AS [Date], 'Balance b/d' AS Particulars, A AS ItemName, ISNULL(B,0) - ISNULL(C,0) AS UnitQtyRec, 0 AS UnitQtyIss,
				ISNULL(D,0) - ISNULL(E,0) AS UnitQtyRecAmt, 0 AS UnitQtyIssAmt INTO #Temp2 FROM #Temp1;

		-- Calculates Transactions during the specified period
		WITH T AS(
		SELECT [Date], CASE CHeads.CHOA WHEN 'Payable to Suppliers' THEN S.SHOA
		WHEN 'Advance to Suppliers' THEN S.SHOA ELSE CHeads.CHOA END AS Particulars, 
		SHeads.SHOA AS ItemName,
		UnitQtyRec, UnitQtyIss, UnitQtyRecAmt, UnitQtyIssAmt
		FROM TTable
		JOIN CHeads ON CHeads.CCODE = TTable.CCCode
		JOIN SHeads ON SHeads.SCODE = TTable.DSCode
		JOIN SHeads AS S ON S.SCODE = TTable.CSCode
		WHERE DCCode = @InvCode AND CCCode != @InvCode AND LotNo IS NOT null AND [Date] BETWEEN @BeDate AND @EnDate

		UNION ALL
		SELECT [Date], CHeads.CHOA AS Particulars, SHeads.SHOA AS ItemName,
		UnitQtyRec, UnitQtyIss, UnitQtyRecAmt, UnitQtyIssAmt
		FROM TTable
		JOIN CHeads ON CHeads.CCODE = TTable.DCCode
		JOIN SHeads ON SHeads.SCODE = TTable.CSCode
		WHERE CCCode = @InvCode AND DCCode != @InvCode AND LotNo IS NOT null AND [Date] BETWEEN @BeDate AND @EnDate
		
		UNION ALL
		SELECT [Date], 'Transferred to Loose' AS Particulars, SHeads.SHOA AS ItemName,
		UnitQtyRec, UnitQtyIss, UnitQtyRecAmt, UnitQtyIssAmt
		FROM TTable
		JOIN CHeads ON CHeads.CCODE = TTable.DCCode
		JOIN SHeads ON SHeads.SCODE = TTable.CSCode
		WHERE CCCode = @InvCode AND DCCode = @InvCode AND [Date] BETWEEN @BeDate AND @EnDate
		)

		SELECT * INTO #Temp3 FROM T;

		-- Joins both Table
		WITH R ([Date], Particulars, ItemName, UnitQtyRec, UnitQtyIss, UnitQtyRecAmt, UnitQtyIssAmt)AS(
		SELECT * FROM #Temp2
		UNION ALL
		SELECT * FROM #Temp3)
		SELECT * FROM R ORDER BY [Date]
	END

	ELSE IF (@Specification = 'Kg')
	BEGIN
		--Calculates the Beginning Inventory
		WITH Q AS(
		SELECT S.SHOA AS D, SUM(ISNULL(KGQtyRec,0)) AS QR, SUM(ISNULL(KGQtyIss,0)) AS QI,
		SUM(ISNULL(KGQtyRecAmt,0)) AS BR, SUM(ISNULL(KGQtyIssAmt,0)) AS BI
		FROM TTable
		JOIN SHeads AS S ON S.SCODE = TTable.DSCode
		WHERE DCCode = @InvCode AND CCCode != @InvCode AND LooseLotNo IS NOT null AND [Date] <  @BeDate
		GROUP BY S.SHOA
		UNION ALL
		SELECT SHeads.SHOA AS D, SUM(ISNULL(KGQtyRec,0)) AS QR, SUM(ISNULL(KGQtyIss,0)) AS QI,
		SUM(ISNULL(KGQtyRecAmt,0)) AS BR, SUM(ISNULL(KGQtyIssAmt,0)) AS BI
		FROM TTable
		JOIN SHeads ON SHeads.SCODE = TTable.CSCode
		WHERE CCCode = @InvCode AND DCCode != @InvCode AND LooseLotNo IS NOT null AND [Date] < @BeDate
		GROUP BY SHeads.SHOA
		
		UNION ALL
		SELECT SHeads.SHOA AS D, SUM(ISNULL(KGQtyRec,0)) AS QR, SUM(ISNULL(KGQtyIss,0)) AS QI,
		SUM(ISNULL(KGQtyRecAmt,0)) AS BR, SUM(ISNULL(KGQtyIssAmt,0)) AS BI
		FROM TTable
		JOIN SHeads ON SHeads.SCODE = TTable.CSCode
		WHERE CCCode = @InvCode AND DCCode = @InvCode AND [Date] < @BeDate
		GROUP BY SHeads.SHOA
		) 

		SELECT D AS A, SUM(QR) AS B, SUM(QI) AS C, SUM(BR) AS D, SUM(BI) AS E INTO #Temp4 FROM Q GROUP BY D;
		SELECT @BeDate AS [Date], 'Balance b/d' AS Particulars, A AS ItemName, ISNULL(B,0) - ISNULL(C,0) AS UnitQtyRec, 0 AS UnitQtyIss,
				ISNULL(D,0) - ISNULL(E,0) AS UnitQtyRecAmt, 0 AS UnitQtyIssAmt INTO #Temp5 FROM #Temp4;

		-- Calculates Transactions during the specified period
		WITH T AS(
		SELECT [Date], CASE CHeads.CHOA WHEN 'Payable to Suppliers' THEN S.SHOA
		WHEN 'Advance to Suppliers' THEN S.SHOA ELSE CHeads.CHOA END AS Particulars, SHeads.SHOA AS ItemName,
		KGQtyRec AS UnitQtyRec, KGQtyIss AS UnitQtyIss, KGQtyRecAmt AS UnitQtyRecAmt, KGQtyIssAmt AS UnitQtyIssAmt
		FROM TTable
		JOIN CHeads ON CHeads.CCODE = TTable.CCCode
		JOIN SHeads ON SHeads.SCODE = TTable.DSCode
		JOIN SHeads AS S ON S.SCODE = TTable.CSCode
		WHERE DCCode = @InvCode AND CCCode != @InvCode AND LooseLotNo IS NOT null AND [Date] BETWEEN @BeDate AND @EnDate

		UNION ALL
		SELECT [Date], CHeads.CHOA AS Particulars, SHeads.SHOA AS ItemName,
		KGQtyRec AS UnitQtyRec, KGQtyIss AS UnitQtyIss, KGQtyRecAmt AS UnitQtyRecAmt, KGQtyIssAmt AS UnitQtyIssAmt
		FROM TTable
		JOIN CHeads ON CHeads.CCODE = TTable.DCCode
		JOIN SHeads ON SHeads.SCODE = TTable.CSCode
		WHERE CCCode = @InvCode AND DCCode != @InvCode AND LooseLotNo IS NOT null  AND [Date] BETWEEN @BeDate AND @EnDate
		
		UNION ALL
		SELECT [Date], 'Taken from Unit' AS Particulars, SHeads.SHOA AS ItemName,
		KGQtyRec AS UnitQtyRec, KGQtyIss AS UnitQtyIss, KGQtyRecAmt AS UnitQtyRecAmt, KGQtyIssAmt AS UnitQtyIssAmt
		FROM TTable
		JOIN CHeads ON CHeads.CCODE = TTable.DCCode
		JOIN SHeads ON SHeads.SCODE = TTable.CSCode
		WHERE CCCode = @InvCode AND DCCode = @InvCode AND [Date] BETWEEN @BeDate AND @EnDate
		)

		SELECT * INTO #Temp6 FROM T;

		-- Joins both Table
		WITH R ([Date], Particulars, ItemName, UnitQtyRec, UnitQtyIss, UnitQtyRecAmt, UnitQtyIssAmt)AS(
		SELECT * FROM #Temp5
		UNION ALL
		SELECT * FROM #Temp6)
		SELECT * FROM R ORDER BY [Date]
	END
END

--EXEC Inv '1/1/2015','12/31/2015','20101000', 'Unit'

