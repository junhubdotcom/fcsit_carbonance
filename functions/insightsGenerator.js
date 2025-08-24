import { onDocumentCreated, onDocumentWritten } from 'firebase-functions/v2/firestore';
import { Timestamp } from 'firebase-admin/firestore';
import axios from 'axios';
import dotenv from 'dotenv';

// ==================== COLLECTION NAMES ====================
const COLLECTIONS = {
    PERIOD_COUNTERS: 'period_counters',
    INSIGHTS_SUMMARY: 'insights'
};

dotenv.config();
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
if (!GEMINI_API_KEY) {
    console.error('❌ ERROR: GEMINI_API_KEY not found in environment variables!');
}
const GEMINI_URL = `https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=${GEMINI_API_KEY}`;

// Firestore instance will be passed from index.js
let db = null;

// Function to set the database instance
export function setDatabase(databaseInstance) {
    db = databaseInstance;
}

// ==================== INSIGHTS GENERATION FUNCTIONS ====================

/**
 * Generate AI-powered insights for a specific period counter with transaction data
 * @param {Object} periodData - The period counter data from Firestore
 * @param {string} period - The period type (daily, weekly, monthly)
 * @param {Array} transactions - Array of individual transaction data for detailed analysis
 * @param {Object} previousInsights - Previous period insights for context (optional)
 * @returns {Object} Generated insights object with metadata
 */
async function generatePeriodInsights(periodData, period, transactions = [], previousInsights = null) {
    try {
        const { totals, breakdowns, appliedTxIds } = periodData;

        // Build transaction context for AI analysis
        let transactionContext = "";
        if (transactions && transactions.length > 0) {
            transactionContext = `
TRANSACTION DETAILS (${transactions.length} transactions):
${transactions.map(tx =>
                `- ${tx.type}: ${tx.category} | RM${tx.amount?.toFixed(2) || 0} | ${tx.carbonFootprint ? tx.carbonFootprint.toFixed(2) + ' kg CO₂' : 'No CO₂'} | ${tx.description || 'No description'}`
            ).join('\n')}`;
        }

        // Build previous insights context for trend analysis
        let previousContext = "";
        if (previousInsights) {
            previousContext = `
PREVIOUS PERIOD CONTEXT:
- Previous Core Insights: ${previousInsights.core?.[0] || 'None'}
- Key Trend: ${previousInsights.core?.[1] || 'No previous data'}
- Previous Recommendations: ${previousInsights.spending?.[0] || 'None'}`;
        }

        // Create a comprehensive prompt for Gemini AI
        const prompt = `You are a smart financial and environmental advisor analyzing a user's ${period} spending and carbon footprint data.

PERIOD DATA:
- Period: ${period}
- Income: RM${totals.income.toFixed(2)}
- Expenses: RM${totals.expense.toFixed(2)}
- Carbon Footprint: ${totals.co2Kg.toFixed(2)} kg
- Balance: RM${(totals.income - totals.expense).toFixed(2)}

CATEGORY BREAKDOWNS:
- Income Categories: ${JSON.stringify(breakdowns.incomeByCategory || {})}
- Expense Categories: ${JSON.stringify(breakdowns.expenseByCategory || {})}
- CO2 by Category: ${JSON.stringify(breakdowns.co2ByCategory || {})}${transactionContext}${previousContext}

ANALYSIS REQUIREMENTS:
1. **Financial Health Assessment**: Analyze spending vs income ratio, savings rate, and spending patterns
2. **Environmental Impact Analysis**: Evaluate carbon intensity (kg/RM) and identify high-impact categories
3. **Behavioral Insights**: Identify trends, recurring patterns, and unusual spending
4. **Actionable Recommendations**: Provide specific, actionable advice for both financial and environmental improvement
5. **Trend Analysis**: Compare with previous period if available

OUTPUT FORMAT (JSON):
{
  "core": [
    "Core insight 1 (always shown)",
    "Core insight 2 (always shown)",
    "Core insight 3 (always shown)"
  ],
  "spending": [
    "Spending-specific insight 1",
    "Spending-specific insight 2"
  ],
  "category": [
    "Category-specific insight 1", 
    "Category-specific insight 2"
  ],
  "carbon": [
    "Carbon-specific insight 1",
    "Carbon-specific insight 2"
  ]
}

REQUIREMENTS:
- core: 3 insights that are always relevant regardless of chart
- spending: 2 insights specific to spending/income trends
- category: 2 insights specific to category breakdowns
- carbon: 2 insights specific to environmental impact
- Each insight should be 1 sentence, max 15 words
- Use specific numbers and percentages when available
- Focus on actionable insights, not just observations

Focus on being specific, actionable, and personalized based on the actual data. If amounts are 0, provide encouraging messages about starting good habits.`;

        const response = await axios.post(GEMINI_URL, {
            contents: [{ parts: [{ text: prompt }] }]
        });

        let text = response.data?.candidates?.[0]?.content?.parts?.[0]?.text || '{}';
        text = text.replace(/```json|```/g, '').trim();

        const insights = JSON.parse(text);

        // Add comprehensive metadata for future batch analysis
        insights.metadata = {
            generatedAt: Timestamp.now(),
            period: period,
            dataSource: 'period_counters',
            transactionCount: transactions.length,
            hasPreviousInsights: !!previousInsights,
            analysisVersion: '2.0',
            dataCompleteness: {
                hasTotals: !!totals,
                hasBreakdowns: !!breakdowns,
                hasTransactions: transactions.length > 0,
                hasPreviousContext: !!previousInsights
            },
            // Store transaction IDs for future reference (not the full data)
            transactionIds: appliedTxIds || [],
            // Store key metrics for trend analysis
            keyMetrics: {
                savingsRate: totals.income > 0 ? ((totals.income - totals.expense) / totals.income) * 100 : 0,
                carbonIntensity: totals.expense > 0 ? totals.co2Kg / totals.expense : 0,
                expenseToIncomeRatio: totals.income > 0 ? totals.expense / totals.income : 0
            }
        };

        return insights;

    } catch (error) {
        console.error('❌ Error generating AI insights:', error);

        // Fallback insights if AI fails
        return generateFallbackInsights(periodData, period);
    }
}

