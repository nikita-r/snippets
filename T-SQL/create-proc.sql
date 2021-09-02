/* create-proc.sql */

-- EXEC @rc = [dbo].[sp_...] 1, @rez = @result OUTPUT;

CREATE PROCEDURE [dbo].[sp_...]
	@flag bit = 'False',
	@rez int OUTPUT
AS
BEGIN
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
      ;THROW 5####, 'Invalid @flag', 1;
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
