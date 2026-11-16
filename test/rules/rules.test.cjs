const { test }=require('node:test');
const {readFileSync}=require('node:fs');
const {initializeTestEnvironment,assertFails,assertSucceeds}=require('@firebase/rules-unit-testing');
const {doc,getDoc,getDocs,collection,setDoc,updateDoc,deleteDoc}=require('firebase/firestore');
test('yönetici listesi yalnızca ilgili kimlik tarafından okunabilir',async()=>{
 const env=await initializeTestEnvironment({projectId:'demo-design-battle',firestore:{rules:readFileSync('firestore.rules','utf8')}});
 try {
  await env.withSecurityRulesDisabled(async c=>setDoc(doc(c.firestore(),'admins/admin-1'),{}));
  const admin=env.authenticatedContext('admin-1',{firebase:{sign_in_provider:'password'}}).firestore();
  const other=env.authenticatedContext('other',{firebase:{sign_in_provider:'password'}}).firestore();
  const anonymous=env.authenticatedContext('anon',{firebase:{sign_in_provider:'anonymous'}}).firestore();
  const no=env.unauthenticatedContext().firestore();
  await assertSucceeds(getDoc(doc(admin,'admins/admin-1')));
  await assertSucceeds(getDoc(doc(other,'admins/other')));
  await assertFails(getDoc(doc(other,'admins/admin-1')));
  await assertFails(getDocs(collection(admin,'admins')));
  await assertFails(getDoc(doc(anonymous,'admins/anon')));
  await assertFails(getDoc(doc(no,'admins/admin-1')));
  await assertFails(setDoc(doc(other,'admins/other'),{}));
  await assertFails(updateDoc(doc(admin,'admins/admin-1'),{enabled:false}));
  await assertFails(deleteDoc(doc(admin,'admins/admin-1')));
 } finally {await env.cleanup();}
});
