import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createTransport, Transporter } from 'nodemailer';

export interface MailMessage {
  to: string;
  subject: string;
  text: string;
  html?: string;
}

/**
 * SMTP mailer. When SMTP_HOST is not configured, messages are written to the
 * log instead so local development and staging keep working.
 */
@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);
  private readonly transporter?: Transporter;
  private readonly from: string;

  constructor(config: ConfigService) {
    const host = config.get<string>('SMTP_HOST');
    this.from = config.get<string>('SMTP_FROM') || 'no-reply@localhost';
    if (host) {
      const port = Number(config.get<string>('SMTP_PORT') || 587);
      const user = config.get<string>('SMTP_USER');
      this.transporter = createTransport({
        host,
        port,
        secure: port === 465,
        auth: user ? { user, pass: config.get<string>('SMTP_PASS') } : undefined,
      });
    }
  }

  get enabled() {
    return !!this.transporter;
  }

  async send(message: MailMessage, fromName?: string): Promise<void> {
    if (!this.transporter) {
      this.logger.log(
        `[mail disabled] to=${message.to} subject="${message.subject}"\n${message.text}`,
      );
      return;
    }
    try {
      await this.transporter.sendMail({
        from: fromName ? `"${fromName.replace(/"/g, '')}" <${this.from}>` : this.from,
        ...message,
      });
    } catch (err) {
      // Never leak delivery failures to the caller (e.g. account enumeration).
      this.logger.error(`Failed to send mail to ${message.to}`, err as Error);
    }
  }
}
