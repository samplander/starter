const express = require('express');
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
        module.exports = router;
