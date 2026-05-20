from sqlalchemy import Column, Integer, String, Float
from app.database.connection import Base

class Producto(Base):
    __tablename__ = "productos"

    id       = Column(Integer, primary_key=True, index=True)
    nombre   = Column(String(100), nullable=False)   # FIX: longitud + not null
    precio   = Column(Float,       nullable=False)   # FIX: not null
    stock    = Column(Integer,     nullable=False, default=0)  # FIX: default 0
    categoria = Column(String(50), nullable=False)  # FIX: longitud + not null