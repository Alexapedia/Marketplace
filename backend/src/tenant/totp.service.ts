import { Injectable } from '@nestjs/common';
import { createHash, randomBytes } from 'crypto';
import { Secret, TOTP } from 'otpauth';
import QRCode from 'qrcode';

@Injectable()
export class TotpService {
  generateSecret(): string {
    return new Secret({ size: 20 }).base32;
  }

  keyuri(email: string, secret: string, issuer: string): string {
    return new TOTP({
      issuer,
      label: email,
      secret: Secret.fromBase32(secret),
      algorithm: 'SHA1',
      digits: 6,
      period: 30,
    }).toString();
  }

  async qrDataUrl(otpauthUrl: string): Promise<string> {
    return QRCode.toDataURL(otpauthUrl, { margin: 1, width: 220 });
  }

  verify(secret: string, token: string): boolean {
    const totp = new TOTP({
      secret: Secret.fromBase32(secret),
      algorithm: 'SHA1',
      digits: 6,
      period: 30,
    });
    return totp.validate({ token: token.replace(/\s/g, ''), window: 1 }) !== null;
  }

  backupCodes(count = 8): string[] {
    return Array.from({ length: count }, () => randomBytes(4).toString('hex'));
  }

  hashCode(code: string): string {
    return createHash('sha256').update(code.trim().toLowerCase()).digest('hex');
  }
}
