import fastapi
from fastapi import status, HTTPException
import sympy
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import requests
from requests.exceptions import RequestException

app = fastapi.FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

class Armstrong(BaseModel):
    number: int
    is_prime: bool
    is_perfect: bool
    properties: list
    digit_sum: int
    fun_fact: str

def split_integer(n: int):
    digits = []
    while n > 0:
        digit = n % 10
        digits.append(digit)
        n //= 10
    return digits[::-1]

def check_perfect(n: int):
    divisor_sum = 0
    counter = 1
    while counter < n:
        if n % counter == 0:
            divisor_sum += counter
        counter += 1
    return n == divisor_sum

def check_armstrong(n: int):
    armstrong = 0
    armstrong_property = ""
    no = split_integer(n)
    for digit in no:
        armstrong += digit**len(no)
    if armstrong == n:
        armstrong_property = "armstrong"
    return armstrong_property

def check_even_or_odd(n: int):
    even_or_odd_property = ""
    if n % 2 != 0:
        even_or_odd_property = "odd"
    else:
        even_or_odd_property = "even"
    return even_or_odd_property

def assign_property(n: int):
    property_list = []
    if check_armstrong(n) == "armstrong":
        property_list = ["armstrong", check_even_or_odd(n)]
    else:
        property_list = [check_even_or_odd(n)]
    return property_list

def add_digits(n: int):
    digit_list = split_integer(n)
    digit_sum = 0
    for digit in digit_list:
        digit_sum += digit
    return digit_sum

@app.get("/api/classify-number", response_model=Armstrong, status_code=status.HTTP_200_OK)
def display_armstrong_facts(number: int):
    fun_fact = ""
    try:
        api_url = f"http://numbersapi.com/{number}/math"
        response = requests.get(api_url, timeout=5)
        response.raise_for_status()
        fun_fact = response.text
    except RequestException as e:
        print(f"Error fetching fun fact: {e}") # Log the error (optional)
        fun_fact = "Could not retrieve fun fact at this time."
    except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={
                    "number": "alphabet",
                    "error": True
                }
        )
    return {
            "number": number,
            "is_prime": sympy.isprime(number),
            "is_perfect": check_perfect(number),
            "properties": assign_property(number),
            "digit_sum": add_digits(number),
            "fun_fact": fun_fact
        }