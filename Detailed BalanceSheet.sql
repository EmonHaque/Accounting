--DROP TABLE #Temp1
--DROP TABLE #Temp2
CREATE PROCEDURE BalanceSheet
@asatDate date
AS
BEGIN
	WITH T (Description, MHOA, GHOA, CHOA, SHOA, Debit, Credit) AS
	(
		SELECT M1.DESCRIPTION, M2.MHOA, GHeads.GHOA, CHeads.CHOA, SHeads.SHOA, Amount AS Debit, 0 AS Credit
		FROM TTable 
		JOIN MHeads AS M1 ON M1.MCODE = TTable.DMCode
		JOIN MHeads AS M2 ON M2.MCODE = TTable.DMCode
		JOIN GHeads ON GHeads.GCODE = TTable.DGCode
		JOIN CHeads ON CHeads.CCODE = TTable.DCCode
		JOIN SHeads ON SHeads.SCODE = TTable.DSCode
		WHERE [Date] <= @asatDate
		UNION ALL
		SELECT M1.DESCRIPTION, M2.MHOA, GHeads.GHOA, CHeads.CHOA, SHeads.SHOA, 0 AS Debit, Amount AS Credit
		FROM TTable 
		JOIN MHeads AS M1 ON M1.MCODE = TTable.CMCode
		JOIN MHeads AS M2 ON M2.MCODE = TTable.CMCode
		JOIN GHeads ON GHeads.GCODE = TTable.CGCode
		JOIN CHeads ON CHeads.CCODE = TTable.CCCode
		JOIN SHeads ON SHeads.SCODE = TTable.CSCode
		WHERE [Date] <= @asatDate
	)
	SELECT Description, MHOA, GHOA, CHOA, SHOA, 
	CASE Description WHEN 'Asset' THEN (Debit - Credit) ELSE (Credit - Debit) END AS Balance,
	CASE MHOA WHEN 'Non-Current Assets' THEN 1 WHEN 'Current Assets' THEN 2 WHEN 'Non-Current Liabilities' THEN 3
			  WHEN 'Current Liabilities' THEN 4 ELSE 5 END AS OrderingId
	INTO #Temp1 FROM T;

	SELECT * FROM #Temp1 ORDER BY OrderingId
END
