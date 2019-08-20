SELECT [Date], VcNo, TransRefId, DebitM.MHOA + SPACE(1) + '-' + SPACE(1) + DebitG.GHOA AS DebitMain,
DebitC.CHOA + Space(1) + '-' + Space(1) + DebitS.SHOA AS DebitHead, 
CreditM.MHOA + SPACE(1) + '-' + SPACE(1) + CreditG.GHOA AS CreditMain,
CrediC.CHOA + Space(1) + '-' + Space(1) + CreditS.SHOA AS CreditHead, Amount, Narration
FROM TTable
JOIN MHeads AS DebitM ON DebitM.MCODE = TTable.DMCode
JOIN MHeads AS CreditM ON CreditM.MCODE = TTable.CMCode
JOIN GHeads AS DebitG ON DebitG.GCODE = TTable.DGCode
JOIN GHeads AS CreditG ON CreditG.GCODE = TTable.CGCode
JOIN CHeads AS DebitC ON DebitC.CCODE = TTable.DCCode
JOIN CHeads AS CrediC ON CrediC.CCODE = TTable.CCCode
JOIN SHeads AS DebitS On DebitS.SCODE = TTable.DSCode
JOIN SHeads AS CreditS On CreditS.SCODE = TTable.CSCode
WHERE [Date] BETWEEN '1/1/2015' AND '12/31/2015'
ORDER BY [Date], VcNo