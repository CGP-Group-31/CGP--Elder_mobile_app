import React, { useState, useCallback } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import SplashScreen from './components/SplashScreen';
import Login from './pages/Login';
import Register from './pages/Register';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import Elders from './pages/Elders';
import Appointments from './pages/Appointments';
import Messages from './pages/Messages';
import SOSAlerts from './pages/SOSAlerts';
import Reminders from './pages/Reminders';
import WellBeing from './pages/WellBeing';
import LocationTracking from './pages/LocationTracking';
import Profile from './pages/Profile';
import './App.css';

function PrivateRoute({ children }) {
  const { currentUser, loading } = useAuth();
  if (loading) return <div className="loading-screen"><div className="spinner"></div><p>Loading your workspace...</p></div>;
  return currentUser ? children : <Navigate to="/login" />;
}

function PublicRoute({ children }) {
  const { currentUser, loading } = useAuth();
  if (loading) return <div className="loading-screen"><div className="spinner"></div><p>Loading...</p></div>;
  return !currentUser ? children : <Navigate to="/" />;
}

function App() {
  const [showSplash, setShowSplash] = useState(true);
  const handleSplashFinish = useCallback(() => setShowSplash(false), []);

  if (showSplash) return <SplashScreen onFinish={handleSplashFinish} />;

  return (
    <AuthProvider>
      <Router>
        <Routes>
          <Route path="/login" element={<PublicRoute><Login /></PublicRoute>} />
          <Route path="/register" element={<PublicRoute><Register /></PublicRoute>} />
          <Route path="/" element={<PrivateRoute><Layout /></PrivateRoute>}>
            <Route index element={<Dashboard />} />
            <Route path="elders" element={<Elders />} />
            <Route path="appointments" element={<Appointments />} />
            <Route path="messages" element={<Messages />} />
            <Route path="sos-alerts" element={<SOSAlerts />} />
            <Route path="reminders" element={<Reminders />} />
            <Route path="well-being" element={<WellBeing />} />
            <Route path="location" element={<LocationTracking />} />
            <Route path="profile" element={<Profile />} />
          </Route>
        </Routes>
      </Router>
    </AuthProvider>
  );
}

export default App;
