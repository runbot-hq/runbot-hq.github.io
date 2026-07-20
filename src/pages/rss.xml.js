// @astrojs/rss is a plain npm helper package — NOT an Astro integration.
// Do NOT add it to astro.config.mjs integrations:[]. It is imported and
// called directly here, the same way you'd use any utility library.
// context.site is populated by the `site` field in astro.config.mjs alone.
import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';
import { postPath } from '../lib/postPath';

export async function GET(context) {
  const posts = await getCollection('blog');
  // post.data.date is already a Date object — enforced by z.coerce.date() in
  // src/content/config.ts. .valueOf() is sufficient; wrapping in new Date()
  // again would be redundant.
  posts.sort((a, b) => b.data.date.valueOf() - a.data.date.valueOf());
  return rss({
    title: 'RunBot Blog',
    description: 'Release notes, guides, and updates from the RunBot team — GitHub Actions and local runners in your macOS menu bar.',
    // context.site resolves to 'https://runbot-hq.github.io' (set in
    // astro.config.mjs). The rss() helper uses it to produce absolute URLs
    // for each <link> — valid per RSS spec. No manual concatenation needed.
    site: context.site,
    items: posts.map((post) => ({
      title: post.data.title,
      pubDate: post.data.date,
      description: post.data.summary,
      // postPath() is the single source of truth for URL construction —
      // shared with blog/index.astro and [...slug].astro. See src/lib/postPath.ts.
      link: postPath(post.id),
    })),
    customData: '<language>en-us</language>',
  });
}
