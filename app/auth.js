/**
 * Authentication Modal
 * Handles login and registration UI
 */

class AuthModal {
  constructor(apiClient) {
    this.api = apiClient;
    this.modal = null;
    this.currentTab = 'login';
    this.init();
  }

  init() {
    this.createModal();
    this.attachEventListeners();
  }

  createModal() {
    const modalHTML = `
      <div id="auth-modal" class="auth-modal" style="display: none;">
        <div class="auth-modal-overlay"></div>
        <div class="auth-modal-content">
          <button class="auth-modal-close">&times;</button>

          <div class="auth-modal-header">
            <h2>Welcome to Landset</h2>
            <p class="auth-modal-subtitle">Property intelligence for Austin real estate</p>
          </div>

          <div class="auth-tabs">
            <button class="auth-tab active" data-tab="login">Log In</button>
            <button class="auth-tab" data-tab="register">Sign Up</button>
          </div>

          <div class="auth-error" id="auth-error" style="display: none;"></div>

          <!-- Login Form -->
          <form id="login-form" class="auth-form" style="display: block;">
            <div class="form-group">
              <label for="login-email">Email</label>
              <input type="email" id="login-email" name="email" required autocomplete="email">
            </div>
            <div class="form-group">
              <label for="login-password">Password</label>
              <input type="password" id="login-password" name="password" required autocomplete="current-password">
            </div>
            <button type="submit" class="btn btn-primary btn-block">
              Log In
            </button>
          </form>

          <!-- Register Form -->
          <form id="register-form" class="auth-form" style="display: none;">
            <div class="form-group">
              <label for="register-email">Email *</label>
              <input type="email" id="register-email" name="email" required autocomplete="email">
            </div>
            <div class="form-group">
              <label for="register-password">Password *</label>
              <input type="password" id="register-password" name="password" required autocomplete="new-password">
              <small class="form-help">At least 12 characters with uppercase, lowercase, number, and special character</small>
            </div>
            <div class="form-group">
              <label for="register-name">Full Name *</label>
              <input type="text" id="register-name" name="name" required autocomplete="name">
            </div>
            <div class="form-group">
              <label for="register-phone">Phone Number *</label>
              <input type="tel" id="register-phone" name="phone" required autocomplete="tel" placeholder="(512) 555-0100">
            </div>
            <div class="form-group">
              <label for="register-address">Address *</label>
              <input type="text" id="register-address" name="address" required autocomplete="street-address" placeholder="123 Main St, Austin, TX 78701">
            </div>
            <div class="form-group">
              <label for="register-customer-type">I am a *</label>
              <select id="register-customer-type" name="customer_type" required>
                <option value="">Select...</option>
                <option value="agent">Real Estate Agent</option>
                <option value="buyer">Buyer</option>
                <option value="seller">Seller</option>
                <option value="other">Other</option>
              </select>
            </div>
            <button type="submit" class="btn btn-primary btn-block">
              Sign Up
            </button>
          </form>
        </div>
      </div>
    `;

    document.body.insertAdjacentHTML('beforeend', modalHTML);
    this.modal = document.getElementById('auth-modal');
  }

  attachEventListeners() {
    // Close modal handlers
    const closeBtn = this.modal.querySelector('.auth-modal-close');
    const overlay = this.modal.querySelector('.auth-modal-overlay');

    closeBtn.addEventListener('click', () => this.hide());
    overlay.addEventListener('click', () => this.hide());

    // Tab switching
    const tabs = this.modal.querySelectorAll('.auth-tab');
    tabs.forEach(tab => {
      tab.addEventListener('click', (e) => this.switchTab(e.target.dataset.tab));
    });

    // Form submissions
    document.getElementById('login-form').addEventListener('submit', (e) => this.handleLogin(e));
    document.getElementById('register-form').addEventListener('submit', (e) => this.handleRegister(e));

    // ESC key to close
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && this.modal.style.display === 'block') {
        this.hide();
      }
    });
  }

  switchTab(tab) {
    this.currentTab = tab;

    // Update tab buttons
    this.modal.querySelectorAll('.auth-tab').forEach(btn => {
      btn.classList.toggle('active', btn.dataset.tab === tab);
    });

    // Update forms
    document.getElementById('login-form').style.display = tab === 'login' ? 'block' : 'none';
    document.getElementById('register-form').style.display = tab === 'register' ? 'block' : 'none';

    // Clear errors
    this.hideError();
  }

  async handleLogin(e) {
    e.preventDefault();
    this.hideError();

    const form = e.target;
    const email = form.email.value.trim();
    const password = form.password.value;

    const submitBtn = form.querySelector('button[type="submit"]');
    submitBtn.disabled = true;
    submitBtn.textContent = 'Logging in...';

    try {
      await this.api.login(email, password);
      this.hide();
      this.onLoginSuccess?.();
    } catch (err) {
      this.showError(err.message, err.detail);
    } finally {
      submitBtn.disabled = false;
      submitBtn.textContent = 'Log In';
    }
  }

  async handleRegister(e) {
    e.preventDefault();
    this.hideError();

    const form = e.target;
    const email = form.email.value.trim();
    const password = form.password.value;
    const name = form.name.value.trim();
    const phone = form.phone.value.trim();
    const address = form.address.value.trim();
    const customerType = form.customer_type.value;

    const submitBtn = form.querySelector('button[type="submit"]');
    submitBtn.disabled = true;
    submitBtn.textContent = 'Creating account...';

    try {
      const result = await this.api.register(email, password, name, phone, address, customerType);

      // Handle generic response for existing email
      if (result.message) {
        this.showError(result.message, result.note);
        submitBtn.disabled = false;
        submitBtn.textContent = 'Sign Up';
        return;
      }

      this.hide();
      this.onRegisterSuccess?.();
    } catch (err) {
      this.showError(err.message, err.detail);
    } finally {
      submitBtn.disabled = false;
      submitBtn.textContent = 'Sign Up';
    }
  }

  showError(message, detail) {
    const errorEl = document.getElementById('auth-error');
    errorEl.textContent = message;
    if (detail) {
      errorEl.textContent += ` ${detail}`;
    }
    errorEl.style.display = 'block';
  }

  hideError() {
    const errorEl = document.getElementById('auth-error');
    errorEl.style.display = 'none';
    errorEl.textContent = '';
  }

  show(tab = 'login') {
    this.switchTab(tab);
    this.modal.style.display = 'block';
    document.body.style.overflow = 'hidden';

    // Focus first input
    setTimeout(() => {
      const firstInput = this.modal.querySelector(`.auth-form[style*="display: block"] input`);
      firstInput?.focus();
    }, 100);
  }

  hide() {
    this.modal.style.display = 'none';
    document.body.style.overflow = '';

    // Clear forms
    document.getElementById('login-form').reset();
    document.getElementById('register-form').reset();
    this.hideError();
  }
}

// Create instance when DOM is ready (only if auth feature is enabled)
let authModal;

function initAuthModal() {
  // Check if auth feature is enabled
  const authEnabled = window.LandsetConfig?.isFeatureEnabled('AUTH_ENABLED');

  if (authEnabled) {
    authModal = new AuthModal(api);
    console.log('🔐 Auth modal initialized');
  } else {
    console.log('🔒 Auth is disabled. Enable with: enableAuth()');
    // Create a stub to prevent errors if code tries to use authModal
    authModal = {
      show: () => console.warn('Auth is currently disabled'),
      hide: () => {},
      onLoginSuccess: null,
      onRegisterSuccess: null
    };
  }
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initAuthModal);
} else {
  initAuthModal();
}
