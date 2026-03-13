import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, query, where, onSnapshot } from 'firebase/firestore';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import {
  FiUsers, FiCalendar, FiAlertTriangle, FiBell,
  FiMessageSquare, FiClock, FiArrowRight, FiMapPin, FiActivity
} from 'react-icons/fi';

export default function Dashboard() {
  const { currentUser, doctorProfile } = useAuth();
  const navigate = useNavigate();
  const [stats, setStats] = useState({ elders: 0, appointments: 0, sosAlerts: 0, reminders: 0 });
  const [recentAlerts, setRecentAlerts] = useState([]);
  const [upcomingAppointments, setUpcomingAppointments] = useState([]);

  useEffect(() => {
    if (!currentUser) return;
    const doctorId = currentUser.uid;
    const unsubs = [];

    // Elders count - realtime
    const eldersQ = query(collection(db, 'elders'), where('doctorId', '==', doctorId));
    unsubs.push(onSnapshot(eldersQ, snap => {
      setStats(s => ({ ...s, elders: snap.size }));
    }, () => {}));

    // Appointments - realtime count + upcoming list
    const apptQ = query(collection(db, 'appointments'), where('doctorId', '==', doctorId));
    unsubs.push(onSnapshot(apptQ, snap => {
      const allAppts = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      setStats(s => ({ ...s, appointments: allAppts.length }));
      // Sort by date ascending and take first 5 for upcoming
      const upcoming = [...allAppts]
        .filter(a => a.status !== 'cancelled')
        .sort((a, b) => (a.date || '').localeCompare(b.date || ''))
        .slice(0, 5);
      setUpcomingAppointments(upcoming);
    }, () => {}));

    // Reminders count - realtime
    const remQ = query(collection(db, 'reminders'), where('doctorId', '==', doctorId));
    unsubs.push(onSnapshot(remQ, snap => {
      setStats(s => ({ ...s, reminders: snap.size }));
    }, () => {}));

    // SOS alerts - realtime
    const sosQ = query(collection(db, 'sosAlerts'), where('doctorId', '==', doctorId));
    unsubs.push(onSnapshot(sosQ, snap => {
      const alerts = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      alerts.sort((a, b) => (b.createdAt?.seconds || 0) - (a.createdAt?.seconds || 0));
      setRecentAlerts(alerts.slice(0, 5));
      setStats(s => ({ ...s, sosAlerts: alerts.filter(a => a.status === 'active').length }));
    }, () => {}));

    return () => unsubs.forEach(u => u());
  }, [currentUser]);

  const greeting = () => {
    const h = new Date().getHours();
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  };

  return (
    <>
      <div className="page-header">
        <h1>{greeting()}, Dr. {doctorProfile?.lastName || doctorProfile?.firstName || 'Doctor'}</h1>
        <p>Here's what's happening with your patients today.</p>
      </div>
      <div className="page-body">
        {/* Active SOS alerts */}
        {recentAlerts.filter(a => a.status === 'active').map(alert => (
          <div key={alert.id} className="sos-alert">
            <div className="sos-icon"><FiAlertTriangle /></div>
            <div className="sos-info">
              <h4>SOS Alert from {alert.elderName || 'Elder'}</h4>
              <p>{alert.message || 'Emergency assistance requested'} — {alert.createdAt?.toDate?.()?.toLocaleString() || 'Just now'}</p>
            </div>
            <button className="btn btn-danger btn-sm" onClick={() => navigate('/sos-alerts')}>
              Respond <FiArrowRight />
            </button>
          </div>
        ))}

        {/* Stats */}
        <div className="stats-grid">
          <div className="stat-card" onClick={() => navigate('/elders')} style={{ cursor: 'pointer' }}>
            <div className="stat-icon blue"><FiUsers /></div>
            <div className="stat-info">
              <h4>{stats.elders}</h4>
              <p>My Elders</p>
            </div>
          </div>
          <div className="stat-card" onClick={() => navigate('/appointments')} style={{ cursor: 'pointer' }}>
            <div className="stat-icon green"><FiCalendar /></div>
            <div className="stat-info">
              <h4>{stats.appointments}</h4>
              <p>Appointments</p>
            </div>
          </div>
          <div className="stat-card" onClick={() => navigate('/sos-alerts')} style={{ cursor: 'pointer' }}>
            <div className="stat-icon red"><FiAlertTriangle /></div>
            <div className="stat-info">
              <h4>{stats.sosAlerts}</h4>
              <p>Active SOS</p>
            </div>
          </div>
          <div className="stat-card" onClick={() => navigate('/reminders')} style={{ cursor: 'pointer' }}>
            <div className="stat-icon orange"><FiBell /></div>
            <div className="stat-info">
              <h4>{stats.reminders}</h4>
              <p>Reminders</p>
            </div>
          </div>
        </div>

        <div className="grid-2">
          {/* Upcoming Appointments */}
          <div className="card">
            <div className="card-header">
              <h3><FiClock style={{ marginRight: 8 }} />Upcoming Appointments</h3>
              <button className="btn btn-sm btn-outline" onClick={() => navigate('/appointments')}>
                View All <FiArrowRight />
              </button>
            </div>
            <div className="card-body">
              {upcomingAppointments.length === 0 ? (
                <div className="empty-state">
                  <div className="icon"><FiCalendar /></div>
                  <h3>No Appointments</h3>
                  <p>Schedule appointments from the Appointments page</p>
                  <button className="btn btn-primary btn-sm" onClick={() => navigate('/appointments')}>
                    Schedule Now <FiArrowRight />
                  </button>
                </div>
              ) : (
                upcomingAppointments.map(appt => (
                  <div key={appt.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 0', borderBottom: '1px solid var(--border)' }}>
                    <div>
                      <strong style={{ fontSize: 13, color: 'var(--text)' }}>{appt.elderName}</strong>
                      <p style={{ fontSize: 12, color: 'var(--text-light)', marginTop: 2 }}>{appt.reason}</p>
                    </div>
                    <div style={{ textAlign: 'right' }}>
                      <span className="badge badge-info">{appt.date}</span>
                      <p style={{ fontSize: 11, color: 'var(--text-light)', marginTop: 4 }}>{appt.time}</p>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>

          {/* Quick Actions */}
          <div className="card">
            <div className="card-header">
              <h3><FiActivity style={{ marginRight: 8 }} />Quick Actions</h3>
            </div>
            <div className="card-body">
              <div style={{ display: 'grid', gap: 10 }}>
                <button className="btn btn-primary btn-lg" onClick={() => navigate('/elders')} style={{ justifyContent: 'flex-start' }}>
                  <FiUsers /> Manage Elders
                </button>
                <button className="btn btn-success btn-lg" onClick={() => navigate('/appointments')} style={{ justifyContent: 'flex-start' }}>
                  <FiCalendar /> Schedule Appointment
                </button>
                <button className="btn btn-warning btn-lg" onClick={() => navigate('/reminders')} style={{ justifyContent: 'flex-start' }}>
                  <FiBell /> Set Reminder
                </button>
                <button className="btn btn-outline btn-lg" onClick={() => navigate('/messages')} style={{ justifyContent: 'flex-start' }}>
                  <FiMessageSquare /> Send Message
                </button>
                <button className="btn btn-outline btn-lg" onClick={() => navigate('/location')} style={{ justifyContent: 'flex-start' }}>
                  <FiMapPin /> Track Locations
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
