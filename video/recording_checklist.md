# Screen Recording Checklist — Setup & Technical Preparation

Ensure your environment is properly prepared before recording the 5–8 minute project demo.

---

## 1. Environment & Display Setup

- [ ] **Screen Resolution:** Set display resolution to 1920x1080 (1080p Full HD) or 2560x1440 (1440p).
- [ ] **Aspect Ratio:** Standard 16:9 widescreen.
- [ ] **System Scaling / Zoom:** 100% or 125% scaling (ensure text is easily readable on mobile and desktop).
- [ ] **Clean Desktop & Taskbar:** Hide unnecessary desktop icons and hide personal Windows taskbar notifications/popups (Turn on 'Do Not Disturb' / Focus Mode).
- [ ] **Close Unrelated Applications:** Close Slack, Discord, Email, Spotify, or background apps to prevent popups or CPU throttling.

---

## 2. Code & SQL Editor Setup (MySQL Workbench / VS Code / DBeaver)

- [ ] **Theme:** Dark mode preferred (e.g., VS Code Dark+, One Dark Pro, or DBeaver Dark).
- [ ] **Font Size:** Increase editor font size to **16px–18px** for code clarity.
- [ ] **SQL Query Tabs:** Open the following files in tabs beforehand:
  1. `sql/01_database_schema.sql`
  2. `sql/04_sales_analysis.sql`
  3. `sql/05_customer_analysis.sql`
  4. `sql/06_product_analysis.sql`
  5. `sql/08_target_analysis.sql`
  6. `sql/09_advanced_analysis.sql`
- [ ] **Pre-Execute Database Load:** Ensure `sales_analytics_db` is pre-populated so queries execute instantly without load delays.

---

## 3. Browser & GitHub Setup

- [ ] **Browser Zoom:** 100% or 110% zoom in Chrome / Edge / Firefox.
- [ ] **Browser Tabs Open:**
  - Tab 1: GitHub Repository Root (`README.md`).
  - Tab 2: `documentation/data_dictionary.md` (showing ER diagram).
  - Tab 3: `documentation/business_insights.md`.
  - Tab 4: `documentation/business_recommendations.md`.
- [ ] **Bookmarks Bar:** Hide browser bookmarks bar (`Ctrl + Shift + B`).

---

## 4. Audio & Microphone Checklist

- [ ] **Microphone Selection:** Use a clean external USB microphone or headset mic.
- [ ] **Input Volume:** Set mic gain to avoid clipping or distortion (peak around -6dB to -3dB).
- [ ] **Noise Suppression:** Enable noise suppression / background noise gate (e.g., OBS Noise Suppression or Krisp).
- [ ] **Acoustics:** Record in a quiet room with minimal echo.

---

## 5. Screen Recording Software Setup (OBS Studio / Loom / Camtasia)

- [ ] **Framerate:** 30 FPS or 60 FPS.
- [ ] **Video Format:** MP4 or MKV with AAC audio codec.
- [ ] **Mouse Cursor:** Highlight mouse cursor clicks or enable subtle cursor highlighting.

---

## 6. Post-Recording Editing Checklist

- [ ] Trim leading/trailing silence.
- [ ] Ensure smooth transitions between SQL editor and browser documentation.
- [ ] Verify audio volume is balanced and clear throughout.
- [ ] Export final video in 1080p HD MP4 format.
