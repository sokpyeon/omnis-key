// OMNIS KEY — Configuration
export const OMNIS_CONFIG = {
  version: '1.0.0',
  apiBase: process.env.OMNIS_API_URL || 'https://api.omniskey.ai',
  apiKey: process.env.OMNIS_API_KEY || null,
  aurora: {
    threshold: 0.80,  // floor — never go below this
    enabled: true,
  },
  vellum: {
    enabled: true,
    local: true,      // envelope IDs created locally, intelligence in cloud
  },
  luna: {
    local: 'sqlite',  // cache only
    cloud: true,      // real memory in API
  },
  degraded: {
    message: 'Advanced intelligence unavailable. Connect to OMNIS KEY API for full capabilities.',
  },
}
