from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database.connection import engine, Base
from app.routers import productos_router, ventas_router, auth_router

# Importar modelos para que SQLAlchemy los registre antes de create_all
import app.models.producto_model  # noqa
import app.models.venta_model      # noqa

app = FastAPI(title="POS API", version="2.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Crear todas las tablas
Base.metadata.create_all(bind=engine)

PREFIX = "/api/v1"
app.include_router(auth_router.router,      prefix=PREFIX, tags=["Auth"])
app.include_router(productos_router.router, prefix=PREFIX, tags=["Productos"])
app.include_router(ventas_router.router,    prefix=PREFIX, tags=["Ventas"])

@app.get("/")
def root():
    return {"mensaje": "POS API v2 funcionando"}