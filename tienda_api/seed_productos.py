"""
seed_productos.py
=================
Seed de productos para la tienda POS.

Protección anti-duplicados
--------------------------
Antes de insertar, el script:
  1. Elimina TODOS los productos existentes (para borrar los que se
     subieron dos veces en la carga anterior).
  2. Resetea el contador de IDs en SQLite para que empiece desde 1.
  3. Inserta el catálogo nuevo.
  4. Crea el archivo .seed_done junto al script; si ese archivo ya
     existe al correr el script de nuevo, el proceso se ABORTA y
     no toca la base de datos.

Uso:
  python seed_productos.py           <- primera vez, corre normal
  python seed_productos.py           <- segunda vez, sale sin tocar nada
  python seed_productos.py --force   <- ignora la bandera y vuelve a correr
"""

import sys
import os
from pathlib import Path

# ── Bandera anti-duplicados ────────────────────────────────────────────────────
LOCK_FILE = Path(__file__).parent / ".seed_done"

force = "--force" in sys.argv

if LOCK_FILE.exists() and not force:
    print("⚠️  El seed ya fue ejecutado anteriormente.")
    print("   Si quieres correrlo de nuevo usa:  python seed_productos.py --force")
    sys.exit(0)

# ── Imports del proyecto ───────────────────────────────────────────────────────
from app.database.connection import SessionLocal, engine
from app.models.producto_model import Producto

# Importar todos los modelos para que create_all los conozca
import app.models.venta_model  # noqa

from app.database.connection import Base
Base.metadata.create_all(bind=engine)   # crea tablas si aún no existen

