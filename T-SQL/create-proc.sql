/* create-proc.sql */

-- EXEC @rc = [dbo].[sp_...] 1, @iReturn = @n OUTPUT;

CREATE OR ALTER PROCEDURE [dbo].[sp_...]
	@int int,
	@flag bit = 'False',
	@patLiteral nvarchar(max) = '',
	@iReturn int OUTPUT
AS
BEGIN
  DECLARE @msg nvarchar(max);
  SET XACT_ABORT, NOCOUNT ON;
  BEGIN TRY
    BEGIN TRAN;

    DECLARE
      @var nchar(3) = '···',
      @cnt int = 0;

    IF ( @flag = 'True'
    ) BEGIN
      NOOP00:;
    END ELSE BEGIN -- @flag is either 'False' or NULL
      SET @msg = '@int=' + Format(@int, 'N0') + ' with invalid @flag at 100%%';
      SET @msg += ' rcvd at ' + Format(GetUtcDate(), 'yyyy-MM-ddTHH:mm:ss.fffZ')
      ;THROW 5xxxx, @msg, 1;
    END;

    SELECT TOP 1 @var = Value FROM DataTable
     WHERE Name LIKE '%' + REPLACE(REPLACE(REPLACE(@patLiteral, '[', '[[]'), '_', '[_]'), '%', '[%]') + '%'
     ORDER BY id desc;

    SELECT @cnt = @@ROWCOUNT;

    DECLARE @Inserted TABLE (ID int NOT NULL);

    INSERT INTO ...
    OUTPUT INSERTED.ID INTO @Inserted (ID)
    VALUES (), (), ...;

    SET @iReturn = @@ROWCOUNT;

    SELECT @var;

    COMMIT TRAN; RETURN 0;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW
  END CATCH
END
;
