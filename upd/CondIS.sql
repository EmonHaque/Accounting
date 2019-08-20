CREATE PROCEDURE IncomeExpense
@fromDate date,
@toDate date
AS
BEGIN
	WITH Q([Date], DGCode, DCCode, DSCode, CGCode, CCCode, CSCode, Amount) 
	AS(
		SELECT [Date], D.GCODE AS DGCode, D.CCODE AS DCCode, DSCode, C.GCODE AS DGCode, C.CCODE AS DCCode, CSCode, Amount FROM TTable
		JOIN SHeads AS D ON D.SCODE = TTable.DSCode
		JOIN SHeads AS C ON C.SCODE = TTable.CSCode
		)
	SELECT * INTO #TempTTable FROM Q;

	DECLARE @BDebit float, @BCredit float, @EDebit float, @ECredit float
	SELECT @BDebit = SUM(Amount) FROM #TempTTable WHERE DGCode = 50200000 AND [Date] < @fromDate
	SELECT @BCredit = SUM(Amount) FROM #TempTTable WHERE CGCode = 50200000 AND [Date] < @fromDate 
	SELECT @EDebit = SUM(Amount) FROM #TempTTable WHERE DGCode = 50200000 AND [Date] BETWEEN @fromDate AND @toDate
	SELECT @ECredit = SUM(Amount) FROM #TempTTable WHERE CGCode = 50200000 AND [Date] BETWEEN @fromDate AND @toDate;

	 WITH T(Description, CHOA, SHOA, Debit, Credit) AS
		(
			SELECT CHeads.DESCRIPTION As Description, CHeads.CHOA AS CHOA, SHeads.SHOA AS SHOA, Amount AS Debit, 0 AS Credit
			FROM #TempTTable 
			JOIN CHeads ON CHeads.CCODE = #TempTTable.DCCode
			JOIN SHeads ON SHeads.SCODE = #TempTTable.DSCode
			WHERE DGCode IN (50200000) AND [Date] BETWEEN @fromDate AND @toDate
			UNION ALL
			SELECT CHeads.DESCRIPTION As Description, CHeads.CHOA AS CHOA, SHeads.SHOA AS SHOA, 0 AS Debit, Amount AS Credit
			FROM #TempTTable 
			JOIN CHeads ON CHeads.CCODE = #TempTTable.CCCode
			JOIN SHeads ON SHeads.SCODE = #TempTTable.CSCode
			WHERE CGCode IN (50200000) AND [Date] BETWEEN @fromDate AND @toDate
		)
		SELECT Description AS Description, CHOA AS CHOA, SHOA AS SHOA, Debit AS Debit, Credit AS Credit INTO #Temp1 FROM T;

		SELECT Description, CHOA, SHOA, SUM(Debit) AS Debit, SUM(Credit) AS Credit INTO #Temp2
		FROM #Temp1 GROUP BY Description, CHOA, SHOA;

		SELECT Description, CHOA, SHOA, CASE Description WHEN 'Income' THEN (Credit - Debit) ELSE (Debit - Credit) END AS Amount,
		CASE Description WHEN 'Income' THEN 1 ELSE 2 END AS OrderingId INTO #Temp3
		FROM #Temp2;
		INSERT INTO #Temp3 VALUES
		('Profit & Loss Account balance', 'Transferred to balance Sheet', 'surplus/(deficit) for the period', @ECredit - @EDebit, 3),
		('Profit & Loss Account balance', 'Transferred to balance Sheet', 'accumulated balance', @BCredit - @BDebit, 3)
	
		SELECT Description, CHOA, SHOA, Amount FROM #Temp3 WHERE Amount != 0 ORDER BY OrderingId
END