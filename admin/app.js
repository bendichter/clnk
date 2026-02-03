// BiteVue Admin Dashboard JavaScript

// Supabase Configuration
const SUPABASE_URL = 'https://kgfdwcsydjzioqdlovjy.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_C-zYfZQIRTa1JaTuIkVf1w_Sy_bh19K';

// Simple admin password (in production, use Supabase Auth)
const ADMIN_PASSWORD = 'bitevue2024';

// Initialize Supabase client
const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Global state
let currentFilter = 'all';
let allReports = [];

// Initialize app
document.addEventListener('DOMContentLoaded', () => {
    checkAuth();
    setupEventListeners();
});

// Authentication
function checkAuth() {
    const isAuthenticated = sessionStorage.getItem('bitevue_admin_auth') === 'true';
    
    if (isAuthenticated) {
        showDashboard();
    } else {
        showLogin();
    }
}

function showLogin() {
    document.getElementById('login-screen').classList.add('active');
    document.getElementById('dashboard-screen').classList.remove('active');
}

function showDashboard() {
    document.getElementById('login-screen').classList.remove('active');
    document.getElementById('dashboard-screen').classList.add('active');
    loadDashboardData();
}

function logout() {
    sessionStorage.removeItem('bitevue_admin_auth');
    showLogin();
}

// Event Listeners
function setupEventListeners() {
    // Login form
    document.getElementById('login-form').addEventListener('submit', (e) => {
        e.preventDefault();
        const password = document.getElementById('admin-password').value;
        const errorDiv = document.getElementById('login-error');
        
        if (password === ADMIN_PASSWORD) {
            sessionStorage.setItem('bitevue_admin_auth', 'true');
            errorDiv.textContent = '';
            showDashboard();
        } else {
            errorDiv.textContent = 'Invalid password';
        }
    });

    // Navigation tabs
    document.querySelectorAll('.nav-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const tab = btn.dataset.tab;
            switchTab(tab);
        });
    });

    // Filter buttons
    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            currentFilter = btn.dataset.filter;
            document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            filterReports();
        });
    });

    // Modal close
    document.querySelector('.close-modal').addEventListener('click', () => {
        document.getElementById('report-modal').classList.remove('active');
    });

    window.addEventListener('click', (e) => {
        const modal = document.getElementById('report-modal');
        if (e.target === modal) {
            modal.classList.remove('active');
        }
    });
}

// Tab switching
function switchTab(tabName) {
    // Update nav buttons
    document.querySelectorAll('.nav-btn').forEach(btn => {
        btn.classList.remove('active');
        if (btn.dataset.tab === tabName) {
            btn.classList.add('active');
        }
    });

    // Update tab content
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    document.getElementById(`${tabName}-tab`).classList.add('active');

    // Load data for the tab
    if (tabName === 'reports' && allReports.length === 0) {
        loadReports();
    } else if (tabName === 'blocked') {
        loadBlockedUsers();
    }
}

// Load Dashboard Data
async function loadDashboardData() {
    loadStats();
    loadReports();
}

// Load Statistics
async function loadStats() {
    try {
        // Get counts from each table
        const [restaurants, dishes, ratings, users, reports, blocks] = await Promise.all([
            supabase.from('restaurants').select('id', { count: 'exact', head: true }),
            supabase.from('dishes').select('id', { count: 'exact', head: true }),
            supabase.from('ratings').select('id', { count: 'exact', head: true }),
            supabase.from('profiles').select('id', { count: 'exact', head: true }),
            supabase.from('reports').select('id', { count: 'exact', head: true }),
            supabase.from('blocked_users').select('id', { count: 'exact', head: true })
        ]);

        document.getElementById('stat-restaurants').textContent = restaurants.count || 0;
        document.getElementById('stat-dishes').textContent = dishes.count || 0;
        document.getElementById('stat-ratings').textContent = ratings.count || 0;
        document.getElementById('stat-users').textContent = users.count || 0;
        document.getElementById('stat-reports').textContent = reports.count || 0;
        document.getElementById('stat-blocks').textContent = blocks.count || 0;
    } catch (error) {
        console.error('Error loading stats:', error);
    }
}

// Load Reports
async function loadReports() {
    const container = document.getElementById('reports-list');
    container.innerHTML = '<div class="loading">Loading reports...</div>';

    try {
        const { data, error } = await supabase
            .from('reports')
            .select(`
                *,
                reporter:reporter_id(id, username, full_name),
                reported_user:reported_user_id(id, username, full_name),
                rating:rating_id(id, rating, review_text, dish_id, restaurant_id)
            `)
            .order('created_at', { ascending: false });

        if (error) throw error;

        allReports = data || [];
        filterReports();
    } catch (error) {
        console.error('Error loading reports:', error);
        container.innerHTML = '<div class="loading">Error loading reports</div>';
    }
}

