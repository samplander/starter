/**
        * Style helper for managing page-specific CSS files
        */

        const baseStyles = ['/css/main.css']; // Always included styles
        const baseScripts = ['/js/main.js']; // Always included scripts

        const pageAssets = {
            // Dashboard pages
            dashboard: {
                styles: [
                    '/css/main.css',
                    '/css/sidebar.css',
                    '/css/datatable.css'
                ],
                scripts: [
                    '/js/datatable.js',
                    '/js/sidebar.js',
                    '/js/datatable.js'
                
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
            
            // Profile pages
            profile: {
                styles: [
                    '/css/sidebar.css',
                    '/css/forms.css'
                ],
                scripts: [
                    '/js/profile.js'
                ]
            },
            
            // Default page (fallback)
            default: {
                styles: [
                    '/css/main.css',
                    '/css/login.css'
                ],
                scripts: [
                    '/js/login.js'
                ]
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
        };
