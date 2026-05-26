/**
 * Landset API Client
 * Handles authenticated requests to the Landset backend
 */

class LandsetAPI {
  constructor(baseURL) {
    this.baseURL = baseURL || 'http://localhost:3000';
    this.currentUser = null;
  }

  /**
   * Make authenticated request with credentials (cookies)
   */
  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;

    const defaultOptions = {
      credentials: 'include', // Include cookies for authentication
      headers: {
        'Content-Type': 'application/json',
        ...options.headers
      }
    };

    const finalOptions = {
      ...defaultOptions,
      ...options,
      headers: {
        ...defaultOptions.headers,
        ...options.headers
      }
    };

    try {
      const response = await fetch(url, finalOptions);

      // Handle various error status codes
      if (!response.ok) {
        const error = await this.handleError(response);
        throw error;
      }

      // For successful responses, return parsed JSON
      if (response.headers.get('content-type')?.includes('application/json')) {
        return await response.json();
      }

      return response;
    } catch (err) {
      // Re-throw with context
      throw err;
    }
  }

  /**
   * Handle API error responses
   */
  async handleError(response) {
    let errorData;
    try {
      errorData = await response.json();
    } catch {
      errorData = { error: 'An error occurred' };
    }

    const error = new Error(errorData.error || 'Request failed');
    error.status = response.status;
    error.detail = errorData.detail;
    error.data = errorData;

    // Handle specific status codes
    if (response.status === 401) {
      // Unauthorized - clear user state
      this.currentUser = null;
      this.onUnauthorized?.();
    }

    return error;
  }

  /**
   * Register new user
   */
  async register(email, password, name, phone, address, customerType) {
    try {
      const data = await this.request('/api/auth/register', {
        method: 'POST',
        body: JSON.stringify({
          email,
          password,
          name,
          phone,
          address,
          customer_type: customerType
        })
      });

      if (data.user) {
        this.currentUser = data.user;
      }

      return data;
    } catch (err) {
      throw err;
    }
  }

  /**
   * Login user
   */
  async login(email, password) {
    try {
      const data = await this.request('/api/auth/login', {
        method: 'POST',
        body: JSON.stringify({ email, password })
      });

      if (data.user) {
        this.currentUser = data.user;
      }

      return data;
    } catch (err) {
      throw err;
    }
  }

  /**
   * Logout user
   */
  async logout() {
    try {
      await this.request('/api/auth/logout', {
        method: 'POST'
      });

      this.currentUser = null;
      return true;
    } catch (err) {
      // Even if request fails, clear user state
      this.currentUser = null;
      throw err;
    }
  }

  /**
   * Get current user info
   */
  async me() {
    try {
      const data = await this.request('/api/auth/me');
      this.currentUser = data.user;
      return data.user;
    } catch (err) {
      this.currentUser = null;
      throw err;
    }
  }

  /**
   * Generate report (multipart/form-data)
   */
  async generateReport(formData) {
    const url = `${this.baseURL}/permits/report`;

    try {
      const response = await fetch(url, {
        method: 'POST',
        credentials: 'include',
        body: formData // Don't set Content-Type - browser will set it with boundary
      });

      if (!response.ok) {
        const error = await this.handleError(response);
        throw error;
      }

      // Return the response for blob handling
      return response;
    } catch (err) {
      throw err;
    }
  }

  /**
   * Get user's reports
   */
  async getReports(limit = 50, offset = 0) {
    try {
      const data = await this.request(`/api/reports?limit=${limit}&offset=${offset}`);
      return data;
    } catch (err) {
      throw err;
    }
  }

  /**
   * Get specific report by ID
   */
  async getReport(id) {
    try {
      const data = await this.request(`/api/reports/${id}`);
      return data.report;
    } catch (err) {
      throw err;
    }
  }

  /**
   * Delete report
   */
  async deleteReport(id) {
    try {
      await this.request(`/api/reports/${id}`, {
        method: 'DELETE'
      });
      return true;
    } catch (err) {
      throw err;
    }
  }

  /**
   * Check if user is authenticated
   */
  isAuthenticated() {
    return this.currentUser !== null;
  }

  /**
   * Get current user
   */
  getCurrentUser() {
    return this.currentUser;
  }
}

// Create singleton instance with config-based URL
const api = new LandsetAPI(
  window.LandsetConfig?.api?.baseURL ||
  (window.location.hostname === 'localhost' ? 'http://localhost:3000' : 'https://api.landset.co')
);

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = LandsetAPI;
}
