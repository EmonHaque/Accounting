CREATE PROCEDURE BalanceSheet
@asatdate Date
AS
BEGIN
	WITH T AS(
		SELECT m.MHOA, g.GHOA, c.CHOA, c.CCODE FROM CHeads c
		JOIN GHeads g ON g.GCODE = c.GCODE
		JOIN MHeads m ON m.MCODE = c.MCODE
	) SELECT * INTO #Temp1 FROM T;

	SELECT DCCode, CCCode, Amount INTo #TempTTable FROM TransTable WHERE [Date] <= @asatdate;
	WITH T AS
	(
		SELECT t.MHOA, t.GHOA, t.CHOA, tt.Amount AS Debit, 0 AS Credit FROM #TempTTable tt
		JOIN #Temp1 t ON t.CCODE = tt.DCCode
		UNION ALL
		SELECT t.MHOA, t.GHOA, t.CHOA, 0 AS Debit, tt.Amount AS Credit FROM #TempTTable tt
		JOIN #Temp1 t ON t.CCODE = tt.CCCode
	) 
	SELECT MHOA, GHOA, CHOA, SUM(Debit) as Debit, SUM(Credit) AS Credit INTO #Temp2 From T
	Group By MHOA, GHOA, CHOA 
	HAVING(SUM(Debit) - SUM(Credit)) <> 0;

	WITH T AS(
	SELECT CASE WHEN MHOA IN('Non-Current Assets', 'Current Assets') THEN 'Asset' 
				WHEN MHOA IN('Non-Current Liabilities', 'Current Liabilities', 'Equity') THEN 'Liability and Equity'
				END AS ALE, MHOA, GHOA, CHOA, 
		   CASE WHEN MHOA IN('Non-Current Assets', 'Current Assets') THEN (Debit - Credit) 
				WHEN MHOA IN('Non-Current Liabilities', 'Current Liabilities', 'Equity') THEN (Credit - Debit)
				END AS Balance		
	FROM #Temp2
	WHERE MHOA NOT IN('Income', 'Expense')
	UNION ALL
	SELECT 'Liability and Equity' AS ALE, 'Equity' AS MHOA, 'Profit and Loss' AS GHOA, 'Profit and Loss' AS CHOA, 
			(SUM(Credit) - Sum(Debit)) AS Balance 
	FROM #Temp2
	WHERE MHOA IN('Income', 'Expense') 
	) SELECT * FROM T
END

