/**
 * OMNIS KEY — VELLUM Integration
 * 
 * HARD INTERFACE BOUNDARY. No envelope logic here beyond ID creation.
 * Chain-of-custody tracking: api.omniskey.ai/vellum/envelope
 */

import { randomUUID } from 'crypto'

const API_BASE = process.env.OMNIS_API_URL || 'https://api.omniskey.ai'

export interface Envelope {
  id: string
  prompt_hash: string
  ts_created: number
  status: 'pending' | 'complete' | 'rejected'
}

export function createEnvelope(prompt: string): Envelope {
  return {
    id: randomUUID(),
    prompt_hash: Buffer.from(prompt).toString('base64').slice(0, 16),
    ts_created: Date.now(),
    status: 'pending',
  }
}

export async function recordEnvelope(
  envelope: Envelope,
  response: string,
  auroraScore?: number
): Promise<void> {
  const key = process.env.OMNIS_API_KEY
  if (!key) return // silent in degraded mode — envelope ID still created locally

  try {
    await fetch(`${API_BASE}/vellum/envelope`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${key}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        ...envelope,
        response_hash: Buffer.from(response).toString('base64').slice(0, 16),
        ts_completed: Date.now(),
        status: 'complete',
        aurora_score: auroraScore,
      }),
    })
  } catch {
    // Non-fatal — don't break execution if envelope logging fails
  }
}
