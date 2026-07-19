#!/usr/bin/env node
// nous-sync-context.mjs — hard auto-sync of a GTM context file into Nous.
//
// Called by the PostToolUse hook the instant a context/*.md file is edited, so the
// file -> Nous sync happens on SAVE, never depending on the agent remembering to call
// sync_icp. This is the difference between "please sync my ICP" and it just always
// being in sync.
//
// No dependencies (Node 18+ global fetch). Fails SILENTLY and exits 0 when Nous isn't
// connected or anything goes wrong — a context edit must never be blocked by the sync.
//
// Credentials, in order: NOUS_API_KEY / NOUS_API_URL env, then ~/.nous/config.json
// (written by `nous login`). API base defaults to https://api.opennous.cloud.

import { readFileSync, existsSync } from 'node:fs';
import { homedir } from 'node:os';
import { join, basename } from 'node:path';

function loadCreds() {
  let apiKey = process.env.NOUS_API_KEY || '';
  let apiUrl = process.env.NOUS_API_URL || '';
  const cfgPath = join(homedir(), '.nous', 'config.json');
  if ((!apiKey || !apiUrl) && existsSync(cfgPath)) {
    try {
      const c = JSON.parse(readFileSync(cfgPath, 'utf8'));
      apiKey = apiKey || c.apiKey || '';
      apiUrl = apiUrl || c.apiUrl || '';
    } catch { /* ignore malformed config */ }
  }
  return { apiKey, apiUrl: (apiUrl || 'https://api.opennous.cloud').replace(/\/$/, '') };
}

// Map a context filename to the Nous ICP-import section it belongs to. One file -> one
// section; anything contextual we don't have a dedicated section for (voice, messaging,
// about-me) goes to Notes. The index/catalog file is not GTM context — skip it.
function sectionFor(name) {
  const n = name.toLowerCase();
  if (n === 'index.md' || n.startsWith('readme')) return null; // catalog, not context
  if (n.startsWith('icp')) return 'ICP';
  if (n.startsWith('positioning')) return 'Positioning';
  if (n.startsWith('pricing')) return 'Pricing';
  if (n.startsWith('competitor')) return 'Competitors';
  if (n.startsWith('market')) return 'Market';
  if (n.startsWith('product')) return 'Product';
  if (n.includes('motion') || n.startsWith('gtm')) return 'GTM Motion';
  return 'Notes'; // voice-and-tone, messaging, about-me, etc.
}

async function main() {
  const file = process.argv[2];
  if (!file || !existsSync(file)) return;

  const section = sectionFor(basename(file));
  if (!section) return;

  const content = readFileSync(file, 'utf8').trim();
  if (!content) return;

  const { apiKey, apiUrl } = loadCreds();
  if (!apiKey) return; // Nous not connected here — nothing to sync to.

  const rel = file.startsWith(process.cwd() + '/') ? file.slice(process.cwd().length + 1) : file;

  try {
    const res = await fetch(`${apiUrl}/v2/workspace/icp/import`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${apiKey}` },
      body: JSON.stringify({ sections: [{ section, content, source_path: rel }] }),
    });
    // stderr only — keep stdout clean so Claude Code never parses it as hook output.
    if (res.ok) console.error(`[nous] synced ${rel} -> ${section}`);
    else console.error(`[nous] sync failed (${res.status}) for ${rel}`);
  } catch (e) {
    console.error(`[nous] sync error: ${e?.message || e}`);
  }
}

main().catch(() => {});
