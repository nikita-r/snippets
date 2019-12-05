/* cursor.sql */

DECLARE @csv nvarchar(max)

set @CSV = '1,2,3,4,5,6,7,8,9,0'

DECLARE @cursor CURSOR LOCAL STATIC FORWARD_ONLY READ_ONLY

SET @cursor = CURSOR FOR
      SELECT value
        FROM string_split(@csv, ',')

DECLARE @value nvarchar(max), @sum int = 0

DECLARE @done bit = 0

OPEN @cursor
WHILE @done = 0
BEGIN
  FETCH NEXT FROM @cursor
        INTO @value

  IF @@FETCH_STATUS <> 0
  BEGIN
    SET @done = 1
    CONTINUE
  END

  SET @sum = @sum + @value + 1
END
CLOSE @cursor

DEALLOCATE @cursor

SELECT @sum as ##;