/**
 * Generate fallback insights when AI generation fails
 * @param {Object} periodData - The period counter data
 * @param {string} period - The period type
 * @returns {Object} Basic insights object
 */
function generateFallbackInsights(periodData, period) {
    const { totals, breakdowns } = periodData;
    const balance = totals.income - totals.expense;
    const savingsRate = totals.income > 0 ? ((balance) / totals.income) * 100 : 0;

    const insights = {
        core: [
            balance > 0
                ? `Positive balance: RM ${balance.toFixed(2)} this ${period}`
                : `Expenses exceed income by RM ${Math.abs(balance).toFixed(2)}`,
            totals.income > 0
                ? `Savings rate: ${savingsRate.toFixed(1)}% - ${savingsRate > 20 ? 'excellent' : 'aim for 20%+'}`
                : 'No income recorded this period',
            totals.co2Kg > 0
                ? `Carbon footprint: ${totals.co2Kg.toFixed(1)} kg CO₂ this ${period}`
                : 'No carbon footprint recorded this period'
        ],
        spending: [
            `Total ${period} expenses: RM ${totals.expense.toFixed(2)}`,
            totals.income > 0 ? `Income: RM ${totals.income.toFixed(2)}` : 'No income recorded'
        ],
        category: [
            'Category breakdown available for analysis',
            'Tap categories to see detailed transactions'
        ],
        carbon: [
            totals.co2Kg > 0
                ? `Environmental impact: ${totals.co2Kg.toFixed(1)} kg CO₂`
                : 'No carbon impact recorded',
            'Consider sustainable alternatives for high-impact categories'
        ]
    };

    return insights;
}

/**
 * Update period counter with generated insights
 * @param {string} periodCounterId - The period counter document ID
 * @param {Object} insights - Generated insights object
 */
async function updatePeriodCounterWithInsights(periodCounterId, insights) {
    try {
        await db.collection(COLLECTIONS.PERIOD_COUNTERS).doc(periodCounterId).update({
            insights: insights,
            insightsLastUpdated: Timestamp.now()
        });
        console.log(`✅ Updated period counter ${periodCounterId} with insights`);
    } catch (error) {
        console.error(`❌ Error updating period counter with insights: ${error}`);
        throw error;
    }
}

// ==================== HELPER FUNCTIONS ====================

/**
 * Fetch detailed transaction data for insights generation
 * @param {Array} transactionIds - Array of transaction IDs
 * @returns {Array} Array of transaction objects with details
 */
