CREATE PROCEDURE InvTest
@fromDate date,
@toDate date,
@InvCode int
AS
BEGIN
	WITH T AS(
	SELECT Id, [Date], D.CCODE AS DCCode, DSCode, C.CCODE AS CCCode, CSCode, DCPId, CCPId, PartyId, VcNo, TransRefId, LotNo, 
			D3.InvCCode AS InvCCode, D3.InvSCode AS InvSCode,
			UnitQtyRec, UnitQtyIss, UnitQtyRecAmt, UnitQtyIssAmt
	FROM TTable
	JOIN SHeads AS D ON D.SCODE = TTable.DSCode
	JOIN SHeads AS C ON C.SCODE = TTable.CSCode
	LEFT OUTER JOIN CProducts AS D3 ON D3.CId = TTable.DCPId
	WHERE InvCCode = @InvCode AND (UnitQtyRec IS NOT NULL OR UnitQtyIss IS NOT NULL)
	)
	SELECT [Date], CASE 
	WHEN (D1.CCODE LIKE '201%' AND C1.CCODE LIKE '201%') THEN 'Transfer to Loose'
	WHEN (D1.CCODE LIKE '201%' AND C1.CCODE NOT LIKE '201%') THEN C1.CHOA + SPACE(1) + '-' + SPACE(1) + P.GName
	WHEN(D1.CCODE LIKE '50203%') THEN D1.CHOA + SPACE(1) + '-' + SPACE(1) + P.GName
	ELSE 'hmm?' END AS Particulars,
	VcNo, LotNo, UnitQtyRec AS QtyIn, UnitQtyIss AS QtyOut, UnitQtyRecAmt AS AmtIn, UnitQtyIssAmt AS AmtOut, Inv1.CHOA AS MainCat, Inv2.SHOA AS SubCat, D3.CName AS Cat 
	INTO #Temp1 
	FROM T
	JOIN CHeads AS D1 ON D1.CCODE = T.DCCode
	JOIN CHeads AS C1 ON C1.CCODE = T.CCCode
	JOIN SHeads AS D2 ON D2.SCODE = T.DSCode
	JOIN SHeads AS C2 ON C2.SCODE = T.CSCode
	LEFT OUTER JOIN CProducts AS D3 ON D3.CId = T.DCPId
	LEFT OUTER JOIN CProducts AS C3 ON C3.CId = T.CCPId
	LEFT OUTER JOIN GParties AS P ON P.GId = T.PartyId
	LEFT OUTER JOIN CHeads AS Inv1 ON Inv1.CCODE = T.InvCCode
	LEFT OUTER JOIN SHeads AS Inv2 ON Inv2.SCODE = T.InvSCode
	ORDER BY T.Id, [Date], VcNo;

	SELECT  'balance b/d' AS Particulars, null AS VcNo, null AS LotNo,
	SUM(ISNULL(QtyIn,0)) - SUM(ISNULL(QtyOut,0)) AS QtyIn, null AS QtyOut,
	SUM(ISNULL(AmtIn,0)) - SUM(ISNULL(AmtOut,0)) AS AmtIn, null AS AmtOut,
	MainCat, SubCat, Cat INTO #Temp2
	FROM #Temp1 WHERE [Date] < @fromDate
	GROUP BY  MainCat, SubCat, Cat; 

	SELECT @fromDate AS [Date], Particulars, MainCat AS ItemName, SubCat AS GName, Cat AS CName, VcNo, LotNo, 
			QtyIn AS QtyRec, QtyOut AS QtyIss, AmtIn AS QtyRecAmt, AmtOut AS QtyIssAmt INTO #Temp3 FROM #Temp2;

	SELECT [Date], Particulars,ItemName,GName,CName,VcNo,LotNo,QtyRec,QtyIss,QtyRecAmt,QtyIssAmt FROM #Temp3
	UNION ALL
	SELECT [Date], Particulars, MainCat AS ItemName, SubCat AS GName, Cat AS CName, VcNo, LotNo,
	QtyIn AS QtyRec, QtyOut AS QtyIss, AmtIn AS QtyRecAmt, AmtOut AS QtyIssAmt
	FROM #Temp1 WHERE [Date] BETWEEN @fromDate AND @toDate
	ORDER BY [Date], VcNo	
END

