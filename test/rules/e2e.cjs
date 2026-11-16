// Runs only against localhost Firebase emulators and a debug Flutter Web build.
// The reference below is deliberately synthetic, not the event answer key.
const { chromium } = require('playwright');
const { PNG } = require('pngjs');
const jsQR = require('jsqr');
const { initializeTestEnvironment } = require('@firebase/rules-unit-testing');
const { doc, setDoc, getDoc, updateDoc } = require('firebase/firestore');
const assert = require('node:assert/strict');
const { createHash } = require('node:crypto');
const base = 'http://localhost:8087/';
const watchdog = setTimeout(() => { console.error('Uçtan uca test 160 saniyeyi aştı.'); process.exit(1); }, 160000);
watchdog.unref();
const email = `host-${Date.now()}@example.test`;

async function enable(page) {
  await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.dispatchEvent(new MouseEvent('click', {bubbles:true})));
  await page.waitForTimeout(400);
}
async function waitText(page, text) { await page.waitForFunction(t => document.body.innerText.includes(t), text, {timeout:25000}); }
async function click(page, name) { await page.getByRole('button', {name, exact:true}).click({timeout:25000}); }
async function vote(page, option) {
  await page.getByRole('button').filter({hasText:new RegExp('^'+option+'\\n')}).first().click({timeout:20000});
  await page.waitForTimeout(500);
  await click(page,'Oyumu gönder');
  try { await waitText(page,'Oyun kaydedildi.'); }
  catch(e) { console.error('Katılımcı durumu:', await page.locator('body').innerText()); throw e; }
}
async function simulateInterruptedClose(id) {
  const env=await initializeTestEnvironment({projectId:'demo-design-battle',firestore:{host:'127.0.0.1',port:8085}});
  try { await env.withSecurityRulesDisabled(async c => updateDoc(doc(c.firestore(),`events/${id}`),{questionStatus:'settling'})); }
  finally { await env.cleanup(); }
}
async function seed() {
  if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST) throw new Error('Yalnızca Firebase emülatörleriyle çalıştırın.');
  const response=await fetch('http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=demo-key',{
    method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({email,password:'demo-password-123',returnSecureToken:true})});
  const result=await response.json(); if (!result.localId) throw new Error(JSON.stringify(result));
  const env=await initializeTestEnvironment({projectId:'demo-design-battle', firestore:{host:'127.0.0.1',port:8085}});
  try {
    await env.withSecurityRulesDisabled(async c=>{
      const db = c.firestore();
      await setDoc(doc(db,'admins',result.localId),{});
      await setDoc(doc(db,'private/reference'),{answers:['A','B','C','B','C','A','C','A','B','A']});
    });
  } finally {await env.cleanup();}
}
(async()=>{
 await seed();
 const browser=await chromium.launch({headless:true,args:['--no-sandbox']});
 try {
  const host=await browser.newPage({viewport:{width:1440,height:1000}});const errors=[];
  host.on('pageerror',e=>errors.push(e.message));
  await host.goto(base+'#/admin', {waitUntil:'domcontentloaded', timeout:45000}); await host.waitForTimeout(3000); await enable(host);
  const fields=host.getByRole('textbox'); await fields.nth(0).click();await host.keyboard.type(email);
  await fields.nth(1).click();await host.keyboard.type('demo-password-123');await click(host,'Giriş yap');
  try { await waitText(host,'Yeni etkinlik oluştur'); } catch(e) { console.error('Yönetici giriş durumu:',(await host.locator('body').innerText()).slice(0,1200)); throw e; }
  await click(host,'Yeni etkinlik oluştur');await waitText(host,'Oylamayı aç');
  const id=host.url().split('event=')[1];assert.match(id,/^[A-Za-z0-9]{20}$/);
  // Synthetic key has B/C in several positions; the projected start must
  // instead match the public demo defaults, not that private key.
  const inspection=await initializeTestEnvironment({projectId:'demo-design-battle',firestore:{host:'127.0.0.1',port:8085}});
  try { await inspection.withSecurityRulesDisabled(async c => {
    const design=(await getDoc(doc(c.firestore(),`events/${id}/design/current`))).data();
    assert.deepEqual(design,{
      primaryColorId:'orange',themeMode:'light',appBarStyle:'logo',productLayout:'list',
      productCardStyle:'image_name_price',buttonStyle:'filled',navigationStyle:'bottom',
      iconStyle:'filled',campaignStyle:'large_banner',detailStyle:'image_focused_full_page'
    },'Başlangıç tasarımı özel referanstan bağımsız olmalı');
  }); } finally { await inspection.cleanup(); }
  const screenshot=PNG.sync.read(await host.screenshot()); const qr=jsQR(new Uint8ClampedArray(screenshot.data),screenshot.width,screenshot.height);
  assert.equal(qr?.data,base+'#/join?event='+id); console.log('QR doğrulandı');
  const p1=await browser.newContext({viewport:{width:390,height:844}});const p2=await browser.newContext({viewport:{width:390,height:844}});
  const a=await p1.newPage(), b=await p2.newPage();
  for(const p of [a,b]) {p.on('pageerror',e=>errors.push(e.message));await p.goto(qr.data,{waitUntil:'domcontentloaded',timeout:45000});await p.waitForTimeout(1800);await enable(p);await waitText(p,'Bir sonraki soru');}
  await waitText(host,'2 katılımcı');console.log('İki oturum katıldı');
  for(let q=1;q<=10;q++) {
    await click(host,'Oylamayı aç');await waitText(a,`SORU ${q} / 10`);await waitText(b,`SORU ${q} / 10`);
    if(q===1) {
      const before=await host.screenshot({clip:{x:945,y:125,width:310,height:650}});
      await vote(a,'A');await a.reload();await a.waitForTimeout(2200);await enable(a);await waitText(a,'Oyun kaydedildi.');await waitText(host,'2 katılımcı');
      await vote(b,'B');await waitText(host,'1 oy · %50');await click(host,'Oylamayı kapat');await waitText(host,'Beraberlik var');
      await click(host,'Beraberliği yeniden oylat');await waitText(a,'Beraberlik turu');
      // Wait for the host to render the new round, too; the previous close
      // button can still be visible while its Firestore snapshot catches up.
      await waitText(host,'Açık');
      // An empty runoff must not reintroduce C, which was not tied.
      await click(host,'Oylamayı kapat');
      try { await waitText(host,'Beraberlik var'); } catch(e) { console.error('Yönetici durumu:',await host.locator('body').innerText()); throw e; }
      assert.equal(await host.getByRole('button',{name:'C manuel seç',exact:true}).count(),0);
      await click(host,'Beraberliği yeniden oylat');await waitText(a,'Beraberlik turu');
      await vote(a,'B');await vote(b,'B');await waitText(host,'2 oy · %100');
      await click(host,'Oylamayı kapat');await waitText(host,'Sonraki soru');await host.waitForTimeout(1000);
      const after=await host.screenshot({clip:{x:945,y:125,width:310,height:650}});
      const digest=x=>createHash('sha256').update(x).digest('hex');assert.notEqual(digest(before),digest(after),'Önizleme yenilenmedi');
    } else if(q===2) {
      await vote(a,'A');await vote(b,'B');await waitText(host,'1 oy · %50');
      // Simulate a host reconnect after closing but before calculating.
      await simulateInterruptedClose(id);await waitText(host,'Sonuçları göster');
      await click(host,'Sonuçları göster');await waitText(host,'Beraberlik var');
      await click(host,'B manuel seç');await waitText(host,'Sonraki soru');
    } else {
      await vote(a,'B');await vote(b,'B');await waitText(host,'2 oy · %100');await click(host,'Oylamayı kapat');await waitText(host,q===10?'Etkinliği bitir':'Sonraki soru');
    }
    assert.equal((await host.locator('body').innerText()).includes('İşlem tamamlanamadı'),false,'Yönetici hata mesajı gösterildi');
    await click(host,q===10?'Etkinliği bitir':'Sonraki soru');
    await waitText(host,q===10?'Sonuçları göster':'Oylamayı aç');console.log(`Soru ${q} tamamlandı`);
  }
  await click(host,'Sonuçları göster');await waitText(host,'3 / 10 eşleşme');await waitText(host,'Manuel karar');
  await waitText(host,'Referans neden A · Turuncu?');
  const resultText = await host.locator('body').innerText();
  assert(!resultText.includes('Referans neden B · Koyu tema?'),'Eşleşen soru için açıklama gösterilmemeli');
  assert.deepEqual(errors,[]);console.log('İki ayrı tarayıcı oturumu, 10 soru, 3/10 (test referansı) ve gerekçe: başarılı');
 } finally { await browser.close(); }
})().catch(e=>{console.error(e);process.exitCode=1});
