ALTER PROCEDURE SubsidiaryLedger
@fromDate date,
@toDate date,
@SCode int
AS
BEGIN
	WITH P AS(
		SELECT Id AS [Order], [Date], D.CCODE AS DCCode, DSCode, C.CCODE AS CCCode, 
		CSCode, VcNo, TransRefId, Amount, PartyId, DCPId, CCPId
		FROM TTable 
		JOIN SHeads AS D ON D.SCODE = TTable.DSCode
		JOIN SHeads AS C ON C.SCODE = TTable.CSCode
		WHERE DSCode = @SCode OR CSCode = @SCode AND
		[Date] BETWEEN @fromDate AND @toDate
	)SELECT * INTO #TempTTable FROM P;

	WITH T ([Order], [Date], CCode, Parti1, VcNo, RefId, Debit, Credit) AS(
		SELECT [Order], [Date], DCCode AS CCode, CASE WHEN (DCCode LIKE '201%' AND CCCode LIKE '201%') THEN 
		'Loose Transfer' + '-' + SPACE(1) + ISNULL(D.CName, C.CName)
		WHEN (CCCode IN(50201000, 50202000, 50203000, 50204000, 50205000, 50206000, 50207000) OR CCCode LIKE '201%' OR DCCode LIKE '201%') THEN
		CHeads.CHOA + SPACE(1) + '-' + SPACE(1) + SHeads.SHOA + SPACE(1) + '-' + SPACE(1) + ISNULL(D.CName, C.CName) + SPACE(1) + '-' + SPACE(1) + ISNULL(GParties.GName,'') ELSE
		CHeads.CHOA + SPACE(1) + '-' + SPACE(1) + SHeads.SHOA + SPACE(1) + '-' + SPACE(1) + GParties.GName END AS Parti1,
		VcNo, TransRefId AS RefId, Amount AS Debit, 0 AS Credit	
		FROM #TempTTable
		JOIN SHeads ON SHeads.SCODE = #TempTTable.CSCode
		JOIN CHeads ON CHeads.CCODE = #TempTTable.CCCode
		LEFT OUTER JOIN GParties ON GParties.GId = #TempTTable.PartyId
		LEFT OUTER JOIN CProducts AS D ON D.CId = #TempTTable.DCPId
		LEFT OUTER JOIN CProducts AS C ON C.CId = #TempTTable.CCPId
		WHERE DSCode = @SCode
		UNION ALL
		SELECT [Order], [Date], CCCode AS CCode, CASE WHEN (DCCode IN(50201000, 50202000, 50203000, 50204000, 50205000, 50206000, 50207000) OR DCCode LIKE '201%' OR CCCode LIKE '201%') THEN
		CHeads.CHOA + SPACE(1) + '-' + SPACE(1) + SHeads.SHOA + SPACE(1) + '-' + SPACE(1) + ISNULL(C.CName, D.CName) + SPACE(1) + '-' + SPACE(1) + ISNULL(GParties.GName,'') ELSE
		CHeads.CHOA + SPACE(1) + '-' + SPACE(1) + SHeads.SHOA + SPACE(1) + '-' + SPACE(1) + GParties.GName END AS Parti1,
		VcNo, TransRefId AS RefId, 0 AS Debit, Amount AS Credit	
		FROM #TempTTable
		JOIN SHeads ON SHeads.SCODE = #TempTTable.DSCode
		JOIN CHeads ON CHeads.CCODE = #TempTTable.DCCode
		LEFT OUTER JOIN GParties ON GParties.GId = #TempTTable.PartyId
		LEFT OUTER JOIN CProducts AS D ON D.CId = #TempTTable.DCPId
		LEFT OUTER JOIN CProducts AS C ON C.CId = #TempTTable.CCPId
		WHERE CSCode = @SCode)
	SELECT * INTO #Temp1 FROM T ORDER BY [Date], VcNo;

	DECLARE @BDebit float, @BCredit float, @BBalance float, @Id int, @CCode int
	SELECT @BDebit = SUM(Amount) FROM #TempTTable WHERE DSCode = @SCode AND [Date] < @fromDate
	SELECT @BCredit = SUM(Amount) FROM #TempTTable WHERE CSCode = @SCode AND [Date] < @fromDate

	IF (@SCode LIKE '1%' OR @SCode LIKE '2%')
	BEGIN
		SELECT @Id = MIN([Order]) FROM #Temp1
		SELECT @BBalance = @BDebit - @BCredit
		SELECT @CCode = CCode FROM #Temp1
		INSERT INTO #Temp1 VALUES(@Id-1, @fromDate, @CCode, 'Balance b/d', 0, 0, ISNULL(@BBalance,0), 0)

		SELECT [Date], Parti1  AS Particulars, 
		VcNo, RefId, Debit, Credit, SUM(Debit-Credit) OVER (ORDER BY [Order]) AS Balance 
		FROM #Temp1
		ORDER BY [Order], [Date], VcNo
	END
	ELSE IF(@SCode LIKE '1%' OR @SCode LIKE '2%' OR @SCode NOT LIKE '502%')
	BEGIN
		SELECT @Id = MIN([Order]) FROM #Temp1
		SELECT @BBalance = @BCredit - @BDebit
		SELECT @CCode = CCode FROM #Temp1
		INSERT INTO #Temp1 VALUES(@Id-1, @fromDate, @CCode, 'Balance b/d', 0, 0, 0, ISNULL(@BBalance,0))

		SELECT [Date], Parti1 AS Particulars, 
		VcNo, RefId, Debit, Credit, SUM(Credit-Debit) OVER (ORDER BY [Order]) AS Balance 
		FROM #Temp1 ORDER BY [Order], [Date], VcNo
	END	
	ELSE
	BEGIN
		SELECT [Date], Parti1  AS Particulars, 
		VcNo, RefId, Debit, Credit, SUM(Credit-Debit) OVER (ORDER BY [Order]) AS Balance 
		FROM #Temp1 ORDER BY [Order], [Date], VcNo
	END
END