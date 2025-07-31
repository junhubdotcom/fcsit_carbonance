
import { onDocumentCreated, onDocumentWritten } from 'firebase-functions/v2/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import axios from 'axios';

initializeApp();
const db = getFirestore();

const GEMINI_API_KEY = 'AIzaSyCIWb3At_0Q-QyZccNX0zlujY8KVCYc2ns';
const GEMINI_URL = `https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=${GEMINI_API_KEY}`;

// ==================== Utility Functions ====================

const MALAYSIA_OFFSET = 8 * 60 * 60 * 1000;

function getToday() {
  return new Date();
}

function shiftToMalaysia(date) {
  return new Date(date.getTime() + MALAYSIA_OFFSET);
}

function shiftToUTC(date) {
  return new Date(date.getTime() - MALAYSIA_OFFSET);
}

function getWeekNumber(date) {
  const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  const dayNum = d.getUTCDay() || 7;
  d.setUTCDate(d.getUTCDate() + 4 - dayNum);
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  return Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
}

function getDateId(prefix, date) {
  const malaysia = shiftToMalaysia(date);
  const y = malaysia.getFullYear();
  const m = String(malaysia.getMonth() + 1).padStart(2, '0');
  const d = String(malaysia.getDate()).padStart(2, '0');
  return `${prefix}_${y}-${m}${prefix === 'monthly' ? '' : `-${d}`}`;
}

function getPreviousPeriodDate(period, currentDate) {
  const date = shiftToMalaysia(currentDate);
  if (period === 'daily') date.setDate(date.getDate() - 1);
  else if (period === 'weekly') {
    const day = date.getDay();
    const offset = day === 0 ? 6 : day - 1;
    date.setDate(date.getDate() - offset - 7);
  } else if (period === 'monthly') {
    date.setMonth(date.getMonth() - 1);
    date.setDate(1);
  }
  return shiftToUTC(date);
}


function getDayRange(dateUTC) {
  // const start = new Date(date.getFullYear(), date.getMonth(), date.getDate());
  // const end = new Date(start);
  // end.setDate(start.getDate() + 1);
  // return { start, end };
  const local = shiftToMalaysia(dateUTC);
  const startLocal = new Date(local.getFullYear(), local.getMonth(), local.getDate());
  const endLocal = new Date(startLocal);
  endLocal.setDate(startLocal.getDate() + 1);
  return { start: shiftToUTC(startLocal), end: shiftToUTC(endLocal) };
}

function getWeekRange(dateUTC) {
  // const day = date.getDay(); // Sunday = 0
  // const start = new Date(date);
  // start.setDate(start.getDate() - (day === 0 ? 6 : day - 1)); // Monday is the first day of the week!
  // start.setHours(0, 0, 0, 0);
  // const end = new Date(start);
  // end.setDate(start.getDate() + 6);
  // return { start, end };
  const local = shiftToMalaysia(dateUTC);
  const day = local.getDay();
  const startLocal = new Date(local);
  startLocal.setDate(local.getDate() - (day === 0 ? 6 : day - 1));
  startLocal.setHours(0, 0, 0, 0);
  const endLocal = new Date(startLocal);
  endLocal.setDate(startLocal.getDate() + 7);
  return { start: shiftToUTC(startLocal), end: shiftToUTC(endLocal) };
}

function getMonthRange(dateUTC) {
  // const start = new Date(date.getFullYear(), date.getMonth(), 1);
  // const end = new Date(date.getFullYear(), date.getMonth() + 1, 1);
  // return { start, end };
  const local = shiftToMalaysia(dateUTC);
  const startLocal = new Date(local.getFullYear(), local.getMonth(), 1);
  const endLocal = new Date(local.getFullYear(), local.getMonth() + 1, 1);
  return { start: shiftToUTC(startLocal), end: shiftToUTC(endLocal) };
}


