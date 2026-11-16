const { test } = require('node:test');
const { readFileSync } = require('node:fs');
const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const { initializeApp, deleteApp } = require('firebase/app');
const { getAuth, connectAuthEmulator, createUserWithEmailAndPassword, signInAnonymously, signOut, signInWithEmailAndPassword } = require('firebase/auth');
const { getFirestore, connectFirestoreEmulator, getDoc, setDoc, doc } = require('firebase/firestore');
const assert = require('node:assert/strict');

test('Auth emulator: yönetici girişi, yetki belgesi ve anonim oturum', async () => {
  const projectId = 'demo-design-battle';
  const env = await initializeTestEnvironment({ projectId, firestore: { rules: readFileSync('firestore.rules', 'utf8') } });
  const app = initializeApp({ apiKey: 'demo-key', appId: 'demo-app', projectId, authDomain: 'localhost' }, 'auth-integration');
  const auth = getAuth(app);
  connectAuthEmulator(auth, 'http://127.0.0.1:9099', { disableWarnings: true });
  const db = getFirestore(app);
  connectFirestoreEmulator(db, '127.0.0.1', 8085);
  try {
    const created = await createUserWithEmailAndPassword(auth, 'yonetici@example.test', 'test-password-123');
    const uid = created.user.uid;
    await env.withSecurityRulesDisabled(async ctx => setDoc(doc(ctx.firestore(), 'admins', uid), { enabled: true }));
    assert.equal((await assertSucceeds(getDoc(doc(db, 'admins', uid)))).exists(), true);
    await signOut(auth);
    const anon = await signInAnonymously(auth);
    assert.equal(anon.user.isAnonymous, true);
    await assertFails(getDoc(doc(db, 'admins', uid)));
    await assertFails(setDoc(doc(db, 'events/a/votes/b'), { option: 'A' }));
    await signOut(auth);
    const again = await signInWithEmailAndPassword(auth, 'yonetici@example.test', 'test-password-123');
    assert.equal(again.user.uid, uid);
    assert.equal((await assertSucceeds(getDoc(doc(db, 'admins', uid)))).exists(), true);
  } finally { await deleteApp(app); await env.cleanup(); }
});
