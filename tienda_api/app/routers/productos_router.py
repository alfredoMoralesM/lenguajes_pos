from fastapi import APIRouter, HTTPException, Depends, Body, status
from sqlalchemy.orm import Session
from app.database.connection import get_db         
from app.models.producto_model import Producto

router = APIRouter()


# GET productos
@router.get("/productos", summary="Listar todos los productos")
def obtener_productos(db: Session = Depends(get_db)):  # FIX: inyección de sesión
    return db.query(Producto).all()


# GET productos{id} 
@router.get("/productos/{id}", summary="Obtener un producto por ID")
def obtener_producto(id: int, db: Session = Depends(get_db)):
    producto = db.query(Producto).filter(Producto.id == id).first()

    if producto is None:
        raise HTTPException(status_code=404, detail="Producto no encontrado")

    return producto


# POST /productos
@router.post(
    "/productos",
    status_code=status.HTTP_201_CREATED,   # FIX: 201 Created (antes devolvía 200)
    summary="Crear un nuevo producto"
)
def crear_producto(
    nombre:    str   = Body(..., min_length=1),   # FIX: Body ahora está importado
    precio:    float = Body(..., gt=0),           # FIX: precio debe ser positivo
    stock:     int   = Body(..., ge=0),           # FIX: stock no puede ser negativo
    categoria: str   = Body(..., min_length=1),
    db: Session = Depends(get_db)
):
    nuevo_producto = Producto(
        nombre=nombre,
        precio=precio,
        stock=stock,
        categoria=categoria
    )

    db.add(nuevo_producto)
    db.commit()
    db.refresh(nuevo_producto)

    return nuevo_producto


# PUT /productos/{id} 
@router.put("/productos/{id}", summary="Actualizar un producto completo")
def actualizar_producto(
    id: int,
    nombre:    str   = Body(..., min_length=1),
    precio:    float = Body(..., gt=0),
    stock:     int   = Body(..., ge=0),
    categoria: str   = Body(..., min_length=1),
    db: Session = Depends(get_db)
):
    producto = db.query(Producto).filter(Producto.id == id).first()

    if producto is None:
        raise HTTPException(status_code=404, detail="Producto no encontrado")

    producto.nombre    = nombre
    producto.precio    = precio
    producto.stock     = stock
    producto.categoria = categoria

    db.commit()
    db.refresh(producto)

    return producto


# PUT /productos/{id}/stock
@router.put("/productos/{id}/stock", summary="Descontar 1 unidad del stock (venta)")
def restar_stock(id: int, db: Session = Depends(get_db)):
    # FIX: antes el bloque try tenía indentación incorrecta
    producto = db.query(Producto).filter(Producto.id == id).first()

    if producto is None:
        raise HTTPException(status_code=404, detail="Producto no encontrado")

    if producto.stock <= 0:
        raise HTTPException(status_code=400, detail="Sin stock disponible")

    producto.stock -= 1
    db.commit()
    db.refresh(producto)

    return {
        "mensaje": "Producto vendido",
        "id": producto.id,
        "stock_restante": producto.stock
    }


# DELETE /productos/{id} 
@router.delete(
    "/productos/{id}",
    status_code=status.HTTP_200_OK,
    summary="Eliminar un producto"
)
def eliminar_producto(id: int, db: Session = Depends(get_db)):
    producto = db.query(Producto).filter(Producto.id == id).first()

    if producto is None:
        raise HTTPException(status_code=404, detail="Producto no encontrado")

    db.delete(producto)
    db.commit()

    return {"mensaje": "Producto eliminado"}