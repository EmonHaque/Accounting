CREATE PROCEDURE ProductList4SubLedger
AS
BEGIN
	WITH P AS(
		select DCCode AS CCode, DProId AS ProId From TransTable WHERE DProId IS NOT NULL
		UNION ALL
		select CCCode AS CCode, CProId AS ProId From TransTable WHERE CProId IS NOT NULL)
	SELECT DISTINCT CCode, ProId, g.GName FROM P
	JOIN GProducts g ON g.GId = P.ProId
END
