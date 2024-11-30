const nodemailer = require('nodemailer');
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
                return ejs.renderFile(`${__dirname}/templates/${templateName}.ejs`, data);
            }
        }
        module.exports = new EmailService();
