CREATE PROCEDURE BalanceSheet
@asatDate date
AS
BEGIN
	WITH Q AS(
		SELECT D.CCODE AS DCCode, DSCode, C.CCODE AS CCCode, CSCode,  Amount AS Debit, Amount AS Credit FROM TTable
		JOIN SHeads AS D ON D.SCODE = TTable.DSCode 
		JOIN SHeads AS C ON C.SCODE = TTable.CSCode
		WHERE [Date] <= '12/31/2015'
	)SELECT * INTO #TempTTable FROM Q;
	
	WITH T (CHOA, Debit, Credit) AS
	(
		SELECT CHeads.CHOA, Debit, 0 AS Credit FROM #TempTTable 
		JOIN CHeads ON CHeads.CCODE = #TempTTable.DCCode
		UNION ALL
		SELECT CHeads.CHOA, 0 AS Debit, Credit FROM #TempTTable 
		JOIN CHeads ON CHeads.CCODE = #TempTTable.CCCode
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