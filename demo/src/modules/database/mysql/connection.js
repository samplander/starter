const mysql = require('mysql2/promise');
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
        module.exports = new MySQLConnection();
