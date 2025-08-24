import { onDocumentCreated, onDocumentWritten } from 'firebase-functions/v2/firestore';
import { getFirestore } from 'firebase-admin/firestore';

// ==================== COLLECTION NAMES ====================
// Note: Collection names are defined in index.js as single source of truth
// These are used for local reference only
const COLLECTIONS = {
    INCOME: 'income',
    EXPENSE: 'expense',
    PERIOD_COUNTERS: 'period_counters',
    TRIGGERS: 'triggers'
};

// Helper function to get Firestore instance when needed
function getDb() {
    return getFirestore();
}


// ==================== PERIOD COUNTERS UPDATE FUNCTIONS ====================

export const onExpenseCreatedForCounters = onDocumentCreated(`${COLLECTIONS.EXPENSE}/{id}`, async (event) => {
    try {
        const expense = event.data.data();
        const expenseId = event.params.id;

        console.log(`🔄 [Period Counters] Expense created: ${expenseId}`);
        await updatePeriodCountersForExpense(expense, expenseId, 'create');
        console.log(`✅ [Period Counters] Period counters updated for expense: ${expenseId}`);
    } catch (error) {
        console.error(`❌ [Period Counters] Error updating period counters for expense: ${error}`);
    }
});

export const onExpenseUpdatedForCounters = onDocumentWritten(`${COLLECTIONS.EXPENSE}/{id}`, async (event) => {
    try {
        const newExpense = event.data.after.data();
        const oldExpense = event.data.before?.data();
        const expenseId = event.params.id;

        if (newExpense && oldExpense) {
            console.log(`🔄 [Period Counters] Expense updated: ${expenseId}`);
            await updatePeriodCountersForExpense(newExpense, expenseId, 'update', oldExpense);
            console.log(`✅ [Period Counters] Period counters updated for expense: ${expenseId}`);
        }
    } catch (error) {
        console.error(`❌ [Period Counters] Error updating period counters for expense: ${error}`);
    }
});

export const onExpenseDeletedForCounters = onDocumentWritten(`${COLLECTIONS.EXPENSE}/{id}`, async (event) => {
    try {
        const expense = event.data.before?.data();
        const expenseId = event.params.id;

        if (expense && !event.data.after?.exists) {
            console.log(`🔄 [Period Counters] Expense deleted: ${expenseId}`);
            await updatePeriodCountersForExpense(expense, expenseId, 'delete');
            console.log(`✅ [Period Counters] Period counters updated for expense: ${expenseId}`);
        }
    } catch (error) {
        console.error(`❌ [Period Counters] Error updating period counters for expense: ${error}`);
    }
});

export const onIncomeCreatedForCounters = onDocumentCreated(`${COLLECTIONS.INCOME}/{id}`, async (event) => {
    try {
        const income = event.data.data();
        const incomeId = event.params.id;

        console.log(`🔄 [Period Counters] Income created: ${incomeId}`);
        await updatePeriodCountersForIncome(income, incomeId, 'create');
        console.log(`✅ [Period Counters] Period counters updated for income: ${incomeId}`);
    } catch (error) {
        console.error(`❌ [Period Counters] Error updating period counters for income: ${error}`);
    }
});

export const onIncomeUpdatedForCounters = onDocumentWritten(`${COLLECTIONS.INCOME}/{id}`, async (event) => {
    try {
        const newIncome = event.data.after.data();
        const oldIncome = event.data.before?.data();
        const incomeId = event.params.id;

        if (newIncome && oldIncome) {
            console.log(`🔄 [Period Counters] Income updated: ${incomeId}`);
            await updatePeriodCountersForIncome(newIncome, incomeId, 'update', oldIncome);
            console.log(`✅ [Period Counters] Period counters updated for income: ${incomeId}`);
        }
    } catch (error) {
        console.error(`❌ [Period Counters] Error updating period counters for income: ${error}`);
    }
});

export const onIncomeDeletedForCounters = onDocumentWritten(`${COLLECTIONS.INCOME}/{id}`, async (event) => {
    try {
        const income = event.data.before?.data();
        const incomeId = event.params.id;

        if (income && !event.data.after?.exists) {
            console.log(`🔄 [Period Counters] Income deleted: ${incomeId}`);
            await updatePeriodCountersForIncome(income, incomeId, 'delete');
            console.log(`✅ [Period Counters] Period counters updated for income: ${incomeId}`);
        }
    } catch (error) {
        console.error(`❌ [Period Counters] Error updating period counters for income: ${error}`);
    }
});

// ==================== PERIOD COUNTERS GENERATION FUNCTIONS ====================

