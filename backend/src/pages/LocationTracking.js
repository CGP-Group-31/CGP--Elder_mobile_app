import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import {
  collection, query, where, onSnapshot, addDoc, updateDoc, deleteDoc,
  doc, serverTimestamp
} from 'firebase/firestore';
import { useAuth } from '../contexts/AuthContext';
import { useToast } from '../contexts/ToastContext';
import { FiPlus, FiEdit2, FiTrash2, FiX, FiMapPin, FiRefreshCw } from 'react-icons/fi';

export default function LocationTracking() {
  const { currentUser } = useAuth();
  const { showToast } = useToast();
  const [locations, setLocations] = useState([]);
  const [elders, setElders] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState(null);
  const [confirmDelete, setConfirmDelete] = useState(null);
  const [form, setForm] = useState({
    elderId: '', elderName: '', latitude: '', longitude: '', address: '', status: 'safe', notes: ''
  });

  useEffect(() => {
    if (!currentUser) return;
    const doctorId = currentUser.uid;

    const q = query(collection(db, 'locations'), where('doctorId', '==', doctorId));
    const unsub = onSnapshot(q, snap => {
      setLocations(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    });

    const unsubElders = onSnapshot(
      query(collection(db, 'elders'), where('doctorId', '==', doctorId)),
      snap => { setElders(snap.docs.map(d => ({ id: d.id, ...d.data() }))); }
    );

    return () => { unsub(); unsubElders(); };
  }, [currentUser]);

  function resetForm() {
    setForm({ elderId: '', elderName: '', latitude: '', longitude: '', address: '', status: 'safe', notes: '' });
    setEditing(null);
  }

  function openAdd() { resetForm(); setShowModal(true); }

  function openEdit(loc) {
    setForm({
      elderId: loc.elderId || '', elderName: loc.elderName || '',
      latitude: loc.latitude || '', longitude: loc.longitude || '',
      address: loc.address || '', status: loc.status || 'safe', notes: loc.notes || ''
    });
    setEditing(loc.id);
    setShowModal(true);
  }

  function handleElderSelect(e) {
    const elder = elders.find(el => el.id === e.target.value);
    setForm({ ...form, elderId: e.target.value, elderName: elder ? `${elder.firstName} ${elder.lastName}` : '' });
  }

  async function handleSubmit(e) {
    e.preventDefault();
    try {
      if (editing) {
        await updateDoc(doc(db, 'locations', editing), { ...form, updatedAt: serverTimestamp() });
        showToast('Location updated');
      } else {
        await addDoc(collection(db, 'locations'), {
          ...form, doctorId: currentUser.uid, createdAt: serverTimestamp(), updatedAt: serverTimestamp()
        });
        showToast('Location record added');
      }
      setShowModal(false);
      resetForm();
    } catch (err) {
      showToast('Error: ' + err.message, 'error');
    }
  }

  async function handleDelete() {
    try {
      await deleteDoc(doc(db, 'locations', confirmDelete));
      showToast('Location record deleted');
      setConfirmDelete(null);
    } catch (err) {
      showToast('Error: ' + err.message, 'error');
    }
  }

  const statusColors = { safe: '#2E7D7A', warning: '#E6B566', danger: '#C62828' };

  return (
    <>
      <div className="page-header">
        <h1>Location Tracking</h1>
        <p>Monitor elder locations for safety</p>
      </div>
      <div className="page-body">
        <div className="toolbar">
          <div></div>
          <button className="btn btn-primary" onClick={openAdd}><FiPlus /> Add Location</button>
        </div>

        {locations.length === 0 ? (
          <div className="card">
            <div className="card-body">
              <div className="empty-state">
                <div className="icon"><FiMapPin /></div>
                <h3>No Location Records</h3>
                <p>Add elder location data to track their whereabouts</p>
              </div>
            </div>
          </div>
        ) : (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(340px, 1fr))', gap: 16 }}>
            {locations.map(loc => (
              <div key={loc.id} className="card" style={{ borderLeft: `4px solid ${statusColors[loc.status] || '#6F7F7D'}` }}>
                <div className="card-body">
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 12 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                      <div style={{
                        width: 40, height: 40, borderRadius: '50%', background: '#BEE8DA',
                        color: '#2E7D7A', display: 'flex', alignItems: 'center', justifyContent: 'center',
                        fontWeight: 700, fontSize: 14
                      }}>
                        {(loc.elderName || 'E')[0]}
                      </div>
                      <div>
                        <strong style={{ fontSize: 14 }}>{loc.elderName}</strong>
                        <div>
                          <span className={`badge ${loc.status === 'safe' ? 'badge-success' : loc.status === 'warning' ? 'badge-warning' : 'badge-danger'}`}>
                            {loc.status}
                          </span>
                        </div>
                      </div>
                    </div>
                    <div className="action-btns">
                      <button className="btn btn-outline btn-sm" onClick={() => openEdit(loc)}><FiEdit2 /></button>
                      <button className="btn btn-danger btn-sm" onClick={() => setConfirmDelete(loc.id)}><FiTrash2 /></button>
                    </div>
                  </div>

                  <div style={{ background: '#D6EFE6', border: '1px solid #BEE8DA', borderRadius: 8, padding: 12, marginBottom: 8 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: 13 }}>
                      <FiMapPin style={{ color: '#2E7D7A' }} />
                      <span>{loc.address || 'No address provided'}</span>
                    </div>
                    {(loc.latitude && loc.longitude) && (
                      <div style={{ fontSize: 11, color: 'var(--text-light)', marginTop: 4 }}>
                        {loc.latitude}, {loc.longitude}
                      </div>
                    )}
                  </div>

                  {loc.notes && (
                    <div style={{ fontSize: 12, color: 'var(--text-light)' }}>📝 {loc.notes}</div>
                  )}

                  <div style={{ fontSize: 11, color: 'var(--text-light)', marginTop: 8, display: 'flex', alignItems: 'center', gap: 4 }}>
                    <FiRefreshCw size={11} />
                    Last updated: {loc.updatedAt?.toDate?.()?.toLocaleString() || 'Unknown'}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal" onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <h2>{editing ? 'Edit Location' : 'Add Location Record'}</h2>
              <button className="modal-close" onClick={() => setShowModal(false)}><FiX /></button>
            </div>
            <form onSubmit={handleSubmit}>
              <div className="modal-body">
                <div className="form-group">
                  <label className="form-label">Elder</label>
                  <select className="form-select" value={form.elderId} onChange={handleElderSelect} required>
                    <option value="">Select Elder</option>
                    {elders.map(el => (
                      <option key={el.id} value={el.id}>{el.firstName} {el.lastName}</option>
                    ))}
                  </select>
                </div>
                <div className="form-group">
                  <label className="form-label">Address</label>
                  <input className="form-input" value={form.address}
                    onChange={e => setForm({ ...form, address: e.target.value })} placeholder="Enter address" />
                </div>
                <div className="form-row">
                  <div className="form-group">
                    <label className="form-label">Latitude</label>
                    <input className="form-input" value={form.latitude}
                      onChange={e => setForm({ ...form, latitude: e.target.value })} placeholder="Enter latitude" />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Longitude</label>
                    <input className="form-input" value={form.longitude}
                      onChange={e => setForm({ ...form, longitude: e.target.value })} placeholder="Enter longitude" />
                  </div>
                </div>
                <div className="form-group">
                  <label className="form-label">Status</label>
                  <select className="form-select" value={form.status} onChange={e => setForm({ ...form, status: e.target.value })}>
                    <option value="safe">✅ Safe</option>
                    <option value="warning">⚠️ Warning</option>
                    <option value="danger">🚨 Danger</option>
                  </select>
                </div>
                <div className="form-group">
                  <label className="form-label">Notes</label>
                  <textarea className="form-textarea" value={form.notes}
                    onChange={e => setForm({ ...form, notes: e.target.value })} placeholder="Additional notes..." />
                </div>
              </div>
              <div className="modal-footer">
                <button type="button" className="btn btn-outline" onClick={() => setShowModal(false)}>Cancel</button>
                <button type="submit" className="btn btn-primary">{editing ? 'Update' : 'Save Location'}</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {confirmDelete && (
        <div className="confirm-overlay" onClick={() => setConfirmDelete(null)}>
          <div className="confirm-box" onClick={e => e.stopPropagation()}>
            <h3>Delete Location?</h3>
            <p>This will permanently remove this location record.</p>
            <div className="btns">
              <button className="btn btn-outline" onClick={() => setConfirmDelete(null)}>Cancel</button>
              <button className="btn btn-danger" onClick={handleDelete}>Delete</button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
