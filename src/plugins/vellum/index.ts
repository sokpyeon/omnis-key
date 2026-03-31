// vellum — Envelope interface. Chain-of-custody tracking via api.omniskey.ai.
import { OMNIS_CONFIG } from '../../omnis/config'
import { randomUUID } from 'crypto'

export function createEnvelope(prompt: string) {
  return {
    id: randomUUID(),
    prompt_hash: Buffer.from(prompt).toString('base64').slice(0, 16),
    ts_created: Date.now(),
    status: 'pending',
  }
}

export async function recordEnvelope(envelope: ReturnType<typeof createEnvelope>, response: string) {
  if (!OMNIS_CONFIG.apiKey) return  // local-only in degraded mode
  await fetch(`${OMNIS_CONFIG.apiBase}/vellum/envelope`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${OMNIS_CONFIG.apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      ...envelope,
      response_hash: Buffer.from(response).toString('base64').slice(0, 16),
      ts_completed: Date.now(),
      status: 'complete',
    }),
  })
}
