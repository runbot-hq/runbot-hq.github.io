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

// APIContext types context.site as URL | undefined. If `site` is ever removed
// from astro.config.mjs, TypeScript will surface the undefined case here at
// build time rather than silently producing broken RSS <link> URLs at runtime.
export async function GET(context: APIContext) {
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
