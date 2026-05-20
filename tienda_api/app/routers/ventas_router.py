from fastapi import APIRouter, HTTPException, Depends
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import List
from datetime import datetime
import csv
import io

from app.database.connection import get_db
from app.models.producto_model import Producto
from app.models.venta_model import Venta, VentaItem

router = APIRouter()

# ── Schemas ────────────────────────────────────────────────────────────────────

class ItemCarrito(BaseModel):
    producto_id: int
    cantidad: int

class VentaRequest(BaseModel):
    items: List[ItemCarrito]

# ── POST /ventas — confirmar venta ────────────────────────────────────────────
@router.post("/ventas", status_code=201)
def confirmar_venta(data: VentaRequest, db: Session = Depends(get_db)):
    if not data.items:
        raise HTTPException(status_code=400, detail="El carrito está vacío")

    total = 0.0
    items_procesados = []

    for item in data.items:
        producto = db.query(Producto).filter(Producto.id == item.producto_id).first()
        if not producto:
            raise HTTPException(status_code=404, detail=f"Producto {item.producto_id} no encontrado")
        if producto.stock < item.cantidad:
            raise HTTPException(
                status_code=400,
                detail=f"Stock insuficiente para '{producto.nombre}' (disponible: {producto.stock})"
            )
        subtotal = producto.precio * item.cantidad
        total += subtotal
        items_procesados.append((producto, item.cantidad, subtotal))

    # Persistir venta
    venta = Venta(total=total)
    db.add(venta)
    db.flush()  # obtener venta.id antes del commit

    for producto, cantidad, subtotal in items_procesados:
        db.add(VentaItem(
            venta_id=venta.id,
            producto_id=producto.id,
            nombre=producto.nombre,
            precio=producto.precio,
            cantidad=cantidad,
            subtotal=subtotal,
        ))
        producto.stock -= cantidad  # descontar inventario

    db.commit()
    db.refresh(venta)

    return {
        "id": venta.id,
        "total": venta.total,
        "fecha": venta.fecha,
        "items": [
            {"nombre": p.nombre, "cantidad": c, "subtotal": s}
            for p, c, s in items_procesados
        ]
    }

# ── GET /ventas — historial ───────────────────────────────────────────────────
@router.get("/ventas")
def historial_ventas(db: Session = Depends(get_db)):
    ventas = db.query(Venta).order_by(Venta.fecha.desc()).all()
    resultado = []
    for v in ventas:
        resultado.append({
            "id": v.id,
            "total": v.total,
            "fecha": v.fecha,
            "items": [
                {
                    "nombre":   i.nombre,
                    "cantidad": i.cantidad,
                    "precio":   i.precio,
                    "subtotal": i.subtotal,
                }
                for i in v.items
            ]
        })
    return resultado

# ── GET /ventas/exportar — CSV ────────────────────────────────────────────────
@router.get("/ventas/exportar")
def exportar_ventas_csv(db: Session = Depends(get_db)):
    ventas = db.query(Venta).order_by(Venta.fecha.desc()).all()

    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(["ID Venta", "Fecha", "Producto", "Cantidad", "Precio Unit.", "Subtotal", "Total Venta"])

    for v in ventas:
        for i in v.items:
            writer.writerow([
                v.id,
                v.fecha.strftime("%Y-%m-%d %H:%M"),
                i.nombre,
                i.cantidad,
                f"{i.precio:.2f}",
                f"{i.subtotal:.2f}",
                f"{v.total:.2f}",
            ])

    output.seek(0)
    return StreamingResponse(
        iter([output.getvalue()]),
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=ventas.csv"}
    )