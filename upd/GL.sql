ALTER PROCEDURE GeneralLedger
@fromDate date,
@toDate date,
@GCode int
AS
BEGIN
	WITH P AS(
		SELECT Id, [Date], D.GCODE AS DGCode, D.CCODE AS DCCode, DSCode, C.GCODE AS CGCode, C.CCODE AS CCCode,  VcNo, TransRefId, Amount FROM TTable
		JOIN SHeads AS D ON D.SCODE = TTable.DSCode 
		JOIN SHeads AS C ON C.SCODE = TTable.CSCode 
	)SELECT * INTO #TempTTable FROM P;

	WITH T (Id, [Date], Particulars, VcNo, RefId, Debit, Credit) AS(
		SELECT Id, [Date], GHeads.GHOA + SPACE(1) + '-' + SPACE(1) + CHeads.CHOA AS Particulars, 
		VcNo, TransRefId AS RefId, 0 AS Debit, Amount AS Credit	
		FROM #TempTTable
		JOIN GHeads ON GHeads.GCODE = #TempTTable.DGCode
		JOIN CHeads ON CHeads.CCODE = #TempTTable.DCCode
		WHERE CGCode = @GCode AND [Date] BETWEEN @fromDate AND @toDate
		UNION ALL
		SELECT Id, [Date], GHeads.GHOA + SPACE(1) + '-' + SPACE(1) + CHeads.CHOA AS Particulars, 
		VcNo, TransRefId AS RefId, Amount AS Debit, 0 AS Credit	
		FROM #TempTTable
		JOIN GHeads ON GHeads.GCODE = #TempTTable.CGCode
		JOIN CHeads ON CHeads.CCODE = #TempTTable.CCCode
		WHERE DGCode = @GCode AND [Date] BETWEEN @fromDate AND @toDate)
	SELECT * INTO #Temp1 FROM T ORDER BY [Date], VcNo;

	DECLARE @BDebit float, @BCredit float, @BBalance float, @Id int
	SELECT @BDebit = SUM(Amount) FROM #TempTTable WHERE DGCode = @GCode AND [Date] < @fromDate
	SELECT @BCredit = SUM(Amount) FROM #TempTTable WHERE CGCode = @GCode AND [Date] < @fromDate

	IF (@GCode LIKE '1%' OR @GCode LIKE '2%')
	BEGIN
		SELECT @Id = MIN(Id) FROM #Temp1
		SELECT @BBalance = @BDebit - @BCredit
		INSERT INTO #Temp1 VALUES(@Id-1, @fromDate, 'Balance b/d', 0, 0, ISNULL(@BBalance,0), 0)

		SELECT [Date], Particulars, VcNo, RefId, Debit, Credit, SUM(Debit-Credit) OVER (ORDER BY Id) AS Balance 
		FROM #Temp1 ORDER BY ID, [Date], VcNo
	END
	ELSE
	BEGIN
		SELECT @Id = MIN(Id) FROM #Temp1
		SELECT @BBalance = @BCredit - @BDebit
		INSERT INTO #Temp1 VALUES(@Id-1, @fromDate, 'Balance b/d', 0, 0, 0, ISNULL(@BBalance,0))

		SELECT [Date], Particulars, VcNo, RefId, Debit, Credit, SUM(Credit-Debit) OVER (ORDER BY Id) AS Balance 
		FROM #Temp1 ORDER BY Id, [Date], VcNo
	END	
END