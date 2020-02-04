/* delete.sql */

-- speed up
ALTER TABLE [Table] NoCheck Constraint All;
ALTER INDEX All on [Table] DISABLE;
ALTER INDEX All on [Table] REBUILD;
ALTER TABLE [Table] Check Constraint All;
DELETE from [Table] where <Predicate>;

-- in batches
SELECT NULL;
WHILE @@rowcount > 0
begin
      DELETE top (10) [Table] where <Predicate>
  end

-- stale stats may slow
update statistics [Table];

