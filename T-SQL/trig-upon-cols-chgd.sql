CREATE TRIGGER TRIG__Dat1_Dat2__CHG ON DataTable
FOR UPDATE
AS
SET NOCOUNT ON;
IF (UPDATE(Dat1) OR UPDATE(Dat2))
BEGIN
   UPDATE dat
      SET DatNChanged = GETUTCDATE()
     FROM (
         SELECT ins.Id, ins.Dat1, ins.Dat2
           FROM Inserted ins
      EXCEPT
         SELECT del.Id, del.Dat1, del.Dat2
           FROM Deleted del
     ) upd
     JOIN DataTable dat ON dat.Id = upd.Id
END;
GO
