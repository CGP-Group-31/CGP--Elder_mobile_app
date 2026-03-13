import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, query, where, onSnapshot, updateDoc, doc, serverTimestamp } from 'firebase/firestore';
import { useAuth } from '../contexts/AuthContext';
import { useToast } from '../contexts/ToastContext';
import { FiAlertTriangle, FiCheck, FiClock } from 'react-icons/fi';

export default function SOSAlerts() {
  const { currentUser } = useAuth();
  const { showToast } = useToast();
  const [alerts, setAlerts] = useState([]);
  const [filter, setFilter] = useState('all');

  useEffect(() => {
    if (!currentUser) return;
    const q = query(
      collection(db, 'sosAlerts'),
      where('doctorId', '==', currentUser.uid)
    );
    const unsub = onSnapshot(q, snap => {
      const data = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      data.sort((a, b) => (b.createdAt?.seconds || 0) - (a.createdAt?.seconds || 0));
      setAlerts(data);
    });
    return unsub;
  }, [currentUser]);

  async function handleResolve(alertId) {
    try {
      await updateDoc(doc(db, 'sosAlerts', alertId), {
        status: 'resolved',
        resolvedAt: serverTimestamp()
      });
      showToast('Alert marked as resolved');
    } catch (err) {
      showToast('Error: ' + err.message, 'error');
    }
  }

  async function handleAcknowledge(alertId) {
    try {
      await updateDoc(doc(db, 'sosAlerts', alertId), {
        status: 'acknowledged',
        acknowledgedAt: serverTimestamp()
      });
      showToast('Alert acknowledged');
    } catch (err) {
      showToast('Error: ' + err.message, 'error');
    }
  }

  const filtered = filter === 'all' ? alerts : alerts.filter(a => a.status === filter);

  return (
    <>
      <div className="page-header">
        <h1>SOS Alerts</h1>
        <p>Emergency alerts from your elder patients</p>
      </div>
      <div className="page-body">
        {/* Active Alert Banner */}
        {alerts.filter(a => a.status === 'active').length > 0 && (
          <div className="sos-alert">
            <div className="sos-icon"><FiAlertTriangle /></div>
            <div className="sos-info">
              <h4>{alerts.filter(a => a.status === 'active').length} Active Emergency Alert(s)</h4>
              <p>Immediate attention required for your patients</p>
            </div>
          </div>
        )}

        {/* Filter Tabs */}
        <div className="tabs">
          {['all', 'active', 'acknowledged', 'resolved'].map(tab => (
            <button key={tab} className={`tab ${filter === tab ? 'active' : ''}`} onClick={() => setFilter(tab)}>
              {tab.charAt(0).toUpperCase() + tab.slice(1)}
              {tab === 'active' && alerts.filter(a => a.status === 'active').length > 0 && (
                <span style={{ marginLeft: 6, background: '#C62828', color: 'white', borderRadius: 10, padding: '2px 8px', fontSize: 11 }}>
                  {alerts.filter(a => a.status === 'active').length}
                </span>
              )}
            </button>
          ))}
        </div>

        {filtered.length === 0 ? (
          <div className="card">
            <div className="card-body">
              <div className="empty-state">
                <div className="icon"><FiAlertTriangle /></div>
                <h3>No {filter !== 'all' ? filter : ''} Alerts</h3>
                <p>{filter === 'all' ? 'No SOS alerts have been received yet' : `No ${filter} alerts found`}</p>
              </div>
            </div>
          </div>
        ) : (
          <div style={{ display: 'grid', gap: 12 }}>
            {filtered.map(alert => (
              <div key={alert.id} className="card" style={{
                borderLeft: `4px solid ${alert.status === 'active' ? '#C62828' : alert.status === 'acknowledged' ? '#E6B566' : '#2E7D7A'}`
              }}>
                <div className="card-body" style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
                  <div style={{
                    width: 48, height: 48, borderRadius: '50%',
                    background: alert.status === 'active' ? '#FBDADA' : alert.status === 'acknowledged' ? '#FDF3DC' : '#D6EFE6',
                    color: alert.status === 'active' ? '#C62828' : alert.status === 'acknowledged' ? '#E6B566' : '#2E7D7A',
                    display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 22, flexShrink: 0
                  }}>
                    <FiAlertTriangle />
                  </div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontWeight: 700, fontSize: 14 }}>{alert.elderName || 'Elder'}</div>
                    <div style={{ fontSize: 13, color: 'var(--text-light)' }}>{alert.message || 'Emergency SOS triggered'}</div>
                    <div style={{ fontSize: 11, color: 'var(--text-light)', marginTop: 4, display: 'flex', gap: 12 }}>
                      <span><FiClock style={{ marginRight: 3 }} />{alert.createdAt?.toDate?.()?.toLocaleString() || 'Unknown time'}</span>
                      {alert.location && <span>📍 {alert.location}</span>}
                    </div>
                  </div>
                  <div>
                    <span className={`badge ${alert.status === 'active' ? 'badge-danger' : alert.status === 'acknowledged' ? 'badge-warning' : 'badge-success'}`}>
                      {alert.status}
                    </span>
                  </div>
                  <div className="action-btns">
                    {alert.status === 'active' && (
                      <button className="btn btn-warning btn-sm" onClick={() => handleAcknowledge(alert.id)}>
                        Acknowledge
                      </button>
                    )}
                    {alert.status !== 'resolved' && (
                      <button className="btn btn-success btn-sm" onClick={() => handleResolve(alert.id)}>
                        <FiCheck /> Resolve
                      </button>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </>
  );
}
