
export class TableUtil {

  static supply_rows_compareFn(orderBys: { field: string, descending: boolean }[]) {
    return function (row_a: any, row_b: any) {
      let rez = 0;

      for (const { field: orderBy, descending } of orderBys) {
        const a = row_a[orderBy];
        const b = row_b[orderBy];
        if (a === undefined || b === undefined) {
          throw new Error(`rows_compare: unable to sort by "${orderBy}"`);
        }

        if (a === b) { continue; }

        if (a == null || b == null) {
          if (descending) {
            return a == null ? -1 : 1;
          } else {
            return b == null ? -1 : 1;
          }
        }

        if (isFinite(a) && isFinite(b)) {
          if (descending) {
            rez = Number(b) - Number(a);
          } else {
            rez = Number(a) - Number(b);
          }
        } else {
          if (descending) {
            rez = String(b).localeCompare(a, 'en', { sensitivity: 'base' });
          } else {
            rez = String(a).localeCompare(b, 'en', { sensitivity: 'base' });
          }
        }

        if (rez) { return rez; }
      }

      /* use [id] to break tie */
      const descending = orderBys[0]?.descending ?? true; // most-recent by default
      if (descending) {
        return Number(row_b['id'] ?? 0) - Number(row_a['id'] ?? 0);
      } else {
        return Number(row_a['id'] ?? 0) - Number(row_b['id'] ?? 0);
      }
    };
  };
}
