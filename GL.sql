CREATE PROCEDURE GeneralLedger
@fromDate date,
@toDate date,
@GCode int
AS
BEGIN
	WITH T (Id, [Date], Particulars, VcNo, RefId, Debit, Credit) AS(
		SELECT Id, [Date], GHeads.GHOA + SPACE(1) + '-' + SPACE(1) + CHeads.CHOA AS Particulars, 
		VcNo, TransRefId AS RefId, 0 AS Debit, Amount AS Credit	
		FROM TTable
		JOIN GHeads ON GHeads.GCODE = TTable.DGCode
		JOIN CHeads ON CHeads.CCODE = TTable.DCCode
		WHERE CGCode = @GCode AND [Date] BETWEEN @fromDate AND @toDate
		UNION ALL
		SELECT Id, [Date], GHeads.GHOA + SPACE(1) + '-' + SPACE(1) + CHeads.CHOA AS Particulars, 
		VcNo, TransRefId AS RefId, Amount AS Debit, 0 AS Credit	
		FROM TTable
		JOIN GHeads ON GHeads.GCODE = TTable.CGCode
		JOIN CHeads ON CHeads.CCODE = TTable.CCCode
		WHERE DGCode = @GCode AND [Date] BETWEEN @fromDate AND @toDate)
	SELECT * INTO #Temp1 FROM T ORDER BY [Date], VcNo;

	DECLARE @BDebit float, @BCredit float, @BBalance float, @Id int
	SELECT @BDebit = SUM(Amount) FROM TTable WHERE DGCode = @GCode AND [Date] < @fromDate
	SELECT @BCredit = SUM(Amount) FROM TTable WHERE CGCode = @GCode AND [Date] < @fromDate

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

EXEC GeneralLedger '1/1/2015', '12/31/2015', 40100000
