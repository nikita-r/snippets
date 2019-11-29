/* fun.ws.sql */

CREATE FUNCTION dbo.fun_Key_no_Value
(
       @key nvarchar(max),
       @val int
)
RETURNS bit
with SchemaBinding
AS
BEGIN
return case when
        @Val not in ( SELECT Value FROM dbo.Table
                       WHERE Key = @Key )
then 1
else 0
end
END
GO

ALTER TABLE dbo.Texts WITH CHECK ADD CONSTRAINT Chk_Texts_WS
CHECK (NOT ([no_ill_ws] like '' OR [no_ill_ws] like ' %' OR [no_ill_ws] like '% ' OR [no_ill_ws] like '%  %'))
GO

select cast('true' as bit) as bit;
select cast('false' as bit) as bit;
select cast('-1' as bit) as bit;

