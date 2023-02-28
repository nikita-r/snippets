
export class TextsUtil {

  static camelCase2TitlePhrase_NoTrim(identifier: string) {
    let rez = '';
    const re = /([Dd]ataTable|[A-Z]+(?![a-z])|[A-Za-z][a-z]*|_+|[^_A-Za-z\s]+)/y;

    let m, lastIndex;
    while ((m = re.exec(identifier)) !== null) {
      lastIndex = re.lastIndex;
      if (m[1].charAt(0) === '_') { continue; }

      const l = m[1].toLowerCase();
      if (['id', 'utc'].includes(l)) {
        rez += l.toUpperCase();
      } else if (['num', 'number'].includes(l)) {
        rez += '#';
      } else {
        rez += m[1].charAt(0).toUpperCase() + m[1].substring(1);
      }
      rez += ' ';
    }

    if (rez) {
      rez = rez.slice(0, -1);

      if (rez.startsWith('# ') && !rez.startsWith('# Of ')) {
        rez = '# of ' + rez.slice(2);
      }
    } else {
      return '???';
    }
    return rez + identifier.slice(lastIndex);
  }
}
