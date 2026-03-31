// aurora — Thin wrapper. Real scoring lives at api.omniskey.ai.
import { OMNIS_CONFIG } from '../../omnis/config'

export async function score(text: string): Promise<{ score: number; approved: boolean; degraded?: boolean }> {
  if (!OMNIS_CONFIG.apiKey) {
    // Degraded: basic local heuristic only (not the real AURORA)
    const basic = text.length > 100 ? 0.5 : 0.2
    return { score: basic, approved: basic >= OMNIS_CONFIG.aurora.threshold, degraded: true }
  }
  const res = await fetch(`${OMNIS_CONFIG.apiBase}/aurora/score`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${OMNIS_CONFIG.apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ text }),
  })
  const data = await res.json()
  return { score: data.score, approved: data.score >= OMNIS_CONFIG.aurora.threshold }
}
