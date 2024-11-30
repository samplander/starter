const express = require('express');
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
                title: 'Login - Page',
                stylesheets: getStylesheets('default'),
                scripts: getScripts('default')
            });
        });

        app.get('/dashboard', (req, res) => {
            res.render('dashboard', {
                title: 'Dashbaord - Page',  
                stylesheets: getStylesheets('dashboard'),
                scripts: getScripts('dashboard')
            });
        });

        const PORT = process.env.PORT || 3000;
        app.listen(PORT, () => {
            console.log(`Server is running on port ${PORT}`);
        });
