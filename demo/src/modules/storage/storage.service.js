const { S3 } = require('aws-sdk');
        const { s3Config } = require('../../config');

        class StorageService {
            constructor() {
                this.s3 = new S3(s3Config);
            }
            async uploadToS3(file) {
                const params = {
                    Bucket: s3Config.bucket,
                    Key: `uploads/${Date.now()}-${file.originalname}`,
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

         module.exports = new StorageService();
