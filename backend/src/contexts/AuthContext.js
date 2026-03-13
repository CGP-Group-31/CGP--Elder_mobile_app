import React, { createContext, useContext, useState, useEffect } from 'react';
import { auth, db } from '../firebase';
import {
  onAuthStateChanged,
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut
} from 'firebase/auth';
import { doc, getDoc, setDoc, serverTimestamp } from 'firebase/firestore';

const AuthContext = createContext();

export const useAuth = () => useContext(AuthContext);

export function AuthProvider({ children }) {
  const [currentUser, setCurrentUser] = useState(null);
  const [doctorProfile, setDoctorProfile] = useState(null);
  const [loading, setLoading] = useState(true);

  async function login(email, password) {
    const result = await signInWithEmailAndPassword(auth, email, password);
    return result;
  }

  async function register(email, password, profileData) {
    const result = await createUserWithEmailAndPassword(auth, email, password);
    const profile = {
      ...profileData,
      email,
      uid: result.user.uid,
      role: 'doctor',
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp()
    };
    await setDoc(doc(db, 'doctors', result.user.uid), profile);
    // Set profile immediately so onAuthStateChanged doesn't get stale/null data
    setDoctorProfile({ ...profileData, email, uid: result.user.uid, role: 'doctor' });
    return result;
  }

  async function refreshProfile() {
    if (!currentUser) return;
    try {
      const docSnap = await getDoc(doc(db, 'doctors', currentUser.uid));
      if (docSnap.exists()) {
        setDoctorProfile(docSnap.data());
      }
    } catch (error) {
      console.error('Error refreshing doctor profile:', error);
    }
  }

  async function logout() {
    await signOut(auth);
    setCurrentUser(null);
    setDoctorProfile(null);
  }

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      setCurrentUser(user);
      if (user) {
        // Only fetch profile if we don't already have it (avoids overwriting data set during register)
        if (!doctorProfile || doctorProfile.uid !== user.uid) {
          try {
            const docSnap = await getDoc(doc(db, 'doctors', user.uid));
            if (docSnap.exists()) {
              setDoctorProfile(docSnap.data());
            }
          } catch (error) {
            console.error('Error fetching doctor profile:', error);
          }
        }
      } else {
        setDoctorProfile(null);
      }
      setLoading(false);
    });
    return unsubscribe;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const value = {
    currentUser,
    doctorProfile,
    setDoctorProfile,
    refreshProfile,
    login,
    register,
    logout,
    loading
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}
