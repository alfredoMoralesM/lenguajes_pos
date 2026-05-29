from fastapi import APIRouter, HTTPException, Body
from pydantic import BaseModel

router = APIRouter()

# Credenciales del administrador (en producción usa variables de entorno + hash)
ADMIN_USER = "admin"
ADMIN_PASSWORD = "pos2026"

class LoginRequest(BaseModel):
    usuario: str
    password: str

class LoginResponse(BaseModel):
    token: str
    mensaje: str

@router.post("/login", response_model=LoginResponse)
def login(data: LoginRequest):
    if data.usuario == ADMIN_USER and data.password == ADMIN_PASSWORD:
        return {"token": "pos-admin-token-seguro", "mensaje": "Bienvenido"}
    raise HTTPException(status_code=401, detail="Credenciales incorrectas")