export async function generateAllPeriodCounters() {
    try {
        console.log('🔄 Starting to generate all period counters...');

        const allDates = await getAllTransactionDates();
        const userId = 'default_user'; // You can make this configurable

        for (const date of allDates) {
            await generatePeriodCountersForDate(userId, date);
        }

        console.log('✅ All period counters generated successfully!');
    } catch (error) {
        console.error('❌ Error generating period counters:', error);
        throw error;
    }
}

async function generatePeriodCountersForDate(userId, date) {
    try {
        // Generate daily counter
        const dailyPeriodId = generateDailyPeriodId(date);
        await generatePeriodCounter(userId, 'daily', dailyPeriodId, date);

        // Generate weekly counter
        const weeklyPeriodId = generateWeeklyPeriodId(date);
        await generatePeriodCounter(userId, 'weekly', weeklyPeriodId, date);

        // Generate monthly counter
        const monthlyPeriodId = generateMonthlyPeriodId(date);
        await generatePeriodCounter(userId, 'monthly', monthlyPeriodId, date);

        console.log(`✅ Generated period counters for date: ${date.toDateString()}`);
    } catch (error) {
        console.error(`❌ Error generating period counters for date ${date.toDateString()}:`, error);
    }
}

async function generatePeriodCounter(userId, period, periodId, date) {
    try {
        const docId = `${userId}_${period}_${periodId}`;
        const docRef = getDb().collection(COLLECTIONS.PERIOD_COUNTERS).doc(docId);

        // Get date range for this period
        let start, end;
        if (period === 'daily') {
            const { start: s, end: e } = getDayRange(date);
            start = s;
            end = e;
        } else if (period === 'weekly') {
            const { start: s, end: e } = getWeekRange(date);
            start = s;
            end = e;
        } else if (period === 'monthly') {
            const { start: s, end: e } = getMonthRange(date);
            start = s;
            end = e;
        }

        // Collect transactions for this period
        const transactions = await collectTransactions(start, end);

        // Calculate totals and breakdowns
        const totals = calculateTotalsFromTransactions(transactions);
        const breakdowns = calculateBreakdownsFromTransactions(transactions);

        // Create period counter document (REPLACE existing data)
        const periodCounterData = {
            id: docId,
            userId: userId,
            period: period,
            periodId: periodId,
            totals: totals,
            breakdowns: breakdowns,
            appliedTxIds: transactions.map(t => t.id),
            lastUpdated: new Date()
        };

        await docRef.set(periodCounterData); // This will REPLACE existing data
        console.log(`✅ Created/Updated period counter: ${docId}`);

    } catch (error) {
        console.error(`❌ Error creating period counter ${period}_${periodId}:`, error);
        throw error;
    }
}

function calculateTotalsFromTransactions(transactions) {
    let income = 0;
    let expense = 0;
    let co2Kg = 0;

    for (const transaction of transactions) {
        if (transaction.type === 'income') {
            income += transaction.amount || 0;
        } else if (transaction.type === 'expense') {
            expense += transaction.amount || 0;
            co2Kg += transaction.carbon_footprint || 0;
        }
    }

    return { income, expense, co2Kg };
}

function calculateBreakdownsFromTransactions(transactions) {
    const incomeByCategory = {};
    const expenseByCategory = {};
    const co2ByCategory = {};

    for (const transaction of transactions) {
        if (transaction.type === 'income') {
            const category = transaction.category || 'Uncategorized';
            incomeByCategory[category] = (incomeByCategory[category] || 0) + (transaction.amount || 0);
        } else if (transaction.type === 'expense') {
            const category = transaction.category || 'General';
            expenseByCategory[category] = (expenseByCategory[category] || 0) + (transaction.amount || 0);
            co2ByCategory[category] = (co2ByCategory[category] || 0) + (transaction.carbon_footprint || 0);
        }
    }

    return {
        incomeByCategory,
        expenseByCategory,
        co2ByCategory
    };
}

