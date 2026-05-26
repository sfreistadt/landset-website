/**
 * Utility Functions
 * Toast notifications, validation, and helpers
 */

/**
 * Show toast notification
 */
function showToast(message, type = 'info') {
  // Remove existing toast
  const existing = document.getElementById('toast');
  if (existing) {
    existing.remove();
  }

  // Create new toast
  const toast = document.createElement('div');
  toast.id = 'toast';
  toast.className = `toast ${type}`;
  toast.textContent = message;
  document.body.appendChild(toast);

  // Show toast
  setTimeout(() => toast.classList.add('show'), 10);

  // Hide after 5 seconds
  setTimeout(() => {
    toast.classList.remove('show');
    setTimeout(() => toast.remove(), 300);
  }, 5000);
}

/**
 * Validate email format
 */
function isValidEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

/**
 * Validate password strength
 * Must be 12+ chars with uppercase, lowercase, number, and special char
 */
function isValidPassword(password) {
  if (!password || password.length < 12) {
    return false;
  }

  const hasUpperCase = /[A-Z]/.test(password);
  const hasLowerCase = /[a-z]/.test(password);
  const hasNumber = /[0-9]/.test(password);
  const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>_\-+=[\]\\\/`~;']/.test(password);

  return hasUpperCase && hasLowerCase && hasNumber && hasSpecialChar;
}

/**
 * Get password requirements message
 */
function getPasswordRequirements() {
  return 'Password must be at least 12 characters and include uppercase, lowercase, number, and special character';
}

/**
 * Format file size for display
 */
function formatFileSize(bytes) {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
}

/**
 * Debounce function
 */
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

/**
 * Check if user is authenticated (has session cookie)
 */
async function checkAuth() {
  try {
    const user = await api.me();
    return user ? true : false;
  } catch (err) {
    // If API call fails (no backend, no session, etc.), user is not authenticated
    console.log('Not authenticated:', err.message);
    return false;
  }
}

/**
 * Initialize app on page load (for homepage)
 */
async function initializeApp() {
  // Check if auth feature is enabled
  const authEnabled = window.LandsetConfig?.isFeatureEnabled('AUTH_ENABLED');

  if (authEnabled) {
    // Only check authentication if feature is enabled
    const isAuth = await checkAuth();

    if (isAuth) {
      // User is logged in, redirect to dashboard
      window.location.href = '/dashboard.html';
      return;
    }
  }

  // Setup event handlers for existing page elements
  setupExistingPageHandlers();
}

/**
 * Setup handlers for existing page CTAs
 */
function setupExistingPageHandlers() {
  // Check if auth feature is enabled
  const authEnabled = window.LandsetConfig?.isFeatureEnabled('AUTH_ENABLED');

  // Handle navigation "Get early access" links (scroll to bottom section)
  const navCtaButtons = document.querySelectorAll('a[href="#early-access"]');
  navCtaButtons.forEach(btn => {
    if (!authEnabled) {
      // Auth disabled: Show nav button, scroll to bottom section
      btn.style.display = '';
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        document.getElementById('early-access')?.scrollIntoView({
          behavior: 'smooth',
          block: 'center'
        });
      });
    } else {
      // Auth enabled: Hide nav button (LOGIN button will show instead)
      btn.style.display = 'none';
    }
  });

  // Handle bottom section button (opens Tally modal)
  const bottomButton = document.getElementById('cta-get-access-btn');
  if (bottomButton) {
    if (!authEnabled) {
      // Auth disabled: Show button, open Tally modal
      bottomButton.style.display = '';
      bottomButton.addEventListener('click', (e) => {
        e.preventDefault();
        openTallyModal();
      });
    } else {
      // Auth enabled: Hide button
      bottomButton.style.display = 'none';
    }
  }
}

/**
 * Open Tally form modal
 */
function openTallyModal() {
  const modal = document.getElementById('tally-modal');
  if (modal) {
    modal.classList.add('active');
    document.body.style.overflow = 'hidden';

    // Load Tally embed script if not already loaded
    const iframe = modal.querySelector('iframe[data-tally-src]');
    if (iframe && !iframe.src) {
      iframe.src = iframe.getAttribute('data-tally-src');
    }
  }
}

/**
 * Close Tally form modal
 */
function closeTallyModal() {
  const modal = document.getElementById('tally-modal');
  if (modal) {
    modal.classList.remove('active');
    document.body.style.overflow = '';
  }
}

/**
 * Setup auth modal success callbacks
 */
if (typeof authModal !== 'undefined') {
  authModal.onLoginSuccess = () => {
    showToast('Logged in successfully!', 'success');
    // Redirect to dashboard after short delay
    setTimeout(() => {
      window.location.href = '/dashboard.html';
    }, 500);
  };

  authModal.onRegisterSuccess = () => {
    showToast('Account created successfully!', 'success');
    // Redirect to dashboard after short delay
    setTimeout(() => {
      window.location.href = '/dashboard.html';
    }, 500);
  };
}

/**
 * Setup API unauthorized callback
 */
if (typeof api !== 'undefined') {
  api.onUnauthorized = () => {
    // Only show "session expired" and redirect if we're on a protected page
    // If we're already on homepage/public page, don't redirect (prevents loop)
    const isProtectedPage = window.location.pathname.includes('dashboard') ||
                           window.location.pathname.includes('account');

    if (isProtectedPage) {
      showToast('Your session has expired. Please log in again.', 'warning');
      // Redirect to homepage
      setTimeout(() => {
        window.location.href = '/';
      }, 1000);
    }
    // On public pages (homepage), silently handle 401 - just show login button
  };
}

// Initialize app when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeApp);
} else {
  initializeApp();
}
