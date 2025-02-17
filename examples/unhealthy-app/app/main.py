"""The entrypoint for the app"""

import logging
import random
import os
import uvicorn
from fastapi import FastAPI, HTTPException, Request, Query
from fastapi.responses import JSONResponse

# Configure logging with a format suitable for IT operations environments
logging.basicConfig(
    level=logging.ERROR,
    format="%(asctime)s - %(levelname)s - [%(module)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[logging.FileHandler("ecommerce_error_logs.log"), logging.StreamHandler()],
)

app = FastAPI()


def generate_random_user_id():
    """Helper function to simulate user and order data"""
    return random.randint(1000, 9999)


@app.post("/unhealthy-app/product/{product_id}")
async def get_product(product_id: int):
    """Endpoint 1: Simulate Product Not Found Error"""
    if product_id % 2 == 0:  # Simulate "not found" for even product IDs
        error_message = f"ProductNotFoundError: Product with ID {product_id} does not exist in the inventory database."
        logging.error(error_message)
        raise HTTPException(status_code=404, detail=error_message)
    return {"product_id": product_id, "name": "Sample Product", "price": 99.99}


@app.post("/unhealthy-app/checkout")
async def checkout(order_id: int = Query(...), payment_method: str = Query(...)):
    """Endpoint 2: Simulate Checkout Error (e.g., Payment Failure)"""
    if payment_method not in ["credit_card", "paypal"]:
        error_message = f"UnsupportedPaymentMethodError: Payment method '{payment_method}' is not supported. Supported methods are 'credit_card' and 'paypal'."
        logging.error(error_message)
        raise HTTPException(status_code=400, detail=error_message)
    if order_id % 5 == 0:  # Simulate a failed payment for every fifth order ID
        error_message = f"PaymentProcessingError: Payment gateway timeout while processing Order ID {order_id}."
        logging.error(error_message)
        raise HTTPException(status_code=500, detail=error_message)
    return {"order_id": order_id, "status": "success", "payment_method": payment_method}


@app.post("/unhealthy-app/fulfill-order")
async def fulfill_order(order_id: int):
    """Endpoint 3: Simulate Internal Server Error During Order Fulfillment"""
    if order_id % 3 == 0:  # Simulate errors for every third order ID
        error_message = f"OrderFulfillmentError: Unable to allocate inventory for Order ID {order_id}. Possible stock inconsistency."
        logging.error(error_message)
        raise HTTPException(status_code=500, detail=error_message)
    return {"order_id": order_id, "status": "fulfilled"}


@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception):
    """Generic custom exception handler for all errors"""
    if isinstance(exc, HTTPException):
        logging.error("[HTTP Exception] URL: %s | Detail: %s", request.url, exc.detail)
        return JSONResponse(
            status_code=exc.status_code,
            content={"error": exc.detail},
        )

    # Handle generic exceptions (unexpected errors)
    error_message = f"UnhandledExceptionError: An unexpected error occurred at {request.url}. Exception details: {str(exc)}"
    logging.error(error_message)
    return JSONResponse(
        status_code=500,
        content={"error": "An unexpected error occurred. Please contact support."},
    )


if __name__ == "__main__":
    env = os.environ.get("ENV", "production")
    uvicorn.run("main:app", host="0.0.0.0", port=5001, reload=env == "development")
