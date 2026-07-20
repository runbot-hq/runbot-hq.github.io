import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';
import { postPath } from '../lib/postPath';

export async function GET(context) {
  const posts = await getCollection('blog');
  // Sort newest-first. post.data.date is already a Date (z.coerce.date() in
  // the schema), so .valueOf() is sufficient — no need to re-wrap in new Date().
  posts.sort((a, b) => b.data.date.valueOf() - a.data.date.valueOf());
  return rss({
    title: 'RunBot Blog',
    description: 'Release notes, guides, and updates from the RunBot team — GitHub Actions and local runners in your macOS menu bar.',
    site: context.site,
    items: posts.map((post) => ({
      title: post.data.title,
      pubDate: post.data.date,
      description: post.data.summary,
      link: postPath(post.id),
    })),
    customData: '<language>en-us</language>',
  });
}
