DROP TABLE #Temp1
DROP TABLE #Temp2

WITH T (CHOA, Balance) AS(
SELECT CHeads.CHOA AS CHOA, Amount AS Balance
FROM TTable 
JOIN CHeads ON CHeads.CCODE = TTable.DCCode
WHERE DGCode IN (50200000) AND [Date] BETWEEN '1/1/2015'AND'12/31/2015' -- to be parametrized
UNION ALL
SELECT CHeads.CHOA AS CHOA, Amount AS Balance
FROM TTable 
JOIN CHeads ON CHeads.CCODE = TTable.CCCode
WHERE CGCode IN (50200000) AND [Date] BETWEEN '1/1/2015'AND'12/31/2015')  -- to be parametrized

SELECT CHOA, SUM(Balance) AS Balance INTO #Temp1 FROM T GROUP BY CHOA;

SELECT CHeads.DESCRIPTION As Description, #Temp1.CHOA, Balance,
CASE Description When 'Income' THEN 1 Else 2 END AS Type 
INTO #Temp2 FROM #Temp1
JOIN CHeads ON CHeads.CHOA = #Temp1.CHOA;

DECLARE @PLDebit money, @PLCredit money, @Profit money, @PPLDebit money, @PPLCredit money, @PPLBalance money
SELECT @PLDebit = SUM(Amount) From TTable WHERE DGCode IN (50200000) AND [Date] BETWEEN '1/1/2015'AND'12/31/2015'  -- to be parametrized
SELECT @PLCredit = SUM(AMount)	From TTable WHERE CGCode IN (50200000) AND [Date] BETWEEN '1/1/2015'AND'12/31/2015'  -- to be parametrized
SELECT @Profit = @PLCredit - @PLDebit
INSERT INTo #Temp2 VALUES('Profit & Loss Account', 'Surplus/(Deficit) for the period', @Profit, 3); 

SELECT @PPLDebit = SUM(Amount) From TTable WHERE DGCode IN (50200000) AND [Date] < '1/1/2015'  -- to be parametrized
SELECT @PPLCredit = SUM(Amount) From TTable WHERE CGCode IN (50200000) AND [Date] < '1/1/2015'  -- to be parametrized
SELECT @PPLBalance = @PPLCredit - @PPLDebit
INSERT INTo #Temp2 VALUES('Profit & Loss Account', 'Balance Carried down', @PPLBalance, 3); 

SELECT * FROM #Temp2 ORDER BY Type

