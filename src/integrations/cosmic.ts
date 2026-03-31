/**
 * OMNIS KEY — COSMIC Integration
 * 
 * This file is a HARD INTERFACE BOUNDARY.
 * It contains NO logic, NO scoring, NO intelligence.
 * All computation happens at api.omniskey.ai.
 * 
 * If you are looking for COSMIC engine logic: it is not here.
 * It never will be here.
 */

const API_BASE = process.env.OMNIS_API_URL || 'https://api.omniskey.ai'
const DEGRADED_MSG = 'COSMIC requires API access. Set OMNIS_API_KEY to enable advanced intelligence.'

function requireApiKey(): string {
  const key = process.env.OMNIS_API_KEY
  if (!key) {
    console.warn(`[OMNIS KEY] ${DEGRADED_MSG}`)
    throw new Error(DEGRADED_MSG)
  }
  return key
}

export async function runCosmic(query: string, engine?: string) {
  const key = requireApiKey()
  const res = await fetch(`${API_BASE}/cosmic/run`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${key}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ query, engine }),
  })
  if (!res.ok) throw new Error(`COSMIC API error: ${res.status}`)
  return res.json()
}

export async function runCosmicSafe(query: string, engine?: string): Promise<{
  result?: unknown
  degraded: boolean
  error?: string
}> {
  try {
    const result = await runCosmic(query, engine)
    return { result, degraded: false }
  } catch {
    return { degraded: true, error: DEGRADED_MSG }
  }
}
