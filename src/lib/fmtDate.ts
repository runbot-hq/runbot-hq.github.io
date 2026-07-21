export function fmtDate(d: Date): string {
  return d.toLocaleDateString('en-GB', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    timeZone: 'UTC', // dates from frontmatter are UTC midnight; without this
                     // the displayed date can shift back one day in negative-
                     // offset timezones (e.g. local dev on America/Los_Angeles)
  });
}
