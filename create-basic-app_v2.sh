#!/bin/bash
# chmod +x script_name.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_message() {
    echo -e "${BLUE}→ ${NC}$1"
}

print_success() {
    echo -e "${GREEN}✓ ${NC}$1"
}

print_error() {
    echo -e "${RED}✗ ${NC}$1"
}

# Create project directory and initialize npm
setup_project() {
    print_message "Enter project name (lowercase, no spaces):"
    read project_name

    mkdir "$project_name"
    cd "$project_name"

    print_message "Initializing npm project..."
    npm init -y

    node -e "
        const pkg = require('./package.json');
        pkg.scripts = {
            ...pkg.scripts,
            'dev': 'nodemon src/app.js',
            'start': 'node src/app.js',
            'test': 'jest'
        };
        pkg.main = 'src/app.js';
        require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2))
    "
}

# Install dependencies
install_dependencies() {
    print_message "Installing dependencies..."
    
    # Core dependencies
    npm install express dotenv cors helmet

    # File upload dependencies
    npm install multer aws-sdk

    # Email and template dependencies
    npm install nodemailer ejs express-ejs-layouts

    # Authentication dependencies
    npm install jsonwebtoken bcryptjs
    
    # Database dependencies
    npm install mongoose mysql2

    # Development dependencies
    npm install --save-dev nodemon jest
    
    print_success "Dependencies installed successfully!"
}