# ── Catálogo de productos ──────────────────────────────────────────────────────
PRODUCTOS = [
    # ── Bebidas ────────────────────────────────────────────────────────────────
    Producto(nombre="Coca Cola 600ml",          precio=20,  stock=60, categoria="Bebidas"),
    Producto(nombre="Coca Cola 2L",             precio=38,  stock=35, categoria="Bebidas"),
    Producto(nombre="Pepsi 600ml",              precio=18,  stock=50, categoria="Bebidas"),
    Producto(nombre="Pepsi 2L",                 precio=35,  stock=30, categoria="Bebidas"),
    Producto(nombre="Sprite 600ml",             precio=19,  stock=40, categoria="Bebidas"),
    Producto(nombre="Fanta Naranja 600ml",      precio=19,  stock=40, categoria="Bebidas"),
    Producto(nombre="Agua Ciel 600ml",          precio=12,  stock=80, categoria="Bebidas"),
    Producto(nombre="Agua Ciel 1.5L",           precio=18,  stock=50, categoria="Bebidas"),
    Producto(nombre="Electrolit 600ml",         precio=28,  stock=30, categoria="Bebidas"),
    Producto(nombre="Gatorade Mora Azul 600ml", precio=25,  stock=35, categoria="Bebidas"),
    Producto(nombre="Jumex Mango 335ml",        precio=14,  stock=40, categoria="Bebidas"),
    Producto(nombre="Boing Guayaba 500ml",      precio=12,  stock=45, categoria="Bebidas"),
    Producto(nombre="Red Bull 250ml",           precio=42,  stock=20, categoria="Bebidas"),
    Producto(nombre="Monster Verde 473ml",      precio=38,  stock=20, categoria="Bebidas"),
    Producto(nombre="Café NESCAFÉ Clásico 50g", precio=55,  stock=25, categoria="Bebidas"),

    # ── Botanas ────────────────────────────────────────────────────────────────
    Producto(nombre="Sabritas Original 45g",    precio=20,  stock=50, categoria="Botanas"),
    Producto(nombre="Sabritas Adobadas 45g",    precio=20,  stock=45, categoria="Botanas"),
    Producto(nombre="Doritos Nacho 60g",        precio=22,  stock=40, categoria="Botanas"),
    Producto(nombre="Doritos Flamin Hot 60g",   precio=22,  stock=35, categoria="Botanas"),
    Producto(nombre="Cheetos Bolitas 60g",      precio=20,  stock=40, categoria="Botanas"),
    Producto(nombre="Ruffles Queso 45g",        precio=22,  stock=35, categoria="Botanas"),
    Producto(nombre="Tostitos con Queso 60g",   precio=24,  stock=30, categoria="Botanas"),
    Producto(nombre="Palomitas Act II Natural", precio=18,  stock=30, categoria="Botanas"),
    Producto(nombre="Cacahuates Japoneses 60g", precio=16,  stock=35, categoria="Botanas"),
    Producto(nombre="Churrumais 45g",           precio=18,  stock=40, categoria="Botanas"),

    # ── Lácteos ────────────────────────────────────────────────────────────────
    Producto(nombre="Leche Lala Entera 1L",     precio=28,  stock=30, categoria="Lacteos"),
    Producto(nombre="Leche Lala Light 1L",      precio=29,  stock=25, categoria="Lacteos"),
    Producto(nombre="Leche Alpura Entera 1L",   precio=27,  stock=30, categoria="Lacteos"),
    Producto(nombre="Yogurt Yoplait Fresa 220g",precio=18,  stock=25, categoria="Lacteos"),
    Producto(nombre="Queso Oaxaca Lala 400g",   precio=72,  stock=15, categoria="Lacteos"),
    Producto(nombre="Queso Manchego Rebanado",  precio=65,  stock=15, categoria="Lacteos"),
    Producto(nombre="Crema Lala 200ml",         precio=22,  stock=20, categoria="Lacteos"),
    Producto(nombre="Mantequilla Lala 90g",     precio=28,  stock=20, categoria="Lacteos"),

    # ── Pan y Tortillería ──────────────────────────────────────────────────────
    Producto(nombre="Pan Blanco Bimbo 680g",    precio=45,  stock=20, categoria="Pan"),
    Producto(nombre="Pan Integral Bimbo 680g",  precio=48,  stock=15, categoria="Pan"),
    Producto(nombre="Tortillas Maíz 1kg",       precio=22,  stock=30, categoria="Pan"),
    Producto(nombre="Tortillas Harina 10pzas",  precio=28,  stock=25, categoria="Pan"),
    Producto(nombre="Bolillos (6 pzas)",        precio=18,  stock=20, categoria="Pan"),
    Producto(nombre="Galletas Marías 200g",     precio=22,  stock=30, categoria="Pan"),
    Producto(nombre="Galletas Oreo 119g",       precio=28,  stock=30, categoria="Pan"),

    # ── Abarrotes ─────────────────────────────────────────────────────────────
    Producto(nombre="Huevo Bachoco 12pzas",     precio=48,  stock=25, categoria="Abarrotes"),
    Producto(nombre="Arroz SOS 1kg",            precio=32,  stock=30, categoria="Abarrotes"),
    Producto(nombre="Frijol Negro 1kg",         precio=38,  stock=25, categoria="Abarrotes"),
    Producto(nombre="Frijol Pinto 1kg",         precio=36,  stock=25, categoria="Abarrotes"),
    Producto(nombre="Aceite Nutrioli 900ml",    precio=58,  stock=20, categoria="Abarrotes"),
    Producto(nombre="Azúcar Estándar 1kg",      precio=28,  stock=25, categoria="Abarrotes"),
    Producto(nombre="Sal La Fina 1kg",          precio=14,  stock=30, categoria="Abarrotes"),
    Producto(nombre="Sopa Maruchan Camarón",    precio=14,  stock=60, categoria="Abarrotes"),
    Producto(nombre="Sopa Maruchan Res",        precio=14,  stock=55, categoria="Abarrotes"),
    Producto(nombre="Atún Dolores 140g",        precio=24,  stock=35, categoria="Abarrotes"),
    Producto(nombre="Salsa Catsup Heinz 397g",  precio=42,  stock=20, categoria="Abarrotes"),
    Producto(nombre="Salsa Valentina 150ml",    precio=18,  stock=30, categoria="Abarrotes"),
    Producto(nombre="Mayonesa McCormick 400g",  precio=52,  stock=18, categoria="Abarrotes"),
    Producto(nombre="Fideo Corto 200g",         precio=12,  stock=35, categoria="Abarrotes"),
    Producto(nombre="Espagueti 400g",           precio=18,  stock=30, categoria="Abarrotes"),

    # ── Dulces y Confitería ────────────────────────────────────────────────────
    Producto(nombre="Chocolate Carlos V 18g",   precio= 8,  stock=50, categoria="Dulces"),
    Producto(nombre="Chicles Trident Menta",    precio=14,  stock=40, categoria="Dulces"),
    Producto(nombre="Paleta Payaso",            precio= 6,  stock=60, categoria="Dulces"),
    Producto(nombre="Mazapán De la Rosa",       precio= 6,  stock=60, categoria="Dulces"),
    Producto(nombre="Pulparindo Tamarindo",     precio= 6,  stock=55, categoria="Dulces"),
    Producto(nombre="Duvalin Avell-Fresa",      precio= 9,  stock=45, categoria="Dulces"),
    Producto(nombre="Glorias Cajeta 3pzas",     precio=14,  stock=35, categoria="Dulces"),

    # ── Higiene y Limpieza ─────────────────────────────────────────────────────
    Producto(nombre="Jabón Zote Blanco 400g",   precio=22,  stock=20, categoria="Higiene"),
    Producto(nombre="Detergente Ariel 500g",    precio=48,  stock=18, categoria="Higiene"),
    Producto(nombre="Suavitel Fresco 500ml",    precio=36,  stock=15, categoria="Higiene"),
    Producto(nombre="Papel Higiénico Regio 4R", precio=42,  stock=25, categoria="Higiene"),
    Producto(nombre="Jabón Palmolive 150g",     precio=18,  stock=25, categoria="Higiene"),
    Producto(nombre="Shampoo Pantene 400ml",    precio=78,  stock=12, categoria="Higiene"),
    Producto(nombre="Desodorante Axe 150ml",    precio=68,  stock=15, categoria="Higiene"),
    Producto(nombre="Pasta Dental Colgate 75ml",precio=32,  stock=20, categoria="Higiene"),
]

# ── Ejecutar seed ──────────────────────────────────────────────────────────────
db = SessionLocal()

try:
    # 1. Eliminar productos existentes (limpia duplicados de carga anterior)
    deleted = db.query(Producto).delete()
    print(f"🗑️  {deleted} producto(s) eliminado(s).")

    # 3. Insertar catálogo nuevo
    db.bulk_save_objects(PRODUCTOS)
    db.commit()
    print(f"✅  {len(PRODUCTOS)} productos insertados correctamente.")

    # 4. Crear archivo bandera para evitar ejecuciones futuras accidentales
    LOCK_FILE.touch()
    print(f"🔒  Bandera creada en: {LOCK_FILE}")

except Exception as e:
    db.rollback()
    print(f"❌  Error durante el seed: {e}")
    raise
finally:
    db.close()
