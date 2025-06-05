### **𝗙𝗮𝘀𝘁𝗔𝗣𝗜 𝟭𝟬𝟭: 𝗕𝘂𝗶𝗹𝗱𝗶𝗻𝗴 𝗔𝗴𝗶𝗹𝗲 𝗔𝗣𝗜𝘀 𝗳𝗼𝗿 𝗠𝗼𝗱𝗲𝗿𝗻 𝗧𝗲𝗮𝗺 𝗦𝘂𝗰𝗰𝗲𝘀𝘀**
---
#### **What is FastAPI?**

- FastAPI is a modern, high-performance web framework for building APIs. It is built on top of **Starlette** for the web server and **Pydantic** for data validation.
- It supports asynchronous programming via `asyncio` and provides automatic validation and interactive documentation with OpenAPI standards.

#### **Why Use FastAPI?**

- **Fast Development:** Write less code with built-in tools for validation and documentation.
- **Developer-Friendly:** Designed for ease of use, with clear error messages and a powerful IDE experience.
- **Standards-Based:** Ensures compatibility with OpenAPI and JSON Schema.

---

### **0. Setting Up the Environment** 
#### For the complete code:
``` bash
git checkout 0-initialization
```
#### **Prerequisites:**

- Python 3.12 or higher installed.
- Basic knowledge of Python programming.
- A `git` client installed to clone repositories.

#### **Steps:**

1. Fork the provided workshop repository on GitHub to your account.
2. Clone the forked repository:
    
    ```bash
    git clone https://github.com/{github_username}/fastapi-workshop
    ```
    
3. Change into the project directory:
    
    ```bash
    cd fastapi-workshop
    ```
    
4. Create a Python virtual environment for the project:
    
    ```bash
    python3.12 -m venv env
    source env/bin/activate
    ```
    
5. Install the required dependencies:
    
    ```bash
    pip install -r requirements.txt
    ```
    

---

### **1. Hello World with FastAPI**
#### For the complete code:
``` bash
git checkout 1-first-fastapi
```
#### **Explanation:**

This step introduces creating and running a simple API endpoint in FastAPI. The `@app.get("/")` decorator is used to define a route, and FastAPI handles the HTTP request and response.

#### **Code Example:**

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def read_root():
    return {"message": "Hello, World!"}
```

#### **Running the Application:**

- Start the server using the following command:
    
    ```bash
    fastapi dev
    ```
    
- Access the application in your browser at `http://127.0.0.1:8000`.

#### **Interactive Documentation:**

- Swagger UI: `http://127.0.0.1:8000/docs`
- ReDoc: `http://127.0.0.1:8000/redoc`

---

### **2. Path and Query Parameters**
#### For the complete code:
``` bash
git checkout 2-path-parameters-and-query-parameters
```
#### **Explanation:**

FastAPI allows you to define dynamic paths and query parameters for your endpoints. Path parameters are defined in the route, while query parameters are passed after the `?` in the URL.

#### **Code Example:**

```python
@app.get("/items/{item_id}")
async def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "q": q}
```

- Path Parameter: `{item_id}` is dynamically replaced with the actual value in the URL.
- Query Parameter: `q` is optional and accessed with `?q=value`.

#### **Access Example:**

- `http://127.0.0.1:8000/items/42?q=test`

---

### **3. Request Body and Validation**
#### For the complete code:
``` bash
git checkout 3-request-body-and-validation
```
#### **Explanation:**

Pydantic models are used to define the expected structure of the request body, allowing FastAPI to validate input data automatically.

#### **Code Example:**

```python
from pydantic import BaseModel

class Item(BaseModel):
    name: str
    price: float
    description: str = None

@app.post("/items/")
async def create_item(item: Item):
    return item
```

- The `Item` model ensures all input data matches the defined structure.

#### **Validation Example:**
- Sending invalid data (e.g., an int for `description`) will result in an automatically generated validation error. 
	![[Pasted image 20241123100116.png]]
	![[Pasted image 20241123100124.png]]

---

### **4. Advanced Validation and Documentation**
#### For the complete code:
``` bash
git checkout 4-validation-documentation-enhanements
```
#### **Explanation:**

FastAPI provides options for customizing OpenAPI documentation based on the type hints and parameter configurations like `response_model`, `summary`, and `description`.
#### **Documentation Enhancements:**
- Add a `summary` for a concise route description.
- Use `description` to provide detailed information.
- Add a `response_model` to define the expected response structure.
    - To do this, we need to define a Pydantic model for the expected response.
    - We can inherit from the `Item` model to avoid repeating the fields.
    - **Code Example**
        ``` python
        from datetime import datetime
        from pydantic import BaseModel
        from typing import Optional

        class Item(BaseModel):
            name: str
            price: float
            description: Optional[str] = None

        class ItemOut(Item):
            created_at: datetime
        ```
- Use `response_model_exclude_none` and `response_model_exclude_unset` to exclude fields with `None` or `unset` values.
- Use `responses` to define custom error responses.

#### **Code Example:**

```python
@app.post(
    "/items",
    response_model=ItemOut,
    response_model_exclude_none=True,
    response_model_exclude_unset=True,
    responses={
        HTTPStatus.INTERNAL_SERVER_ERROR: {"model": Message, "description": "Internal Server Error"},
    },
    summary="Create Item",
    description="Create item details for a product",
)
async def create_item(
    item: Item,
):
    response = ItemOut(
        **item.model_dump(),
        created_at=datetime.now(),
    )
    return response

```

---
### **5. Dependency Injection**