async function fetchTransactionDetails(transactionIds) {
    if (!transactionIds || transactionIds.length === 0) {
        return [];
    }

    try {
        const transactions = [];

        for (const txId of transactionIds) {
            // Try to fetch from expense collection first
            let doc = await db.collection('expense').doc(txId).get();
            if (doc.exists) {
                const data = doc.data();
                transactions.push({
                    id: txId,
                    type: 'expense',
                    amount: data.amount || 0,
                    category: data.category || 'General',
                    carbonFootprint: data.carbon_footprint || 0,
                    description: data.transactionName || 'No description',
                    date: data.dateTime
                });
                continue;
            }

            // Try income collection
            doc = await db.collection('income').doc(txId).get();
            if (doc.exists) {
                const data = doc.data();
                transactions.push({
                    id: txId,
                    type: 'income',
                    amount: data.amount || 0,
                    category: data.name || 'Unknown',
                    carbonFootprint: 0, // Income has no carbon footprint
                    description: data.name || 'No description',
                    date: data.dateTime
                });
            }
        }

        return transactions;
    } catch (error) {
        console.error(`❌ Error fetching transaction details: ${error}`);
        return [];
    }
}

/**
 * Fetch previous period insights for context and trend analysis
 * @param {string} userId - User ID
 * @param {string} period - Period type (daily, weekly, monthly)
 * @param {string} currentPeriodId - Current period ID
 * @returns {Object|null} Previous period insights or null if not found
 */
async function fetchPreviousPeriodInsights(userId, period, currentPeriodId) {
    try {
        // Generate previous period ID based on current period
        let previousPeriodId = '';

        if (period === 'daily') {
            // Get previous day
            const currentDate = new Date(currentPeriodId.split('+')[0]);
            const previousDate = new Date(currentDate.getTime() - 24 * 60 * 60 * 1000);
            previousPeriodId = previousDate.toISOString().split('T')[0] + '+GMT8';
        } else if (period === 'weekly') {
            // Get previous week
            const currentWeek = parseInt(currentPeriodId.match(/W(\d+)/)?.[1] || '1');
            const currentYear = currentPeriodId.split('-')[0];
            const previousWeek = currentWeek > 1 ? currentWeek - 1 : 52; // Wrap around to previous year
            const previousYear = currentWeek > 1 ? currentYear : parseInt(currentYear) - 1;
            previousPeriodId = `${previousYear}-W${previousWeek.toString().padStart(2, '0')}+GMT8`;
        } else if (period === 'monthly') {
            // Get previous month
            const currentDate = new Date(currentPeriodId.split('+')[0] + '-01');
            const previousDate = new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1);
            previousPeriodId = `${previousDate.getFullYear()}-${(previousDate.getMonth() + 1).toString().padStart(2, '0')}+GMT8`;
        }

        if (!previousPeriodId) {
            return null;
        }

        // Fetch previous period counter
        const previousDocId = `${userId}_${period}_${previousPeriodId}`;
        const previousDoc = await db.collection(COLLECTIONS.PERIOD_COUNTERS).doc(previousDocId).get();

        if (previousDoc.exists && previousDoc.data().insights) {
            return previousDoc.data().insights;
        }

        return null;
    } catch (error) {
        console.error(`❌ Error fetching previous period insights: ${error}`);
        return null;
    }
}

// ==================== EVENT-DRIVEN INSIGHTS GENERATION ====================
// Insights are generated automatically when period counters are created or updated
// This ensures real-time insights without unnecessary scheduled processing

/**
 * Generate insights when a new period counter is created
 */
export const onPeriodCounterCreated = onDocumentCreated(`${COLLECTIONS.PERIOD_COUNTERS}/{id}`, async (event) => {
    try {
        const periodCounterId = event.params.id;
        const periodData = event.data.data();

        console.log(`🔄 Generating insights for new period counter: ${periodCounterId}`);

        // Fetch transaction details for better insights
        const transactions = await fetchTransactionDetails(periodData.appliedTxIds || []);

        // Fetch previous period insights for context
        const previousInsights = await fetchPreviousPeriodInsights(periodData.userId, periodData.period, periodData.periodId);

        const insights = await generatePeriodInsights(periodData, periodData.period, transactions, previousInsights);
        await updatePeriodCounterWithInsights(periodCounterId, insights);

        console.log(`✅ Insights generated and saved for: ${periodCounterId}`);
    } catch (error) {
        console.error(`❌ Error in onPeriodCounterCreated: ${error}`);
    }
});

/**
 * Regenerate insights when period counter is updated
 */
