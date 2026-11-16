const { test } = require('node:test');
const assert = require('node:assert/strict');
const {readFileSync} = require('node:fs');
const {initializeTestEnvironment, assertFails} = require('@firebase/rules-unit-testing');
const {doc,collection,getDocs,setDoc,updateDoc,serverTimestamp,runTransaction} = require('firebase/firestore');

test('eşzamanlı tek oy ve kapanış sonrası yeni oy reddi', async () => {
 const env=await initializeTestEnvironment({projectId:'demo-design-battle',firestore:{rules:readFileSync('firestore.rules','utf8')}});
 try {
  const admin=env.authenticatedContext('race-host',{firebase:{sign_in_provider:'password'}}).firestore();
  const a=env.authenticatedContext('race-a',{firebase:{sign_in_provider:'anonymous'}}).firestore();
  await env.withSecurityRulesDisabled(async c=>{const d=c.firestore();await setDoc(doc(d,'admins/race-host'),{});await setDoc(doc(d,'events/race'),{createdBy:'race-host',status:'active',questionStatus:'open',questionIndex:0,round:1,allowedOptions:['A','B','C']});await setDoc(doc(d,'events/race/participants/race-a'),{joinedAt:new Date()});});
  const path='events/race/rounds/1/votes/race-a';
  const payload={option:'B',questionIndex:0,createdAt:serverTimestamp()};
  const attempts=await Promise.allSettled([setDoc(doc(a,path),payload),setDoc(doc(a,path),payload)]);
  assert.equal(attempts.filter(x=>x.status==='fulfilled').length,1);
  await runTransaction(admin,async tx=>{const ref=doc(admin,'events/race');await tx.get(ref);tx.update(ref,{questionStatus:'settling'});});
  assert.equal((await getDocs(collection(admin,'events/race/rounds/1/votes'))).size,1);
  await assertFails(setDoc(doc(a,'events/race/rounds/1/votes/race-a'),payload));
  await assertFails(updateDoc(doc(a,path),{option:'A'}));
 } finally {await env.cleanup();}
});
