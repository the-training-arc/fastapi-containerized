from datetime import datetime
from typing import Optional

from pydantic import BaseModel
from sqlalchemy import Float, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from models.base import Base


class Item(BaseModel):
    name: str
    price: float
    description: Optional[str] = None


class ItemOut(Item):
    created_at: datetime


class ItemDB(Base):
    __tablename__ = 'item'

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String, nullable=False)
    price: Mapped[float] = mapped_column(Float, nullable=False)
    description: Mapped[str] = mapped_column(String, nullable=True)
