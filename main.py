from datetime import datetime
from fastapi import FastAPI, Depends, Query, Path, HTTPException
from sqlalchemy.orm import Session
from models.constants import Message
from models.item import Item, ItemOut, ItemDB
from http import HTTPStatus
from typing import List, Annotated
from auth import app as auth_app, User, get_current_active_user
from database import SessionLocal

app = FastAPI()


# Database Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/")
def read_root():
    return {"Hello": "World"}


async def common_parameters(
    q: str | None = Query(..., description="Query string"),
    item_id: int = Path(..., description="The ID of the item to get"),
):
    return {"q": q, "item_id": item_id}


@app.get(
    "/items/{item_id}",
    response_model=ItemOut,
    response_model_exclude_none=True,
    response_model_exclude_unset=True,
    responses={
        HTTPStatus.NOT_FOUND: {"model": Message, "description": "Item not found"},
        HTTPStatus.INTERNAL_SERVER_ERROR: {
            "model": Message,
            "description": "Internal Server Error",
        },
    },
    summary="Get Item",
    description="Get item details for a product",
)
async def read_item(
    params: dict = Depends(common_parameters),
    db: Session = Depends(get_db)
):
    item = db.query(ItemDB).filter(ItemDB.id == params["item_id"]).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    
    return ItemOut(
        name=item.name,
        price=item.price,
        description=item.description,
        created_at=datetime.now(),
    )


@app.get(
    "/items_list/{item_id}",
    dependencies=[Depends(common_parameters)],
    response_model=List[ItemOut],
)
async def read_item_list(
    params: dict = Depends(common_parameters),
    db: Session = Depends(get_db)
):
    items = db.query(ItemDB).all()
    return [
        ItemOut(
            name=item.name,
            price=item.price,
            description=item.description,
            created_at=datetime.now(),
        )
        for item in items
    ]


@app.post(
    "/items",
    response_model=ItemOut,
    response_model_exclude_none=True,
    response_model_exclude_unset=True,
    responses={
        HTTPStatus.INTERNAL_SERVER_ERROR: {
            "model": Message,
            "description": "Internal Server Error",
        },
    },
    summary="Create Item",
    description="Create item details for a product",
)
async def create_item(
    item: Item,
    current_user: Annotated[User, Depends(get_current_active_user)],
    db: Session = Depends(get_db),
):
    _ = current_user
    db_item = ItemDB(
        name=item.name,
        price=item.price,
        description=item.description,
        id=1
    )
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    
    return ItemOut(
        name=db_item.name,
        price=db_item.price,
        description=db_item.description,
        created_at=datetime.now(),
    )


app.include_router(auth_app)
