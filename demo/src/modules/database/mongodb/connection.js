const mongoose = require('mongoose');
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
        module.exports = new MongoDBConnection();
