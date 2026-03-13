import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { doc, updateDoc, serverTimestamp } from 'firebase/firestore';
import { useAuth } from '../contexts/AuthContext';
import { useToast } from '../contexts/ToastContext';
import { FiUser, FiMail, FiPhone, FiEdit2, FiSave, FiX, FiAward, FiHash } from 'react-icons/fi';

export default function Profile() {
  const { currentUser, doctorProfile, setDoctorProfile } = useAuth();
  const { showToast } = useToast();
  const [editing, setEditing] = useState(false);
  const [loading, setLoading] = useState(false);
  const [form, setForm] = useState({
    firstName: '', lastName: '', phone: '', specialization: '', licenseNumber: '', bio: ''
  });

  useEffect(() => {
    if (doctorProfile) {
      setForm({
        firstName: doctorProfile.firstName || '',
        lastName: doctorProfile.lastName || '',
        phone: doctorProfile.phone || '',
        specialization: doctorProfile.specialization || '',
        licenseNumber: doctorProfile.licenseNumber || '',
        bio: doctorProfile.bio || ''
      });
    }
  }, [doctorProfile]);

  async function handleSave(e) {
    e.preventDefault();
    if (!form.firstName.trim() || !form.lastName.trim()) {
      showToast('First and last name are required', 'error');
      return;
    }
    setLoading(true);
    try {
      await updateDoc(doc(db, 'doctors', currentUser.uid), {
        ...form, updatedAt: serverTimestamp()
      });
      // Sync updated profile back to AuthContext so sidebar/dashboard reflect changes immediately
      setDoctorProfile(prev => ({ ...prev, ...form }));
      showToast('Profile updated successfully');
      setEditing(false);
    } catch (err) {
      showToast('Error: ' + err.message, 'error');
    }
    setLoading(false);
  }

  const specializations = [
    'General Practitioner', 'Geriatrics', 'Cardiology', 'Neurology',
    'Psychiatry', 'Orthopedics', 'Internal Medicine', 'Other'
  ];

  const initials = `${(form.firstName || 'D')[0]}${(form.lastName || '')[0] || ''}`.toUpperCase();

  return (
    <>
      <div className="page-header">
        <h1>My Profile</h1>
        <p>Manage your doctor profile information</p>
      </div>
      <div className="page-body">
        <div style={{ maxWidth: 700, margin: '0 auto' }}>
          {/* Profile Header Card */}
          <div className="card" style={{ background: 'linear-gradient(135deg, #2E7D7A 0%, #1A5955 100%)', color: '#fff', marginBottom: 24 }}>
            <div className="card-body" style={{ display: 'flex', alignItems: 'center', gap: 24 }}>
              <div style={{
                width: 80, height: 80, borderRadius: '50%', background: 'rgba(255,255,255,0.2)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontSize: 28, fontWeight: 700, border: '3px solid rgba(255,255,255,0.4)'
              }}>
                {initials}
              </div>
              <div>
                <h2 style={{ color: '#fff', margin: 0, fontSize: 22 }}>
                  Dr. {form.firstName} {form.lastName}
                </h2>
                <div style={{ opacity: 0.8, marginTop: 4, fontSize: 14 }}>
                  {form.specialization || 'Specialization not set'}
                </div>
                <div style={{ opacity: 0.7, marginTop: 2, fontSize: 13 }}>
                  {currentUser?.email}
                </div>
              </div>
              {!editing && (
                <button
                  onClick={() => setEditing(true)}
                  style={{
                    marginLeft: 'auto', background: 'rgba(255,255,255,0.2)', border: '1px solid rgba(255,255,255,0.4)',
                    color: '#fff', cursor: 'pointer', padding: '8px 16px', borderRadius: 8,
                    display: 'flex', alignItems: 'center', gap: 6, fontSize: 13
                  }}
                >
                  <FiEdit2 /> Edit Profile
                </button>
              )}
            </div>
          </div>

          {/* Profile Details */}
          <div className="card">
            <div className="card-body">
              {editing ? (
                <form onSubmit={handleSave}>
                  <h3 style={{ marginBottom: 16 }}>Edit Profile</h3>
                  <div className="form-row">
                    <div className="form-group">
                      <label className="form-label">First Name</label>
                      <input className="form-input" value={form.firstName}
                        onChange={e => setForm({ ...form, firstName: e.target.value })} required />
                    </div>
                    <div className="form-group">
                      <label className="form-label">Last Name</label>
                      <input className="form-input" value={form.lastName}
                        onChange={e => setForm({ ...form, lastName: e.target.value })} required />
                    </div>
                  </div>
                  <div className="form-group">
                    <label className="form-label">Phone</label>
                    <input className="form-input" value={form.phone}
                      onChange={e => setForm({ ...form, phone: e.target.value })} placeholder="Enter phone number" />
                  </div>
                  <div className="form-row">
                    <div className="form-group">
                      <label className="form-label">Specialization</label>
                      <select className="form-select" value={form.specialization}
                        onChange={e => setForm({ ...form, specialization: e.target.value })}>
                        <option value="">Select</option>
                        {specializations.map(s => <option key={s} value={s}>{s}</option>)}
                      </select>
                    </div>
                    <div className="form-group">
                      <label className="form-label">License Number</label>
                      <input className="form-input" value={form.licenseNumber}
                        onChange={e => setForm({ ...form, licenseNumber: e.target.value })} />
                    </div>
                  </div>
                  <div className="form-group">
                    <label className="form-label">Bio</label>
                    <textarea className="form-textarea" rows={3} value={form.bio}
                      onChange={e => setForm({ ...form, bio: e.target.value })}
                      placeholder="A brief description about yourself..." />
                  </div>
                  <div style={{ display: 'flex', gap: 12, justifyContent: 'flex-end', marginTop: 16 }}>
                    <button type="button" className="btn btn-outline" onClick={() => {
                      setEditing(false);
                      if (doctorProfile) setForm({
                        firstName: doctorProfile.firstName || '', lastName: doctorProfile.lastName || '',
                        phone: doctorProfile.phone || '', specialization: doctorProfile.specialization || '',
                        licenseNumber: doctorProfile.licenseNumber || '', bio: doctorProfile.bio || ''
                      });
                    }}><FiX /> Cancel</button>
                    <button type="submit" className="btn btn-primary" disabled={loading}>
                      <FiSave /> {loading ? 'Saving...' : 'Save Changes'}
                    </button>
                  </div>
                </form>
              ) : (
                <div>
                  <h3 style={{ marginBottom: 20 }}>Profile Information</h3>
                  <div style={{ display: 'grid', gap: 16 }}>
                    <InfoRow icon={<FiUser />} label="Full Name" value={`Dr. ${form.firstName} ${form.lastName}`} />
                    <InfoRow icon={<FiMail />} label="Email" value={currentUser?.email} />
                    <InfoRow icon={<FiPhone />} label="Phone" value={form.phone || 'Not provided'} />
                    <InfoRow icon={<FiAward />} label="Specialization" value={form.specialization || 'Not set'} />
                    <InfoRow icon={<FiHash />} label="License Number" value={form.licenseNumber || 'Not provided'} />
                    {form.bio && (
                      <div>
                        <div style={{ fontSize: 12, color: 'var(--text-light)', marginBottom: 4 }}>Bio</div>
                        <div style={{ fontSize: 14, lineHeight: 1.6 }}>{form.bio}</div>
                      </div>
                    )}
                  </div>
                  <div style={{ marginTop: 24, padding: '12px 16px', background: '#D6EFE6', borderRadius: 8, fontSize: 12, color: '#2E7D7A' }}>
                    Account created: {doctorProfile?.createdAt?.toDate?.()?.toLocaleDateString() || 'Unknown'}
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

function InfoRow({ icon, label, value }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '10px 0', borderBottom: '1px solid #BEE8DA' }}>
      <div style={{
        width: 36, height: 36, borderRadius: 8, background: '#BEE8DA', color: '#2E7D7A',
        display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 16
      }}>
        {icon}
      </div>
      <div>
        <div style={{ fontSize: 11, color: 'var(--text-light)' }}>{label}</div>
        <div style={{ fontSize: 14, fontWeight: 500 }}>{value}</div>
      </div>
    </div>
  );
}