export const onPeriodCounterUpdated = onDocumentWritten(`${COLLECTIONS.PERIOD_COUNTERS}/{id}`, async (event) => {
    try {
        // Only regenerate if it's an update (not create)
        if (event.data.before?.exists && event.data.after?.exists) {
            const periodCounterId = event.params.id;
            const newData = event.data.after.data();
            const oldData = event.data.before.data();

            // Check if significant data changed (totals, breakdowns, or appliedTxIds)
            const totalsChanged = JSON.stringify(newData.totals) !== JSON.stringify(oldData.totals);
            const breakdownsChanged = JSON.stringify(newData.breakdowns) !== JSON.stringify(oldData.breakdowns);
            const transactionsChanged = JSON.stringify(newData.appliedTxIds) !== JSON.stringify(oldData.appliedTxIds);

            if (totalsChanged || breakdownsChanged || transactionsChanged) {
                console.log(`🔄 Regenerating insights for updated period counter: ${periodCounterId}`);

                // Fetch transaction details for better insights
                const transactions = await fetchTransactionDetails(newData.appliedTxIds || []);

                // Fetch previous period insights for context
                const previousInsights = await fetchPreviousPeriodInsights(newData.userId, newData.period, newData.periodId);

                const insights = await generatePeriodInsights(newData, newData.period, transactions, previousInsights);
                await updatePeriodCounterWithInsights(periodCounterId, insights);

                console.log(`✅ Insights regenerated for: ${periodCounterId}`);
            }
        }
    } catch (error) {
        console.error(`❌ Error in onPeriodCounterUpdated: ${error}`);
    }
});

/**
 * Manual insights generation for testing/debugging
 * @param {string} periodCounterId - The period counter document ID to generate insights for
 */
export async function manualGenerateInsights(periodCounterId) {
    try {
        console.log(`🔄 Manually generating insights for: ${periodCounterId}`);

        const docRef = db.collection(COLLECTIONS.PERIOD_COUNTERS).doc(periodCounterId);
        const doc = await docRef.get();

        if (!doc.exists) {
            throw new Error(`Period counter ${periodCounterId} not found`);
        }

        const periodData = doc.data();

        // Fetch transaction details for better insights
        const transactions = await fetchTransactionDetails(periodData.appliedTxIds || []);

        // Fetch previous period insights for context
        const previousInsights = await fetchPreviousPeriodInsights(periodData.userId, periodData.period, periodData.periodId);

        const insights = await generatePeriodInsights(periodData, periodData.period, transactions, previousInsights);
        await updatePeriodCounterWithInsights(periodCounterId, insights);

        console.log(`✅ Manual insights generation completed for: ${periodCounterId}`);
        return insights;

    } catch (error) {
        console.error(`❌ Error in manual insights generation: ${error}`);
        throw error;
    }
}

/**
 * Generate insights for all existing period counters
 */
export async function generateInsightsForAllPeriodCounters() {
    try {
        console.log('🔄 Generating insights for all period counters...');

        const periodCountersSnap = await db.collection(COLLECTIONS.PERIOD_COUNTERS).get();
        let processedCount = 0;
        let errorCount = 0;

        for (const doc of periodCountersSnap.docs) {
            try {
                const periodData = doc.data();

                // Skip if already has recent insights (within last hour)
                if (periodData.insightsLastUpdated) {
                    const lastUpdate = periodData.insightsLastUpdated.toDate();
                    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
                    if (lastUpdate > oneHourAgo) {
                        console.log(`⏭️ Skipping ${doc.id} - insights are recent`);
                        continue;
                    }
                }

                console.log(`🔄 Generating insights for: ${doc.id}`);

                // Fetch transaction details for better insights
                const transactions = await fetchTransactionDetails(periodData.appliedTxIds || []);

                // Fetch previous period insights for context
                const previousInsights = await fetchPreviousPeriodInsights(periodData.userId, periodData.period, periodData.periodId);

                const insights = await generatePeriodInsights(periodData, periodData.period, transactions, previousInsights);
                await updatePeriodCounterWithInsights(doc.id, insights);

                processedCount++;
                console.log(`✅ Insights generated for: ${doc.id}`);

                // Add small delay to avoid overwhelming the API
                await new Promise(resolve => setTimeout(resolve, 1000));

            } catch (error) {
                console.error(`❌ Error generating insights for ${doc.id}:`, error);
                errorCount++;
            }
        }

        console.log(`✅ Insights generation completed. Processed: ${processedCount}, Errors: ${errorCount}`);
        return { processedCount, errorCount };

    } catch (error) {
        console.error('❌ Error in generateInsightsForAllPeriodCounters:', error);
        throw error;
    }
}
