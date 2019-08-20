CREATE PROCEDURE BalanceSheet
@asatDate date
AS
BEGIN

	WITH T (CHOA, Debit, Credit) AS
	(
		SELECT  CHeads.CHOA, Amount AS Debit, 0 AS Credit FROM TTable 
		JOIN CHeads ON CHeads.CCODE = TTable.DCCode
		WHERE [Date] <= @asatDate
		UNION ALL
		SELECT CHeads.CHOA, 0 AS Debit, Amount AS Credit FROM TTable 
		JOIN CHeads ON CHeads.CCODE = TTable.CCCode
		WHERE [Date] <= @asatDate
	)
	SELECT CHOA, SUM(Debit) AS Debit, SUM(Credit) AS Credit INTO #Temp1 FROM T GROUP BY CHOA;

	SELECT CHeads.MCODE AS MCODE, CHeads.GCODE AS GCODE, CHeads.CCODE AS CCODE, CHeads.CHOA AS CHOA, Debit, Credit 
	INTO #Temp2 FROM #Temp1
	JOIN CHeads ON CHeads.CHOA = #Temp1.CHOA;

	SELECT D.DESCRIPTION AS Description, MHeads.MHOA AS MHOA, GHeads.GHOA AS GHOA, CHOA,
	CASE MHeads.MHOA WHEN 'Non-Current Assets' THEN (Debit - Credit) WHEN 'Current Assets' THEN (Debit - Credit) ELSE (Credit - Debit) END AS Balance,
	CASE MHeads.MHOA WHEN 'Non-Current Assets' THEN 1 WHEN 'Current Assets' THEN 2 WHEN 'Non-Current Liabilities' THEN 3 WHEN 'Current Liabilities' THEN 4 ELSE 5 END AS OrderingId
	INTO #Temp3 FROM #Temp2
	JOIN MHeads as D ON D.MCODE = #Temp2.MCODE
	JOIN MHeads ON MHeads.MCODE = #Temp2.MCODE
	JOIN GHeads ON GHeads.GCODE = #Temp2.GCODE;

	WITH R(Description,MHOA,GHOA,CHOA,Balance,OrderingId)AS(
	SELECT * FROM #Temp3 WHERE GHOA ! = 'Profit and Loss'
	UNION ALL
	SELECT 'Liability and Equity', 'Equity', 'Profit and Loss', 'Profit and Loss', SUM(Balance), 5
	FROM #Temp3 WHERE GHOA  = 'Profit and Loss')
	SELECT Description,MHOA,GHOA,CHOA,Balance FROM R  WHERE Balance !=0 Order by OrderingId
END


