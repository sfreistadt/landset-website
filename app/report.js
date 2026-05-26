/**
 * Report Generation
 * Handles report form submission and PDF generation
 */

class ReportGenerator {
  constructor(apiClient) {
    this.api = apiClient;
    this.form = null;
    this.loadingOverlay = null;
    this.init();
  }

  init() {
    this.createForm();
    this.createLoadingOverlay();
    this.attachEventListeners();
  }

  createForm() {
    const formHTML = `
      <div id="report-form-container" class="report-form-container" style="display: none;">
        <div class="report-form-header">
          <h2>Generate Property Report</h2>
          <p>Get permit history and neighborhood insights for any Austin property</p>
        </div>

        <form id="report-form" class="report-form">
          <!-- Property Address -->
          <div class="form-group">
            <label for="address">Property Address *</label>
            <input
              type="text"
              id="address"
              name="address"
              placeholder="123 Main St, Austin, TX"
              required
              autocomplete="street-address"
            >
          </div>

          <!-- Unit Number (optional) -->
          <div class="form-group">
            <label for="unit">Unit Number (optional)</label>
            <input
              type="text"
              id="unit"
              name="unit"
              placeholder="e.g., 2B"
              autocomplete="off"
            >
            <small class="form-help">For condos and multi-unit properties</small>
          </div>

          <!-- Agent Information -->
          <div class="form-section-header">
            <h3>Agent Information (optional)</h3>
            <p>Your information will appear on the report</p>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="agent">Agent Name</label>
              <input
                type="text"
                id="agent"
                name="agent"
                placeholder="John Doe"
                autocomplete="name"
              >
            </div>

            <div class="form-group">
              <label for="agency">Agency Name</label>
              <input
                type="text"
                id="agency"
                name="agency"
                placeholder="ABC Realty"
                autocomplete="organization"
              >
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="agent_phone">Phone</label>
              <input
                type="tel"
                id="agent_phone"
                name="agent_phone"
                placeholder="(512) 555-0100"
                autocomplete="tel"
              >
            </div>

            <div class="form-group">
              <label for="agent_email">Email</label>
              <input
                type="email"
                id="agent_email"
                name="agent_email"
                placeholder="john@example.com"
                autocomplete="email"
              >
            </div>
          </div>

          <!-- Photo Uploads -->
          <div class="form-section-header">
            <h3>Photos (optional)</h3>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="headshot">Agent Headshot</label>
              <input
                type="file"
                id="headshot"
                name="headshot"
                accept="image/*"
              >
              <small class="form-help">Max 5MB</small>
            </div>

            <div class="form-group">
              <label for="agency_logo">Agency Logo</label>
              <input
                type="file"
                id="agency_logo"
                name="agency_logo"
                accept="image/*"
              >
              <small class="form-help">Max 5MB</small>
            </div>
          </div>

          <!-- Search Radius -->
          <div class="form-group">
            <label for="radius">Neighborhood Radius: <span id="radius-value">0.5</span> miles</label>
            <input
              type="range"
              id="radius"
              name="radius"
              min="0.1"
              max="2.0"
              step="0.1"
              value="0.5"
            >
            <small class="form-help">Area to analyze around the property</small>
          </div>

          <button type="submit" class="btn btn-primary btn-block">
            Generate Report
          </button>
        </form>

        <div class="report-user-info">
          <div class="user-credits">
            <span id="user-name"></span>
            <button id="logout-btn" class="btn-link">Log out</button>
          </div>
        </div>
      </div>
    `;

    document.body.insertAdjacentHTML('beforeend', formHTML);
    this.form = document.getElementById('report-form');
  }

  createLoadingOverlay() {
    const overlayHTML = `
      <div id="loading-overlay" class="loading-overlay" style="display: none;">
        <div class="spinner"></div>
        <div class="loading-message" id="loading-message">Generating your report...</div>
        <div class="loading-submessage">This typically takes 30-45 seconds</div>
      </div>
    `;

    document.body.insertAdjacentHTML('beforeend', overlayHTML);
    this.loadingOverlay = document.getElementById('loading-overlay');
  }

  attachEventListeners() {
    // Form submission
    this.form.addEventListener('submit', (e) => this.handleSubmit(e));

    // Radius slider
    document.getElementById('radius').addEventListener('input', (e) => {
      document.getElementById('radius-value').textContent = e.target.value;
    });

    // File size validation
    ['headshot', 'agency_logo'].forEach(fieldName => {
      document.getElementById(fieldName).addEventListener('change', (e) => {
        this.validateFileSize(e.target);
      });
    });

    // Logout button
    document.getElementById('logout-btn').addEventListener('click', () => this.handleLogout());
  }

  validateFileSize(input) {
    const file = input.files[0];
    if (file && file.size > 5 * 1024 * 1024) { // 5MB
      showToast(`File "${file.name}" is too large. Maximum size is 5MB.`, 'error');
      input.value = '';
      return false;
    }
    return true;
  }

  async handleSubmit(e) {
    e.preventDefault();

    // Check authentication
    if (!this.api.isAuthenticated()) {
      showToast('Please log in to generate reports', 'error');
      authModal.show('login');
      return;
    }

    const formData = new FormData(this.form);

    // Show loading overlay
    this.showLoading();

    try {
      const response = await this.api.generateReport(formData);

      // Get filename from Content-Disposition header if available
      const contentDisposition = response.headers.get('Content-Disposition');
      let filename = 'landset-report.pdf';
      if (contentDisposition) {
        const matches = /filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/.exec(contentDisposition);
        if (matches && matches[1]) {
          filename = matches[1].replace(/['"]/g, '');
        }
      }

      // Download the PDF
      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = filename;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);

      showToast('Report generated successfully!', 'success');

      // Clear form
      this.form.reset();
      document.getElementById('radius-value').textContent = '0.5';

    } catch (err) {
      console.error('Report generation failed:', err);

      let errorMessage = err.message || 'Failed to generate report';
      if (err.status === 429) {
        errorMessage = 'Rate limit exceeded. You can generate 10 reports per hour.';
      } else if (err.status === 422) {
        errorMessage = 'Could not find that address. Please check and try again.';
      }

      showToast(errorMessage, 'error');
    } finally {
      this.hideLoading();
    }
  }

  async handleLogout() {
    try {
      await this.api.logout();
      this.hide();
      showToast('Logged out successfully', 'success');
      // Optionally redirect or show login modal
    } catch (err) {
      showToast('Logout failed', 'error');
    }
  }

  showLoading() {
    this.loadingOverlay.style.display = 'flex';
  }

  hideLoading() {
    this.loadingOverlay.style.display = 'none';
  }

  show() {
    const container = document.getElementById('report-form-container');
    container.style.display = 'block';

    // Update user info and pre-fill form fields
    const user = this.api.getCurrentUser();
    if (user) {
      document.getElementById('user-name').textContent = user.name || user.email;

      // Pre-fill agent information if user is an agent
      if (user.customer_type === 'agent') {
        document.getElementById('agent').value = user.name || '';
        document.getElementById('agent_phone').value = user.phone || '';
        document.getElementById('agent_email').value = user.email || '';
      }
    }
  }

  hide() {
    const container = document.getElementById('report-form-container');
    container.style.display = 'none';
  }
}

// Create instance when DOM is ready
let reportGenerator;
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    reportGenerator = new ReportGenerator(api);
  });
} else {
  reportGenerator = new ReportGenerator(api);
}
