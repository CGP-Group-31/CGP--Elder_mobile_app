import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, query, where, onSnapshot, addDoc, updateDoc, deleteDoc, doc, serverTimestamp } from 'firebase/firestore';
import { useAuth } from '../contexts/AuthContext';
import { useToast } from '../contexts/ToastContext';
import { FiPlus, FiEdit2, FiTrash2, FiSearch, FiX, FiUser, FiPhone, FiMail } from 'react-icons/fi';

export default function Elders() {
  const { currentUser } = useAuth();
  const { showToast } = useToast();
  const [elders, setElders] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState(null);
  const [search, setSearch] = useState('');
  const [confirmDelete, setConfirmDelete] = useState(null);
  const [form, setForm] = useState({
    firstName: '', lastName: '', email: '', phone: '', age: '',
    address: '', emergencyContact: '', medicalConditions: '', notes: ''
  });

  useEffect(() => {
    if (!currentUser) return;
    const q = query(collection(db, 'elders'), where('doctorId', '==', currentUser.uid));
    const unsub = onSnapshot(q, snap => {
      setElders(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    });
    return unsub;
  }, [currentUser]);

  function resetForm() {
    setForm({ firstName: '', lastName: '', email: '', phone: '', age: '', address: '', emergencyContact: '', medicalConditions: '', notes: '' });
    setEditing(null);
  }

  function openAdd() {
    resetForm();
    setShowModal(true);
  }

  function openEdit(elder) {
    setForm({
      firstName: elder.firstName || '',
      lastName: elder.lastName || '',
      email: elder.email || '',
      phone: elder.phone || '',
      age: elder.age || '',
      address: elder.address || '',
      emergencyContact: elder.emergencyContact || '',
      medicalConditions: elder.medicalConditions || '',
      notes: elder.notes || ''
    });
    setEditing(elder.id);
    setShowModal(true);
  }

  async function handleSubmit(e) {
    e.preventDefault();
    try {
      if (editing) {
        await updateDoc(doc(db, 'elders', editing), { ...form, updatedAt: serverTimestamp() });
        showToast('Elder updated successfully');
      } else {
        await addDoc(collection(db, 'elders'), {
          ...form,
          doctorId: currentUser.uid,
          createdAt: serverTimestamp(),
          updatedAt: serverTimestamp()
        });
        showToast('Elder added successfully');
      }
      setShowModal(false);
      resetForm();
    } catch (err) {
      showToast('Error saving elder: ' + err.message, 'error');
    }
  }

  async function handleDelete() {
    if (!confirmDelete) return;
    try {
      await deleteDoc(doc(db, 'elders', confirmDelete));
      showToast('Elder removed successfully');
      setConfirmDelete(null);
    } catch (err) {
      showToast('Error deleting: ' + err.message, 'error');
    }
  }

  const filtered = elders.filter(e =>
    `${e.firstName} ${e.lastName} ${e.email}`.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <>
      <div className="page-header">
        <h1>My Elders</h1>
        <p>Manage your assigned elderly patients</p>
      </div>
      <div className="page-body">
        <div className="toolbar">
          <div className="search-bar">
            <FiSearch className="search-icon" />
            <input placeholder="Search elders..." value={search} onChange={e => setSearch(e.target.value)} />
          </div>
          <button className="btn btn-primary" onClick={openAdd}><FiPlus /> Add Elder</button>
        </div>

        <div className="card">
          <div className="table-wrapper">
            <table>
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Age</th>
                  <th>Phone</th>
                  <th>Email</th>
                  <th>Conditions</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filtered.length === 0 ? (
                  <tr><td colSpan="6">
                    <div className="empty-state">
                      <div className="icon"><FiUser /></div>
                      <h3>No Elders Found</h3>
                      <p>Add your first elder patient to get started</p>
                    </div>
                  </td></tr>
                ) : filtered.map(elder => (
                  <tr key={elder.id}>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                        <div style={{
                          width: 34, height: 34, borderRadius: '50%', background: '#BEE8DA',
                          color: '#2E7D7A', display: 'flex', alignItems: 'center', justifyContent: 'center',
                          fontWeight: 700, fontSize: 13, flexShrink: 0
                        }}>
                          {(elder.firstName?.[0] || '') + (elder.lastName?.[0] || '')}
                        </div>
                        <div>
                          <strong>{elder.firstName} {elder.lastName}</strong>
                        </div>
                      </div>
                    </td>
                    <td>{elder.age || '—'}</td>
                    <td>{elder.phone || '—'}</td>
                    <td>{elder.email || '—'}</td>
                    <td>
                      <span className="badge badge-info">{elder.medicalConditions || 'None'}</span>
                    </td>
                    <td>
                      <div className="action-btns">
                        <button className="btn btn-outline btn-sm" onClick={() => openEdit(elder)}><FiEdit2 /></button>
                        <button className="btn btn-danger btn-sm" onClick={() => setConfirmDelete(elder.id)}><FiTrash2 /></button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* Add/Edit Modal */}
      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal" onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <h2>{editing ? 'Edit Elder' : 'Add New Elder'}</h2>
              <button className="modal-close" onClick={() => setShowModal(false)}><FiX /></button>
            </div>
            <form onSubmit={handleSubmit}>
              <div className="modal-body">
                <div className="form-row">
                  <div className="form-group">
                    <label className="form-label"><FiUser style={{ marginRight: 4 }} /> First Name</label>
                    <input className="form-input" value={form.firstName}
                      onChange={e => setForm({ ...form, firstName: e.target.value })} required />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Last Name</label>
                    <input className="form-input" value={form.lastName}
                      onChange={e => setForm({ ...form, lastName: e.target.value })} required />
                  </div>
                </div>
                <div className="form-row">
                  <div className="form-group">
                    <label className="form-label"><FiMail style={{ marginRight: 4 }} /> Email</label>
                    <input className="form-input" type="email" value={form.email}
                      onChange={e => setForm({ ...form, email: e.target.value })} />
                  </div>
                  <div className="form-group">
                    <label className="form-label"><FiPhone style={{ marginRight: 4 }} /> Phone</label>
                    <input className="form-input" value={form.phone}
                      onChange={e => setForm({ ...form, phone: e.target.value })} required />
                  </div>
                </div>
                <div className="form-row">
                  <div className="form-group">
                    <label className="form-label">Age</label>
                    <input className="form-input" type="number" value={form.age}
                      onChange={e => setForm({ ...form, age: e.target.value })} />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Emergency Contact</label>
                    <input className="form-input" value={form.emergencyContact}
                      onChange={e => setForm({ ...form, emergencyContact: e.target.value })} />
                  </div>
                </div>
                <div className="form-group">
                  <label className="form-label">Address</label>
                  <input className="form-input" value={form.address}
                    onChange={e => setForm({ ...form, address: e.target.value })} />
                </div>
                <div className="form-group">
                  <label className="form-label">Medical Conditions</label>
                  <textarea className="form-textarea" value={form.medicalConditions}
                    onChange={e => setForm({ ...form, medicalConditions: e.target.value })}
                    placeholder="Enter medical conditions" />
                </div>
                <div className="form-group">
                  <label className="form-label">Notes</label>
                  <textarea className="form-textarea" value={form.notes}
                    onChange={e => setForm({ ...form, notes: e.target.value })}
                    placeholder="Additional notes..." />
                </div>
              </div>
              <div className="modal-footer">
                <button type="button" className="btn btn-outline" onClick={() => setShowModal(false)}>Cancel</button>
                <button type="submit" className="btn btn-primary">{editing ? 'Update' : 'Add Elder'}</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Confirm */}
      {confirmDelete && (
        <div className="confirm-overlay" onClick={() => setConfirmDelete(null)}>
          <div className="confirm-box" onClick={e => e.stopPropagation()}>
            <h3>Delete Elder?</h3>
            <p>This action cannot be undone. All data for this elder will be permanently removed.</p>
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
