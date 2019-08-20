--Journal confirmation on passing entries
ALTER PROCEDURE JournalEntries
@fromDate date,
@toDate date
AS
BEGIN
	WITH T AS(
	SELECT [Id], [Date], VcNo, TransRefId, D.MCODE AS DM, D.GCODE AS DG, D.CCODE AS DC, DSCode, 
	C.MCODE AS CM, C.GCODE AS CG, C.CCODE AS CC, CSCode, Amount, Narration, DCPId, CCPId, DP.GId AS DGP, CP.GId AS CGP
	FROM TTable WITH(NOLOCK)

	JOIN SHeads AS D ON D.SCODE = TTable.DSCode
	JOIN SHeads AS C ON C.SCODE = TTable.CSCode
	LEFT OUTER JOIN CProducts AS DP ON DP.CId = TTable.DCPId
	LEFT OUTER JOIN CProducts AS CP ON CP.CId = TTable.CCPId)

	SELECT  [Date], VcNo, TransRefId, 
	D1.MHOA + SPACE(1) + '-' + SPACE(1) + D2.GHOA AS DebitMain, CASE 
	WHEN D2.GHOA IN ('Inventories') THEN D3.CHOA + Space(1) + '-' + Space(1) + D4.SHOA + Space(1) + '-' + Space(1) +  DP2.CName 
	WHEN D3.CHOA IN ('Sales', 'Sales Return','Cost of Goods Sold','Weight Adjustment','Sales Return Adjustment','Purchase Return') 
	THEN D3.CHOA + Space(1) + '-' + Space(1) + D4.SHOA + Space(1) + '-' + Space(1) + DP1.GName + Space(1) + '-' + Space(1) + DP2.CName 
	ELSE D3.CHOA + Space(1) + '-' + Space(1) + D4.SHOA END AS DebitHead, 
	C1.MHOA + SPACE(1) + '-' + SPACE(1) + C2.GHOA AS CreditMain, CASE
	WHEN C2.GHOA IN ('Inventories') THEN C3.CHOA + Space(1) + '-' + Space(1) + C4.SHOA + Space(1) + '-' + Space(1) +  CP2.CName
	WHEN C3.CHOA IN ('Sales', 'Sales Return','Cost of Goods Sold','Weight Adjustment','Sales Return Adjustment','Purchase Return')
	THEN C3.CHOA + Space(1) + '-' + Space(1) + C4.SHOA + Space(1) + '-' + Space(1) + CP1.GName + Space(1) + '-' + Space(1) + CP2.CName 
	ELSE C3.CHOA + Space(1) + '-' + Space(1) + C4.SHOA END AS CreditHead,
	Amount, Narration 
	FROM T
	JOIN MHeads AS D1 ON D1.MCODE = T.DM 
	JOIN MHeads AS C1 ON C1.MCODE = T.CM 
	JOIN GHeads AS D2 ON D2.GCODE = T.DG 
	JOIN GHeads AS C2 ON C2.GCODE = T.CG 
	JOIN CHeads AS D3 ON D3.CCODE = T.DC 
	JOIN CHeads AS C3 ON C3.CCODE = T.CC 
	JOIN SHeads AS D4 ON D4.SCODE = T.DSCode 
	JOIN SHeads AS C4 ON C4.SCODE = T.CSCode
	LEFT OUTER JOIN GProducts AS DP1 ON DP1.GId = T.DGP
	LEFT OUTER JOIN GProducts AS CP1 ON CP1.GId = T.CGP
	LEFT OUTER JOIN CProducts AS DP2 ON DP2.CId = T.DCPId
	LEFT OUTER JOIN CProducts AS CP2 ON CP2.CId = T.CCPId

	WHERE [Date] BETWEEN @fromDate AND @toDate
	ORDER BY [Id], [Date], VcNo, TransRefId
END
