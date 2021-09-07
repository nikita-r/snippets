/* create-proc.sql */

-- EXEC @rc = [dbo].[sp_...] 1, @rez = @result OUTPUT;

CREATE PROCEDURE [dbo].[sp_...]
	@int int,
	@flag bit = 'False',
	@rez int OUTPUT
AS
BEGIN
  DECLARE @msg nvarchar(max);
  SET XACT_ABORT, NOCOUNT ON;
  BEGIN TRY
    BEGIN TRAN;

    DECLARE
      @var nchar(3) = '···',
      @cnt int = 0;

    IF @flag = 'True'
    BEGIN
      NOOP:;
    END -- ELSE IF
    ELSE -- @flag='False' -- @flag is NULL
    BEGIN
      SET @msg = '@int=' + Format(@int, 'N0') + ' with invalid @flag';
      SET @msg += ' rcvd at ' + Format(GetUtcDate(), 'yyyy-MM-ddTHH:mm:ss.fffZ')
      ;THROW 5####, @msg, 1;
    END

    SELECT @var = 'abc', @cnt = 3;

    DECLARE @Inserted TABLE (ID int NOT NULL);

    INSERT INTO ...
    OUTPUT INSERTED.ID INTO @Inserted (ID)
    VALUES (), (), ...;

    SET @rez = @@ROWCOUNT;

    SELECT @var;

    COMMIT TRAN; RETURN 0;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW
  END CATCH
END
;
