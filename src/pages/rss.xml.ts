// @astrojs/rss is a plain npm helper package — NOT an Astro integration.
// Do NOT add it to astro.config.mjs integrations:[]. It is imported and
// called directly here, the same way you'd use any utility library.
// context.site is populated by the `site` field in astro.config.mjs alone.
//
// Routing note: Astro's file-based router strips only the LAST extension from
// endpoint files. rss.xml.ts → /rss.xml (not /rss.xml.ts, not /rss).
// This is standard Astro endpoint behaviour, verified in dist/ after build.
import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';
import type { APIContext } from 'astro';
import { postPath } from '../lib/postPath';

export async function GET(context: APIContext) {
  const posts = await getCollection('blog');

  // Explicit guard: @astrojs/rss accepts `string | URL | undefined` for site,
  // so TypeScript alone will not catch a missing `site` in astro.config.mjs.
  // This throws at build time (during `astro build`) with a clear message
  // rather than silently producing an RSS feed with broken <link> URLs.
  if (!context.site) {
    throw new Error(
      'rss.xml.ts: context.site is undefined. ' +
      'Ensure `site` is set in astro.config.mjs.'
    );
  }

  // post.data.date is already a Date object — enforced by z.coerce.date() in
  // src/content/config.ts. .valueOf() is sufficient; wrapping in new Date()
  // again would be redundant.
  posts.sort((a, b) => b.data.date.valueOf() - a.data.date.valueOf());
  return rss({
    title: 'RunBot Blog',
    description: 'Release notes, guides, and updates from the RunBot team — GitHub Actions and local runners in your macOS menu bar.',
    // context.site is a URL object (guaranteed non-undefined by the guard above).
    // The rss() helper uses it to produce absolute URLs for each <link> —
    // valid per RSS spec. No manual concatenation needed.
    site: context.site,
    items: posts.map((post) => ({
      title: post.data.title,
      pubDate: post.data.date,
      description: post.data.summary,
      // postPath() returns a root-relative path (e.g. /blog/2026-07-18-ai-pr-review).
      // @astrojs/rss resolves root-relative paths against context.site automatically,
      // producing a valid absolute URL in the RSS output. This is documented
      // behaviour in @astrojs/rss — not an implicit contract. If postPath() ever
      // changes to return a path without a leading slash, this will break.
      // postPath() is the single source of truth — see src/lib/postPath.ts.
      link: postPath(post.id),
    })),
    customData: '<language>en-us</language>',
  });
}
