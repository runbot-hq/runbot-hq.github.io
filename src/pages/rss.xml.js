import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const posts = await getCollection('blog');
  // Sort newest-first
  posts.sort((a, b) => new Date(b.data.date) - new Date(a.data.date));
  return rss({
    title: 'RunBot Blog',
    description: 'Release notes, guides, and updates from the RunBot team — GitHub Actions and local runners in your macOS menu bar.',
    site: context.site,
    items: posts.map((post) => ({
      title: post.data.title,
      pubDate: post.data.date,
      description: post.data.summary,
      link: `/blog/${post.id.replace(/\.mdx?$/, '')}/`,
    })),
    customData: '<language>en-us</language>',
  });
}
