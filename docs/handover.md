# Production handover checklist

- [ ] MongoDB provisioned with backups
- [ ] `backend/.env` secrets set (JWT, CORS, Firebase)
- [ ] API reachable over HTTPS; `/api/v1/health` monitored
- [ ] Admin dashboard built against production `apiUrl`
- [ ] Seed admin password rotated
- [ ] Firebase project: Auth, FCM, APNs, Google, Apple
- [ ] `google-services.json` / `GoogleService-Info.plist` installed (not in git)
- [ ] Store URLs and min versions set in App Config
- [ ] Delivery fee and COD rules confirmed in app config / ops
- [ ] Brand logo and colors applied
- [ ] Privacy Policy, Terms, support contact added
- [ ] Play Console + App Store Connect access
- [ ] Staging vs production Firebase/API split verified
