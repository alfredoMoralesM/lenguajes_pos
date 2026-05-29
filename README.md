# 🛒 POS System — Guía de Instalación Completa

Sistema de punto de venta con backend en **FastAPI + SQLite** y frontend en **Flutter Web**.

---

## 📋 Tabla de Contenidos

1. [Requisitos previos](#1-requisitos-previos)
2. [Estructura del proyecto](#2-estructura-del-proyecto)
3. [Configurar el Backend (FastAPI)](#3-configurar-el-backend-fastapi)
4. [Configurar el Frontend (Flutter Web)](#4-configurar-el-frontend-flutter-web)
5. [Correr el sistema completo](#5-correr-el-sistema-completo)
6. [Credenciales de acceso](#6-credenciales-de-acceso)
7. [Uso de la app](#7-uso-de-la-app)
8. [Solución de problemas](#8-solución-de-problemas)

---

## 1. Requisitos Previos

Instala los siguientes programas **antes** de continuar. Todos son gratuitos.

### 🐍 Python 3.10 o superior
- Descarga: https://www.python.org/downloads/
- Durante la instalación, activa la casilla ✅ **"Add Python to PATH"**
- Verifica en terminal: `python --version`

### 🎯 Flutter SDK
- Descarga: https://docs.flutter.dev/get-started/install/windows
- Extrae el ZIP en `C:\flutter` (sin espacios en la ruta)
- Agrega `C:\flutter\bin` a la variable de entorno `PATH`
- Verifica en terminal: `flutter --version`

### 🌐 Google Chrome
- Necesario para ejecutar Flutter Web
- Descarga: https://www.google.com/chrome/

> ⚠️ **Nota**: No es necesario instalar Android Studio ni Xcode. Solo Chrome.

---

## 2. Estructura del Proyecto

Organiza los archivos en esta estructura de carpetas:

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

## 3. Configurar el Backend (FastAPI)

### 3.1 Instalar dependencias

Abre una terminal en la carpeta `tienda_api/` y ejecuta:

```bash
# Crear entorno virtual (recomendado)
python -m venv venv

# Activar el entorno virtual
venv\Scripts\activate

# Instalar dependencias
pip install -r requirements.txt
```

### 3.3 Correr el seed de productos (primera vez)

```bash
python seed_productos.py
```

Deberías ver:
```
✅  68 productos insertados correctamente.
🔒  Bandera creada en: .seed_done
```

### 3.4 Iniciar el servidor

```bash
uvicorn main:app --reload --port 8000
```

El servidor estará disponible en: **http://localhost:8000**

Puedes explorar la API en: **http://localhost:8000/docs**

---

## 4. Configurar el Frontend (Flutter Web)

### 4.1 Instalar dependencias de Flutter

Abre una terminal en la carpeta `front/` y ejecuta:

```bash
flutter pub get
```

### 4.2 Habilitar soporte web

```bash
flutter config --enable-web
```

El proyecto usa los siguientes paquetes (ya declarados en `pubspec.yaml`): `http`, `fl_chart`, `url_launcher` y `cupertino_icons`.

---

## 5. Correr el Sistema Completo

Necesitas **dos terminales abiertas al mismo tiempo**.

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

Abre Chrome e ingresa a la siguiente ruta **http://localhost:3000**

---

## 6. Credenciales de Acceso

| Campo     | Valor      |
|-----------|------------|
| Usuario   | `admin`    |
| Contraseña | `pos2026` |

---

## 7. Uso de la App

### 🛒 Ventas
- Busca productos en el catálogo
- Agrégalos al carrito con el botón `+`
- Ajusta cantidades o elimina ítems
- Presiona **Confirmar Venta** para procesar

### 📦 Productos
- Visualiza el inventario filtrado por categoría
- Agrega nuevos productos con el botón **Nuevo**
- Edita o elimina productos existentes
- El stock se actualiza automáticamente con cada venta

### 📊 Reportes
- Consulta el historial completo de ventas
- Exporta los datos a CSV con un clic

---

## 8. Solución de Problemas

### ❌ `flutter: command not found`
→ Flutter no está en el PATH. Agrega `C:\flutter\bin` a las variables de entorno y reinicia la terminal.

### ❌ `No se puede conectar al servidor`
→ Verifica que el backend esté corriendo en el puerto 8000 y que la URL en `api_service.dart` sea `http://localhost:8000/api/v1`.

### ❌ Error CORS al hacer peticiones desde Flutter Web
→ El backend ya incluye el middleware CORS configurado para aceptar todos los orígenes. Si persiste, reinicia el servidor.

### ❌ `ModuleNotFoundError: No module named 'app'`
→ Asegúrate de ejecutar `uvicorn` y `seed_productos.py` **desde la carpeta `tienda_api/`**, no desde subcarpetas.

### ❌ Productos duplicados en el seed
→ El seed tiene protección anti-duplicados. Si quieres volver a correrlo:
```bash
python seed_productos.py --force
```

### ❌ La base de datos no se crea
→ Asegúrate de que la carpeta `tienda_api/` tenga permisos de escritura. SQLite crea el archivo `tienda.db` en esa misma carpeta.

---

## 📌 URLs de Referencia Rápida

| Servicio        | URL                               |
|-----------------|-----------------------------------|
| App principal   | http://localhost:3000             |
| API backend     | http://localhost:8000             |
| Documentación   | http://localhost:8000/docs        |
| Exportar CSV    | http://localhost:8000/api/v1/ventas/exportar |
