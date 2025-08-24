import { onDocumentCreated, onDocumentWritten } from 'firebase-functions/v2/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import axios from 'axios';
import dotenv from 'dotenv';

// Initialize Firebase Admin first, before importing other modules
initializeApp();
const db = getFirestore();

// ==================== COLLECTION NAMES - SINGLE SOURCE OF TRUTH ====================
const COLLECTIONS = {
  INCOME: 'income',
  EXPENSE: 'expense',
  EXPENSE_ITEM: 'expenseItem',
  INSIGHTS_SUMMARY: 'insights',
  PERIOD_COUNTERS: 'period_counters',
  TRIGGERS: 'triggers'
};

dotenv.config();
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
if (!GEMINI_API_KEY) {
  console.error('❌ ERROR: GEMINI_API_KEY not found in environment variables!');
}
const GEMINI_URL = `https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=${GEMINI_API_KEY}`;

// Import period counter functions
import * as periodCounters from './periodCounters.js';

// Import insights generator functions
import * as insightsGenerator from './insightsGenerator.js';

// Set the database instance for insightsGenerator
insightsGenerator.setDatabase(db);

// ==================== PERIOD COUNTERS EXPORTS ====================
export const {
  onExpenseCreatedForCounters,
  onExpenseUpdatedForCounters,
  onExpenseDeletedForCounters,
  onIncomeCreatedForCounters,
  onIncomeUpdatedForCounters,
  onIncomeDeletedForCounters,
} = periodCounters;

// ==================== INSIGHTS GENERATOR EXPORTS ====================
export const {
  onPeriodCounterCreated,
  onPeriodCounterUpdated,
} = insightsGenerator;

// ==================== MANUAL TRIGGERS ====================

// GENERATE PERIOD COUNTERS (stats only)
export const generatePeriodCountersOnly = onDocumentWritten(`${COLLECTIONS.TRIGGERS}/generate-period-counters`, async (event) => {
  try {
    const before = event.data?.before?.data() || {};
    const after = event.data?.after?.data() || {};

    const shouldGenerate = after.shouldGenerate && !before.shouldGenerate;

    if (shouldGenerate) {
      console.log('🚀 Generating period counters only (no insights)');
      await periodCounters.generateAllPeriodCounters();

      // Reset the flag
      await db.doc(`${COLLECTIONS.TRIGGERS}/generate-period-counters`).update({
        shouldGenerate: false
      });

      console.log('✅ Period counters generated successfully (no insights)');
    }
  } catch (error) {
    console.error('❌ Error generating period counters:', error);
  }
});

// GENERATE INSIGHTS ONLY (for existing period counters)
export const generateInsightsOnly = onDocumentWritten(`${COLLECTIONS.TRIGGERS}/generate-insights`, async (event) => {
  try {
    const before = event.data?.before?.data() || {};
    const after = event.data?.after?.data() || {};

    const shouldGenerate = after.shouldGenerate && !before.shouldGenerate;
    const periodCounterId = after.periodCounterId || null;

    if (shouldGenerate) {
      if (periodCounterId) {
        // Generate insights for specific period counter
        console.log(`🚀 Generating insights for specific period counter: ${periodCounterId}`);
        await insightsGenerator.manualGenerateInsights(periodCounterId);
      } else {
        // Generate insights for all period counters
        console.log('🚀 Generating insights for all period counters');
        await insightsGenerator.generateInsightsForAllPeriodCounters();
      }

      // Reset the flag
      await db.doc(`${COLLECTIONS.TRIGGERS}/generate-insights`).update({
        shouldGenerate: false,
        periodCounterId: null
      });

      console.log('✅ Insights generation completed');
    }
  } catch (error) {
    console.error('❌ Error generating insights:', error);
  }
});

// GENERATE BOTH (period counters + insights)
export const generatePeriodCountersWithInsights = onDocumentWritten(`${COLLECTIONS.TRIGGERS}/generate-both`, async (event) => {
  try {
    const before = event.data?.before?.data() || {};
    const after = event.data?.after?.data() || {};

    const shouldGenerate = after.shouldGenerate && !before.shouldGenerate;

    if (shouldGenerate) {
      console.log('🚀 Generating period counters with insights');

      // First generate period counters
      await periodCounters.generateAllPeriodCounters();

      // Then generate insights for all
      await insightsGenerator.generateInsightsForAllPeriodCounters();

      // Reset the flag
      await db.doc(`${COLLECTIONS.TRIGGERS}/generate-both`).update({
        shouldGenerate: false
      });

      console.log('✅ Period counters and insights generated successfully');
    }
  } catch (error) {
    console.error('❌ Error generating both:', error);
  }
});
