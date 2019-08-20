-- Charges to COGS on FIFO
-- Add INSERT Entry to UPDATE TTable
CREATE TRIGGER InvUpdate_On_PurChase_Sales
ON TTable
FOR INSERT AS
BEGIN

DECLARE @Counter int, @QtyinLot int, @QtySold int, @InvCode int, @Amount money, 
		@MainId int, @ControlId int, @SubId int, @Date nvarchar(50), @SLotNo int, @PLotNo int,
		@DrCont int, @CrSub int, @QtyRec int, @AmtRec money, @MrNo int, @DChal int, @SupCode int

		SET @Counter = 1

		SELECT @DrCont = DrCont from inserted
		SELECT @CrSub = CrSub from inserted

		SELECT @QtySold = Qty from inserted
		SELECT @InvCode = InvCode from inserted

		SELECT @Date = [Date] from inserted
		SELECT @MainId = DrMain from inserted
		SELECT @ControlId = DrCont from inserted
		SELECT @SubId = DrSubs from inserted
		SELECT @QtyRec = Qty from inserted
		SELECT @AmtRec = Amount from inserted
		SELECT @MrNo = MRNo from inserted
		SELECT @DChal = DeliveryChallan from inserted
		SELECT @SupCode = CrSub from inserted
		SELECT @PLotNo = LotNo from inserted

	IF(@DrCont = 2001000) -- Inventory Account
	BEGIN
		INSERT INTO Inventory VALUES(@MainId,@ControlId,@SubId,@QtyRec,null,@AmtRec,null,@MrNo,
										@DChal,null,@SupCode,null,@PLotNo,@Date,@SubId);
	END

	ELSE IF (@CrSub = 5001001) -- Sales Account
	BEGIN
		WHILE (@QtySold > 0)
		BEGIN
		
			WITH T(Lot, QtyBal, BalAmount, RN) 
				 AS(
					SELECT LotNo, (SUM(ISNULL(QtryRec,0))-SUM(ISNULL(QtyIss,0))) As QtyBal, 
								  (SUM(ISNULL(AmountRec,0))-SUM(ISNULL(AmountISS,0))) AS BalAmount, 
								   ROW_NUMBER() Over (Order by LotNo) AS RN  From Inventory
					Where ItemCode = @InvCode
					Group By LotNo
					Having (SUM(QtryRec)-SUM(ISNULL(QtyIss,0))) > 0
					)
			SELECT @SLotNo = Lot FROM T WHERE RN = @Counter;

			WITH T(Lot, QtyBal, BalAmount, RN) 
				 AS(
					SELECT LotNo, (SUM(ISNULL(QtryRec,0))-SUM(ISNULL(QtyIss,0))) As QtyBal, 
								  (SUM(ISNULL(AmountRec,0))-SUM(ISNULL(AmountISS,0))) AS BalAmount, 
								   ROW_NUMBER() Over (Order by LotNo) AS RN  From Inventory
					Where ItemCode = @InvCode
					Group By LotNo
					Having (SUM(QtryRec)-SUM(ISNULL(QtyIss,0))) > 0
					)
			SELECT @QtyinLot = QtyBal FROM T WHERE RN = @Counter;

			WITH T(Lot, QtyBal, BalAmount, RN) 
				 AS(
					SELECT LotNo, (SUM(ISNULL(QtryRec,0))-SUM(ISNULL(QtyIss,0))) As QtyBal, 
								  (SUM(ISNULL(AmountRec,0))-SUM(ISNULL(AmountISS,0))) AS BalAmount, 
								   ROW_NUMBER() Over (Order by LotNo) AS RN  From Inventory
					Where ItemCode = @InvCode
					Group By LotNo
					Having (SUM(QtryRec)-SUM(ISNULL(QtyIss,0))) > 0
					)
				SELECT @Amount = BalAmount FROM T WHERE RN = @Counter;

			IF ( (@QtySold - @QtyinLot) < 0)
			BEGIN
					INSERT INTO Inventory VALUES(@MainId,@ControlId,@SubId,null,@QtySold,null,
					((@Amount/@QtyinLot)*@QtySold),null,null,null,null,null,@SLotNo,@Date,@InvCode);
			-- Add INSERT Entry to UPDATE TTable
			END

			ELSE
			BEGIN
				INSERT INTO Inventory VALUES(@MainId,@ControlId,@SubId,null,@QtyinLot,null,@Amount, 
													null,null,null,null,null,@SLotNo,@Date,@InvCode);
			-- Add INSERT Entry to UPDATE TTable
			END
		
			SELECT @QtySold = @QtySold - @QtyinLot
		END
	END
END