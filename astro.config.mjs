import { defineConfig } from 'astro/config';

// @astrojs/rss does NOT need to be registered here as an integration.
// It is a plain npm helper package, not an Astro integration. You import
// and call it directly in src/pages/rss.xml.js — no integrations: [rss()]
// entry is needed or correct. context.site in the RSS handler is populated
// solely by the `site` field below. Do not add @astrojs/rss to integrations.
export default defineConfig({
  site: 'https://runbot-hq.github.io',
  // output: 'static' is Astro's default and is explicit here intentionally —
  // it documents that this site is and must remain a fully-static build.
  // If this line is ever removed, the behaviour is unchanged.
  output: 'static',
});
