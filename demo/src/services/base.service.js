class BaseService {
        constructor() {
                // Add common service functionality
            }

            async handleError(error) {
                console.error(error);
                throw error;
            }
        }
        module.exports = BaseService;
