# 🛒 POS System — Complete Installation Guide

Point of sale system with a **FastAPI + SQLite** backend and **Flutter Web** frontend.

---

## Screenshots

* Login
<img width="1583" height="892" alt="image" src="https://github.com/user-attachments/assets/8697a35c-aba2-459d-98f8-ea46dfacd08a" />

* Ventas page/carrito
<img width="1920" height="1020" alt="image" src="https://github.com/user-attachments/assets/4b955914-eefd-467d-ad59-34a7e0916510" />

* Productos page
<img width="1583" height="892" alt="image" src="https://github.com/user-attachments/assets/551afa79-06e0-41ee-aff2-dddd1e73405e" />

* Reportes page
<img width="1583" height="892" alt="image" src="https://github.com/user-attachments/assets/3ce06866-0e5f-46d1-8402-eda546f5eb6f" />

<img width="1583" height="892" alt="image" src="https://github.com/user-attachments/assets/d2d1fb2a-6e87-48c8-b064-93aa1e37bb3e" />

## 📋 Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Project Structure](#2-project-structure)
3. [Configure the Backend (FastAPI)](#3-configure-the-backend-fastapi)
4. [Configure the Frontend (Flutter Web)](#4-configure-the-frontend-flutter-web)
5. [Run the Complete System](#5-run-the-complete-system)
6. [Login Credentials](#6-login-credentials)
7. [Using the App](#7-using-the-app)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. Prerequisites

Install the following programs **before** continuing. All are free.

### 🐍 Python 3.10 or higher
- Download: https://www.python.org/downloads/
- During installation, check the ✅ **"Add Python to PATH"** box
- Verify in terminal: `python --version`

### 🎯 Flutter SDK
- Go to: https://docs.flutter.dev/get-started/install/windows, navigate to **Custom Setup** → **Install Manually**. Download the ZIP.
- Extract the ZIP to `C:\flutter` (no spaces in the path)
- Add `C:\flutter\bin` to the `PATH` environment variable
- Verify in terminal: `flutter --version`

### 🌐 Google Chrome
- Required to run Flutter Web
- Download: https://www.google.com/chrome/

> ⚠️ **Note**: No need to install Android Studio or Xcode. Chrome only.

---

## 2. Project Structure

Before starting, clone and download the repository from GitHub to get the complete project structure:

```bash
git clone https://github.com/alfredoMoralesM/lenguajes_pos.git
```

```
pos_system/
│
├── tienda_api/
│   ├── app/
│   │   ├── database/
│   │   │   └── connection.py
│   │   ├── models/
│   │   │   ├── producto_model.py
│   │   │   └── venta_model.py
│   │   └── routers/
│   │       ├── auth_router.py
│   │       ├── productos_router.py
│   │       └── ventas_router.py
│   ├── main.py
│   └── seed_productos.py
│
└── front/
        ├── lib/
        │   ├── main.dart
        │   ├── models/
        │   │   ├── producto.dart
        │   │   └── venta.dart
        │   ├── screens/
        │   │   ├── login_page.dart
        │   │   ├── home_page.dart
        │   │   ├── ventas_page.dart
        │   │   ├── productos_page.dart
        │   │   ├── agregar_producto_page.dart
        │   │   └── reportes_page.dart
        │   └── services/
        │       └── api_service.dart
        └── pubspec.yaml
```

---

## 3. Configure the Backend (FastAPI)

### 3.1 Install dependencies

Open a terminal in the project's `tienda_api/` folder and run:

```bash
# Create virtual environment (recommended)
python -m venv venv
# or
py -m venv venv

# Activate the virtual environment
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 3.2 Run the product seed (first time only)

```bash
python seed_productos.py
```

You should see:

```
✅  68 products inserted successfully.
🔒  Flag created at: .seed_done
```

### 3.3 Start the server

```bash
uvicorn main:app --reload --port 8000
```

Verify everything started correctly:

| Service       | URL                        |
|---------------|----------------------------|
| Server        | http://localhost:8000      |
| API Docs      | http://localhost:8000/docs |

---

## 4. Configure the Frontend (Flutter Web)

### 4.1 Install Flutter dependencies

Open another terminal in the project's `front/` folder and run:

```bash
flutter pub get
```

### 4.2 Enable web support

```bash
flutter config --enable-web
```

> The project uses the following packages (already declared in `pubspec.yaml`): `http`, `fl_chart`, `url_launcher`, and `cupertino_icons`.

---

## 5. Run the Complete System

You need **two terminals open at the same time**.

### Terminal 1 — Backend

```bash
cd pos_system/tienda_api
venv\Scripts\activate
uvicorn main:app --reload --port 8000
```

### Terminal 2 — Frontend

```bash
cd pos_system/front
flutter run -d web-server --web-port 3000
```

Open Chrome and navigate to **http://localhost:3000**

---

## 6. Login Credentials

| Field    | Value     |
|----------|-----------|
| Username | `admin`   |
| Password | `pos2026` |

---

## 7. Using the App

### 🛒 Sales
- Search for products in the catalog
- Add them to the cart with the `+` button
- Adjust quantities or remove items
- Press **Confirm Sale** to process

### 📦 Products
- View inventory filtered by category
- Add new products with the **New** button
- Edit or delete existing products
- Stock updates automatically with each sale

### 📊 Reports
- View the complete sales history
- Export data to CSV with one click

---

## 8. Troubleshooting

### ❌ `flutter: command not found`
→ Flutter is not in the PATH. Add `C:\flutter\bin` to your environment variables and restart the terminal.

### ❌ Cannot connect to the server
→ Verify that the backend is running on port 8000 and that the URL in `api_service.dart` is `http://localhost:8000/api/v1`.

### ❌ CORS error when making requests from Flutter Web
→ The backend already includes CORS middleware configured to accept all origins. If it persists, restart the server.

### ❌ `ModuleNotFoundError: No module named 'app'`
→ Make sure to run `uvicorn` and `seed_productos.py` **from the `tienda_api/` folder**, not from subfolders.

### ❌ Duplicate products in the seed
→ The seed has anti-duplication protection. To force a re-run:

```bash
python seed_productos.py --force
```

### ❌ The database is not created
→ Make sure the `tienda_api/` folder has write permissions. SQLite creates the `tienda.db` file in that same folder.

---

## 📌 Quick Reference URLs

| Service       | URL                                           |
|---------------|-----------------------------------------------|
| Main app      | http://localhost:3000                         |
| Backend API   | http://localhost:8000                         |
| Documentation | http://localhost:8000/docs                    |
| Export CSV    | http://localhost:8000/api/v1/ventas/exportar  |

