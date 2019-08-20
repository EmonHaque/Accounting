--General Ledger
WITH T AS(
SELECT [Date], GHeads.GHOA + SPACE(1) + '-' + SPACE(1) + CHeads.CHOA AS Particulars, 
VcNo, TransRefId, 0 AS Debit, Amount AS Credit	
FROM TTable
JOIN GHeads ON GHeads.GCODE = TTable.DGCode
JOIN CHeads ON CHeads.CCODE = TTable.DCCode
WHERE CGCode = 20400000
UNION ALL
SELECT [Date], GHeads.GHOA + SPACE(1) + '-' + SPACE(1) + CHeads.CHOA AS Particulars, 
VcNo, TransRefId, Amount AS Debit, 0 AS Credit	
FROM TTable
JOIN GHeads ON GHeads.GCODE = TTable.CGCode
JOIN CHeads ON CHeads.CCODE = TTable.CCCode
WHERE DGCode = 20400000)
SELECT * FROM T ORDER BY [Date], VcNo

--Control Ledger
WITH T AS(
SELECT [Date], CHeads.CHOA + SPACE(1) + '-' + SPACE(1) + SHeads.SHOA AS Particulars, 
VcNo, TransRefId, 0 AS Debit, Amount AS Credit	
FROM TTable
JOIN CHeads ON CHeads.CCODE = TTable.DCCode
JOIN SHeads ON SHeads.SCODE = TTable.DSCode
WHERE CGCode = 20400000
UNION ALL
SELECT [Date], CHeads.CHOA + SPACE(1) + '-' + SPACE(1) + SHeads.SHOA AS Particulars, 
VcNo, TransRefId, Amount AS Debit, 0 AS Credit	
FROM TTable
JOIN CHeads ON CHeads.CCODE = TTable.CCCode
JOIN SHeads ON SHeads.SCODE = TTable.CSCode
WHERE DGCode = 20400000)
SELECT * FROM T ORDER BY [Date], VcNo
