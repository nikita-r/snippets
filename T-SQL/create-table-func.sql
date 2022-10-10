
IF TYPE_ID('dbo.TyList') IS NULL
CREATE TYPE dbo.TyList AS TABLE ( [i] int );
GO

GRANT EXECUTE ON TYPE::dbo.TyList TO [Func-User];
GO

CREATE OR ALTER FUNCTION dbo.GetData (
  @list AS dbo.TyList READONLY
) RETURNS TABLE
--with SchemaBinding
AS
RETURN (
SELECT dat.Value FROM DataTable dat JOIN @list list ON dat.Id = list.i
);
GO

GRANT SELECT ON dbo.GetData TO [Func-User]
GO
