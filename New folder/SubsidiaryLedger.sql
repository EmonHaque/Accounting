CREATE PROCEDURE SubSidiaryLedger
@fromDate date,
@toDate date,
@GeneralCode int,
@ControlCode int,
@SubsidiaryCode int
AS
BEGIN
	SELECT  g.GCODE AS GCODE, g.GHOA AS GHOA, CCODE, CHOA INTO #Temp1 FROM CHeads c
	JOIN GHeads g ON g.GCODE = c.GCODE;

	IF(@GeneralCode IN(201, 601, 602, 701, 705, 706, 707, 708))
	BEGIN
		SELECT * INTO #TT1 FROM TransTable WHERE (DCCode = @ControlCode AND DProId = @SubsidiaryCode) OR 
												(CCCode = @ControlCode AND CProId = @SubsidiaryCode);
		WITH P AS(
			SELECT Id, [Date], D.GCODE AS DGCODE, D.CCODE AS DCCode, C.GCODE AS CGCODE, C.CCODE AS CCCode, DPartyId, CPartyId, DProId, CProId, VcNo, Amount 
			FROM #TT1 t
			JOIN #Temp1 AS D ON D.CCODE = t.DCCode 
			JOIN #Temp1 AS C ON C.CCODE = t.CCCode)
		SELECT * INTO #TempTTable1 FROM P;
	END
	ELSE
	BEGIN
		SELECT * INTO #TT2 FROM TransTable WHERE (DCCode = @ControlCode AND DPartyId = @SubsidiaryCode) OR 
												(CCCode = @ControlCode AND CPartyId = @SubsidiaryCode);
		WITH P AS(
			SELECT Id, [Date], D.GCODE AS DGCODE, D.CCODE AS DCCode, C.GCODE AS CGCODE, C.CCODE AS CCCode, DPartyId, CPartyId, DProId, CProId, VcNo, Amount 
			FROM TransTable t
			JOIN #Temp1 AS D ON D.CCODE = t.DCCode 
			JOIN #Temp1 AS C ON C.CCODE = t.CCCode)
	SELECT * INTO #TempTTable2 FROM P;
	END;

	WITH P AS(
		SELECT CustId AS ID, Name FROM Customers
		UNION ALL
		SELECT SupId AS ID, Name FROM Suppliers
		UNION ALL
		SELECT OwnId AS ID, Name FROM Owners
		UNION ALL
		SELECT EmpId AS ID, Name FROM Employees
		UNION ALL
		SELECT OthId AS ID, Name FROM Others
		UNION ALL
		SELECT BankId AS ID, Name FROM Banks
		UNION ALL
		SELECT GovtId AS ID, DeptName FROM Govt)
	SELECT * INTO #TempParty FROM P;

	DECLARE @BDebit float, @BCredit float, @BBalance float, @Id int
	IF(@GeneralCode IN(201, 601, 602, 701, 705, 706, 707, 708))
	BEGIN
		WITH T (Id, [Date], Particulars, VcNo, Debit, Credit)AS(
				SELECT tt.Id, [Date],t.CHOA + SPACE(1) + '-' + SPACE(1) + ISNULL(tp1.Name,'') AS Particulars,
				VcNo, 0 AS Debit, Amount AS Credit
				FROM #TempTTable1 tt
				JOIN #Temp1 t ON t.CCODE = tt.DCCode
				LEFT OUTER JOIN #TempParty tp1 ON tp1.ID = tt.DPartyId
				WHERE CCCode = @ControlCode AND CProId = @SubsidiaryCode AND [Date] BETWEEN @fromDate AND @toDate
				UNION ALL
				SELECT tt.Id, [Date], t.CHOA + SPACE(1) + '-' + SPACE(1) + ISNULL(tp2.Name,'') AS Particulars, 
				VcNo, Amount AS Debit, 0 AS Credit	
				FROM #TempTTable1 tt
				JOIN #Temp1 t ON t.CCODE = tt.CCCode
				LEFT OUTER JOIN #TempParty tp2 ON tp2.ID = tt.CPartyId
				WHERE DCCode = @ControlCode AND DProId = @SubsidiaryCode AND [Date] BETWEEN @fromDate AND @toDate)
		SELECT * INTO #Temp2 FROM T ORDER BY [Date], VcNo;

		SELECT @BDebit = SUM(Amount) FROM #TempTTable1 WHERE DCCode = @SubsidiaryCode AND [Date] < @fromDate
		SELECT @BCredit = SUM(Amount) FROM #TempTTable1 WHERE CCCode = @SubsidiaryCode AND [Date] < @fromDate

		IF (@GeneralCode LIKE '1%' OR @GeneralCode LIKE '2%')
		BEGIN
			SELECT @Id = ISNULL(MIN(Id),0) FROM #Temp2
			SELECT @BBalance = ISNULL(@BDebit,0) - ISNULL(@BCredit,0)
			INSERT INTO #Temp2 VALUES(@Id-1, @fromDate, 'Balance b/d',  0, ISNULL(@BBalance,0), 0)

			SELECT [Date], Particulars, VcNo, Debit, Credit, SUM(Debit-Credit) OVER (ORDER BY Id) AS Balance 
			FROM #Temp2 ORDER BY ID, [Date], VcNo
		END
		ELSE
		BEGIN
			SELECT @Id = ISNULL(MIN(Id),0)  FROM #Temp2
			SELECT @BBalance = ISNULL(@BCredit,0) - ISNULL(@BDebit,0)
			INSERT INTO #Temp2 VALUES(@Id-1, @fromDate, 'Balance b/d', 0,  0, ISNULL(@BBalance,0))

			SELECT [Date], Particulars, VcNo, Debit, Credit, SUM(Credit-Debit) OVER (ORDER BY Id) AS Balance 
			FROM #Temp2 ORDER BY Id, [Date], VcNo
		END	
	END

	ELSE
	BEGIN
		WITH T (Id, [Date], Particulars, VcNo, Debit, Credit)AS(
				SELECT tt.Id, [Date], 
					CASE WHEN(DGCODE IN(201, 601, 602, 701, 705, 706, 707, 708)) 
					 THEN t.CHOA + SPACE(1) + '-' + SPACE(1) + ISNULL(gp1.GName,'') 
					 WHEN(tp1.Name IS NULL) THEN t.CHOA
				ELSE t.CHOA + SPACE(1) + '-' + SPACE(1) + tp1.Name END AS Particulars,
				VcNo, 0 AS Debit, Amount AS Credit
				FROM #TempTTable2 tt
				JOIN #Temp1 t ON t.CCODE = tt.DCCode
				LEFT OUTER JOIN #TempParty tp1 ON tp1.ID = tt.DPartyId
				LEFT OUTER JOIN GProducts gp1 ON gp1.GId = tt.DProId
				WHERE CCCode = @ControlCode AND CPartyId = @SubsidiaryCode AND [Date] BETWEEN @fromDate AND @toDate
				UNION ALL
				SELECT tt.Id, [Date], 
					CASE WHEN(CGCODE IN(201, 601, 602, 701, 705, 706, 707, 708)) 
					 THEN t.CHOA + SPACE(1) + '-' + SPACE(1) + ISNULL(gp2.GName,'')
					 WHEN(tp2.Name IS NULL) THEN  t.CHOA
				ELSE t.CHOA + SPACE(1) + '-' + SPACE(1) + tp2.Name END AS Particulars,  
				VcNo, Amount AS Debit, 0 AS Credit	
				FROM #TempTTable2 tt
				JOIN #Temp1 t ON t.CCODE = tt.CCCode
				LEFT OUTER JOIN #TempParty tp2 ON tp2.ID = tt.CPartyId
				LEFT OUTER JOIN GProducts gp2 ON gp2.GId = tt.CProId
				WHERE DCCode = @ControlCode AND  DPartyId = @SubsidiaryCode AND [Date] BETWEEN @fromDate AND @toDate)
		SELECT * INTO #Temp3 FROM T ORDER BY [Date], VcNo;

		SELECT @BDebit = SUM(Amount) FROM #TempTTable2 WHERE DCCode = @SubsidiaryCode AND [Date] < @fromDate
		SELECT @BCredit = SUM(Amount) FROM #TempTTable2 WHERE CCCode = @SubsidiaryCode AND [Date] < @fromDate

		IF (@GeneralCode LIKE '1%' OR @GeneralCode LIKE '2%')
		BEGIN
			SELECT @Id = ISNULL(MIN(Id),0)  FROM #Temp3
			SELECT @BBalance = ISNULL(@BDebit,0) - ISNULL(@BCredit,0)
			INSERT INTO #Temp3 VALUES(@Id-1, @fromDate, 'Balance b/d',  0, ISNULL(@BBalance,0), 0)

			SELECT [Date], Particulars, VcNo, Debit, Credit, SUM(Debit-Credit) OVER (ORDER BY Id) AS Balance 
			FROM #Temp3 ORDER BY ID, [Date], VcNo
		END
		ELSE
		BEGIN
			SELECT @Id = ISNULL(MIN(Id),0)  FROM #Temp3
			SELECT @BBalance = ISNULL(@BCredit,0) - ISNULL(@BDebit,0)
			INSERT INTO #Temp3 VALUES(@Id-1, @fromDate, 'Balance b/d', 0,  0, ISNULL(@BBalance,0))

			SELECT [Date], Particulars, VcNo, Debit, Credit, SUM(Credit-Debit) OVER (ORDER BY Id) AS Balance 
			FROM #Temp3 ORDER BY Id, [Date], VcNo
		END	
	END
END