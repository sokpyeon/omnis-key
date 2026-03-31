/**
 * OMNIS KEY — LUNA Integration
 * 
 * HARD INTERFACE BOUNDARY. No memory intelligence here.
 * Real memory graph: api.omniskey.ai/luna
 * Local: temporary session cache only.
 */

const API_BASE = process.env.OMNIS_API_URL || 'https://api.omniskey.ai'

export interface MemoryEntry {
  key: string
  value: unknown
  context?: string
  ts?: number
}

export async function readMemory(query: string): Promise<{
  memories: MemoryEntry[]
  degraded: boolean
}> {
  const key = process.env.OMNIS_API_KEY
  if (!key) {
    return { memories: [], degraded: true }
  }

  try {
    const res = await fetch(`${API_BASE}/luna/read`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${key}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ query }),
    })
    if (!res.ok) return { memories: [], degraded: true }
    const data = await res.json()
    return { memories: data.memories || [], degraded: false }
  } catch {
    return { memories: [], degraded: true }
  }
}

export async function writeMemory(entry: MemoryEntry): Promise<void> {
  const key = process.env.OMNIS_API_KEY
  if (!key) return // silent in degraded mode

  try {
    await fetch(`${API_BASE}/luna/write`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${key}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ ...entry, ts: Date.now() }),
    })
  } catch {
    // Non-fatal
  }
}