// Get and parse transactions from income/expense in Firestore 
async function collectTransactions(start, end) {
  const transactions = [];

  const incomeSnap = await db.collection('Income')
    .where('dateTime', '>=', start)
    .where('dateTime', '<', end)
    .get();

  incomeSnap.forEach(doc => {
    const d = doc.data();
    transactions.push({
      id: doc.id,
      date: d.dateTime.toDate().toISOString(),
      category: d.category || 'Unknown',
      amount: d.amount,
      type: 'income',
      description: d.name || '',
      carbon_footprint: 0
    });
  });

  const expenseSnap = await db.collection('Expense')
    .where('dateTime', '>=', start)
    .where('dateTime', '<', end)
    .get();

  for (const expenseDoc of expenseSnap.docs) {
    const expense = expenseDoc.data();
    const itemsRef = expense.items || [];

    for (const itemRef of itemsRef) {
      if (!itemRef) continue;
      const itemSnap = await itemRef.get();
      if (!itemSnap.exists) continue;
      const item = itemSnap.data();

      transactions.push({
        id: expenseDoc.id,
        date: expense.dateTime.toDate().toISOString(),
        category: item.category || 'General',
        amount: item.price * (item.quantity || 1),
        type: 'expense',
        description: item.name || expense.transactionName || '',
        carbon_footprint: item.carbon_footprint || 0
      });
    }
  }

  return transactions;
}

// Fetch previous summary to be more smart and personalized
async function fetchPreviousSummary(period, currentDate = new Date()) {
  try {
    const prevDate = getPreviousPeriodDate(period, currentDate);

    const y = prevDate.getFullYear();
    const m = String(prevDate.getMonth() + 1).padStart(2, '0');
    const d = String(prevDate.getDate()).padStart(2, '0');

    let docId;
    if (period === 'daily') docId = `daily_${y}-${m}-${d}`;
    else if (period === 'weekly') docId = `weekly_${y}-${m}-${d}`;
    else docId = `monthly_${y}-${m}`;

    const snapshot = await db.collection('InsightsSummary').doc(docId).get();

    if (!snapshot.exists) {
      console.log(`🕵️ No previous ${period} summary found (id: ${docId})`);
      return null;
    }

    const data = snapshot.data();
    if (!data || !Array.isArray(data.insights) || data.insights.length === 0) {
      console.log(`⚠️ Previous ${period} summary exists but empty or invalid`);
      return null;
    }

    return data.insights.join(' ');
  } catch (e) {
    console.error("🚨 Failed to fetch previous summary:", e);
    return null;
  }
}