async function getAllTransactionDates() {
    const dateSet = new Set();

    const incomeSnap = await getDb().collection(COLLECTIONS.INCOME).get();
    incomeSnap.forEach((doc) => {
        const d = doc.data();
        if (d.dateTime?.toDate) {
            dateSet.add(d.dateTime.toDate().toDateString());
        }
    });

    const expenseSnap = await getDb().collection(COLLECTIONS.EXPENSE).get();
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

// Helper functions for date ranges
function getDayRange(dateUTC) {
    const local = shiftToMalaysia(dateUTC);
    const startLocal = new Date(local.getFullYear(), local.getMonth(), local.getDate());
    const endLocal = new Date(startLocal);
    endLocal.setDate(startLocal.getDate() + 1);
    return { start: shiftToUTC(startLocal), end: shiftToUTC(endLocal) };
}

function getWeekRange(dateUTC) {
    const local = shiftToMalaysia(dateUTC);
    const day = local.getDay();
    const startLocal = new Date(local);
    startLocal.setDate(local.getDate() - (day === 0 ? 6 : day - 1));
    startLocal.setHours(0, 0, 0, 0);
    const endLocal = new Date(startLocal);
    endLocal.setDate(startLocal.getDate() + 6);
    return { start: shiftToUTC(startLocal), end: shiftToUTC(endLocal) };
}

function getMonthRange(dateUTC) {
    const local = shiftToMalaysia(dateUTC);
    const startLocal = new Date(local.getFullYear(), local.getMonth(), 1);
    const endLocal = new Date(local.getFullYear(), local.getMonth() + 1, 1);
    return { start: shiftToUTC(startLocal), end: shiftToUTC(endLocal) };
}

function shiftToMalaysia(date) {
    const MALAYSIA_OFFSET = 8 * 60 * 60 * 1000;
    return new Date(date.getTime() + MALAYSIA_OFFSET);
}

function shiftToUTC(date) {
    const MALAYSIA_OFFSET = 8 * 60 * 60 * 1000;
    return new Date(date.getTime() - MALAYSIA_OFFSET);
}

// Get and parse transactions from income/expense in Firestore 
async function collectTransactions(start, end) {
    const transactions = [];

    const incomeSnap = await getDb().collection(COLLECTIONS.INCOME)
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

    const expenseSnap = await getDb().collection(COLLECTIONS.EXPENSE)
        .where('dateTime', '>=', start)
        .where('dateTime', '<', end)
        .get();

    for (const expenseDoc of expenseSnap.docs) {
        const expense = expenseDoc.data();
        const itemsRef = expense.items || [];

        if (itemsRef.length === 0) continue;

        let totalAmount = 0;

        for (const itemRef of itemsRef) {
            if (!itemRef) continue;
            try {
                const itemSnap = await itemRef.get();
                if (!itemSnap.exists) continue;
                const item = itemSnap.data();

                const itemAmount = (item.price || 0) * (item.quantity || 1);
                totalAmount += itemAmount;
            } catch (error) {
                console.warn(`Could not fetch expense item: ${error}`);
            }
        }

        if (totalAmount > 0) {
            transactions.push({
                id: expenseDoc.id,
                date: expense.dateTime.toDate().toISOString(),
                category: expense.category || 'General',
                amount: totalAmount,
                type: 'expense',
                description: expense.transactionName || 'Expense',
                carbon_footprint: expense.carbon_footprint || 0
            });
        }
    }

    return transactions;
}

// ==================== HELPER FUNCTIONS ====================

async function updatePeriodCountersForExpense(expense, expenseId, operation, oldExpense = null) {
    const userId = expense.userId || 'default_user';
    const expenseDate = expense.dateTime.toDate();

    // Get all affected periods
    const affectedPeriods = getAffectedPeriods(expenseDate, oldExpense?.dateTime?.toDate());

    for (const period of affectedPeriods) {
        await updatePeriodCounter(
            userId,
            period.period,
            period.periodId,
            'expense',
            expense,
            operation,
            oldExpense,
            event
        );
    }
}

async function updatePeriodCountersForIncome(income, incomeId, operation, oldIncome = null) {
    const userId = income.userId || 'default_user';
    const incomeDate = income.dateTime.toDate();

    // Get all affected periods
    const affectedPeriods = getAffectedPeriods(incomeDate, oldIncome?.dateTime?.toDate());

    for (const period of affectedPeriods) {
        await updatePeriodCounter(
            userId,
            period.period,
            period.periodId,
            'income',
            income,
            operation,
            oldIncome,
            event
        );
    }
}

function getAffectedPeriods(newDate, oldDate = null) {
    const periods = [];

    // Always include the new date's periods
    periods.push({
        period: 'daily',
        periodId: generateDailyPeriodId(newDate)
    });
    periods.push({
        period: 'weekly',
        periodId: generateWeeklyPeriodId(newDate)
    });
    periods.push({
        period: 'monthly',
        periodId: generateMonthlyPeriodId(newDate)
    });

    // If updating, also include old date's periods
    if (oldDate && !isSameDay(newDate, oldDate)) {
        periods.push({
            period: 'daily',
            periodId: generateDailyPeriodId(oldDate)
        });
        periods.push({
            period: 'weekly',
            periodId: generateWeeklyPeriodId(oldDate)
        });
        periods.push({
            period: 'monthly',
            periodId: generateMonthlyPeriodId(oldDate)
        });
    }

    return periods;
}

function generateDailyPeriodId(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const timezone = 'GMT8'; // Adjust based on your timezone

    console.log(`📅 [Cloud Functions] Daily ID: date=${date}, result=${year}-${month}-${day}+${timezone}`);

    return `${year}-${month}-${day}+${timezone}`;
}

function generateWeeklyPeriodId(date) {
    const year = date.getFullYear();
    const startOfWeek = new Date(date);

    // Convert JavaScript getDay() (0-6) to Flutter weekday (1-7)
    const jsDay = date.getDay(); // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
    const flutterWeekday = jsDay === 0 ? 7 : jsDay; // Convert Sunday from 0 to 7

    startOfWeek.setDate(date.getDate() - flutterWeekday + 1); // Monday start
    const weekOfYear = Math.floor((startOfWeek - new Date(year, 0, 1)) / (7 * 24 * 60 * 60 * 1000)) + 1;
    const timezone = 'GMT8';

    console.log(`📅 [Cloud Functions] Weekly ID: date=${date}, jsDay=${jsDay}, flutterWeekday=${flutterWeekday}, startOfWeek=${startOfWeek}, weekOfYear=${weekOfYear}`);

    return `${year}-W${String(weekOfYear).padStart(2, '0')}+${timezone}`;
}

function generateMonthlyPeriodId(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const timezone = 'GMT8';

    console.log(`📅 [Cloud Functions] Monthly ID: date=${date}, result=${year}-${month}+${timezone}`);

    return `${year}-${month}+${timezone}`;
}

function isSameDay(a, b) {
    return a.getFullYear() === b.getFullYear() &&
        a.getMonth() === b.getMonth() &&
        a.getDate() === b.getDate();
}

async function updatePeriodCounter(userId, period, periodId, type, data, operation, oldData = null, event = null) {
    const docId = `${userId}_${period}_${periodId}`;
    const docRef = getDb().collection(COLLECTIONS.PERIOD_COUNTERS).doc(docId);

    try {
        const doc = await docRef.get();
        let currentData = doc.exists ? doc.data() : {
            id: docId,
            userId: userId,
            period: period,
            periodId: periodId,
            totals: { income: 0, expense: 0, co2Kg: 0 },
            breakdowns: {
                incomeByCategory: {},
                expenseByCategory: {},
                co2ByCategory: {}
            },
            appliedTxIds: [],
            lastUpdated: new Date(),
            insights: {}
        };

        // Calculate changes based on operation and type
        let incomeChange = 0;
        let expenseChange = 0;
        let co2Change = 0;
        let categoryChanges = {};

        if (type === 'expense') {
            // Calculate expense amount and categories from expense items
            let expenseAmount = 0;
            let categoryAmounts = {};

            if (data.items && Array.isArray(data.items)) {
                for (const itemRef of data.items) {
                    try {
                        const itemDoc = await itemRef.get();
                        if (itemDoc.exists) {
                            const itemData = itemDoc.data();
                            const itemAmount = (itemData.price || 0) * (itemData.quantity || 1);
                            expenseAmount += itemAmount;

                            // Group by category
                            const category = itemData.category || 'General';
                            categoryAmounts[category] = (categoryAmounts[category] || 0) + itemAmount;
                        }
                    } catch (error) {
                        console.warn(`Could not fetch expense item: ${error}`);
                    }
                }
            }

            // Use carbon footprint directly from expense
            const carbonFootprint = data.carbonFootprint || 0;

            switch (operation) {
                case 'create':
                    expenseChange = expenseAmount;
                    co2Change = carbonFootprint;
                    categoryChanges = categoryAmounts;
                    break;
                case 'update':
                    if (oldData) {
                        // Calculate old values from old expense items
                        let oldExpenseAmount = 0;
                        let oldCarbonFootprint = oldData.carbonFootprint || 0;
                        let oldCategoryAmounts = {};

                        if (oldData.items && Array.isArray(oldData.items)) {
                            for (const itemRef of oldData.items) {
                                try {
                                    const itemDoc = await itemRef.get();
                                    if (itemDoc.exists) {
                                        const itemData = itemDoc.data();
                                        const itemAmount = (itemData.price || 0) * (itemData.quantity || 1);
                                        oldExpenseAmount += itemAmount;

                                        const category = itemData.category || 'General';
                                        oldCategoryAmounts[category] = (oldCategoryAmounts[category] || 0) + itemAmount;
                                    }
                                } catch (error) {
                                    console.warn(`Could not fetch old expense item: ${error}`);
                                }
                            }
                        }

                        expenseChange = expenseAmount - oldExpenseAmount;
                        co2Change = carbonFootprint - oldCarbonFootprint;

                        // Calculate category changes
                        categoryChanges = {};
                        const allCategories = new Set([...Object.keys(categoryAmounts), ...Object.keys(oldCategoryAmounts)]);

                        for (const category of allCategories) {
                            const newAmount = categoryAmounts[category] || 0;
                            const oldAmount = oldCategoryAmounts[category] || 0;
                            const change = newAmount - oldAmount;
                            if (change !== 0) {
                                categoryChanges[category] = change;
                            }
                        }
                    }
                    break;
                case 'delete':
                    expenseChange = -expenseAmount;
                    co2Change = -carbonFootprint;
                    // Negate all category amounts
                    categoryChanges = {};
                    for (const [category, amount] of Object.entries(categoryAmounts)) {
                        categoryChanges[category] = -amount;
                    }
                    break;
            }
        } else if (type === 'income') {
            const incomeAmount = data.amount || 0;
            const category = data.category || 'Uncategorized';

            switch (operation) {
                case 'create':
                    incomeChange = incomeAmount;
                    categoryChanges = { [category]: incomeAmount };
                    break;
                case 'update':
                    if (oldData) {
                        const oldIncomeAmount = oldData.amount || 0;
                        const oldCategory = oldData.category || 'Uncategorized';

                        incomeChange = incomeAmount - oldIncomeAmount;

                        if (oldCategory !== category) {
                            categoryChanges = {
                                [oldCategory]: -oldIncomeAmount,
                                [category]: incomeAmount
                            };
                        } else {
                            categoryChanges = { [category]: incomeChange };
                        }
                    }
                    break;
                case 'delete':
                    incomeChange = -incomeAmount;
                    categoryChanges = { [category]: -incomeAmount };
                    break;
            }
        }

        // Update totals
        currentData.totals.income += incomeChange;
        currentData.totals.expense += expenseChange;
        currentData.totals.co2Kg += co2Change;

        // Update breakdowns
        if (type === 'expense') {
            currentData.breakdowns.expenseByCategory = updateCategoryBreakdown(
                currentData.breakdowns.expenseByCategory,
                categoryChanges
            );

            // For CO2, distribute the carbon footprint across categories proportionally
            if (co2Change !== 0) {
                const totalExpense = Object.values(categoryChanges).reduce((sum, change) => sum + Math.abs(change), 0);
                if (totalExpense > 0) {
                    const co2Changes = {};
                    for (const [category, change] of Object.entries(categoryChanges)) {
                        if (change > 0) {
                            // Distribute CO2 proportionally based on expense amount
                            co2Changes[category] = (change / totalExpense) * co2Change;
                        }
                    }
                    currentData.breakdowns.co2ByCategory = updateCategoryBreakdown(
                        currentData.breakdowns.co2ByCategory,
                        co2Changes
                    );
                }
            }
        } else if (type === 'income') {
            currentData.breakdowns.incomeByCategory = updateCategoryBreakdown(
                currentData.breakdowns.incomeByCategory,
                categoryChanges
            );
        }

        // Update applied transaction IDs
        const transactionId = data.id || event?.params?.id || 'unknown';
        if (operation === 'create' || operation === 'update') {
            if (!currentData.appliedTxIds.includes(transactionId)) {
                currentData.appliedTxIds.push(transactionId);
            }
        } else if (operation === 'delete') {
            currentData.appliedTxIds = currentData.appliedTxIds.filter(id => id !== transactionId);
        }

        currentData.lastUpdated = new Date();



        // Save to Firestore
        await docRef.set(currentData, { merge: true });

    } catch (error) {
        console.error(`Error updating period counter: ${error}`);
        throw error;
    }
}

function updateCategoryBreakdown(currentBreakdown, changes) {
    const newBreakdown = { ...currentBreakdown };

    for (const [category, change] of Object.entries(changes)) {
        if (newBreakdown[category]) {
            newBreakdown[category] += change;

            // Remove category if amount becomes 0 or negative
            if (newBreakdown[category] <= 0) {
                delete newBreakdown[category];
            }
        } else if (change > 0) {
            newBreakdown[category] = change;
        }
    }

    return newBreakdown;
}
