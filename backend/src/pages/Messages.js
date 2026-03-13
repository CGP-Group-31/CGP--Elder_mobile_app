import React, { useState, useEffect, useRef } from 'react';
import { db } from '../firebase';
import {
  collection, query, where, onSnapshot, addDoc, serverTimestamp, orderBy
} from 'firebase/firestore';
import { useAuth } from '../contexts/AuthContext';
import { FiSend } from 'react-icons/fi';

export default function Messages() {
  const { currentUser, doctorProfile } = useAuth();
  const [elders, setElders] = useState([]);
  const [selectedElder, setSelectedElder] = useState(null);
  const [messages, setMessages] = useState([]);
  const [newMsg, setNewMsg] = useState('');
  const messagesEndRef = useRef(null);

  useEffect(() => {
    if (!currentUser) return;
    const q = query(collection(db, 'elders'), where('doctorId', '==', currentUser.uid));
    const unsub = onSnapshot(q, snap => {
      setElders(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    });
    return unsub;
  }, [currentUser]);

  useEffect(() => {
    if (!selectedElder || !currentUser) return;
    const chatId = [currentUser.uid, selectedElder.id].sort().join('_');
    const q = query(
      collection(db, 'messages'),
      where('chatId', '==', chatId),
      orderBy('createdAt', 'asc')
    );
    const unsub = onSnapshot(q, snap => {
      setMessages(snap.docs.map(d => ({ id: d.id, ...d.data() })));
      setTimeout(() => messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' }), 100);
    });
    return unsub;
  }, [selectedElder, currentUser]);

  async function sendMessage(e) {
    e.preventDefault();
    if (!newMsg.trim() || !selectedElder) return;

    try {
      const chatId = [currentUser.uid, selectedElder.id].sort().join('_');
      await addDoc(collection(db, 'messages'), {
        chatId,
        senderId: currentUser.uid,
        senderName: `Dr. ${doctorProfile?.firstName || ''} ${doctorProfile?.lastName || ''}`,
        receiverId: selectedElder.id,
        receiverName: `${selectedElder.firstName} ${selectedElder.lastName}`,
        text: newMsg.trim(),
        createdAt: serverTimestamp()
      });
      setNewMsg('');
    } catch (err) {
      console.error('Send message error:', err);
    }
  }

  return (
    <>
      <div className="page-header">
        <h1>Messages</h1>
        <p>Communicate with your elder patients</p>
      </div>
      <div className="page-body">
        <div className="chat-layout">
          {/* Sidebar */}
          <div className="chat-sidebar-list">
            <div className="chat-sidebar-header">Conversations</div>
            {elders.length === 0 ? (
              <div className="empty-state" style={{ padding: 20 }}>
                <p>No elders assigned yet. Add elders first.</p>
              </div>
            ) : elders.map(elder => (
              <div
                key={elder.id}
                className={`chat-item ${selectedElder?.id === elder.id ? 'active' : ''}`}
                onClick={() => setSelectedElder(elder)}
              >
                <div className="avatar">
                  {(elder.firstName?.[0] || '') + (elder.lastName?.[0] || '')}
                </div>
                <div className="chat-meta">
                  <div className="name">{elder.firstName} {elder.lastName}</div>
                  <div className="preview">{elder.medicalConditions || 'Patient'}</div>
                </div>
              </div>
            ))}
          </div>

          {/* Chat Main */}
          <div className="chat-main">
            {!selectedElder ? (
              <div className="empty-state" style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
                <div className="icon"><FiSend /></div>
                <h3>Select a Conversation</h3>
                <p>Choose an elder from the list to start chatting</p>
              </div>
            ) : (
              <>
                <div className="chat-main-header">
                  {selectedElder.firstName} {selectedElder.lastName}
                </div>
                <div className="chat-messages">
                  {messages.length === 0 && (
                    <div className="empty-state">
                      <p>No messages yet. Start the conversation!</p>
                    </div>
                  )}
                  {messages.map(msg => (
                    <div key={msg.id} className={`message ${msg.senderId === currentUser.uid ? 'sent' : 'received'}`}>
                      <div>{msg.text}</div>
                      <div className="time">
                        {msg.createdAt?.toDate?.()?.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) || ''}
                      </div>
                    </div>
                  ))}
                  <div ref={messagesEndRef} />
                </div>
                <form className="chat-input-area" onSubmit={sendMessage}>
                  <input
                    placeholder="Type a message..."
                    value={newMsg}
                    onChange={e => setNewMsg(e.target.value)}
                  />
                  <button type="submit" className="btn btn-primary"><FiSend /></button>
                </form>
              </>
            )}
          </div>
        </div>
      </div>
    </>
  );
}