// Call Gemini 
async function getAIInsights(transactions, dateRange, rawDate) {
  const previousSummary = await fetchPreviousSummary(dateRange, rawDate);

  const prompt = `You are a smart assistant analyzing a user's spending and environmental footprint over time.
  The transaction is in RM and carbon footprint is recorded in kg.
  This week’s transaction period is: ${dateRange}

  ${previousSummary ? `Here is the previous period's summary for context:\n"${previousSummary}"\n` : ""}

  Now, analyze the new transactions. Identify:
  - Recurring behaviors or new spending trends
  - Notable increases/decreases in categories
  - Environmental impact (CO2 per category)
  - Summary that feels personalized and insightful

  Then, provide:
  - Insights in one paragraph
  - 2-3 actionable financial tips (max 20 words each)
  - 2-3 carbon-saving suggestions, based on transaction behavior

  If there's no data, write a friendly message explaining that and suggest habits they could try.

  Return this JSON:
  {
    "insights": [""],
    "financeTips": ["", ""],
    "environmentTips": ["", ""]
  }

  Date Range: ${dateRange}
  Transactions: ${JSON.stringify(transactions)}
  `;

  const res = await axios.post(GEMINI_URL, {
    contents: [{ parts: [{ text: prompt }] }]
  });

  let text = res.data?.candidates?.[0]?.content?.parts?.[0]?.text || '{}';
  text = text.replace(/```json|```/g, '').trim();
  return JSON.parse(text);
}

// Write insights to Firestore
async function writeInsights(id, insights) {
  await db.collection('InsightsSummary').doc(id).set({
    ...insights,
    generatedAt: Timestamp.now(),
  });
}

// Generate insights on transaction created
export const onIncomeCreated = onDocumentCreated('Income/{id}', async (event) => {
  await handleTransactionEvent(event);
});

export const onExpenseCreated = onDocumentCreated('Expense/{id}', async (event) => {
  await handleTransactionEvent(event);
});

export const onIncomeChanged = onDocumentWritten('Income/{id}', async (event) => {
  await handleTransactionEvent(event);
});

export const onExpenseChanged = onDocumentWritten('Expense/{id}', async (event) => {
  await handleTransactionEvent(event);
});

async function handleTransactionEvent(event) {

  const snapshot = event.data?.after || event.data;

  if (event.data?.before?.exists && event.data?.after?.exists) {
    console.log("✏️ This is an update.");
  } else if (!event.data?.before?.exists && event.data?.after?.exists) {
    console.log("🆕 This is a create.");
  }
  if (!snapshot?.data) {
    console.log("⚠️ No event data found.");
    return;
  }

  const doc = snapshot.data();

  if (!doc?.dateTime) {
    console.log("⚠️ No dateTime field in document.");
    return;
  }

  const txnDate = doc.dateTime.toDate();

  const now = getToday();
  const txnWeek = getWeekNumber(txnDate);
  const currentWeek = getWeekNumber(now);

  const updateDaily = true;
  const updateWeekly = txnWeek !== currentWeek;
  const updateMonthly =
    txnDate.getMonth() !== now.getMonth() ||
    txnDate.getFullYear() !== now.getFullYear();

  if (updateDaily) {
    const { start, end } = getDayRange(txnDate);
    const transactions = await collectTransactions(start, end);
    const insights = await getAIInsights(transactions, `${start.toISOString()} - ${end.toISOString()}`, start);
    const id = getDateId('daily', start);
    await writeInsights(id, insights);
  }

  if (updateWeekly) {
    const { start, end } = getWeekRange(txnDate);
    const transactions = await collectTransactions(start, end);
    const insights = await getAIInsights(transactions, `${start.toISOString()} - ${end.toISOString()}`, start);
    const id = getDateId('weekly', start);
    await writeInsights(id, insights);
  }

  if (updateMonthly) {
    const { start, end } = getMonthRange(txnDate);
    const transactions = await collectTransactions(start, end);
    const insights = await getAIInsights(transactions, `${start.toISOString()} - ${end.toISOString()}`, start);
    const id = getDateId('monthly', start);
    await writeInsights(id, insights);
  }
}

// Generate insights on schedule
export const generateDailyInsights = onSchedule('0 16 * * *', async () => {
  const today = getToday();
  const { start, end } = getDayRange(today);
  const transactions = await collectTransactions(start, end);
  const insights = await getAIInsights(transactions, `${start.toISOString()} - ${end.toISOString()}`, start);
  const id = getDateId('daily', start);
  await writeInsights(id, insights);
});

export const generateWeeklyInsights = onSchedule('0 16 * * *', async () => {
  const today = getToday();
  const { start, end } = getWeekRange(today);
  const transactions = await collectTransactions(start, end);
  const insights = await getAIInsights(transactions, `${start.toISOString()} - ${end.toISOString()}`, start);
  const id = getDateId('weekly', start);
  await writeInsights(id, insights);
});

export const generateMonthlyInsights = onSchedule('0 16 * * *', async () => {
  const today = getToday();
  const { start, end } = getMonthRange(today);
  const transactions = await collectTransactions(start, end);
  const insights = await getAIInsights(transactions, `${start.toISOString()} - ${end.toISOString()}`, start);
  const id = getDateId('monthly', start);
  await writeInsights(id, insights);
});

// ==================== Manual Insight Generation Triggers for Debugging ====================
export const manualInsightTrigger = onDocumentWritten('Triggers/force-insight-generation', async (event) => {
  const before = event.data?.before?.data() || {};
  const after = event.data?.after?.data() || {};

  const generateAll = after.generateAll && !before.generateAll;
  const generateToday = after.generateToday && !before.generateToday;

  if (generateAll) {
    await generateAllDailyInsights();
    await generateAllWeeklyInsights();
    await generateAllMonthlyInsights();
  }

  if (generateToday) {
    const now = getToday();

    const { start: dayStart, end: dayEnd } = getDayRange(now);
    const dailyTxns = await collectTransactions(dayStart, dayEnd);
    await writeInsights(getDateId("daily", dayStart), await getAIInsights(dailyTxns, `${dayStart.toISOString()} - ${dayEnd.toISOString()}`));

    const { start: weekStart, end: weekEnd } = getWeekRange(now);
    const weeklyTxns = await collectTransactions(weekStart, weekEnd);
    await writeInsights(getDateId("weekly", weekStart), await getAIInsights(weeklyTxns, `${weekStart.toISOString()} - ${weekEnd.toISOString()}`));

    const { start: monthStart, end: monthEnd } = getMonthRange(now);
    const monthlyTxns = await collectTransactions(monthStart, monthEnd);
    await writeInsights(getDateId("monthly", monthStart), await getAIInsights(monthlyTxns, `${monthStart.toISOString()} - ${monthEnd.toISOString()}`));
  }

  // Reset flags after execution
  await db.doc('Triggers/force-insight-generation').update({
    generateToday: false,
    generateAll: false
  });
});

async function generateAllDailyInsights() {
  const allDates = await getAllTransactionDates();
  for (const date of allDates) {
    const { start, end } = getDayRange(date);
    const transactions = await collectTransactions(start, end);
    const insights = await getAIInsights(transactions, `${start.toISOString()} - ${end.toISOString()}`, start);
    await writeInsights(getDateId("daily", start), insights);
  }
}

async function generateAllWeeklyInsights() {
  const allDates = await getAllTransactionDates();
  const seen = new Set();

  for (const date of allDates) {
    const { start, end } = getWeekRange(date);
    const key = start.toDateString();
    if (seen.has(key)) continue;

    const transactions = await collectTransactions(start, end);
    const insights = await getAIInsights(transactions, `${start.toISOString()} - ${end.toISOString()}`, start);
    await writeInsights(getDateId("weekly", start), insights);
    seen.add(key);
  }
}

async function generateAllMonthlyInsights() {
  const allDates = await getAllTransactionDates();
  const seen = new Set();

  for (const date of allDates) {
    const { start, end } = getMonthRange(date);
    const key = start.toDateString();
    if (seen.has(key)) continue;

    const transactions = await collectTransactions(start, end);
    const insights = await getAIInsights(transactions, `${start.toISOString()} - ${end.toISOString()}`, start);
    await writeInsights(getDateId("monthly", start), insights);
    seen.add(key);
  }
}

async function getAllTransactionDates() {
  const dateSet = new Set();

  const incomeSnap = await db.collection("Income").get();
  incomeSnap.forEach((doc) => {
    const d = doc.data();
    if (d.dateTime?.toDate) {
      dateSet.add(d.dateTime.toDate().toDateString());
    }
  });

  const expenseSnap = await db.collection("Expense").get();
  expenseSnap.forEach((doc) => {
    const d = doc.data();
    if (d.dateTime?.toDate) {
      dateSet.add(d.dateTime.toDate().toDateString());
    }
  });

  const uniqueDates = [...dateSet].map((str) => new Date(str));
  uniqueDates.sort((a, b) => a - b);

  return uniqueDates;
}
