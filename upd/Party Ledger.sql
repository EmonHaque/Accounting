WITH T(GCode, CCode, SCode, CPId, UQI, KQI,  Debit, Credit) AS(
SELECT DGCode, DCCode, DSCode, CCPId, SUM(UnitQtyIss), SUM(KGQtyIss), SUM(Amount) AS Debit, 0 AS Credit FROM TTable
WHERE PartyId = 20001
GROUP BY DGCode, DCCode, DSCode, CCPId
UNION ALL
SELECT CGCode, CCCode, CSCode, CCPId, SUM(UnitQtyIss), SUM(KGQtyIss), 0 AS Debit, SUM(Amount) AS Credit FROM TTable
WHERE PartyId = 20001
GROUP BY CGCode, CCCode, CSCode, CCPId)

SELECT GCode, CCode, SCode, CPId, SUM(UQI) AS UQtyI, SUM(KQI) AS KQtyI, SUM(Debit) AS Debit, SUM(Credit) AS Credit
INTO #Temp1 FROM T GROUP BY GCode, CCode, SCode, CPId;

SELECT GHeads.GHOA, CHeads.CHOA, SHeads.SHOA, CProducts.CName, UQtyI, KQtyI, Debit, Credit FROM #Temp1
JOIN GHeads ON GHeads.GCODE = #Temp1.GCode
JOIN CHeads ON CHeads.CCODE = #Temp1.CCode
JOIN SHeads ON SHeads.SCODE = #Temp1.SCode
LEFT OUTER JOIN CProducts ON CProducts.CId = #Temp1.CPId


--DROP TABLE #Temp1