#### **Explanation:**
Dependencies in FastAPI allow you to define shared logic that can be injected into multiple routes, promoting reusability and cleaner code.
- Without using `Depends()`, the code would have to replicate the common logic in each endpoint.
    #### **Code Example without Depends:**
    ```python
    from fastapi import FastAPI

    app = FastAPI()

    async def common_parameters(q: str = None):
        return {"q": q}

    @app.get("/items/")
    async def read_items(q: str = None):
        commons = await common_parameters(q)
        return commons

    @app.get("/users/")
    async def read_users(q: str = None):
        commons = await common_parameters(q)
        return commons
    ```
- Dependencies are handled mainly with the special function `Depends()` that takes a callable.
    #### **Code Example with Depends:**
    ```python
    from typing import Annotated

    from fastapi import Depends, FastAPI

    app = FastAPI()


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
        async def read_item(params: dict = Depends(common_parameters)):
            print(params)
            return ItemOut(
                name=str(params["item_id"]),
                price=100,
                description=params["q"],
                created_at=datetime.now(),
            )


    @app.get(
        "/items_list/{item_id}",
        dependencies=[Depends(common_parameters)],
        response_model=List[ItemOut],
    )
    async def read_item_list(params: dict = Depends(common_parameters)):
        return [
            ItemOut(
                name=str(params["item_id"]),
                price=100,
                description=params["q"],
                created_at=datetime.now(),
            )
        ]
    ```
- FastAPI will also handle the OpenAPI documentation for dependencies.
    ![[Pasted image 20241123110905.png]]
- For more information, check the [official documentation](https://fastapi.tiangolo.com/tutorial/dependencies/#create-a-dependency-or-dependable).

---

### **6. Authentication and Security**

#### **Explanation:**

The provided code snippet illustrates how to implement authentication and security in a FastAPI application using OAuth2 and JWT. It includes the following key components:

1. **User Models**:
   - `User` and `UserInDB` models are defined using Pydantic to represent user data, with `UserInDB` including a hashed password.

2. **Password Management**:
   - Passwords are hashed using `passlib`'s `CryptContext` to ensure secure storage and verification.

3. **OAuth2 and JWT Setup**:
   - `OAuth2PasswordBearer` is used to handle token-based authentication, with a token URL specified for obtaining tokens.
   - JWT tokens are created and verified using the `jwt` library, with a secret key and algorithm specified for encoding and decoding.

4. **Authentication Endpoints**:
   - The `/auth/token` endpoint allows users to log in by providing their username and password, returning a JWT token upon successful authentication.
   - The `/users/me/` and `/users/me/items/` endpoints demonstrate how to use dependencies to ensure that only authenticated and active users can access certain resources.

5. **Error Handling**:
   - The code includes error handling for invalid credentials and inactive users, returning appropriate HTTP status codes and messages.

This example provides a foundational approach to implementing authentication in FastAPI, suitable for development and testing purposes. For production, ensure the use of secure password hashing and proper JWT token management.

``` python
from datetime import datetime, timedelta, timezone
from typing import Annotated

import jwt
from fastapi import Depends, APIRouter, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jwt.exceptions import InvalidTokenError
from passlib.context import CryptContext
from pydantic import BaseModel

# to get a string like this run:
# openssl rand -hex 32
SECRET_KEY = "09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30


fake_users_db = {
    "johndoe": {
        "username": "johndoe",
        "full_name": "John Doe",
        "email": "johndoe@example.com",
        "hashed_password": "$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW",
        "disabled": False,
    }
}


class Token(BaseModel):
    access_token: str
    token_type: str


class TokenData(BaseModel):
    username: str | None = None


class User(BaseModel):
    username: str
    email: str | None = None
    full_name: str | None = None
    disabled: bool | None = None


class UserInDB(User):
    hashed_password: str


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/token")

app = APIRouter(prefix="/auth", tags=["auth"])


def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password):
    return pwd_context.hash(password)


def get_user(db, username: str):
    if username in db:
        user_dict = db[username]
        return UserInDB(**user_dict)


def authenticate_user(fake_db, username: str, password: str):
    user = get_user(fake_db, username)
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user


def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


async def get_current_user(token: Annotated[str, Depends(oauth2_scheme)]):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        token_data = TokenData(username=username)
    except InvalidTokenError:
        raise credentials_exception
    user = get_user(fake_users_db, username=token_data.username)
    if user is None:
        raise credentials_exception
    return user


async def get_current_active_user(
    current_user: Annotated[User, Depends(get_current_user)],
):
    if current_user.disabled:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user


@app.post("/token")
async def login_for_access_token(
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
) -> Token:
    user = authenticate_user(fake_users_db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return Token(access_token=access_token, token_type="bearer")


@app.get("/users/me/", response_model=User)
async def read_users_me(
    current_user: Annotated[User, Depends(get_current_active_user)],
):
    return current_user


@app.get("/users/me/items/")
async def read_own_items(
    current_user: Annotated[User, Depends(get_current_active_user)],
):
    return [{"item_id": "Foo", "owner": current_user.username}]

```

---

### **7. Deploying FastAPI Applications**

#### **Explanation:**

FastAPI apps can be deployed using ASGI servers like `uvicorn` or `gunicorn`. Containerization with Docker ensures portability and scalability.

#### **Dockerfile Example:**

```dockerfile
FROM python:3.12
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
```

#### **Run with Gunicorn:**

```bash
gunicorn -w 4 -k uvicorn.workers.UvicornWorker main:app
```

---
### **Conclusion**

- FastAPI simplifies API development with built-in validation, documentation, and support for modern development practices.
- Explore integrating databases, caching, and microservices for advanced use cases.