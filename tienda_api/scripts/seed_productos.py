from app.database.connection import SessionLocal
from app.models.producto_model import Producto

db = SessionLocal()

productos = [

    Producto(nombre="Coca Cola 600ml", precio=18, stock=40, categoria="Bebidas"),
    Producto(nombre="Pepsi 600ml", precio=17, stock=30, categoria="Bebidas"),
    Producto(nombre="Sabritas Original", precio=20, stock=25, categoria="Botanas"),
    Producto(nombre="Doritos Nacho", precio=22, stock=20, categoria="Botanas"),
    Producto(nombre="Leche Lala 1L", precio=28, stock=15, categoria="Lacteos"),
    Producto(nombre="Pan Bimbo", precio=40, stock=10, categoria="Pan"),
    Producto(nombre="Huevo 12pzas", precio=45, stock=12, categoria="Abarrotes"),
    Producto(nombre="Arroz 1kg", precio=30, stock=18, categoria="Abarrotes")

]

for producto in productos:
    db.add(producto)

db.commit()
db.close()

print("Productos de prueba insertados correctamente")