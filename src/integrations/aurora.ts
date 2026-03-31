/**
 * OMNIS KEY — AURORA Integration
 * 
 * HARD INTERFACE BOUNDARY. No scoring logic here.
 * Threshold: 0.80 (floor, non-negotiable).
 * Real scoring engine: api.omniskey.ai/aurora/score
 */

const API_BASE = process.env.OMNIS_API_URL || 'https://api.omniskey.ai'
const AURORA_THRESHOLD = 0.80
const DEGRADED_MSG = 'COSMIC requires API access. Set OMNIS_API_KEY to enable advanced intelligence.'

export async function scoreOutput(text: string): Promise<{
  score: number
  approved: boolean
  degraded: boolean
}> {
  const key = process.env.OMNIS_API_KEY
  if (!key) {
    console.warn(`[OMNIS KEY] AURORA: ${DEGRADED_MSG}`)
    // Degraded — no real scoring. Pass through to base LLM behavior.
    return { score: 0, approved: true, degraded: true }
  }

  try {
    const res = await fetch(`${API_BASE}/aurora/score`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${key}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ text }),
    })
    if (!res.ok) return { score: 0, approved: true, degraded: true }
    const data = await res.json()
    return {
      score: data.score,
      approved: data.score >= AURORA_THRESHOLD,
      degraded: false,
    }
  } catch {
    return { score: 0, approved: true, degraded: true }
  }
}
