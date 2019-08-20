--DROP TABLE #Temp1
ALTER PROCEDURE CashFlow
@fromDate date,
@toDate date
AS
BEGIN
	SELECT [Date], D1.MCODE AS DMCode, D1.GCODE AS DGCode, D1.CCODE AS DCCode, DSCode,
	C1.MCODE AS CMCode, C1.GCODE AS CGCode, C1.CCODE AS CCCode, CSCode, Amount INTO #Temp1 FROM TTable
	JOIN SHeads AS D1 ON D1.SCODE = TTable.DSCode
	JOIN SHeads AS C1 ON C1.SCODE = TTable.CSCode
	WHERE (DSCode LIKE '204%') OR (CSCode LIKE '204%');

	WITH R(Cat, Head, Amount) AS(
	SELECT 'Operating activities' AS Cat, CHeads.CHOA + SPACE(1) + SHeads.SHOA AS Head, -1*Amount AS Amount FROM #Temp1
	JOIN CHeads ON CHeads.CCODE = #Temp1.DCCode
	JOIN SHeads ON SHeads.SCODE = #Temp1.DSCode
	WHERE CGCode = 20400000 AND ((DMCode NOT IN (10000000, 30000000, 50000000)) OR (DMCode = 50000000 AND DGCode = 50200000))
	AND ([Date] BETWEEN @fromDate AND @toDate)
	UNION ALL
	SELECT 'Operating activities' AS Cat, CHeads.CHOA + SPACE(1) + SHeads.SHOA AS Head, Amount AS Amount FROM #Temp1
	JOIN CHeads ON CHeads.CCODE = #Temp1.CCCode
	JOIN SHeads ON SHeads.SCODE = #Temp1.CSCode
	WHERE DGCode = 20400000 AND ((CMCode NOT IN (10000000, 30000000, 50000000)) OR (DMCode = 50000000 AND DGCode = 50200000))
	AND ([Date] BETWEEN @fromDate AND @toDate))
	SELECT * INTO #Temp2 FROM R;

	WITH T(Cat, Head, Amount) AS(
	SELECT 'Investing activities' AS Cat, CHeads.CHOA + SPACE(1) + SHeads.SHOA AS Head, -1*Amount AS Amount FROM #Temp1
	JOIN CHeads ON CHeads.CCODE = #Temp1.DCCode
	JOIN SHeads ON SHeads.SCODE = #Temp1.DSCode
	WHERE CGCode = 20400000 AND DMCode = 10000000 AND ([Date] BETWEEN @fromDate AND @toDate)
	UNION ALL
	SELECT 'Investing activities' AS Cat, CHeads.CHOA + SPACE(1) + SHeads.SHOA AS Head, Amount AS Amount FROM #Temp1
	JOIN CHeads ON CHeads.CCODE = #Temp1.CCCode
	JOIN SHeads ON SHeads.SCODE = #Temp1.CSCode
	WHERE DGCode = 20400000 AND CMCode = 10000000 AND ([Date] BETWEEN @fromDate AND @toDate))
	SELECT * INTO #Temp3 FROM T;

	WITH S(Cat, Head, Amount) AS(
	SELECT 'Financing activities' AS Cat, CHeads.CHOA + SPACE(1) + SHeads.SHOA AS Head, -1*Amount AS Amount FROM #Temp1
	JOIN CHeads ON CHeads.CCODE = #Temp1.DCCode
	JOIN SHeads ON SHeads.SCODE = #Temp1.DSCode
	WHERE CGCode = 20400000 AND (DMCode = 30000000 OR (DMCode = 50000000 AND DGCode != 50200000))
	AND ([Date] BETWEEN @fromDate AND @toDate)
	UNION ALL
	SELECT 'Financing activities' AS Cat, CHeads.CHOA + SPACE(1) + SHeads.SHOA AS Head, Amount AS Amount FROM #Temp1
	JOIN CHeads ON CHeads.CCODE = #Temp1.CCCode
	JOIN SHeads ON SHeads.SCODE = #Temp1.CSCode
	WHERE DGCode = 20400000 AND (CMCode = 30000000 OR (CMCode = 50000000 AND CGCode != 50200000))
	AND ([Date] BETWEEN @fromDate AND @toDate))
	SELECT * INTO #Temp4 FROM S;

	DECLARE @BeCash float, @NCF float, @Debit float, @Credit float,
			@CF1 float, @CF2 float, @CF3 float
	
	SELECT @Debit = ISNULL(SUM(Amount),0) FROM #Temp1 WHERE DGCode = 20400000 AND [Date] < @fromDate
	SELECT @Credit = ISNULL(SUM(Amount),0) FROM #Temp1 WHERE CGCode = 20400000 AND[Date] < @fromDate
	SELECT @BeCash = @Debit - @Credit

	SELECT @CF1 = ISNULL(SUM(Amount),0) FROM #Temp2
	SELECT @CF2 = ISNULL(SUM(Amount),0) FROM #Temp3
	SELECT @CF3 = ISNULL(SUM(Amount),0) FROM #Temp4

	SELECT @NCF = @CF1 + @CF2 + @CF3;

	CREATE TABLE #Temp5(
	Cat nvarchar(25) null, 
	Head nvarchar(25) null, 
	Amount money null,
	Serial int not null);

	INSERT INTO #Temp5 VALUES
	('Closing Balance', 'Beginning Cash and bank', @BeCash, 4),
	('Closing Balance', 'Net Cash Flow', @NCF, 4);
	 
	WITH P AS(
	SELECT * FROM #Temp2
	UNION ALL
	SELECT * FROM #Temp3
	UNION ALL
	SELECT * FROM #Temp4)

	SELECT Cat, Head, SUM(Amount) AS Amount, CASE Cat WHEN 'Operating activities' THEN 1 WHEN 'Investing activities' THEN 2 ELSE 3 END AS Serial
	INTO #Temp6 FROM P
	GROUP BY Cat, Head;

	WITH M AS(
	SELECT * FROM #Temp6
	UNION ALL
	SELECT * FROM #Temp5
	)
	SELECT Cat, Head, Amount FROM M ORDER BY Serial
END
