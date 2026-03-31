// luna — Memory interface. Real intelligence at api.omniskey.ai.
import { OMNIS_CONFIG } from '../../omnis/config'

export async function read(query: string) {
  if (!OMNIS_CONFIG.apiKey) return { memories: [], degraded: true }
  const res = await fetch(`${OMNIS_CONFIG.apiBase}/luna/read`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${OMNIS_CONFIG.apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ query }),
  })
  return res.json()
}

export async function write(memory: { key: string; value: unknown; context?: string }) {
  if (!OMNIS_CONFIG.apiKey) return { degraded: true }
  await fetch(`${OMNIS_CONFIG.apiBase}/luna/write`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${OMNIS_CONFIG.apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(memory),
  })
}
