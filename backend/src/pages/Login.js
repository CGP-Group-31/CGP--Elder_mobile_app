import React, { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import { FiMail, FiLock, FiEye, FiEyeOff, FiArrowRight } from 'react-icons/fi';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await login(email, password);
      navigate('/');
    } catch (err) {
      const code = err.code || '';
      setError(
        code === 'auth/user-not-found' ? 'No account found with this email.' :
        code === 'auth/wrong-password' ? 'Incorrect password.' :
        code === 'auth/invalid-credential' ? 'Invalid email or password.' :
        code === 'auth/invalid-email' ? 'Please enter a valid email address.' :
        code === 'auth/too-many-requests' ? 'Too many attempts. Please try again later.' :
        code === 'auth/network-request-failed' ? 'Network error. Check your connection.' :
        'Failed to sign in. Please try again.'
      );
    }
    setLoading(false);
  }

  return (
    <div className="auth-page">
      <div className="auth-card">
        <div className="auth-logo">
          <div className="icon">🩺</div>
          <h1>ElderCare Doctor</h1>
          <p>Sign in to manage your patients</p>
        </div>

        {error && <div className="auth-error">{error}</div>}

        <form className="auth-form" onSubmit={handleSubmit}>
          <div className="form-group">
            <label className="form-label"><FiMail style={{ marginRight: 6, opacity: 0.6 }} />Email Address</label>
            <input
              type="email"
              className="form-input"
              placeholder="Enter your email"
              value={email}
              onChange={e => setEmail(e.target.value)}
              required
              autoComplete="email"
            />
          </div>
          <div className="form-group">
            <label className="form-label"><FiLock style={{ marginRight: 6, opacity: 0.6 }} />Password</label>
            <div style={{ position: 'relative' }}>
              <input
                type={showPassword ? 'text' : 'password'}
                className="form-input"
                style={{ paddingRight: 44 }}
                placeholder="Enter your password"
                value={password}
                onChange={e => setPassword(e.target.value)}
                required
                autoComplete="current-password"
              />
              <button type="button" onClick={() => setShowPassword(!showPassword)}
                style={{
                  position: 'absolute', right: 12, top: '50%', transform: 'translateY(-50%)',
                  background: 'none', border: 'none', cursor: 'pointer', color: '#7C8B89',
                  display: 'flex', alignItems: 'center', padding: 4
                }}>
                {showPassword ? <FiEyeOff size={16} /> : <FiEye size={16} />}
              </button>
            </div>
          </div>
          <button type="submit" className="btn btn-primary" disabled={loading}
            style={{ marginTop: 8 }}>
            {loading ? (
              <span style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <span className="spinner" style={{ width: 16, height: 16, borderWidth: 2 }}></span>
                Signing in...
              </span>
            ) : (
              <span style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                Sign In <FiArrowRight />
              </span>
            )}
          </button>
        </form>

        <div className="auth-footer">
          Don't have an account?{' '}
          <span className="link" onClick={() => navigate('/register')}>Create Account</span>
        </div>
      </div>
    </div>
  );
}
