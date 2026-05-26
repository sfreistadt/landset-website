/**
 * Feature Flags & Configuration
 * Control what features are enabled in production
 */

const LandsetConfig = {
  // Feature Flags
  features: {
    /**
     * AUTH_ENABLED - Controls whether authentication UI is shown
     *
     * Production rollout strategy:
     * 1. Set to false initially (auth backend works, but UI hidden)
     * 2. Enable for beta testers via localStorage: localStorage.setItem('landset_auth_beta', 'true')
     * 3. Or enable via URL: ?auth_beta=true
     * 4. Set to true for full public rollout
     */
    AUTH_ENABLED: false,  // Set to true when ready for public rollout
  },

  // API Configuration
  api: {
    baseURL: window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1'
      ? 'http://localhost:3000'
      : 'https://api.landset.co',  // Update with your production API URL
  },

  /**
   * Check if a feature is enabled
   * Respects production config, localStorage overrides, and URL parameters
   */
  isFeatureEnabled(featureName) {
    // Check URL parameter first (highest priority for testing)
    const urlParams = new URLSearchParams(window.location.search);
    const urlOverride = urlParams.get(`${featureName.toLowerCase()}`);
    if (urlOverride === 'true') {
      return true;
    }
    if (urlOverride === 'false') {
      return false;
    }

    // Check localStorage override (for beta testers)
    const storageKey = `landset_${featureName.toLowerCase()}`;
    const storageValue = localStorage.getItem(storageKey);
    if (storageValue === 'true') {
      return true;
    }
    if (storageValue === 'false') {
      return false;
    }

    // Fall back to default configuration
    return this.features[featureName] || false;
  },

  /**
   * Enable feature for current user (persists in localStorage)
   */
  enableFeature(featureName) {
    const storageKey = `landset_${featureName.toLowerCase()}`;
    localStorage.setItem(storageKey, 'true');
    console.log(`✅ Feature "${featureName}" enabled for this browser`);
  },

  /**
   * Disable feature for current user
   */
  disableFeature(featureName) {
    const storageKey = `landset_${featureName.toLowerCase()}`;
    localStorage.setItem(storageKey, 'false');
    console.log(`❌ Feature "${featureName}" disabled for this browser`);
  },

  /**
   * Reset feature to default config value
   */
  resetFeature(featureName) {
    const storageKey = `landset_${featureName.toLowerCase()}`;
    localStorage.removeItem(storageKey);
    console.log(`🔄 Feature "${featureName}" reset to default`);
  }
};

// Make available globally
window.LandsetConfig = LandsetConfig;

// Helper functions for console (for easy beta testing)
window.enableAuth = () => LandsetConfig.enableFeature('AUTH_ENABLED');
window.disableAuth = () => LandsetConfig.disableFeature('AUTH_ENABLED');
window.resetAuth = () => LandsetConfig.resetFeature('AUTH_ENABLED');

// Log current auth status on load (only in development)
if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
  console.log('🔐 Auth enabled:', LandsetConfig.isFeatureEnabled('AUTH_ENABLED'));
  console.log('💡 To enable auth: enableAuth() or visit ?auth_enabled=true');
}
