// Builds a clean URL path from a post ID.
// - Strips the .md/.mdx extension (Astro 4.x includes it in post.id; Astro 5
//   does not — the replace() becomes a no-op after upgrading and can stay
//   until a cleanup pass).
// - encodeURIComponent guards against filenames with spaces or non-ASCII
//   characters silently producing broken hrefs. Convention is YYYY-MM-DD-slug
//   (hyphens only), but this makes it safe regardless.
// - No trailing slash. GitHub Pages serves both forms but canonical URLs
//   should be consistent; the blog index and RSS feed both use this function
//   so they stay in sync automatically.
export function postPath(id: string): string {
  return `/blog/${id.replace(/\.mdx?$/, '').split('/').map(encodeURIComponent).join('/')}`;
}
