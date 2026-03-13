import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import {
  collection, query, where, onSnapshot, addDoc, updateDoc, deleteDoc,
  doc, serverTimestamp
} from 'firebase/firestore';
import { useAuth } from '../contexts/AuthContext';
import { useToast } from '../contexts/ToastContext';
import { FiPlus, FiEdit2, FiTrash2, FiSearch, FiX, FiBell, FiClock } from 'react-icons/fi';

export default function Reminders() {
  const { currentUser } = useAuth();
  const { showToast } = useToast();
  const [reminders, setReminders] = useState([]);
  const [elders, setElders] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState(null);
  const [search, setSearch] = useState('');
  const [confirmDelete, setConfirmDelete] = useState(null);
  const [form, setForm] = useState({
    elderId: '', elderName: '', title: '', description: '', type: 'medication',
    date: '', time: '', recurring: 'none', status: 'active'
  });

  useEffect(() => {
    if (!currentUser) return;
    const doctorId = currentUser.uid;

    const remQ = query(collection(db, 'reminders'), where('doctorId', '==', doctorId));
    const unsub = onSnapshot(remQ, snap => {
      setReminders(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    });

    const unsubElders = onSnapshot(
      query(collection(db, 'elders'), where('doctorId', '==', doctorId)),
      snap => { setElders(snap.docs.map(d => ({ id: d.id, ...d.data() }))); }
    );

    return () => { unsub(); unsubElders(); };
  }, [currentUser]);

  function resetForm() {
    setForm({ elderId: '', elderName: '', title: '', description: '', type: 'medication', date: '', time: '', recurring: 'none', status: 'active' });
    setEditing(null);
  }

  function openAdd() { resetForm(); setShowModal(true); }

  function openEdit(rem) {
    setForm({
      elderId: rem.elderId || '', elderName: rem.elderName || '', title: rem.title || '',
      description: rem.description || '', type: rem.type || 'medication',
      date: rem.date || '', time: rem.time || '', recurring: rem.recurring || 'none',
      status: rem.status || 'active'
    });
    setEditing(rem.id);
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
        await updateDoc(doc(db, 'reminders', editing), { ...form, updatedAt: serverTimestamp() });
        showToast('Reminder updated');
      } else {
        await addDoc(collection(db, 'reminders'), {
          ...form, doctorId: currentUser.uid, createdAt: serverTimestamp(), updatedAt: serverTimestamp()
        });
        showToast('Reminder created');
      }
      setShowModal(false);
      resetForm();
    } catch (err) {
      showToast('Error: ' + err.message, 'error');
    }
  }

  async function handleDelete() {
    try {
      await deleteDoc(doc(db, 'reminders', confirmDelete));
      showToast('Reminder deleted');
      setConfirmDelete(null);
    } catch (err) {
      showToast('Error: ' + err.message, 'error');
    }
  }

  async function toggleStatus(rem) {
    const next = rem.status === 'active' ? 'completed' : 'active';
    try {
      await updateDoc(doc(db, 'reminders', rem.id), { status: next, updatedAt: serverTimestamp() });
      showToast(`Reminder ${next}`);
    } catch (err) {
      showToast('Error updating status: ' + err.message, 'error');
    }
  }

  const filtered = reminders.filter(r =>
    `${r.elderName} ${r.title} ${r.type}`.toLowerCase().includes(search.toLowerCase())
  );

  const typeIcon = (type) => {
    const icons = { medication: '💊', appointment: '📅', exercise: '🏃', meal: '🍽️', checkup: '🩺', other: '📝' };
    return icons[type] || '📝';
  };

  return (
    <>
      <div className="page-header">
        <h1>Reminders</h1>
        <p>Set and manage reminders for your elder patients</p>
      </div>
      <div className="page-body">
        <div className="toolbar">
          <div className="search-bar">
            <FiSearch className="search-icon" />
            <input placeholder="Search reminders..." value={search} onChange={e => setSearch(e.target.value)} />
          </div>
          <button className="btn btn-primary" onClick={openAdd}><FiPlus /> New Reminder</button>
        </div>

        <div className="card">
          <div className="table-wrapper">
            <table>
              <thead>
                <tr>
                  <th>Type</th>
                  <th>Title</th>
                  <th>Elder</th>
                  <th>Date & Time</th>
                  <th>Recurring</th>
                  <th>Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filtered.length === 0 ? (
                  <tr><td colSpan="7">
                    <div className="empty-state">
                      <div className="icon"><FiBell /></div>
                      <h3>No Reminders</h3>
                      <p>Create reminders for your elders</p>
                    </div>
                  </td></tr>
                ) : filtered.map(rem => (
                  <tr key={rem.id}>
                    <td><span style={{ fontSize: 20 }}>{typeIcon(rem.type)}</span></td>
                    <td><strong>{rem.title}</strong><br /><span style={{ fontSize: 12, color: 'var(--text-light)' }}>{rem.description}</span></td>
                    <td>{rem.elderName}</td>
                    <td><FiClock style={{ marginRight: 4 }} />{rem.date} {rem.time}</td>
                    <td><span className="badge badge-neutral">{rem.recurring}</span></td>
                    <td>
                      <span style={{ cursor: 'pointer' }} onClick={() => toggleStatus(rem)}>
                        <span className={`badge ${rem.status === 'active' ? 'badge-success' : 'badge-neutral'}`}>
                          {rem.status}
                        </span>
                      </span>
                    </td>
                    <td>
                      <div className="action-btns">
                        <button className="btn btn-outline btn-sm" onClick={() => openEdit(rem)}><FiEdit2 /></button>
                        <button className="btn btn-danger btn-sm" onClick={() => setConfirmDelete(rem.id)}><FiTrash2 /></button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal" onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <h2>{editing ? 'Edit Reminder' : 'New Reminder'}</h2>
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
                <div className="form-row">
                  <div className="form-group">
                    <label className="form-label">Title</label>
                    <input className="form-input" value={form.title}
                      onChange={e => setForm({ ...form, title: e.target.value })} required placeholder="Enter reminder title" />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Type</label>
                    <select className="form-select" value={form.type} onChange={e => setForm({ ...form, type: e.target.value })}>
                      <option value="medication">💊 Medication</option>
                      <option value="appointment">📅 Appointment</option>
                      <option value="exercise">🏃 Exercise</option>
                      <option value="meal">🍽️ Meal</option>
                      <option value="checkup">🩺 Checkup</option>
                      <option value="other">📝 Other</option>
                    </select>
                  </div>
                </div>
                <div className="form-group">
                  <label className="form-label">Description</label>
                  <textarea className="form-textarea" value={form.description}
                    onChange={e => setForm({ ...form, description: e.target.value })} placeholder="Details about this reminder..." />
                </div>
                <div className="form-row">
                  <div className="form-group">
                    <label className="form-label">Date</label>
                    <input type="date" className="form-input" value={form.date}
                      onChange={e => setForm({ ...form, date: e.target.value })} required />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Time</label>
                    <input type="time" className="form-input" value={form.time}
                      onChange={e => setForm({ ...form, time: e.target.value })} required />
                  </div>
                </div>
                <div className="form-group">
                  <label className="form-label">Recurring</label>
                  <select className="form-select" value={form.recurring} onChange={e => setForm({ ...form, recurring: e.target.value })}>
                    <option value="none">None (One-time)</option>
                    <option value="daily">Daily</option>
                    <option value="weekly">Weekly</option>
                    <option value="monthly">Monthly</option>
                  </select>
                </div>
              </div>
              <div className="modal-footer">
                <button type="button" className="btn btn-outline" onClick={() => setShowModal(false)}>Cancel</button>
                <button type="submit" className="btn btn-primary">{editing ? 'Update' : 'Create Reminder'}</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {confirmDelete && (
        <div className="confirm-overlay" onClick={() => setConfirmDelete(null)}>
          <div className="confirm-box" onClick={e => e.stopPropagation()}>
            <h3>Delete Reminder?</h3>
            <p>This will permanently remove this reminder.</p>
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
