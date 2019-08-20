DROP TABLE #Temp1
DROP Table #Temp2
DROP Table #Temp3

WITH T (GHOA, Balance) AS
(
SELECT GHeads.GHOA, Amount AS Balance
FROM TTable 
JOIN GHeads ON GHeads.GCODE = TTable.DGCode
WHERE DMCode IN (10000000, 20000000) AND [Date] <= '12/31/2015'  -- to be parametrized
UNION ALL
SELECT GHeads.GHOA, -1*Amount AS Balance
FROM TTable 
JOIN GHeads ON GHeads.GCODE = TTable.CGCode
WHERE CMCode IN (10000000, 20000000) AND [Date] <= '12/31/2015'  -- to be parametrized
UNION ALL
SELECT GHeads.GHOA, -1*Amount AS Balance
FROM TTable 
JOIN GHeads ON GHeads.GCODE = TTable.DGCode
WHERE DMCode NOT IN (10000000, 20000000) AND [Date] <= '12/31/2015'  -- to be parametrized
UNION ALL
SELECT GHeads.GHOA, Amount AS Balance
FROM TTable 
JOIN GHeads ON GHeads.GCODE = TTable.CGCode
WHERE CMCode NOT IN (10000000, 20000000) AND [Date] <= '12/31/2015'  -- to be parametrized
)
SELECT GHOA, SUM(Balance) as Balance INTO #Temp1 
FROM T
GROUP BY GHOA;

SELECT GHeads.MCODE, GHeads.GHOA, Balance INTO #Temp2 FROM #Temp1
JOIN GHeads ON GHeads.GHOA = #Temp1.GHOA;

SELECT MHeads.DESCRIPTION, MHeads.MHOA, GHOA, Balance, 
CASE MHOA 
WHEN 'Non-Current Assets' Then 1
WHEN 'Current Assets' Then 2 
WHEN 'Non-Current Liabilities' Then 3 
WHEN 'Current Liabilities' Then 4 
ELSE 5 
END AS OID INTO #Temp3 FROM #Temp2
JOIN MHeads ON MHeads.MCODE = #Temp2.MCODE;
SELECT * FROM #Temp3 ORDER BY OID
 

