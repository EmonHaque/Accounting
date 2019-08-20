CREATE PROCEDURE ProfitAndLoss
@fromDate date,
@toDate date
AS
BEGIN
	SELECT DCCode, CCCode, Amount INTO #TempTTable 
	FROM TransTable 
	WHERE ((DCCode LIKE '6%' OR DCCode LIKE '7%')
	OR (CCCode LIKE '6%' OR CCCode LIKE '7%'))
	AND [Date] BETWEEN @fromDate AND @toDate;

	WITH T AS
		(
			SELECT m.MHOA, g.GHOA, c.CHOA, c.CCODE FROM CHeads c
			JOIN GHeads g ON g.GCODE = c.GCODE
			JOIN MHeads m ON m.MCODE = c.MCODE
		) 
	SELECT * INTO #Temp1 FROM T;

	WITH T AS
		(
			SELECT t.MHOA, t.GHOA, t.CHOA, tt.Amount AS Debit, 0 AS Credit FROM #TempTTable tt
			JOIN #Temp1 t ON t.CCODE = tt.DCCode
			WHERE tt.DCCode LIKE '6%' OR tt.DCCode LIKE '7%'
			UNION ALL
			SELECT t.MHOA, t.GHOA, t.CHOA, 0 AS Debit, tt.Amount AS Credit FROM #TempTTable tt
			JOIN #Temp1 t ON t.CCODE = tt.CCCode
			WHERE tt.CCCode LIKE '6%' OR tt.CCCode LIKE '7%'
		) 
	SELECT MHOA, GHOA, CHOA, SUM(Debit) as Debit, SUM(Credit) AS Credit INTO #Temp2 From T
	Group By MHOA, GHOA, CHOA 
	HAVING(SUM(Debit) - SUM(Credit)) <> 0;

	SELECT MHOA, GHOA, CHOA, 
		CASE MHOA WHEN 'Income' THEN (Credit - Debit)
				  ELSE (Debit - Credit) 
		END AS Balance
	INTO #Temp3 FROM #Temp2;

	DECLARE @BeginningDrBalance int, @BeginningCrBalance int, 
	        @CurrentDrBalance int, @CurrentCrBalance int

	SELECT @BeginningDrBalance = SUM(Amount)  FROM TransTable tt
			WHERE (tt.DCCode LIKE '6%' OR tt.DCCode LIKE '7%') AND [Date] < @fromDate

	SELECT @BeginningCrBalance = SUM(Amount)  FROM TransTable tt
			WHERE (tt.CCCode LIKE '6%' OR tt.CCCode LIKE '7%') AND [Date] < @fromDate

	SELECT @CurrentDrBalance = SUM(Balance) FROM #Temp3 WHERE MHOA = 'Expense'
	SELECT @CurrentCrBalance = SUM(Balance) FROM #Temp3 WHERE MHOA = 'Income'

	INSERT INTO #Temp3 VALUES 
		('Profit and Loss', 'Balance b/d', 'Balance b/d', (ISNULL(@BeginningCrBalance,0) - ISNULL(@BeginningDrBalance,0))),
		('Profit and Loss', 'Net Profit/(Loss)', 'Net Profit/(Loss)', (ISNULL(@CurrentCrBalance,0) - ISNULL(@CurrentDrBalance,0)))
	
	SELECT * From #Temp3
END