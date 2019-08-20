--DROP TABLE #Temp1
--DROP TABLE #Temp2
CREATE PROCEDURE IncomeExpense
@fromDate date,
@toDate date
AS
BEGIN
	WITH T(Description, CHOA, SHOA, Debit, Credit) AS
	(
		SELECT CHeads.DESCRIPTION As Description, CHeads.CHOA AS CHOA, SHeads.SHOA AS SHOA, Amount AS Debit, 0 As Credit
		FROM TTable 
		JOIN CHeads ON CHeads.CCODE = TTable.DCCode
		JOIN SHeads ON SHeads.SCODE = TTable.DSCode
		WHERE DGCode IN (50200000) AND [Date] BETWEEN @fromDate AND @toDate
		UNION ALL
		SELECT CHeads.DESCRIPTION As Description, CHeads.CHOA AS CHOA, SHeads.SHOA AS SHOA, 0 AS Debit,Amount AS Credit
		FROM TTable 
		JOIN CHeads ON CHeads.CCODE = TTable.CCCode
		JOIN SHeads ON SHeads.SCODE = TTable.CSCode
		WHERE CGCode IN (50200000) AND [Date] BETWEEN @fromDate AND @toDate
	)
	SELECT Description AS Description, CHOA AS CHOA, SHOA AS SHOA, Debit AS Debit, Credit AS Credit INTO #Temp1 FROM T;

	SELECT Description, CHOA, SHOA, 
	CASE Description WHEN 'Income' THEN (Credit - Debit) ELSE (Debit - Credit) END AS Amount,
	CASE Description WHEN 'Income' THEN 1 ELSE 2 END AS OrderingId
	INTO #Temp2 FROM #Temp1; 

	SELECT * FROM #Temp2 Order BY OrderingId
END