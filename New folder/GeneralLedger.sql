CREATE PROCEDURE GeneralLedger
@fromDate date,
@toDate date,
@GeneralCode int
AS
BEGIN
	SELECT  g.GCODE AS GCODE, g.GHOA AS GHOA, CCODE, CHOA INTO #Temp1 FROM CHeads c
	JOIN GHeads g ON g.GCODE = c.GCODE;

	SELECT * INTO #TT FROM TransTable WHERE DCCode LIKE Convert(varchar, @GeneralCode)+'%' OR 
											CCCode LIKE Convert(varchar, @GeneralCode)+'%';
	WITH P AS(
		SELECT Id, [Date], D.GCODE AS DGCode, D.CCODE AS DCCode, C.GCODE AS CGCode, C.CCODE AS CCCode, VcNo, Amount 
		FROM #TT t
		JOIN #Temp1 AS D ON D.CCODE = t.DCCode 
		JOIN #Temp1 AS C ON C.CCODE = t.CCCode)
	SELECT * INTO #TempTTable FROM P;

	WITH T (Id, [Date], Particulars, VcNo, Debit, Credit)AS(
		SELECT Id, [Date], t.GHOA + SPACE(1) + '-' + SPACE(1) + t.CHOA AS Particulars,
		VcNo, 0 AS Debit, Amount AS Credit
		FROM #TempTTable
		JOIN #Temp1 t ON t.CCODE = #TempTTable.DCCode
		WHERE CGCode = @GeneralCode AND [Date] BETWEEN @fromDate AND @toDate
		UNION ALL
		SELECT Id, [Date], t.GHOA + SPACE(1) + '-' + SPACE(1) + t.CHOA AS Particulars, 
		VcNo, Amount AS Debit, 0 AS Credit	
		FROM #TempTTable
		JOIN #Temp1 t ON t.CCODE = #TempTTable.CCCode
		WHERE DGCode = @GeneralCode AND [Date] BETWEEN @fromDate AND @toDate
		)
	SELECT * INTO #Temp2 FROM T ORDER BY [Date], VcNo;

	DECLARE @BDebit float, @BCredit float, @BBalance float, @Id int
	SELECT @BDebit = SUM(Amount) FROM #TempTTable WHERE DGCode = @GeneralCode AND [Date] < @fromDate
	SELECT @BCredit = SUM(Amount) FROM #TempTTable WHERE CGCode = @GeneralCode AND [Date] < @fromDate

	IF (@GeneralCode LIKE '1%' OR @GeneralCode LIKE '2%')
	BEGIN
		SELECT @Id = ISNULL(MIN(Id),0) FROM #Temp2
		SELECT @BBalance = ISNULL(@BDebit,0) - ISNULL(@BCredit,0)
		INSERT INTO #Temp2 VALUES(@Id-1, @fromDate, 'Balance b/d',  0, ISNULL(@BBalance,0), 0)

		SELECT [Date], Particulars, VcNo, Debit, Credit, SUM(Debit-Credit) OVER (ORDER BY Id) AS Balance 
		FROM #Temp2 ORDER BY ID, [Date], VcNo
	END
	ELSE
	BEGIN
		SELECT @Id = ISNULL(MIN(Id),0) FROM #Temp2
		SELECT @BBalance = ISNULL(@BCredit,0) - ISNULL(@BDebit,0)
		INSERT INTO #Temp2 VALUES(@Id-1, @fromDate, 'Balance b/d', 0,  0, ISNULL(@BBalance,0))

		SELECT [Date], Particulars, VcNo, Debit, Credit, SUM(Credit-Debit) OVER (ORDER BY Id) AS Balance 
		FROM #Temp2 ORDER BY Id, [Date], VcNo
	END	
END
