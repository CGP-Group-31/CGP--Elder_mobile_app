import React, { useState } from 'react';
import { NavLink, Outlet } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { ToastProvider } from '../contexts/ToastContext';
import {
  FiHome, FiUsers, FiCalendar, FiMessageSquare, FiAlertTriangle,
  FiBell, FiHeart, FiMapPin, FiUser, FiLogOut, FiMenu, FiX, FiShield
} from 'react-icons/fi';

export default function Layout() {
  const { doctorProfile, logout } = useAuth();
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const navItems = [
    { to: '/', icon: <FiHome />, label: 'Dashboard', end: true },
    { to: '/elders', icon: <FiUsers />, label: 'My Elders' },
    { to: '/appointments', icon: <FiCalendar />, label: 'Appointments' },
    { to: '/messages', icon: <FiMessageSquare />, label: 'Messages' },
    { to: '/sos-alerts', icon: <FiAlertTriangle />, label: 'SOS Alerts' },
    { to: '/reminders', icon: <FiBell />, label: 'Reminders' },
    { to: '/well-being', icon: <FiHeart />, label: 'Well-Being' },
    { to: '/location', icon: <FiMapPin />, label: 'Location Tracking' },
  ];

  const initials = doctorProfile
    ? (doctorProfile.firstName?.[0] || '') + (doctorProfile.lastName?.[0] || '')
    : 'DR';

  return (
    <ToastProvider>
      <div className="app-layout">
        {sidebarOpen && <div className="sidebar-overlay" onClick={() => setSidebarOpen(false)} />}
        
        <button className="mobile-toggle" onClick={() => setSidebarOpen(!sidebarOpen)}>
          {sidebarOpen ? <FiX /> : <FiMenu />}
        </button>

        <aside className={`sidebar ${sidebarOpen ? 'open' : ''}`}>
          <div className="sidebar-header">
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <div style={{ width: 36, height: 36, borderRadius: 10, background: 'rgba(255,255,255,0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <FiShield size={20} />
              </div>
              <div>
                <h2 style={{ margin: 0 }}>ElderCare</h2>
                <p style={{ margin: 0, fontSize: 11, opacity: 0.7 }}>Doctor Portal</p>
              </div>
            </div>
          </div>

          <nav className="sidebar-nav">
            <div className="nav-section-title">Main Menu</div>
            {navItems.map(item => (
              <NavLink
                key={item.to}
                to={item.to}
                end={item.end}
                className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}
                onClick={() => setSidebarOpen(false)}
              >
                <span className="icon">{item.icon}</span>
                {item.label}
              </NavLink>
            ))}

            <div className="nav-section-title">Account</div>
            <NavLink
              to="/profile"
              className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}
              onClick={() => setSidebarOpen(false)}
            >
              <span className="icon"><FiUser /></span>
              My Profile
            </NavLink>
          </nav>

          <div className="sidebar-footer">
            <div className="sidebar-user">
              <div className="avatar">{initials}</div>
              <div className="info">
                <div className="name">
                  Dr. {doctorProfile?.firstName || 'Doctor'} {doctorProfile?.lastName || ''}
                </div>
                <div className="role">{doctorProfile?.specialization || 'General Practitioner'}</div>
              </div>
              <button className="sidebar-logout" onClick={logout} title="Logout">
                <FiLogOut />
              </button>
            </div>
          </div>
        </aside>

        <main className="main-content">
          <Outlet />
        </main>
      </div>
    </ToastProvider>
  );
}
