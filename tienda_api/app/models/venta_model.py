from sqlalchemy import Column, Integer, Float, DateTime, ForeignKey, String
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database.connection import Base

class Venta(Base):
    __tablename__ = "ventas"

    id         = Column(Integer, primary_key=True, index=True)
    total      = Column(Float,   nullable=False)
    fecha      = Column(DateTime, default=datetime.utcnow)
    items      = relationship("VentaItem", back_populates="venta", cascade="all, delete")

class VentaItem(Base):
    __tablename__ = "venta_items"

    id          = Column(Integer, primary_key=True, index=True)
    venta_id    = Column(Integer, ForeignKey("ventas.id"))
    producto_id = Column(Integer, ForeignKey("productos.id"))
    nombre      = Column(String(100))   # snapshot del nombre al momento de venta
    precio      = Column(Float)
    cantidad    = Column(Integer)
    subtotal    = Column(Float)

    venta       = relationship("Venta",    back_populates="items")
    producto    = relationship("Producto")