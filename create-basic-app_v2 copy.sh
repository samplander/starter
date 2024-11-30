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
    echo "" > src/views/layouts/main.ejs
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
            res.render('index', {
                title: 'Welcome',
                stylesheets: getStylesheets('default'),
                scripts: getScripts('default')
            });
        });

        const PORT = process.env.PORT || 3000;
        app.listen(PORT, () => {
            console.log(\`Server is running on port \${PORT}\`);
        });" > src/app.js

    # Create sample CSS file
    echo "body {
        font-family: Arial, sans-serif;
        margin: 0;
        padding: 0;
        background-color: #f0f0f0;
    }" > src/public/css/main.css

    # Create layout file
    echo "<!DOCTYPE html>
        <html lang=\"en\">
        <head>
            <meta charset=\"UTF-8\">
            <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
            <title><%- typeof title != 'undefined' ? title : 'Default Title' %></title>
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
            <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
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

            <main>
               <%- include('../includes/sidebar') %>
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
        </html>" > src/views/layouts/main_layout.ejs

    # Create sample index view
    mkdir -p src/views
    echo "<%- contentFor('body') %>
        <div class=\"container\">
            <!-- inclde datatable from includes folder -->
            <%- include('./includes/datatable') %>
        </div>" > src/views/dashbaord.ejs

    # Create sidebar.ejs file with a basic nav tag
    echo "<nav>
        <!-- Sidebar content will be added here -->
        </nav>" > src/views/includes/sidebar.ejs

    # Create datatable view
    echo " 
            <div class="page-container">
            <div class="content-container">
                <div class="table-controls">
                    <button class="btn btn-primary">
                        <i class="bi bi-plus-lg"></i>
                        <span>Add New</span>
                    </button>
                    <div class="search-container">
                        <i class="bi bi-search"></i>
                        <input type="text" class="search-input" placeholder="Search...">
                    </div>
                </div>

                <div class="table-container">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>
                                    <div class="checkbox-wrapper">
                                        <input type="checkbox" class="form-check-input" id="selectAll">
                                    </div>
                                </th>
                                <th class="sortable" data-sort="id">ID</th>
                                <th class="sortable" data-sort="name">Name</th>
                                <th class="sortable" data-sort="email">Email</th>
                                <th class="sortable" data-sort="role">Role</th>
                                <th class="sortable" data-sort="status">Status</th>
                                <th class="sortable" data-sort="lastLogin">Last Login</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="tableBody"></tbody>
                    </table>
                </div>

                <div class="pagination">
                    <span class="page-info">Showing <span id="startRecord">1</span> to <span id="endRecord">10</span> of <span id="totalRecords">0</span> entries</span>
                    <div class="page-buttons">
                        <button class="page-btn" id="prevPage" disabled>Previous</button>
                        <button class="page-btn active">1</button>
                        <button class="page-btn" id="nextPage">Next</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Context Menu -->
        <div class="context-menu">
            <div class="context-menu-item">
                <i class="bi bi-eye"></i>
                <span>View Details</span>
            </div>
            <div class="context-menu-item">
                <i class="bi bi-pencil"></i>
                <span>Edit</span>
            </div>
            <div class="context-menu-item">
                <i class="bi bi-person-fill-lock"></i>
                <span>Change Status</span>
            </div>
            <div class="context-menu-item">
                <i class="bi bi-trash"></i>
                <span>Delete</span>
            </div>
        </div>

    
    " > src/views/includes/datatable.ejs

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