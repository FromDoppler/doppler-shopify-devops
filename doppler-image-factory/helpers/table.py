import re

def print_table(data, headers):
    # Processing
    max_widths = {}
    data_copy = [dict(headers)] + list(data)
    final = ''

    a = '-'
    asc_s = ' | '
    asc_t = '-+-'
    asc_p = '| %s |\n'
    asc_h = '+-%s-+\n'

    # Analyse
    for col in data_copy[0].keys():
        max_widths[col] = max([len(str(row[col])) for row in data_copy])
    cols_order = [tup[0] for tup in headers]

    # Filter
    def leftright(c, value):
        if type(value) == int:
            if re.match('.*\[0m', str(value)):
                # Add the escaped characters if the output is colored
                return str(value).rjust(max_widths[c] + 9)
            else:
                return str(value).rjust(max_widths[c])
        else:
            if re.match('.*\[0m', str(value)):
                # Add the escaped characters if the output is colored
                return value.ljust(max_widths[c] + 9)
            else:
                return value.ljust(max_widths[c])

    # Final
    for idx, row in enumerate(data_copy):
        row_str = asc_s.join([leftright(col, row[col]) for col in cols_order])
        final += asc_p % row_str
        if data_copy.index(row) == 0 or data_copy.index(row) == (len(data_copy) - 1):
            line = asc_t.join([a * max_widths[col] for col in cols_order])
            final += asc_h % line
    final = asc_h % line + final
    # Remove last '\n'
    print(final[:-1])
