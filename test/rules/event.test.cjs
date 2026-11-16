const { test } = require('node:test');
const { readFileSync } = require('node:fs');
const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const { doc, getDoc, getDocs, collection, setDoc, updateDoc, deleteDoc, serverTimestamp } = require('firebase/firestore');

test('olay, referans ve tekil oylar yetkisiz erişime kapalıdır', async () => {
 const env=await initializeTestEnvironment({projectId:'demo-design-battle', firestore:{rules:readFileSync('firestore.rules','utf8')}});
 try {
  await env.withSecurityRulesDisabled(async c=>{
   let d=c.firestore();
   await setDoc(doc(d,'admins/host'),{}); await setDoc(doc(d,'admins/otherhost'),{});
   await setDoc(doc(d,'private/reference'),{answers:['secret']});
   await setDoc(doc(d,'events/event1'),{createdBy:'host',status:'active',questionStatus:'open',questionIndex:0,round:1,allowedOptions:['A','B','C']});
   await setDoc(doc(d,'events/event1/design/current'),{color:'orange'});
  });
  const host=env.authenticatedContext('host',{firebase:{sign_in_provider:'password'}}).firestore();
  const other=env.authenticatedContext('otherhost',{firebase:{sign_in_provider:'password'}}).firestore();
  const a=env.authenticatedContext('a',{firebase:{sign_in_provider:'anonymous'}}).firestore();
  const b=env.authenticatedContext('b',{firebase:{sign_in_provider:'anonymous'}}).firestore();
  const no=env.unauthenticatedContext().firestore();
  await assertSucceeds(getDoc(doc(host,'private/reference')));
  await assertFails(getDoc(doc(a,'private/reference')));
  await assertFails(getDoc(doc(no,'private/reference')));
  await assertSucceeds(getDoc(doc(a,'events/event1')));
  await assertFails(getDoc(doc(no,'events/event1')));
  await assertFails(updateDoc(doc(a,'events/event1'),{status:'completed'}));
  await assertFails(updateDoc(doc(other,'events/event1'),{status:'completed'}));
  await assertFails(setDoc(doc(a,'events/event1/design/current'),{color:'blue'}));
  await assertFails(getDoc(doc(a,'events/event1/design/current')));
  await assertSucceeds(getDoc(doc(host,'events/event1/design/current')));
  await assertFails(setDoc(doc(a,'events/event1/participants/b'),{joinedAt:serverTimestamp()}));
  await assertSucceeds(setDoc(doc(a,'events/event1/participants/a'),{joinedAt:serverTimestamp()}));
  await assertFails(setDoc(doc(a,'events/event1/participants/a'),{joinedAt:serverTimestamp()}));
  await assertSucceeds(setDoc(doc(b,'events/event1/participants/b'),{joinedAt:serverTimestamp()}));
  const avote=doc(a,'events/event1/rounds/1/votes/a');
  await assertFails(setDoc(doc(a,'events/event1/rounds/1/votes/b'),{option:'A',questionIndex:0,createdAt:serverTimestamp()}));
  await assertFails(setDoc(avote,{option:'X',questionIndex:0,createdAt:serverTimestamp()}));
  await assertFails(setDoc(avote,{option:'A',questionIndex:1,createdAt:serverTimestamp()}));
  await assertFails(setDoc(doc(a,'events/event1/rounds/0/votes/a'),{option:'A',questionIndex:0,createdAt:serverTimestamp()}));
  await assertSucceeds(setDoc(avote,{option:'A',questionIndex:0,createdAt:serverTimestamp()}));
  await assertFails(setDoc(avote,{option:'B',questionIndex:0,createdAt:serverTimestamp()}));
  await assertFails(deleteDoc(avote));
  await assertFails(getDocs(collection(a,'events/event1/rounds/1/votes')));
  await assertFails(getDoc(doc(b,'events/event1/rounds/1/votes/a')));
  await assertSucceeds(getDocs(collection(host,'events/event1/rounds/1/votes')));
  await assertFails(getDoc(doc(a,'events/event1/results/0')));
  await assertSucceeds(updateDoc(doc(host,'events/event1'),{questionStatus:'closed'}));
  await assertFails(setDoc(doc(b,'events/event1/rounds/1/votes/b'),{option:'B',questionIndex:0,createdAt:serverTimestamp()}));
  await assertSucceeds(updateDoc(doc(host,'events/event1'),{status:'completed'}));
  await assertFails(setDoc(doc(b,'events/event1/participants/b'),{joinedAt:serverTimestamp()}));
 } finally {await env.cleanup();}
});
