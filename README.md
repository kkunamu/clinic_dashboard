# Clinic Control Dashboard - ADDU Health Services

A modern, comprehensive web dashboard built for the Ateneo de Davao University (ADDU) Clinic. This application streamlines the management of student medical consultations, medication dispensing, and medical certificate records using a secure, responsive, and aesthetic Flutter interface.

## 🚀 Features

### Secure Authentication
* **Role-Based Access:** Designed specifically for clinic staff and administrators.
* **Email & Password Login:** Standard secure authentication using Supabase.
* **Google OAuth Integration:** One-click "Sign in with Google" seamlessly configured for the ADDU domain.
* **Smart UI:** "Enter-to-Submit" keyboard flow and built-in loading states to prevent duplicate submissions.

### Dashboard & Consultations
* **Real-time Data:** Fetches patient records and consultations directly from the Supabase PostgreSQL backend.
* **Smart Search:** Instantly filter records by patient name or chief complaint.
* **Detailed Medical Records:** View comprehensive history including:
  * Chief complaints and attending staff.
  * Finalized diagnoses.
  * Dispensed medications (quantities and dosages).
  * Downloadable medical certificates.
* **Hover Aesthetics:** Material 3 interactive data tables that highlight rows on mouse hover for better readability.

### CRUD Operations
* **Create:** Record new consultations, link them to specific students, and add dispensed medications in a single, streamlined transaction.
* **Read:** View lists of students and their historical medical visits.
* **Update:** Modify and finalize patient diagnoses directly from the details view.

### Account Management
* **Profile Customization:** Clinic staff can update their display names.
* **Secure Details:** Read-only displays for registered emails and assigned administrative roles.

---

## 🛠 Tech Stack

* **Frontend Framework:** [Flutter (Web)](https://flutter.dev/) - Utilizing the latest version (3.41+) and Material 3 design standards.
* **Backend as a Service (BaaS):** [Supabase](https://supabase.com/)
  * PostgreSQL Database
  * Supabase Auth (Email & Google OAuth)
* **Key Packages:**
  * `supabase_flutter`: Database and authentication handling.
  * `url_launcher`: Secure external routing for viewing medical certificates.

---

## ⚙️ Installation & Local Setup

### 1. Prerequisites
* **Flutter SDK:** Version `3.41` or higher.
* **VS Code:** Recommended IDE.

### 2. Clone the Repository
```bash
git clone <repository-url>
cd clinic_dashboard
```

### 3. Install Dependencies
Run the following command to download all required packages:
```bash
flutter pub get
```

### 4. Bypassing Google OAuth Security (Local Testing)
**⚠️ IMPORTANT:** Google's anti-bot security will block OAuth login attempts made from standard debug browsers. To run this project locally with fully functional Google Sign-In, you **must** run it as a web server on Port 3000.

**The Automated Way (VS Code):**
1. Navigate to the `.vscode` folder (or create one at the project root).
2. Ensure `launch.json` contains the following configuration:
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Clinic App (Official Server)",
            "request": "launch",
            "type": "dart",
            "flutterMode": "debug",
            "args": [
                "-d",
                "web-server",
                "--web-port",
                "3000"
            ]
        }
    ]
}
```
3. Go to the "Run and Debug" tab in VS Code, select **"Clinic App (Official Server)"**, and hit the Play button.
4. Once the terminal says the server is running, open your **normal, everyday Chrome browser** and navigate to `http://localhost:3000`.

**The Manual Terminal Way:**
Alternatively, run this command in your terminal:
```bash
flutter run -d web-server --web-port 3000
```
Then open `http://localhost:3000` in a standard browser window.

---

## 👨‍💻 Author

* **Rainzy Belle Cañada** - Web Dashboard / Frontend Engineering

*Developed for the Computer Studies Cluster.*
