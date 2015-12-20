IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sfGetDangerLevel]') AND type = N'FN') BEGIN
	DROP FUNCTION dbo.sfGetDangerLevel
END
GO

CREATE FUNCTION dbo.sfGetDangerLevel(
	@importId as int,
	@loanAccount as varchar(50)
)
RETURNS nvarchar(20)
AS
BEGIN
	--DECLARE @importId as int = 1
	--DECLARE @loanAccount as varchar(50) = '806050001481024889' --806050001481018516
	DECLARE @asOfDate as smalldatetime
	DECLARE @customerType nvarchar(20)
	DECLARE @customerScale char(1) /* 1: ������ҵ, 2: С΢��ҵ, 3: �������� */
	DECLARE @danbaofangshi nvarchar(20)
	DECLARE @overdueDays as int, @oweInterestDays as int
	DECLARE @importLoanId as int
	DECLARE @dangerLevel nvarchar(20) /* ����, ��ע, �μ�, ����, ��ʧ*/

	SELECT @asOfDate = ImportDate FROM Import WHERE Id = @importId
	SELECT @importLoanId = Id
		, @customerType = CASE WHEN LEN(CustomerName) < 5 THEN '��˽' ELSE '�Թ�' END /*CustomerType*/
		, @overdueDays = CASE WHEN LoanEndDate < @asOfDate THEN DATEDIFF(day, LoanEndDate, @asOfDate) ELSE 0 END
	FROM ImportLoan
	WHERE ImportId = @importId AND LoanAccount = @loanAccount

	IF @customerType = '�Թ�' BEGIN
		SELECT @customerScale = (CASE WHEN P.MyBankIndTypeName IN ('΢����ҵ', 'С����ҵ') THEN '2' ELSE '1' END)
			, @oweInterestDays = P.OweInterestDays
		FROM ImportPublic P INNER JOIN ImportLoan L ON P.LoanAccount = L.LoanAccount AND P.ImportId = @importId
		WHERE L.Id = @importLoanId
	END
	ELSE BEGIN
		SELECT @customerScale = (CASE WHEN LEN(P.Direction1) > 0 THEN '2' ELSE '3' END)
			, @oweInterestDays = InterestOverdueDays
		FROM ImportPrivate P INNER JOIN ImportLoan L ON P.CustomerName = L.CustomerName AND P.ContractStartDate = L.LoanStartDate AND P.ContractEndDate = L.LoanEndDate AND P.OrgId = L.OrgId AND P.ImportId = @importId
		WHERE L.Id = @importLoanId
	END

	SELECT @danbaofangshi = DanBaoFangShi FROM ImportNonAccrual A INNER JOIN ImportLoan L ON A.LoanAccount = L.LoanAccount AND A.ImportId = @importId
	WHERE L.Id = @importLoanId

	IF @danbaofangshi IS NULL BEGIN
		SELECT @danbaofangshi = DanBaoFangShi FROM ImportOverdue O INNER JOIN ImportLoan L ON O.LoanAccount = L.LoanAccount AND O.ImportId = @importId
		WHERE L.Id = @importLoanId
	END

	IF @danbaofangshi IS NULL BEGIN
		IF @customerType = '�Թ�' BEGIN
			SELECT @danbaofangshi = P.VOUCHTYPENAME
			FROM ImportPublic P INNER JOIN ImportLoan L ON P.LoanAccount = L.LoanAccount AND P.ImportId = L.ImportId
			WHERE P.ImportId = @importId
		END
		ELSE BEGIN
			SELECT @danbaofangshi = P.DanBaoFangShi
			FROM ImportPrivate P INNER JOIN ImportLoan L ON P.LoanAccount = L.LoanAccount AND P.ImportId = L.ImportId
			WHERE P.ImportId = @importId
		END
		SELECT @danbaofangshi = Category FROM DanBaoFangShi WHERE Name = @danbaofangshi
	END

	--SELECT @customerType, @overdueDays, @oweInterestDays, @danbaofangshi

	DECLARE @days int = (CASE WHEN @overdueDays >= @oweInterestDays THEN @overdueDays ELSE @oweInterestDays END)
	IF @customerScale = '1' BEGIN --������ҵ
		SET @dangerLevel = (CASE WHEN @days = 0 THEN '����' WHEN @days BETWEEN 1 AND 90 THEN '��ע' WHEN @days BETWEEN 91 AND 180 THEN '�μ�' WHEN @days > 181 THEN '����' END)
	END
	ELSE IF @customerScale = '2' BEGIN --С΢��ҵ
		IF @danbaofangshi = '����' BEGIN
			SET @dangerLevel = (CASE
					WHEN @days = 0 THEN '����'
					WHEN @days BETWEEN  1 AND 30 THEN '��ע��'
					WHEN @days BETWEEN 31 AND 60 THEN '��ע��'
					WHEN @days BETWEEN 61 AND 90 THEN '�μ�'
					WHEN @days BETWEEN 91 AND 180 THEN '����'
					WHEN @days BETWEEN 181 AND 360 THEN '����'
					WHEN @days > 361 THEN '��ʧ' END
				)
		END
		ELSE IF @danbaofangshi = '��֤' BEGIN
			SET @dangerLevel = (CASE
					WHEN @days = 0 THEN '����'
					WHEN @days BETWEEN  1 AND 30 THEN '��עһ'
					WHEN @days BETWEEN 31 AND 60 THEN '��ע��'
					WHEN @days BETWEEN 61 AND 90 THEN '��ע��'
					WHEN @days BETWEEN 91 AND 180 THEN '�μ�'
					WHEN @days BETWEEN 181 AND 360 THEN '����'
					WHEN @days > 361 THEN '��ʧ' END
				)
		END
		ELSE IF @danbaofangshi = '��Ѻ' BEGIN
			SET @dangerLevel = (CASE
					WHEN @days = 0 THEN '����'
					WHEN @days BETWEEN  1 AND 30 THEN '����'
					WHEN @days BETWEEN 31 AND 60 THEN '��עһ'
					WHEN @days BETWEEN 61 AND 90 THEN '��ע��'
					WHEN @days BETWEEN 91 AND 180 THEN '��ע��'
					WHEN @days BETWEEN 181 AND 360 THEN '�μ�'
					WHEN @days BETWEEN 361 AND 540 THEN '����'
					WHEN @days > 541 THEN '��ʧ' END
				)
		END
		ELSE IF @danbaofangshi = '��Ѻ' BEGIN
			SET @dangerLevel = (CASE
					WHEN @days = 0 THEN '����'
					WHEN @days BETWEEN  1 AND 30 THEN '����'
					WHEN @days BETWEEN 31 AND 60 THEN '����'
					WHEN @days BETWEEN 61 AND 90 THEN '��ע��'
					WHEN @days BETWEEN 91 AND 180 THEN '��ע��'
					WHEN @days BETWEEN 181 AND 360 THEN '�μ�'
					WHEN @days BETWEEN 361 AND 540 THEN '����'
					WHEN @days > 541 THEN '��ʧ' END
				)
		END
	END
	ELSE IF @customerScale = '3' BEGIN --��������
		SET @dangerLevel = (CASE
				WHEN @days = 0 THEN '����'
				WHEN @days BETWEEN  1 AND 30 THEN '��עһ'
				WHEN @days BETWEEN 31 AND 60 THEN '��ע��'
				WHEN @days BETWEEN 61 AND 90 THEN '��ע��'
				WHEN @days BETWEEN 91 AND 180 THEN '�μ�'
				WHEN @days > 181 THEN '����' END
			)
	END

	RETURN @dangerLevel
END