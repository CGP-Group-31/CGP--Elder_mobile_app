import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import {
  collection, query, where, onSnapshot, addDoc, updateDoc, deleteDoc,
  doc, serverTimestamp
} from 'firebase/firestore';
import { useAuth } from '../contexts/AuthContext';
import { useToast } from '../contexts/ToastContext';
import { FiPlus, FiEdit2, FiTrash2, FiSearch, FiX, FiCalendar, FiClock } from 'react-icons/fi';

export default function Appointments() {
  const { currentUser } = useAuth();
  const { showToast } = useToast();
  const [appointments, setAppointments] = useState([]);
  const [elders, setElders] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState(null);
  const [search, setSearch] = useState('');
  const [confirmDelete, setConfirmDelete] = useState(null);
  const [form, setForm] = useState({
    elderId: '', elderName: '', date: '', time: '', reason: '', status: 'scheduled', notes: ''
  });

  useEffect(() => {
    if (!currentUser) return;
    const doctorId = currentUser.uid;

    const apptQ = query(collection(db, 'appointments'), where('doctorId', '==', doctorId));
    const unsub = onSnapshot(apptQ, snap => {
      setAppointments(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    });

    const elderQ = query(collection(db, 'elders'), where('doctorId', '==', doctorId));
    const unsubElders = onSnapshot(elderQ, snap => {
      setElders(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    });

    return () => { unsub(); unsubElders(); };
  }, [currentUser]);

  function resetForm() {
    setForm({ elderId: '', elderName: '', date: '', time: '', reason: '', status: 'scheduled', notes: '' });
    setEditing(null);
  }

  function openAdd() { resetForm(); setShowModal(true); }

  function openEdit(appt) {
    setForm({
      elderId: appt.elderId || '',
      elderName: appt.elderName || '',
      date: appt.date || '',
      time: appt.time || '',
      reason: appt.reason || '',
      status: appt.status || 'scheduled',
      notes: appt.notes || ''
    });
    setEditing(appt.id);
    setShowModal(true);
  }

  function handleElderSelect(e) {
    const elder = elders.find(el => el.id === e.target.value);
    setForm({
      ...form,
      elderId: e.target.value,
      elderName: elder ? `${elder.firstName} ${elder.lastName}` : ''
    });
  }

  async function handleSubmit(e) {
    e.preventDefault();
    try {
      if (editing) {
        await updateDoc(doc(db, 'appointments', editing), { ...form, updatedAt: serverTimestamp() });
        showToast('Appointment updated');
      } else {
        await addDoc(collection(db, 'appointments'), {
          ...form, doctorId: currentUser.uid, createdAt: serverTimestamp(), updatedAt: serverTimestamp()
        });
        showToast('Appointment scheduled');
      }
      setShowModal(false);
      resetForm();
    } catch (err) {
      showToast('Error: ' + err.message, 'error');
    }
  }

  async function handleDelete() {
    try {
      await deleteDoc(doc(db, 'appointments', confirmDelete));
      showToast('Appointment deleted');
      setConfirmDelete(null);
    } catch (err) {
      showToast('Error: ' + err.message, 'error');
    }
  }

  async function toggleStatus(appt) {
    const next = appt.status === 'scheduled' ? 'completed' : appt.status === 'completed' ? 'cancelled' : 'scheduled';
    try {
      await updateDoc(doc(db, 'appointments', appt.id), { status: next, updatedAt: serverTimestamp() });
      showToast(`Status changed to ${next}`);
    } catch (err) {
      showToast('Error updating status: ' + err.message, 'error');
    }
  }

  const filtered = appointments.filter(a =>
    `${a.elderName} ${a.reason} ${a.date}`.toLowerCase().includes(search.toLowerCase())
  );

  const statusBadge = (status) => {
    const map = { scheduled: 'badge-info', completed: 'badge-success', cancelled: 'badge-danger' };
    return <span className={`badge ${map[status] || 'badge-neutral'}`}>{status}</span>;
  };

  return (
    <>
      <div className="page-header">
        <h1>Appointments</h1>
        <p>Manage and schedule appointments with elders</p>
      </div>
      <div className="page-body">
        <div className="toolbar">
          <div className="search-bar">
            <FiSearch className="search-icon" />
            <input placeholder="Search appointments..." value={search} onChange={e => setSearch(e.target.value)} />
          </div>
          <button className="btn btn-primary" onClick={openAdd}><FiPlus /> New Appointment</button>
        </div>

        <div className="card">
          <div className="table-wrapper">
            <table>
              <thead>
                <tr>
                  <th>Elder</th>
                  <th>Date</th>
                  <th>Time</th>
                  <th>Reason</th>
                  <th>Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filtered.length === 0 ? (
                  <tr><td colSpan="6">
                    <div className="empty-state">
                      <div className="icon"><FiCalendar /></div>
                      <h3>No Appointments</h3>
                      <p>Schedule your first appointment</p>
                    </div>
                  </td></tr>
                ) : filtered.map(appt => (
                  <tr key={appt.id}>
                    <td><strong>{appt.elderName}</strong></td>
                    <td>{appt.date}</td>
                    <td>{appt.time}</td>
                    <td>{appt.reason}</td>
                    <td>
                      <span style={{ cursor: 'pointer' }} onClick={() => toggleStatus(appt)}>
                        {statusBadge(appt.status)}
                      </span>
                    </td>
                    <td>
                      <div className="action-btns">
                        <button className="btn btn-outline btn-sm" onClick={() => openEdit(appt)}><FiEdit2 /></button>
                        <button className="btn btn-danger btn-sm" onClick={() => setConfirmDelete(appt.id)}><FiTrash2 /></button>
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
              <h2>{editing ? 'Edit Appointment' : 'New Appointment'}</h2>
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
                    <label className="form-label"><FiCalendar style={{ marginRight: 4 }} />Date</label>
                    <input type="date" className="form-input" value={form.date}
                      onChange={e => setForm({ ...form, date: e.target.value })} required />
                  </div>
                  <div className="form-group">
                    <label className="form-label"><FiClock style={{ marginRight: 4 }} />Time</label>
                    <input type="time" className="form-input" value={form.time}
                      onChange={e => setForm({ ...form, time: e.target.value })} required />
                  </div>
                </div>
                <div className="form-group">
                  <label className="form-label">Reason</label>
                  <input className="form-input" value={form.reason} placeholder="Enter reason for visit"
                    onChange={e => setForm({ ...form, reason: e.target.value })} required />
                </div>
                <div className="form-group">
                  <label className="form-label">Status</label>
                  <select className="form-select" value={form.status} onChange={e => setForm({ ...form, status: e.target.value })}>
                    <option value="scheduled">Scheduled</option>
                    <option value="completed">Completed</option>
                    <option value="cancelled">Cancelled</option>
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
                <button type="submit" className="btn btn-primary">{editing ? 'Update' : 'Schedule'}</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {confirmDelete && (
        <div className="confirm-overlay" onClick={() => setConfirmDelete(null)}>
          <div className="confirm-box" onClick={e => e.stopPropagation()}>
            <h3>Delete Appointment?</h3>
            <p>This will permanently remove this appointment.</p>
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
