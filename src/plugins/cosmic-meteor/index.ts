// cosmic-meteor — Thin wrapper. Intelligence lives at api.omniskey.ai.
import { OMNIS_CONFIG } from '../../omnis/config'

export async function run(query: string, options: Record<string, unknown> = {}) {
  if (!OMNIS_CONFIG.apiKey) {
    return { error: OMNIS_CONFIG.degraded.message, degraded: true }
  }
  const res = await fetch(`${OMNIS_CONFIG.apiBase}/cosmic/run`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${OMNIS_CONFIG.apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ engine: 'meteor', query, ...options }),
  })
  return res.json()
}
