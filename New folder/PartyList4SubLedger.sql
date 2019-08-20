CREATE PROCEDURE PartyList4SubLedger
AS
BEGIN
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
	WITH P AS(
		SELECT DCCode AS CCode, DPartyId AS PartyId FROM TransTable WHERE DPartyId IS NOT NULL
		UNION ALL
		SELECT CCCode AS CCode, CPartyId AS PartyId FROM TransTable WHERE CPartyId IS NOT NULL)
	SELECT DISTINCT CCode, PartyId, t.Name FROM P
	JOIN #TempParty t ON t.ID = P.PartyId  
END