# Create directory structure
create_structure() {
    print_message "Creating project structure..."
    
    # Create main directories including views/layouts
    mkdir -p src/{config,helpers,modules/{email/templates,storage,auth,database/{mongodb,mysql}},routes,views/{layouts,includes},public/{css,js},services}

    # Create essential files
    # Create empty files with echo
    echo "" > src/config/database.js
    echo "" > src/config/email.js
    echo "" > src/helpers/styleHelper.js
    echo "" > src/views/includes/header.ejs
    echo "" > src/views/includes/footer.ejs
    echo "" > src/views/includes/sidebar.ejs
    echo "" > src/public/css/main.css
    echo "" > src/public/css/sidebar.css
    echo "" > src/public/css/forms.css
    echo "" > src/public/css/datatable.css
    echo "" > src/public/css/login.css
    echo "" > src/public/js/main.js
    echo "" > src/public/js/sidebar.js
    echo "" > src/public/js/forms.js
    echo "" > src/public/js/datatable.js
    echo "" > src/public/js/login.js

    echo "/**
        * Style helper for managing page-specific CSS files
        */

        const baseStyles = ['/css/main.css']; // Always included styles
        const baseScripts = ['/js/main.js']; // Always included scripts

        const pageAssets = {
            // Dashboard pages
            dashboard: {
                styles: [
                    '/css/sidebar.css',
                    '/css/datatable.css'
                ],
                scripts: [
                    '/js/datatable.js',
                    '/js/dashboard.js'
                ]
            },
            
            // Form pages
            forms: {
                styles: [
                    '/css/sidebar.css',
                    '/css/forms.css'
                ],
                scripts: [
                    '/js/forms.js',
                    '/js/validation.js'
                ]
            },
            
            // Table pages
            tables: {
                styles: [
                    '/css/sidebar.css',
                    '/css/datatable.css'
                ],
                scripts: [
                    '/js/datatable.js'
                ]
            },
            
            // Authentication pages
            login: {
                styles: [],
                scripts: [
                    '/js/auth.js'
                ]
            },
            
            // Settings pages
            settings: {
                styles: [
                    '/css/sidebar.css',
                    '/css/forms.css'
                ],
                scripts: [
                    '/js/settings.js'
                ]
            },
            
            // Profile page
            profile: {
                styles: [
                    '/css/sidebar.css',
                    '/css/forms.css'
                ],
                scripts: [
                    '/js/profile.js'
                ]
            },

            // Dashboard pages
            dashboard: {
                styles: [
                    '/css/sidebar.css',
                    '/css/datatable.css',
                ],
                scripts: [
                    '/js/sidebar.js',
                    '/js/datatable.js'
                ]
            },

            // Login page
            login: {
                styles: [
                    '/css/login.css'
                ],
                scripts: [
                    '/js/login.js'
                ]
            },
            
            // Default page (fallback)
            default: {
                styles: [
                    '/css/main.css'
                ],
                scripts: []
            }
        };

        /**
        * Get stylesheets for a specific page
        * @param {string} page - The page identifier
        * @param {string[]} [additional] - Additional stylesheets to include
        * @returns {string[]} Array of stylesheet paths
        */
        const getStylesheets = (page, additional = []) => {
            // Get page-specific styles or default styles if page not found
            const pageSpecificStyles = pageAssets[page]?.styles || pageAssets.default.styles;
            
            // Combine and deduplicate all styles
            return [...new Set([
                ...baseStyles,
                ...pageSpecificStyles,
                ...additional
            ])];
        };

        /**
        * Get scripts for a specific page
        * @param {string} page - The page identifier
        * @param {string[]} [additional] - Additional scripts to include
        * @returns {string[]} Array of script paths
        */
        const getScripts = (page, additional = []) => {
            // Get page-specific scripts or default scripts if page not found
            const pageSpecificScripts = pageAssets[page]?.scripts || pageAssets.default.scripts;
            
            // Combine and deduplicate all scripts
            return [...new Set([
                ...baseScripts,
                ...pageSpecificScripts,
                ...additional
            ])];
        };

        /**
        * Add new page assets configuration
        * @param {string} page - The page identifier
        * @param {Object} assets - The assets configuration
        * @param {string[]} assets.styles - Array of stylesheet paths
        * @param {string[]} assets.scripts - Array of script paths
        */
        const addPageAssets = (page, assets) => {
            pageAssets[page] = {
                styles: assets.styles || [],
                scripts: assets.scripts || []
            };
        };

        module.exports = {
            getStylesheets,
            getScripts,
            addPageAssets
        };" > src/helpers/styleHelper.js

    
    # Create sidebar js file
    echo " 
        document.addEventListener('DOMContentLoaded', function() {
            const sidebar = document.querySelector('.sidebar');
            const mainContent = document.querySelector('.main-content');
            const menuToggle = document.querySelector('.menu-toggle');
            const navLinks = document.querySelectorAll('.nav-link');

            // State management
            let menuState = {
                activeMenu: null,
                expandedMenus: new Set(),
                sidebarCollapsed: false
            };

            // Toggle sidebar
            function toggleSidebar(collapse) {
                const willCollapse = collapse !== undefined ? collapse : !sidebar.classList.contains('collapsed');
                
                if (window.innerWidth <= 768) {
                    sidebar.classList.toggle('mobile-visible');
                } else {
                    sidebar.classList.toggle('collapsed', willCollapse);
                    mainContent.classList.toggle('expanded', willCollapse);
                    menuState.sidebarCollapsed = willCollapse;
                }
            }

            menuToggle.addEventListener('click', () => toggleSidebar());

            // Handle menu clicks and state
            navLinks.forEach(link => {
                link.addEventListener('click', function(e) {
                    e.preventDefault();
                    const menuId = this.dataset.menuId;
                    
                    // If sidebar is collapsed and this is a click on a menu item
                    if (menuState.sidebarCollapsed && !this.classList.contains('active')) {
                        toggleSidebar(false);
                    }

                    if (this.dataset.hasSubmenu) {
                        // Toggle submenu state
                        const wasExpanded = this.classList.contains('expanded');
                        this.classList.toggle('expanded');
                        
                        const submenu = this.nextElementSibling;
                        submenu.classList.toggle('expanded');

                        if (wasExpanded) {
                            menuState.expandedMenus.delete(menuId);
                        } else {
                            menuState.expandedMenus.add(menuId);
                        }
                    } else {
                        // Handle active state for regular menu items
                        navLinks.forEach(l => {
                            if (!l.dataset.hasSubmenu) {
                                l.classList.remove('active');
                            }
                        });
                        this.classList.add('active');
                        menuState.activeMenu = menuId;
                    }
                });
            });

            // Restore menu state after sidebar toggle
            function restoreMenuState() {
                // Restore expanded menus
                menuState.expandedMenus.forEach(menuId => {
                    const link = document.querySelector(`[data-menu-id="${menuId}"]`);
                    const submenu = link?.nextElementSibling;
                    if (link && submenu) {
                        link.classList.add('expanded');
                        submenu.classList.add('expanded');
                    }
                });

                // Restore active menu
                if (menuState.activeMenu) {
                    const activeLink = document.querySelector(`[data-menu-id="${menuState.activeMenu}"]`);
                    if (activeLink) {
                        activeLink.classList.add('active');
                    }
                }
            }

            // Handle window resize
            window.addEventListener('resize', function() {
                if (window.innerWidth <= 768) {
                    sidebar.classList.remove('collapsed');
                    mainContent.classList.remove('expanded');
                    menuState.sidebarCollapsed = false;
                }
                restoreMenuState();
            });

            // Initialize first menu item as active
            const firstMenuItem = document.querySelector('.nav-link[data-menu-id="dashboard"]');
            if (firstMenuItem) {
                firstMenuItem.classList.add('active');
                menuState.activeMenu = 'dashboard';
            }

            console.log('Sidebar initialized');
            
        });
    " > src/public/js/sidebar.js

    # Create main app.js
    echo "const express = require('express');
        const cors = require('cors');
        const helmet = require('helmet');
        const expressLayouts = require('express-ejs-layouts');
        const path = require('path');
        const { getStylesheets, getScripts } = require('./helpers/styleHelper');
        const { mongodb, mysql } = require('./modules/database');
        require('dotenv').config();

        const app = express();

        // View engine setup
        app.set('view engine', 'ejs');
        app.set('views', path.join(__dirname, 'views'));
        app.set('layout', 'layouts/main_layout');
        app.use(expressLayouts);

        // Middleware
        app.use(helmet());
        app.use(cors());
        app.use(express.json());
        app.use(express.urlencoded({ extended: true }));
        app.use(express.static(path.join(__dirname, 'public')));

        // Connect to databases - Uncomment as needed
        // mongodb.connect();
        // mysql.connect();

        // Routes
        app.get('/', (req, res) => {
            res.render('login', {
                title: 'Welcome',
                stylesheets: getStylesheets('login'),
                scripts: getScripts('login'),
                showSidebar: false
            });
        });

        // Dashboard route
        app.get('/dashboard', (req, res) => {
            res.render('dashboard', {
                title: 'Dashboard - Page',  
                stylesheets: getStylesheets('dashboard'),
                scripts: getScripts('dashboard')
            });
        });

        const PORT = process.env.PORT || 3000;
        app.listen(PORT, () => {
            console.log(\`Server is running on port \${PORT}\`);
        });" > src/app.js

    # Create datatable JS file
    echo " 
    class DataTable {
        constructor(tableElement) {
        this.table = tableElement;
        this.pageSize = 10;
        this.currentPage = 1;
        this.sortColumn = 'id';
        this.sortDirection = 'asc';
        this.searchTerm = '';
        this.data = [];
        this.filteredData = [];
        this.selectedRows = new Set();

        this.init();
        }

    init() {
        this.generateMockData();
        this.setupEventListeners();
        this.render();
    }

    generateMockData() {
        // Generate 50 rows of mock data
        for (let i = 1; i <= 50; i++) {
            this.data.push({
                id: i,
                name: \`User ${i}\`,
                email: \`user${i}@example.com\`,
                role: ['Admin', 'User', 'Manager'][Math.floor(Math.random() * 3)],
                status: ['Active', 'Inactive', 'Pending'][Math.floor(Math.random() * 3)],
                lastLogin: new Date(Date.now() - Math.floor(Math.random() * 10000000000)).toLocaleDateString()
            });
        }
        this.filteredData = [...this.data];
    }

    setupEventListeners() {
        // Sort headers
        this.table.querySelectorAll('th.sortable').forEach(th => {
            th.addEventListener('click', () => this.handleSort(th.dataset.sort));
        });

        // Search input
        document.querySelector('.search-input').addEventListener('input', (e) => {
            this.searchTerm = e.target.value;
            this.currentPage = 1;
            this.filterData();
        });

        // Select all checkbox
        document.getElementById('selectAll').addEventListener('change', (e) => {
            const isChecked = e.target.checked;
            this.selectedRows.clear();
            if (isChecked) {
                this.getCurrentPageData().forEach(row => this.selectedRows.add(row.id));
            }
            this.render();
        });

        // Pagination
        document.getElementById('prevPage').addEventListener('click', () => this.prevPage());
        document.getElementById('nextPage').addEventListener('click', () => this.nextPage());

        // Context menu
        document.addEventListener('click', () => this.hideContextMenu());
        const contextMenu = document.querySelector('.context-menu');
        contextMenu.querySelectorAll('.context-menu-item').forEach(item => {
            item.addEventListener('click', (e) => {
                e.stopPropagation();
                const action = item.textContent.trim();
                console.log(\`${action} clicked for selected rows:\`, [...this.selectedRows]);
                this.hideContextMenu();
            });
        });
    }

    handleSort(column) {
        if (this.sortColumn === column) {
            this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            this.sortColumn = column;
            this.sortDirection = 'asc';
        }
        this.sortData();
        this.render();
    }

    filterData() {
        const searchTerm = this.searchTerm.toLowerCase();
        this.filteredData = this.data.filter(row => 
            Object.values(row).some(value => 
                String(value).toLowerCase().includes(searchTerm)
            )
        );
        this.render();
    }

    sortData() {
        this.filteredData.sort((a, b) => {
            let comparison = 0;
            if (a[this.sortColumn] < b[this.sortColumn]) comparison = -1;
            if (a[this.sortColumn] > b[this.sortColumn]) comparison = 1;
            return this.sortDirection === 'asc' ? comparison : -comparison;
        });
    }

    getCurrentPageData() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        return this.filteredData.slice(start, end);
    }

    updatePagination() {
        const totalPages = Math.ceil(this.filteredData.length / this.pageSize);
        const start = (this.currentPage - 1) * this.pageSize + 1;
        const end = Math.min(start + this.pageSize - 1, this.filteredData.length);

        document.getElementById('startRecord').textContent = start;
        document.getElementById('endRecord').textContent = end;
        document.getElementById('totalRecords').textContent = this.filteredData.length;
        document.getElementById('prevPage').disabled = this.currentPage === 1;
        document.getElementById('nextPage').disabled = this.currentPage === totalPages;
    }

    prevPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.render();
        }
    }

    nextPage() {
        const totalPages = Math.ceil(this.filteredData.length / this.pageSize);
        if (this.currentPage < totalPages) {
            this.currentPage++;
            this.render();
        }
    }

    showContextMenu(e, rowId) {
        e.preventDefault();
        const contextMenu = document.querySelector('.context-menu');
        contextMenu.classList.add('show');

        // If the row isn't already selected, select only this row
        if (!this.selectedRows.has(rowId)) {
            this.selectedRows.clear();
            this.selectedRows.add(rowId);
            this.render();
        }
    }

    hideContextMenu() {
        document.querySelector('.context-menu').classList.remove('show');
    }

    handleRowClick(e, rowId) {
        if (e.target.type === 'checkbox') return;
        if (e.target.closest('.action-icons')) return;

        if (e.ctrlKey || e.metaKey) {
            // Toggle selection of this row
            if (this.selectedRows.has(rowId)) {
                this.selectedRows.delete(rowId);
            } else {
                this.selectedRows.add(rowId);
            }
        } else {
            // Select only this row
            this.selectedRows.clear();
            this.selectedRows.add(rowId);
        }
        this.render();
    }

    render() {
        const tableBody = document.getElementById('tableBody');
        tableBody.innerHTML = '';
        
        // Update sort indicators
        this.table.querySelectorAll('th.sortable').forEach(th => {
            th.classList.remove('sorted-asc', 'sorted-desc');
            if (th.dataset.sort === this.sortColumn) {
                th.classList.add(`sorted-${this.sortDirection}`);
            }
        });

        // Render table rows
        this.getCurrentPageData().forEach(row => {
            const tr = document.createElement('tr');
            if (this.selectedRows.has(row.id)) {
                tr.classList.add('selected');
            }

            // Add event listeners
            tr.addEventListener('contextmenu', (e) => this.showContextMenu(e, row.id));
            tr.addEventListener('click', (e) => this.handleRowClick(e, row.id));

            tr.innerHTML = `
                <td>
                    <div class='checkbox-wrapper'>
                        <input type='checkbox' class='form-check-input' ${this.selectedRows.has(row.id) ? 'checked' : ''}>
                    </div>
                </td>
                <td>${row.id}</td>
                <td>${row.name}</td>
                <td>${row.email}</td>
                <td>${row.role}</td>
                <td>
                    <span class='status-badge status-${row.status.toLowerCase()}'>${row.status}</span>
                </td>
                <td>${row.lastLogin}</td>
                <td>
                    <div class='action-icons'>
                        <i class='bi bi-eye' title='View'></i>
                        <i class='bi bi-pencil' title='Edit'></i>
                        <i class='bi bi-trash' title='Delete'></i>
                    </div>
                </td>
            `;

            tableBody.appendChild(tr);
        });

        // Update pagination
        this.updatePagination();

        // Update select all checkbox
        const currentPageData = this.getCurrentPageData();
        const selectAllCheckbox = document.getElementById('selectAll');
        selectAllCheckbox.checked = currentPageData.length > 0 && 
        currentPageData.every(row => this.selectedRows.has(row.id));
        selectAllCheckbox.indeterminate = currentPageData.some(row => this.selectedRows.has(row.id)) && 
        !currentPageData.every(row => this.selectedRows.has(row.id));
    }
}

    // Initialize the DataTable
    document.addEventListener('DOMContentLoaded', function() {
    const table = document.querySelector('.data-table');
    new DataTable(table);
    });
    
    " > src/public/js/datatable.js
    
    # Create main CSS file
    echo "
        /* ==========================================================================
        main.css - Core styles and variables for the application
        ========================================================================== */

        /* Design Tokens
        ========================================================================== */
        :root {
            /* Colors */
            --primary-bg: #1a1d3a;
            --secondary-bg: #242850;
            --hover-bg: #2f345e;
            --active-bg: #3F51B5;
            --text-primary: #ffffff;
            --text-secondary: #a4a6b3;
            --border-color: #e2e8f0;
            --page-bg: #f8fafc;
            
            /* Status Colors */
            --error-color: #ef4444;
            --success-color: #10b981;
            --warning-color: #f59e0b;
            --info-color: #3b82f6;
            
            /* Spacing */
            --spacing-xs: 0.25rem;  /* 4px */
            --spacing-sm: 0.5rem;   /* 8px */
            --spacing-md: 1rem;     /* 16px */
            --spacing-lg: 1.5rem;   /* 24px */
            --spacing-xl: 2rem;     /* 32px */
            
            /* Border Radius */
            --radius-sm: 4px;
            --radius-md: 8px;
            --radius-lg: 16px;
            --radius-full: 9999px;
            
            /* Shadows */
            --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
            --shadow-md: 0 1px 3px rgba(0, 0, 0, 0.1);
            --shadow-lg: 0 8px 32px rgba(0, 0, 0, 0.1);
            
            /* Transitions */
            --transition-fast: 0.15s ease;
            --transition-normal: 0.3s ease;
            --transition-slow: 0.5s ease;
        }

        /* Reset & Base Styles
        ========================================================================== */
        *, *::before, *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        html {
            font-size: 16px;
            -webkit-text-size-adjust: 100%;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }

        body {
            min-height: 100vh;
            margin: 0;
            padding: 0;
            background-color: var(--page-bg);
            font-family: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            color: var(--primary-bg);
            line-height: 1.5;
        }



        /* Typography
        ========================================================================== */
        h1, h2, h3, h4, h5, h6 {
            margin-bottom: var(--spacing-md);
            font-weight: 600;
            line-height: 1.2;
        }

        h1 { font-size: 2rem; }
        h2 { font-size: 1.75rem; }
        h3 { font-size: 1.5rem; }
        h4 { font-size: 1.25rem; }
        h5 { font-size: 1.125rem; }
        h6 { font-size: 1rem; }

        p {
            margin-bottom: var(--spacing-md);
        }

        /* Layout Containers
        ========================================================================== */
        .page-container {
            padding: var(--spacing-lg);
            max-width: 1400px;
            margin: 0 auto;
            width: 100%;
        }

        .content-container {
            background: white;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-md);
            padding: var(--spacing-lg);
            border: 1px solid var(--border-color);
        }

        .flex-container {
            display: flex;
            gap: var(--spacing-md);
        }

        .grid-container {
            display: grid;
            gap: var(--spacing-md);
        }

        /* Common Utility Classes
        ========================================================================== */
        .text-primary { color: var(--text-primary); }
        .text-secondary { color: var(--text-secondary); }
        .text-error { color: var(--error-color); }
        .text-success { color: var(--success-color); }

        .bg-primary { background-color: var(--primary-bg); }
        .bg-secondary { background-color: var(--secondary-bg); }
        .bg-hover { background-color: var(--hover-bg); }
        .bg-active { background-color: var(--active-bg); }

        .mb-0 { margin-bottom: 0; }
        .mb-1 { margin-bottom: var(--spacing-xs); }
        .mb-2 { margin-bottom: var(--spacing-sm); }
        .mb-3 { margin-bottom: var(--spacing-md); }
        .mb-4 { margin-bottom: var(--spacing-lg); }
        .mb-5 { margin-bottom: var(--spacing-xl); }

        /* Common Interactive Elements
        ========================================================================== */
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0.625rem 1.25rem;
            font-weight: 500;
            border-radius: var(--radius-md);
            transition: all var(--transition-normal);
            cursor: pointer;
            border: 1px solid transparent;
            font-size: 1rem;
            line-height: 1.5;
            text-decoration: none;
        }

        .btn-primary {
            background-color: var(--active-bg);
            color: var(--text-primary);
        }

        .btn-primary:hover {
            background-color: var(--hover-bg);
        }

        .btn-secondary {
            background-color: transparent;
            border-color: var(--border-color);
            color: var(--primary-bg);
        }

        .btn-secondary:hover {
            background-color: var(--page-bg);
            border-color: var(--active-bg);
            color: var(--active-bg);
        }

        /* Responsive Design
        ========================================================================== */
        @media (max-width: 1200px) {
            .page-container {
                max-width: 100%;
            }
        }

        @media (max-width: 768px) {
            .page-container {
                padding: var(--spacing-md);
            }
            
            .content-container {
                padding: var(--spacing-md);
            }
            
            h1 { font-size: 1.75rem; }
            h2 { font-size: 1.5rem; }
            h3 { font-size: 1.25rem; }
        }

        @media (max-width: 480px) {
            html {
                font-size: 14px;
            }
            
            .page-container {
                padding: var(--spacing-sm);
            }
        }

    " > src/public/css/main.css

    # Create sidebar CSS file
    echo " 
        :root {
            --sidebar-width: 280px;
            --sidebar-collapsed-width: 64px;
            --transition-speed: 0.3s;
            --primary-bg: #1a1d3a;
            --secondary-bg: #242850;
            --hover-bg: #2f345e;
            --active-bg: #3F51B5;
            --text-primary: #ffffff;
            --text-secondary: #a4a6b3;
        }


        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            width: var(--sidebar-width);
            background: var(--primary-bg);
            transition: all var(--transition-speed) ease;
            z-index: 1000;
            overflow-x: hidden;
            box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
        }

        .sidebar.collapsed {
            width: var(--sidebar-collapsed-width);
        }

        .sidebar-header {
            padding: 1.25rem;
            color: var(--text-primary);
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .menu-toggle {
            color: var(--text-primary);
            background: none;
            border: none;
            font-size: 1.5rem;
            cursor: pointer;
            padding: 0.5rem;
            transition: transform var(--transition-speed);
        }

        .menu-toggle:hover {
            color: var(--text-secondary);
        }

        .nav-item {
            position: relative;
            width: 100%;
            margin: 4px 0;
        }

        .nav-link {
            padding: 0.875rem 1.25rem;
            color: var(--text-secondary);
            display: flex;
            align-items: center;
            text-decoration: none;
            transition: all var(--transition-speed);
            border-radius: 8px;
            margin: 0 0.5rem;
            cursor: pointer;
        }

        .nav-link:hover {
            background-color: var(--hover-bg);
            color: var(--text-primary);
        }

        .nav-link.active {
            background-color: var(--active-bg);
            color: var(--text-primary);
        }

        .nav-link i:first-child {
            width: 1.5rem;
            font-size: 1.25rem;
            margin-right: 1rem;
            text-align: center;
        }

        .nav-link .link-text {
            transition: opacity var(--transition-speed);
            white-space: nowrap;
        }

        .collapsed .link-text {
            display: none;
        }

        .collapsed .toggle-icon {
            display: none;
        }

        .submenu {
            max-height: 0;
            overflow: hidden;
            transition: max-height var(--transition-speed) ease;
            background-color: var(--secondary-bg);
            margin: 0 0.5rem;
            border-radius: 8px;
            opacity: 0;
        }

        .submenu.expanded {
            max-height: 500px;
            opacity: 1;
        }

        .submenu .nav-link {
            padding-left: 3.5rem;
            margin: 0;
            border-radius: 0;
        }

        .toggle-icon {
            margin-left: auto;
            transition: transform var(--transition-speed);
            font-size: 0.875rem;
            opacity: 0.75;
        }

        .nav-link.expanded .toggle-icon {
            transform: rotate(180deg);
        }

        .main-content {
            margin-left: var(--sidebar-width);
            padding: 2rem;
            transition: margin-left var(--transition-speed) ease;
        }

        .main-content.expanded {
            margin-left: var(--sidebar-collapsed-width);
        }

        @media (max-width: 768px) {
            .sidebar {
                transform: translateX(-100%);
                width: var(--sidebar-width) !important;
            }

            .sidebar.mobile-visible {
                transform: translateX(0);
            }

            .main-content {
                margin-left: 0 !important;
            }
        }
    " > src/public/css/sidebar.css
    
    # Create login CSS file
    echo "
        /* ==========================================================================
        login.css - Styles for the authentication pages (login, register, forgot password)
        ========================================================================== */

        /* Login Page Layout
        ========================================================================== */
        .login-container {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            margin: auto; /* Center horizontally */
            display: flex;
            justify-content: center; /* Center vertically */
            background: linear-gradient(135deg, var(--primary-bg), var(--secondary-bg));
        }

        .login-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: var(--spacing-lg);
        }

        /* Logo and Branding
        ========================================================================== */
        .logo-container {
            margin-bottom: var(--spacing-xl);
            text-align: center;
        }

        .logo {
            width: 80px;
            height: 80px;
            background-color: var(--text-primary);
            border-radius: var(--radius-lg);
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto;
            box-shadow: var(--shadow-lg);
        }

        .logo i {
            font-size: 2.5rem;
            color: var(--primary-bg);
        }

        .brand-name {
            color: var(--text-primary);
            font-size: 1.5rem;
            margin-top: var(--spacing-md);
            font-weight: 600;
        }

        /* Login Card
        ========================================================================== */
        .login-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: var(--radius-lg);
            padding: var(--spacing-xl);
            width: 100%;
            max-width: 400px;
            box-shadow: var(--shadow-lg);
            margin: 0 auto; /* Center horizontally */
            
        }

        .login-header {
            text-align: center;
            margin-bottom: var(--spacing-xl);
        }

        .login-header h1 {
            font-size: 1.5rem;
            color: var(--primary-bg);
            margin: 0;
        }

        /* Login Form Elements
        ========================================================================== */
        .form-group {
            margin-bottom: var(--spacing-lg);
            position: relative;
        }

        .form-group i {
            position: absolute;
            left: var(--spacing-md);
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-secondary);
        }

        .form-control {
            width: 100%;
            padding: 0.75rem var(--spacing-md) 0.75rem 2.5rem;
        }

        .form-control.error {
            border-color: var(--error-color);
        }

        .validation-error {
            color: var(--error-color);
            font-size: 0.875rem;
            margin-top: var(--spacing-xs);
            display: none;
        }

        .form-control.error + .validation-error {
            display: block;
        }

        /* Remember Me and Forgot Password
        ========================================================================== */
        .form-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: var(--spacing-lg);
        }

        .form-check {
            display: flex;
            align-items: center;
            gap: var(--spacing-xs);
        }

        .form-check-input {
            width: 1.2rem;
            height: 1.2rem;
            border: 2px solid var(--border-color);
            border-radius: var(--radius-sm);
            cursor: pointer;
        }

        .form-check-input:checked {
            background-color: var(--active-bg);
            border-color: var(--active-bg);
        }

        .form-check-label {
            font-size: 0.875rem;
            color: var(--text-secondary);
            cursor: pointer;
        }

        .forgot-password {
            color: var(--active-bg);
            text-decoration: none;
            font-size: 0.875rem;
            transition: color var(--transition-normal);
        }

        .forgot-password:hover {
            color: var(--hover-bg);
            text-decoration: underline;
        }

        /* Login Button
        ========================================================================== */
        .btn-login {
            width: 100%;
            margin-top: var(--spacing-md);
        }

        /* Alternative Login Methods
        ========================================================================== */
        .alternative-login {
            text-align: center;
            margin-top: var(--spacing-lg);
            padding-top: var(--spacing-lg);
            border-top: 1px solid var(--border-color);
        }

        .alternative-login p {
            color: var(--text-secondary);
            font-size: 0.875rem;
            margin-bottom: var(--spacing-md);
        }

        .social-buttons {
            display: flex;
            gap: var(--spacing-md);
            justify-content: center;
        }

        .btn-social {
            width: 40px;
            height: 40px;
            border-radius: var(--radius-md);
            border: 1px solid var(--border-color);
            background: white;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all var(--transition-normal);
        }

        .btn-social:hover {
            background-color: var(--page-bg);
            transform: translateY(-1px);
        }

        /* Footer
        ========================================================================== */
        .footer {
            text-align: center;
            padding: var(--spacing-lg);
            color: var(--text-secondary);
            font-size: 0.875rem;
        }

        .footer a {
            color: var(--text-primary);
            text-decoration: none;
            transition: color var(--transition-normal);
        }

        .footer a:hover {
            text-decoration: underline;
        }

        /* Responsive Design
        ========================================================================== */
        @media (max-width: 480px) {
            .login-content {
                padding: var(--spacing-md);
            }
            

            .login-card {
                padding: var(--spacing-lg);
            }
            
            .logo {
                width: 60px;
                height: 60px;
            }
            
            .logo i {
                font-size: 2rem;
            }
            
            .brand-name {
                font-size: 1.25rem;
            }
            
            .social-buttons {
                gap: var(--spacing-sm);
            }
        }
    " > src/public/css/login.css
    
    #  Create datatable CSS file
    echo "
    :root {
        --primary-bg: #1a1d3a;
        --secondary-bg: #242850;
        --hover-bg: #2f345e;
        --active-bg: #3F51B5;
        --text-primary: #ffffff;
        --text-secondary: #a4a6b3;
        --border-color: #e2e8f0;
        --page-bg: #f8fafc;
    }

    body {
        background-color: var(--page-bg);
        font-family: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    }

    .page-container {
        padding: 1.5rem;
        max-width: 1400px;
        margin: 0 auto;
    }

    .content-container {
        background: white;
        border-radius: 16px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        padding: 1.5rem;
        border: 1px solid var(--border-color);
    }

    .table-controls {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 1rem;
        gap: 1rem;
        flex-wrap: wrap;
    }

    .search-container {
        position: relative;
        flex: 1;
        max-width: 300px;
    }

    .search-container i {
        position: absolute;
        left: 1rem;
        top: 50%;
        transform: translateY(-50%);
        color: var(--text-secondary);
    }

    .search-input {
        width: 100%;
        padding: 0.625rem 1rem 0.625rem 2.5rem;
        border-radius: 8px;
        border: 1px solid var(--border-color);
        transition: all 0.3s ease;
    }

    .search-input:focus {
        outline: none;
        border-color: var(--active-bg);
        box-shadow: 0 0 0 3px rgba(63, 81, 181, 0.1);
    }

    .btn-primary {
        background-color: var(--active-bg);
        border: none;
        padding: 0.625rem 1.25rem;
        border-radius: 8px;
        color: var(--text-primary);
        display: flex;
        align-items: center;
        gap: 0.5rem;
        transition: all 0.3s ease;
    }

    .btn-primary:hover {
        background-color: var(--hover-bg);
    }

    .table-container {
        overflow-x: auto;
        margin: 1rem -1.5rem;
        padding: 0 1.5rem;
    }

    .data-table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0;
    }

    .data-table th {
        background-color: var(--page-bg);
        color: var(--primary-bg);
        font-weight: 600;
        padding: 1rem;
        text-align: left;
        border-bottom: 2px solid var(--border-color);
        white-space: nowrap;
        cursor: pointer;
        user-select: none;
    }

    .data-table th.sortable:hover {
        background-color: #e2e8f0;
    }

    .data-table th.sorted-asc::after {
        content: "↑";
        margin-left: 0.5rem;
    }

    .data-table th.sorted-desc::after {
        content: "↓";
        margin-left: 0.5rem;
    }

    .data-table td {
        padding: 1rem;
        border-bottom: 1px solid var(--border-color);
        vertical-align: middle;
    }

    .data-table tbody tr {
        transition: all 0.3s ease;
    }

    .data-table tbody tr:hover {
        background-color: var(--page-bg);
    }

    .data-table tbody tr.selected {
        background-color: rgba(63, 81, 181, 0.1);
    }

    .action-icons {
        display: flex;
        gap: 0.5rem;
        color: var(--text-secondary);
    }

    .action-icons i {
        cursor: pointer;
        padding: 0.5rem;
        border-radius: 4px;
        transition: all 0.3s ease;
    }

    .action-icons i:hover {
        color: var(--active-bg);
        background-color: rgba(63, 81, 181, 0.1);
    }

    .checkbox-wrapper {
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .form-check-input {
        width: 1.2rem;
        height: 1.2rem;
        margin: 0;
        cursor: pointer;
        border: 2px solid var(--border-color);
    }

    .form-check-input:checked {
        background-color: var(--active-bg);
        border-color: var(--active-bg);
    }

    .status-badge {
        padding: 0.25rem 0.75rem;
        border-radius: 999px;
        font-size: 0.875rem;
        font-weight: 500;
    }

    .status-active {
        background-color: #dcfce7;
        color: #166534;
    }

    .status-inactive {
        background-color: #fee2e2;
        color: #991b1b;
    }

    .status-pending {
        background-color: #fef9c3;
        color: #854d0e;
    }

    .pagination {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-top: 1rem;
        padding-top: 1rem;
        border-top: 1px solid var(--border-color);
    }

    .page-info {
        color: var(--text-secondary);
        font-size: 0.875rem;
    }

    .page-buttons {
        display: flex;
        gap: 0.5rem;
    }

    .page-btn {
        padding: 0.5rem;
        border: 1px solid var(--border-color);
        background: white;
        border-radius: 4px;
        cursor: pointer;
        transition: all 0.3s ease;
    }

    .page-btn:hover {
        border-color: var(--active-bg);
        color: var(--active-bg);
    }

    .page-btn.active {
        background-color: var(--active-bg);
        color: white;
        border-color: var(--active-bg);
    }

    .page-btn:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }

    /* Context Menu */
    .context-menu {
        position: fixed;
        background: white;
        border-radius: 8px;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        border: 1px solid var(--border-color);
        padding: 0.5rem 0;
        z-index: 1000;
        display: none;
    }

    .context-menu.show {
        display: block;
    }

    .context-menu-item {
        padding: 0.5rem 1rem;
        cursor: pointer;
        display: flex;
        align-items: center;
        gap: 0.5rem;
        color: var(--primary-bg);
        transition: all 0.3s ease;
    }

    .context-menu-item:hover {
        background-color: var(--page-bg);
    }

    @media (max-width: 768px) {
        .page-container {
            padding: 1rem;
        }

        .content-container {
            padding: 1rem;
        }

        .table-container {
            margin: 1rem -1rem;
            padding: 0 1rem;
        }

        .action-icons {
            flex-direction: column;
            gap: 0.25rem;
        }
    }

    
     " > src/public/css/datatable.css

    # Create layout file
    echo "
    <!DOCTYPE html>
        <html lang='en'>
        <head>
            <meta charset='UTF-8'>
            <meta name='viewport' content='width=device-width, initial-scale=1.0'>
            <title><%- typeof title != 'undefined' ? title : 'Default Title' %></title>
            <link href=https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css rel=stylesheet>
            <link href=https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css rel=stylesheet>
            
            <!-- Stylesheets -->
            <% if (typeof stylesheets !== 'undefined' && stylesheets.length > 0) { %>
                <% stylesheets.forEach(function(stylesheet) { %>
                    <link rel='stylesheet' href='<%= stylesheet %>'>
                <% }); %>
            <% } %>

        </head>
        <body>
            <header>
                <!-- Add your header content here -->
            </header>

            
            <% if (typeof showSidebar === 'undefined' || showSidebar === true) { %>
                <%- include('../includes/sidebar') %>
            <% } %>

            <main class='main-content'>
                <%- body %>
            </main>

            <footer>
                <!-- Add your footer content here -->
            </footer>

            <!-- Scripts -->
            <% if (typeof scripts !== 'undefined' && scripts.length > 0) { %>
                <% scripts.forEach(function(script) { %>
                    <script src='<%= script %>'></script>
                <% }); %>
            <% } %>

        </body>
        </html> " > src/views/layouts/main_layout.ejs

    # Create sidebar file in includes
    echo " <nav class='sidebar'>
            <div class='sidebar-header'>
                <span class='link-text'>Dashboard</span>
                <button class='menu-toggle'>
                    <i class='bi bi-list'></i>
                </button>
            </div>
            <ul class='nav flex-column mt-2'>
                <li class='nav-item'>
                    <a class='nav-link' data-menu-id='dashboard'>
                        <i class='bi bi-house-door'></i>
                        <span class='link-text'>Dashboard</span>
                    </a>
                </li>
                <li class='nav-item'>
                    <a class='nav-link' data-has-submenu='true' data-menu-id='users'>
                        <i class='bi bi-people'></i>
                        <span class='link-text'>Users</span>
                        <i class='bi bi-chevron-down toggle-icon'></i>
                    </a>
                    <div class='submenu' data-parent='users'>
                        <a class='nav-link' data-menu-id='user-list'>
                            <span class='link-text'>User List</span>
                        </a>
                        <a class='nav-link' data-menu-id='add-user'>
                            <span class='link-text'>Add User</span>
                        </a>
                    </div>
                </li>
                <li class='nav-item'>
                    <a class='nav-link' data-has-submenu='true' data-menu-id='analytics'>
                        <i class='bi bi-graph-up'></i>
                        <span class='link-text'>Analytics</span>
                        <i class='bi bi-chevron-down toggle-icon'></i>
                    </a>
                    <div class='submenu' data-parent='analytics'>
                        <a class='nav-link' data-menu-id='reports'>
                            <span class='link-text'>Reports</span>
                        </a>
                        <a class='nav-link' data-menu-id='statistics'>
                            <span class='link-text'>Statistics</span>
                        </a>
                    </div>
                </li>
                <li class='nav-item'>
                    <a class='nav-link' data-has-submenu='true' data-menu-id='settings'>
                        <i class='bi bi-gear'></i>
                        <span class='link-text'>Settings</span>
                        <i class='bi bi-chevron-down toggle-icon'></i>
                    </a>
                    <div class='submenu' data-parent='settings'>
                        <a class='nav-link' data-menu-id='general'>
                            <span class='link-text'>General</span>
                        </a>
                        <a class='nav-link' data-menu-id='security'>
                            <span class='link-text'>Security</span>
                        </a>
                    </div>
                </li>
            </ul>
        </nav>
    " > src/views/includes/sidebar.ejs

    # Create datatable view
    echo " 
        <div class='page-container'>
        <div class='content-container'>
            <div class='table-controls'>
                <button class='btn btn-primary'>
                    <i class='bi bi-plus-lg'></i>
                    <span>Add New</span>
                </button>
                <div class='search-container'>
                    <i class='bi bi-search'></i>
                    <input type='text' class='search-input' placeholder='Search...'>
                </div>
            </div>

            <div class='table-container'>
                <table class='data-table'>
                    <thead>
                        <tr>
                            <th>
                                <div class='checkbox-wrapper'>
                                    <input type='checkbox' class='form-check-input' id='selectAll'>
                                </div>
                            </th>
                            <th class='sortable' data-sort='id'>ID</th>
                            <th class='sortable' data-sort='name'>Name</th>
                            <th class='sortable' data-sort='email'>Email</th>
                            <th class='sortable' data-sort='role'>Role</th>
                            <th class='sortable' data-sort='status'>Status</th>
                            <th class='sortable' data-sort='lastLogin'>Last Login</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id='tableBody'></tbody>
                </table>
            </div>

            <div class='pagination'>
                <span class='page-info'>Showing <span id='startRecord'>1</span> to <span id='endRecord'>10</span> of <span id='totalRecords'>0</span> entries</span>
                <div class='page-buttons'>
                    <button class='page-btn' id='prevPage' disabled>Previous</button>
                    <button class='page-btn active'>1</button>
                    <button class='page-btn' id='nextPage'>Next</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Context Menu -->
    <div class='context-menu'>
        <div class='context-menu-item'>
            <i class='bi bi-eye'></i>
            <span>View Details</span>
        </div>
        <div class='context-menu-item'>
            <i class='bi bi-pencil'></i>
            <span>Edit</span>
        </div>
        <div class='context-menu-item'>
            <i class='bi bi-person-fill-lock'></i>
            <span>Change Status</span>
        </div>
        <div class='context-menu-item'>
            <i class='bi bi-trash'></i>
            <span>Delete</span>
        </div>
    </div>

    
    " > src/views/includes/datatable.ejs
    # Create sample dashboard view
    mkdir -p src/views
    echo "<%- contentFor('body') %>
        <div class=\"container\">
            <h1>Dashboard</h1>
            <!-- inclde datatable from includes folder -->
            <%- include('./includes/datatable') %>
        </div>" > src/views/dashboard.ejs
    
    # Create login view
     echo "<%- contentFor('body') %>
        <%- contentFor('body') %>
            <div class='login-container'>
                <div class='logo-container'>
                    <div class='logo'>
                        <i class='bi bi-shield-lock'></i>
                    </div>
                    <div class='brand-name'>CompanyName</div>
                </div>
            
                <div class='login-card'>
                    <div class='login-header'>
                        <h1>Welcome Back</h1>
                        <p class='text-muted'>Please enter your credentials</p>
                    </div>
            
                    <form id='loginForm' onsubmit='return handleSubmit(event)'>
                        <div class='form-group'>
                            <i class='bi bi-person'></i>
                            <input type='text' class='form-control' id='username' placeholder='Username' required>
                            <div class='validation-error'>Please enter a valid username</div>
                        </div>
            
                        <div class='form-group'>
                            <i class='bi bi-lock'></i>
                            <input type='password' class='form-control' id='password' placeholder='Password' required>
                            <div class='validation-error'>Password is required</div>
                        </div>
            
                        <div class='d-flex justify-content-between align-items-center mb-4'>
                            <div class='form-check'>
                                <input class='form-check-input' type='checkbox' id='rememberMe'>
                                <label class='form-check-label' for='rememberMe'>
                                    Remember me
                                </label>
                            </div>
                            <a href='#' class='forgot-password'>Forgot password?</a>
                        </div>
            
                        <button type='submit' class='btn btn-login'>
                            Sign In
                        </button>
                    </form>
            
                    <div class='alternative-login'>
                        <p>Or continue with</p>
                        <div class='social-buttons'>
                            <button class='btn-social'>
                                <i class='bi bi-google'></i>
                            </button>
                            <button class='btn-social'>
                                <i class='bi bi-microsoft'></i>
                            </button>
                            <button class='btn-social'>
                                <i class='bi bi-facebook'></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div> "> src/views/login.ejs

  

    # Create config files
    echo "module.exports = {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
        region: process.env.AWS_REGION,
        bucket: process.env.AWS_BUCKET_NAME
        };" > src/config/s3.config.js

    echo "module.exports = {
        host: process.env.SMTP_HOST,
        port: process.env.SMTP_PORT,
        secure: true,
        auth: {
            user: process.env.SMTP_USER,
            pass: process.env.SMTP_PASS
        }
        };" > src/config/smtp.config.js

    echo "const multer = require('multer');
        const storage = multer.memoryStorage();
        const upload = multer({
        storage: storage,
        limits: {
            fileSize: 5 * 1024 * 1024, // 5MB limit
        }
        });
        module.exports = upload;" > src/config/multer.config.js

    echo "module.exports = {
        s3Config: require('./s3.config'),
        smtpConfig: require('./smtp.config'),
        multerConfig: require('./multer.config')
        };" > src/config/index.js

    # Create email module
    echo "const nodemailer = require('nodemailer');
        const ejs = require('ejs');
        const { smtpConfig } = require('../../config');

        class EmailService {
            constructor() {
                this.transporter = nodemailer.createTransport(smtpConfig);
            }
            async sendEmail({ template, data, to, subject }) {
                const html = await this.renderTemplate(template, data);
                return this.transporter.sendMail({
                    from: smtpConfig.from,
                    to,
                    subject,
                    html
                });
            }
            async renderTemplate(templateName, data) {
                return ejs.renderFile(\`\${__dirname}/templates/\${templateName}.ejs\`, data);
            }
        }
        module.exports = new EmailService();" > src/modules/email/email.service.js

    # Create storage module
    echo "const { S3 } = require('aws-sdk');
        const { s3Config } = require('../../config');

        class StorageService {
            constructor() {
                this.s3 = new S3(s3Config);
            }
            async uploadToS3(file) {
                const params = {
                    Bucket: s3Config.bucket,
                    Key: \`uploads/\${Date.now()}-\${file.originalname}\`,
                    Body: file.buffer,
                    ContentType: file.mimetype
                };
                const result = await this.s3.upload(params).promise();
                return result.Location;
            }
            async deleteFromS3(fileKey) {
                const params = {
                    Bucket: s3Config.bucket,
                    Key: fileKey
                };
                return this.s3.deleteObject(params).promise();
            }
        }

         module.exports = new StorageService();" > src/modules/storage/storage.service.js

    # Create example route
    echo "const express = require('express');
        const router = express.Router();
        const { emailService } = require('../modules/email');
        const { storageService } = require('../modules/storage');
        const { userService } = require('../services');
        const { uploadMiddleware } = require('../modules/storage/multer.middleware');

        router.post('/upload-and-notify', 
            uploadMiddleware.single('file'),
            async (req, res) => {
                try {
                    const user = await userService.getUserById(req.user.id);
                    const fileUrl = await storageService.uploadToS3(req.file);
                    
                    await emailService.sendEmail({
                        template: 'notification',
                        data: { fileUrl, user },
                        to: user.email
                    });

                    res.json({ success: true, fileUrl });
                } catch (error) {
                    res.status(500).json({ error: error.message });
                }
            }
        );
        module.exports = router;" > src/routes/example.route.js

    # Create base service class
    echo "class BaseService {
        constructor() {
                // Add common service functionality
            }

            async handleError(error) {
                console.error(error);
                throw error;
            }
        }
        module.exports = BaseService;" > src/services/base.service.js

    # Create example user service
    echo "const BaseService = require('./base.service');
        class UserService extends BaseService {
            constructor() {
                super();
            }
            async getUserById(id) {
                try {
                    // Add user retrieval logic
                    return { id, name: 'Example User' };
                } catch (error) {
                    return this.handleError(error);
                }
            }
        }
        module.exports = new UserService();" > src/services/user.service.js

    # Create MongoDB connection module
    echo "const mongoose = require('mongoose');
        class MongoDBConnection {
            constructor() {
                this.isConnected = false;
            }

            async connect() {
                if (this.isConnected) return;

                try {
                    await mongoose.connect(process.env.MONGODB_URI, {
                        useNewUrlParser: true,
                        useUnifiedTopology: true
                    });
                    this.isConnected = true;
                    console.log('MongoDB Connected');
                } catch (error) {
                    console.error('MongoDB Connection Error:', error);
                    process.exit(1);
                }
            }

            async disconnect() {
                if (!this.isConnected) return;

                try {
                    await mongoose.disconnect();
                    this.isConnected = false;
                    console.log('MongoDB Disconnected');
                } catch (error) {
                    console.error('MongoDB Disconnection Error:', error);
                }
            }
        }
        module.exports = new MongoDBConnection();" > src/modules/database/mongodb/connection.js

    
    
    # Create MySQL connection module
    echo "const mysql = require('mysql2/promise');
        class MySQLConnection {
            constructor() {
                this.pool = null;
            }
            async connect() {
                if (this.pool) return this.pool;

                try {
                    this.pool = await mysql.createPool({
                        host: process.env.MYSQL_HOST,
                        user: process.env.MYSQL_USER,
                        password: process.env.MYSQL_PASSWORD,
                        database: process.env.MYSQL_DATABASE,
                        waitForConnections: true,
                        connectionLimit: 10,
                        queueLimit: 0
                    });
                    console.log('MySQL Pool Created');
                    return this.pool;
                } catch (error) {
                    console.error('MySQL Connection Error:', error);
                    process.exit(1);
                }
            }

            async query(sql, params) {
                try {
                    const [results] = await this.pool.execute(sql, params);
                    return results;
                } catch (error) {
                    console.error('MySQL Query Error:', error);
                    throw error;
                }
            }

            async disconnect() {
                if (!this.pool) return;

                try {
                    await this.pool.end();
                    this.pool = null;
                    console.log('MySQL Pool Ended');
                } catch (error) {
                    console.error('MySQL Disconnection Error:', error);
                }
            }
        }
        module.exports = new MySQLConnection();" > src/modules/database/mysql/connection.js

    # Create database module index
    echo "module.exports = {
        mongodb: require('./mongodb/connection'),
        mysql: require('./mysql/connection')
        };" > src/modules/database/index.js

    # Create service index file
    echo "module.exports = {
        userService: require('./user.service')
        };" > src/services/index.js

    # Create .env template
    echo "PORT=3000
        NODE_ENV=development

        MONGODB_URI=mongodb://localhost:27017/your_database

        # MySQL Configuration
        MYSQL_HOST=localhost
        MYSQL_USER=your_username
        MYSQL_PASSWORD=your_password
        MYSQL_DATABASE=your_database

        # AWS S3 Configuration
        AWS_ACCESS_KEY_ID=your_access_key
        AWS_SECRET_ACCESS_KEY=your_secret_key
        AWS_REGION=your_region
        AWS_BUCKET_NAME=your_bucket_name

        # SMTP Configuration
        SMTP_HOST=smtp.example.com
        SMTP_PORT=587
        SMTP_USER=your_email
        SMTP_PASS=your_password

        # JWT Configuration
        JWT_SECRET=your_jwt_secret
        JWT_EXPIRES_IN=24h" > .env.example

    # Create .gitignore
    echo "node_modules/
        .env
        .DS_Store
        coverage/
        dist/
        build/" > .gitignore

    print_success "Project structure created successfully!"
}

# Main execution
main() {
    print_message "Starting project setup..."
    
    setup_project
    install_dependencies
    create_structure
    
    print_success "Project setup completed successfully!"
    print_message "To get started:"
    echo "1. cd $project_name"
    echo "2. Copy .env.example to .env and update the values"
    echo "3. npm run dev"
}

main