// Filter Reports
function filterReports() {
    const container = document.getElementById('reports-list');
    
    let filtered = allReports;
    if (currentFilter !== 'all') {
        filtered = allReports.filter(r => r.status === currentFilter);
    }

    if (filtered.length === 0) {
        container.innerHTML = '<div class="loading">No reports found</div>';
        return;
    }

    container.innerHTML = filtered.map(report => createReportCard(report)).join('');

    // Add event listeners to action buttons
    container.querySelectorAll('[data-action]').forEach(btn => {
        btn.addEventListener('click', async (e) => {
            const reportId = btn.dataset.reportId;
            const action = btn.dataset.action;
            await handleReportAction(reportId, action);
        });
    });
}

// Create Report Card HTML
function createReportCard(report) {
    const reporter = report.reporter || { username: 'Unknown' };
    const reportedUser = report.reported_user || { username: 'Unknown' };
    const rating = report.rating || {};
    
    const statusClass = `status-${report.status || 'pending'}`;
    const date = new Date(report.created_at).toLocaleString();

    return `
        <div class="report-card">
            <div class="report-header">
                <div class="report-info">
                    <h3>Report #${report.id.slice(0, 8)}</h3>
                    <div class="report-meta">
                        <span>👤 Reporter: <strong>${reporter.username}</strong></span>
                        <span>🎯 Reported: <strong>${reportedUser.username}</strong></span>
                        <span>📅 ${date}</span>
                    </div>
                </div>
                <span class="status-badge ${statusClass}">${report.status || 'pending'}</span>
            </div>

            <div class="report-content">
                <h4>Reported Review:</h4>
                <p><strong>Rating:</strong> ${rating.rating || 'N/A'} ⭐</p>
                <p><strong>Review:</strong> ${rating.review_text || 'No review text'}</p>
            </div>

            <div class="report-reason">
                <p><strong>Reason:</strong> ${report.reason || 'No reason provided'}</p>
                ${report.details ? `<p><strong>Details:</strong> ${report.details}</p>` : ''}
            </div>

            ${report.status === 'pending' ? `
                <div class="report-actions">
                    <button class="btn-reviewed" data-action="reviewed" data-report-id="${report.id}">
                        ✓ Mark Reviewed
                    </button>
                    <button class="btn-dismiss" data-action="dismissed" data-report-id="${report.id}">
                        ✗ Dismiss
                    </button>
                    <button class="btn-action" data-action="actioned" data-report-id="${report.id}">
                        🚫 Take Action (Hide Review)
                    </button>
                </div>
            ` : ''}
        </div>
    `;
}

// Handle Report Actions
async function handleReportAction(reportId, action) {
    try {
        // Update report status
        const { error: updateError } = await supabase
            .from('reports')
            .update({ 
                status: action,
                reviewed_at: new Date().toISOString()
            })
            .eq('id', reportId);

        if (updateError) throw updateError;

        // If action is "actioned", hide the associated rating
        if (action === 'actioned') {
            const report = allReports.find(r => r.id === reportId);
            if (report && report.rating_id) {
                const { error: ratingError } = await supabase
                    .from('ratings')
                    .update({ is_hidden: true })
                    .eq('id', report.rating_id);

                if (ratingError) console.error('Error hiding rating:', ratingError);
            }
        }

        // Reload reports
        await loadReports();
        await loadStats();

        alert(`Report ${action} successfully!`);
    } catch (error) {
        console.error('Error handling report action:', error);
        alert('Error updating report. Please try again.');
    }
}

// Load Blocked Users
async function loadBlockedUsers() {
    const container = document.getElementById('blocked-list');
    container.innerHTML = '<div class="loading">Loading blocked users...</div>';

    try {
        const { data, error } = await supabase
            .from('blocked_users')
            .select(`
                *,
                blocker:blocker_id(id, username, full_name),
                blocked:blocked_id(id, username, full_name)
            `)
            .order('created_at', { ascending: false });

        if (error) throw error;

        if (!data || data.length === 0) {
            container.innerHTML = '<div class="loading">No blocked users found</div>';
            return;
        }

        container.innerHTML = data.map(block => {
            const blocker = block.blocker || { username: 'Unknown' };
            const blocked = block.blocked || { username: 'Unknown' };
            const date = new Date(block.created_at).toLocaleDateString();

            return `
                <div class="blocked-card">
                    <h3>Block #${block.id.slice(0, 8)}</h3>
                    <p class="blocked-info">👤 <strong>${blocker.username}</strong> blocked <strong>${blocked.username}</strong></p>
                    <p class="blocked-info">📅 ${date}</p>
                </div>
            `;
        }).join('');
    } catch (error) {
        console.error('Error loading blocked users:', error);
        container.innerHTML = '<div class="loading">Error loading blocked users</div>';
    }
}
