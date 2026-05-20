from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

DATABASE_URL = "sqlite:///./tienda.db"

engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False}  # Necesario solo para SQLite
)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

Base = declarative_base()


# Generador de sesión reutilizable con Depends() de FastAPI
def get_db():
    """
    Dependencia para inyectar la sesión de base de datos en los endpoints.
    Garantiza que la sesión siempre se cierre, incluso si hay un error.
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()