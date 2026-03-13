import React, { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import { FiMail, FiLock, FiUser, FiPhone, FiEye, FiEyeOff, FiArrowRight } from 'react-icons/fi';

export default function Register() {
  const [form, setForm] = useState({
    firstName: '', lastName: '', email: '', password: '', confirmPassword: '',
    phone: '', specialization: '', licenseNumber: ''
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [showPw, setShowPw] = useState(false);
  const { register } = useAuth();
  const navigate = useNavigate();

  function handleChange(e) {
    setForm({ ...form, [e.target.name]: e.target.value });
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');

    if (form.password !== form.confirmPassword) {
      return setError('Passwords do not match.');
    }
    if (form.password.length < 6) {
      return setError('Password must be at least 6 characters.');
    }

    setLoading(true);
    try {
      await register(form.email, form.password, {
        firstName: form.firstName,
        lastName: form.lastName,
        phone: form.phone,
        specialization: form.specialization,
        licenseNumber: form.licenseNumber
      });
      navigate('/');
    } catch (err) {
      const code = err.code || '';
      setError(
        code === 'auth/email-already-in-use' ? 'This email is already registered. Try signing in.' :
        code === 'auth/weak-password' ? 'Password is too weak. Use at least 6 characters.' :
        code === 'auth/invalid-email' ? 'Please enter a valid email address.' :
        code === 'auth/too-many-requests' ? 'Too many attempts. Please try again later.' :
        code === 'auth/network-request-failed' ? 'Network error. Check your connection.' :
        'Registration failed. Please try again.'
      );
    }
    setLoading(false);
  }

  return (
    <div className="auth-page">
      <div className="auth-card" style={{ maxWidth: 500 }}>
        <div className="auth-logo">
          <div className="icon">🩺</div>
          <h1>Create Your Account</h1>
          <p>Join the ElderCare Doctor Portal</p>
        </div>

        {error && <div className="auth-error">{error}</div>}

        <form className="auth-form" onSubmit={handleSubmit}>
          <div className="form-row">
            <div className="form-group">
              <label className="form-label"><FiUser style={{ marginRight: 6, opacity: 0.6 }} />First Name</label>
              <input type="text" className="form-input" name="firstName" placeholder="Enter first name"
                value={form.firstName} onChange={handleChange} required autoComplete="given-name" />
            </div>
            <div className="form-group">
              <label className="form-label"><FiUser style={{ marginRight: 6, opacity: 0.6 }} />Last Name</label>
              <input type="text" className="form-input" name="lastName" placeholder="Enter last name"
                value={form.lastName} onChange={handleChange} required autoComplete="family-name" />
            </div>
          </div>
          <div className="form-group">
            <label className="form-label"><FiMail style={{ marginRight: 6, opacity: 0.6 }} />Email Address</label>
            <input type="email" className="form-input" name="email" placeholder="Enter your email"
              value={form.email} onChange={handleChange} required autoComplete="email" />
          </div>
          <div className="form-row">
            <div className="form-group">
              <label className="form-label"><FiLock style={{ marginRight: 6, opacity: 0.6 }} />Password</label>
              <div style={{ position: 'relative' }}>
                <input type={showPw ? 'text' : 'password'} className="form-input" name="password" placeholder="Min 6 characters"
                  value={form.password} onChange={handleChange} required autoComplete="new-password" />
                <button type="button" onClick={() => setShowPw(!showPw)}
                  style={{ position: 'absolute', right: 12, top: '50%', transform: 'translateY(-50%)', background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-light)', padding: 4 }}>
                  {showPw ? <FiEyeOff size={16} /> : <FiEye size={16} />}
                </button>
              </div>
            </div>
            <div className="form-group">
              <label className="form-label"><FiLock style={{ marginRight: 6, opacity: 0.6 }} />Confirm Password</label>
              <div style={{ position: 'relative' }}>
                <input type={showPw ? 'text' : 'password'} className="form-input" name="confirmPassword" placeholder="Confirm"
                  value={form.confirmPassword} onChange={handleChange} required autoComplete="new-password" />
              </div>
            </div>
          </div>
          <div className="form-group">
            <label className="form-label"><FiPhone style={{ marginRight: 6, opacity: 0.6 }} />Phone Number</label>
            <input type="tel" className="form-input" name="phone" placeholder="Enter phone number"
              value={form.phone} onChange={handleChange} required />
          </div>
          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Specialization</label>
              <select className="form-select" name="specialization" value={form.specialization} onChange={handleChange} required>
                <option value="">Select Specialization</option>
                <option value="General Practitioner">General Practitioner</option>
                <option value="Geriatrics">Geriatrics</option>
                <option value="Cardiology">Cardiology</option>
                <option value="Neurology">Neurology</option>
                <option value="Psychiatry">Psychiatry</option>
                <option value="Orthopedics">Orthopedics</option>
                <option value="Internal Medicine">Internal Medicine</option>
              </select>
            </div>
            <div className="form-group">
              <label className="form-label">License Number</label>
              <input type="text" className="form-input" name="licenseNumber" placeholder="Enter license number"
                value={form.licenseNumber} onChange={handleChange} required />
            </div>
          </div>
          <button type="submit" className="btn btn-primary" disabled={loading} style={{ marginTop: 8 }}>
            {loading ? (
              <span style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <span className="spinner" style={{ width: 16, height: 16, borderWidth: 2 }}></span>
                Creating Account...
              </span>
            ) : (
              <span style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                Create Account <FiArrowRight />
              </span>
            )}
          </button>
        </form>

        <div className="auth-footer">
          Already have an account?{' '}
          <span className="link" onClick={() => navigate('/login')}>Sign In</span>
        </div>
      </div>
    </div>
  );
}
