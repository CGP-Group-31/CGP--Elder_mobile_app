import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import {
  collection, query, where, onSnapshot, addDoc, updateDoc, deleteDoc,
  doc, serverTimestamp
} from 'firebase/firestore';
import { useAuth } from '../contexts/AuthContext';
import { useToast } from '../contexts/ToastContext';
import { FiPlus, FiEdit2, FiTrash2, FiX, FiHeart } from 'react-icons/fi';

export default function WellBeing() {
  const { currentUser } = useAuth();
  const { showToast } = useToast();
  const [records, setRecords] = useState([]);
  const [elders, setElders] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState(null);
  const [confirmDelete, setConfirmDelete] = useState(null);
  const [form, setForm] = useState({
    elderId: '', elderName: '', moodScore: 5, sleepHours: 7, physicalActivityLevel: 'moderate',
    appetite: 'normal', socialInteraction: 'moderate', notes: '', date: new Date().toISOString().split('T')[0]
  });

  useEffect(() => {
    if (!currentUser) return;
    const doctorId = currentUser.uid;

    const q = query(collection(db, 'wellbeing'), where('doctorId', '==', doctorId));
    const unsub = onSnapshot(q, snap => {
      const data = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      data.sort((a, b) => (b.date || '').localeCompare(a.date || ''));
      setRecords(data);
    });

    const unsubElders = onSnapshot(
      query(collection(db, 'elders'), where('doctorId', '==', doctorId)),
      snap => { setElders(snap.docs.map(d => ({ id: d.id, ...d.data() }))); }
    );

    return () => { unsub(); unsubElders(); };
  }, [currentUser]);

  function resetForm() {
    setForm({
      elderId: '', elderName: '', moodScore: 5, sleepHours: 7, physicalActivityLevel: 'moderate',
      appetite: 'normal', socialInteraction: 'moderate', notes: '', date: new Date().toISOString().split('T')[0]
    });
    setEditing(null);
  }

  function openAdd() { resetForm(); setShowModal(true); }

  function openEdit(rec) {
    setForm({
      elderId: rec.elderId || '', elderName: rec.elderName || '',
      moodScore: rec.moodScore || 5, sleepHours: rec.sleepHours || 7,
      physicalActivityLevel: rec.physicalActivityLevel || 'moderate',
      appetite: rec.appetite || 'normal', socialInteraction: rec.socialInteraction || 'moderate',
      notes: rec.notes || '', date: rec.date || ''
    });
    setEditing(rec.id);
    setShowModal(true);
  }

  function handleElderSelect(e) {
    const elder = elders.find(el => el.id === e.target.value);
    setForm({ ...form, elderId: e.target.value, elderName: elder ? `${elder.firstName} ${elder.lastName}` : '' });
  }

  async function handleSubmit(e) {
    e.preventDefault();
    try {
      const data = { ...form, moodScore: Number(form.moodScore), sleepHours: Number(form.sleepHours) };
      if (editing) {
        await updateDoc(doc(db, 'wellbeing', editing), { ...data, updatedAt: serverTimestamp() });
        showToast('Record updated');
      } else {
        await addDoc(collection(db, 'wellbeing'), {
          ...data, doctorId: currentUser.uid, createdAt: serverTimestamp(), updatedAt: serverTimestamp()
        });
        showToast('Well-being record created');
      }
      setShowModal(false);
      resetForm();
    } catch (err) {
      showToast('Error: ' + err.message, 'error');
    }
  }

  async function handleDelete() {
    try {
      await deleteDoc(doc(db, 'wellbeing', confirmDelete));
      showToast('Record deleted');
      setConfirmDelete(null);
    } catch (err) {
      showToast('Error: ' + err.message, 'error');
    }
  }

  function getScoreClass(score) {
    if (score >= 7) return 'score-good';
    if (score >= 4) return 'score-moderate';
    return 'score-poor';
  }

  function getMoodEmoji(score) {
    if (score >= 8) return '😊';
    if (score >= 6) return '🙂';
    if (score >= 4) return '😐';
    if (score >= 2) return '😟';
    return '😢';
  }

  return (
    <>
      <div className="page-header">
        <h1>Mental Well-Being</h1>
        <p>Track and monitor elder mental and physical well-being</p>
      </div>
      <div className="page-body">
        <div className="toolbar">
          <div></div>
          <button className="btn btn-primary" onClick={openAdd}><FiPlus /> New Record</button>
        </div>

        {records.length === 0 ? (
          <div className="card">
            <div className="card-body">
              <div className="empty-state">
                <div className="icon"><FiHeart /></div>
                <h3>No Well-Being Records</h3>
                <p>Start tracking elder well-being by adding a record</p>
              </div>
            </div>
          </div>
        ) : (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: 16 }}>
            {records.map(rec => (
              <div key={rec.id} className="card">
                <div className="card-body">
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 16 }}>
                    <div>
                      <strong style={{ fontSize: 15 }}>{rec.elderName}</strong>
                      <p style={{ fontSize: 12, color: 'var(--text-light)' }}>{rec.date}</p>
                    </div>
                    <div className="action-btns">
                      <button className="btn btn-outline btn-sm" onClick={() => openEdit(rec)}><FiEdit2 /></button>
                      <button className="btn btn-danger btn-sm" onClick={() => setConfirmDelete(rec.id)}><FiTrash2 /></button>
                    </div>
                  </div>

                  <div style={{ textAlign: 'center', marginBottom: 16 }}>
                    <div className={`wellbeing-score ${getScoreClass(rec.moodScore)}`}>
                      {getMoodEmoji(rec.moodScore)}
                    </div>
                    <div style={{ fontSize: 13, fontWeight: 600 }}>Mood: {rec.moodScore}/10</div>
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8, fontSize: 13 }}>
                    <div style={{ background: '#F4F5F0', padding: 8, borderRadius: 8 }}>
                      <div style={{ color: 'var(--text-light)', fontSize: 11 }}>Sleep</div>
                      <strong>{rec.sleepHours}h</strong>
                    </div>
                    <div style={{ background: '#F4F5F0', padding: 8, borderRadius: 8 }}>
                      <div style={{ color: 'var(--text-light)', fontSize: 11 }}>Activity</div>
                      <strong>{rec.physicalActivityLevel}</strong>
                    </div>
                    <div style={{ background: '#F4F5F0', padding: 8, borderRadius: 8 }}>
                      <div style={{ color: 'var(--text-light)', fontSize: 11 }}>Appetite</div>
                      <strong>{rec.appetite}</strong>
                    </div>
                    <div style={{ background: '#F4F5F0', padding: 8, borderRadius: 8 }}>
                      <div style={{ color: 'var(--text-light)', fontSize: 11 }}>Social</div>
                      <strong>{rec.socialInteraction}</strong>
                    </div>
                  </div>

                  {rec.notes && (
                    <div style={{ marginTop: 12, fontSize: 12, color: 'var(--text-light)', background: '#F4F5F0', padding: 10, borderRadius: 8 }}>
                      📝 {rec.notes}
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal" onClick={e => e.stopPropagation()} style={{ maxWidth: 560 }}>
            <div className="modal-header">
              <h2>{editing ? 'Edit Record' : 'New Well-Being Record'}</h2>
              <button className="modal-close" onClick={() => setShowModal(false)}><FiX /></button>
            </div>
            <form onSubmit={handleSubmit}>
              <div className="modal-body">
                <div className="form-row">
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
                    <label className="form-label">Date</label>
                    <input type="date" className="form-input" value={form.date}
                      onChange={e => setForm({ ...form, date: e.target.value })} required />
                  </div>
                </div>
                <div className="form-group">
                  <label className="form-label">Mood Score: {form.moodScore}/10 {getMoodEmoji(form.moodScore)}</label>
                  <input type="range" min="1" max="10" value={form.moodScore}
                    onChange={e => setForm({ ...form, moodScore: e.target.value })}
                    style={{ width: '100%' }} />
                </div>
                <div className="form-row">
                  <div className="form-group">
                    <label className="form-label">Sleep Hours</label>
                    <input type="number" className="form-input" min="0" max="24" value={form.sleepHours}
                      onChange={e => setForm({ ...form, sleepHours: e.target.value })} />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Physical Activity</label>
                    <select className="form-select" value={form.physicalActivityLevel}
                      onChange={e => setForm({ ...form, physicalActivityLevel: e.target.value })}>
                      <option value="none">None</option>
                      <option value="low">Low</option>
                      <option value="moderate">Moderate</option>
                      <option value="high">High</option>
                    </select>
                  </div>
                </div>
                <div className="form-row">
                  <div className="form-group">
                    <label className="form-label">Appetite</label>
                    <select className="form-select" value={form.appetite}
                      onChange={e => setForm({ ...form, appetite: e.target.value })}>
                      <option value="poor">Poor</option>
                      <option value="normal">Normal</option>
                      <option value="good">Good</option>
                    </select>
                  </div>
                  <div className="form-group">
                    <label className="form-label">Social Interaction</label>
                    <select className="form-select" value={form.socialInteraction}
                      onChange={e => setForm({ ...form, socialInteraction: e.target.value })}>
                      <option value="none">None</option>
                      <option value="low">Low</option>
                      <option value="moderate">Moderate</option>
                      <option value="high">High</option>
                    </select>
                  </div>
                </div>
                <div className="form-group">
                  <label className="form-label">Notes</label>
                  <textarea className="form-textarea" value={form.notes}
                    onChange={e => setForm({ ...form, notes: e.target.value })} placeholder="Observations..." />
                </div>
              </div>
              <div className="modal-footer">
                <button type="button" className="btn btn-outline" onClick={() => setShowModal(false)}>Cancel</button>
                <button type="submit" className="btn btn-primary">{editing ? 'Update' : 'Save Record'}</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {confirmDelete && (
        <div className="confirm-overlay" onClick={() => setConfirmDelete(null)}>
          <div className="confirm-box" onClick={e => e.stopPropagation()}>
            <h3>Delete Record?</h3>
            <p>This will permanently remove this well-being record.</p>
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
