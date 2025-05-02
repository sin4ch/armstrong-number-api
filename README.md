# Number Classification API

## Description

This API takes an integer as input and returns various mathematical properties about it, including whether it's prime, perfect, or an Armstrong number, its parity (even/odd), the sum of its digits, and a fun mathematical fact fetched from the Numbers API.

## Features

* Checks if the number is prime.
* Checks if the number is a perfect number.
* Checks if the number is an Armstrong number.
* Determines if the number is even or odd.
* Calculates the sum of the number's digits.
* Retrieves a fun math-related fact about the number from `http://numbersapi.com`.

## Technology Stack

* Python 3.x
* FastAPI
* Uvicorn (for serving)
* Requests (for external API calls)
* SymPy (for primality test)

## API Endpoint

* **Method:** `GET`
* **URL:** `/api/classify-number`
* **Query Parameter:**
* `number` (integer, required): The number to classify.

## Request Example

```bash
curl "http://<domain_name>:8000/api/classify-number?number=371"
```

## Response Formats

### Success (200 OK)

Returns a JSON object with the calculated properties and fun fact.

```json
{
"number": 371,
"is_prime": false,
"is_perfect": false,
"properties": ["armstrong", "odd"],
"digit_sum": 11,
"fun_fact": "371 is an Armstrong number because 3^3 + 7^3 + 1^3 = 371"
}
```

### Bad Request (400 Bad Request)

Returned for specific invalid input types handled by the application logic.

```json
{
"number": "alphabet",
"error": true
}
```

> Note: FastAPI's built-in validation might return a 422 Unprocessable Entity status code with a different error detail format for basic type mismatches, e.g., providing a string where an integer is expected.

## Setup and Installation (Local Development)

1.**Prerequisites:**
Python 3.8+

2.**Clone the repository:**

```bash
git clone <your-repository-url>
cd <repository-directory>
```

3.**Create and activate a virtual environment (recommended):**

* On Windows:

```bash
python -m venv venv
.\venv\Scripts\activate
```

* On macOS/Linux:

```bash
python3 -m venv venv
source venv/bin/activate
```

4.**Install dependencies:**

Run the installation command:

```bash
pip install -r requirements.txt
```

## Running Locally

Start the development server using Uvicorn:

```bash
uvicorn main:app --reload
```

The API will typically be available at `http://127.0.0.1:8000` or `http://localhost:8000`.

## Automated Deployment (AWS EC2 Example)

This repository includes a script (`deploy_api.sh`) to automate the deployment process on a fresh Ubuntu-based EC2 instance.

**Prerequisites for EC2 Instance:**

* An Ubuntu EC2 instance (tested with 22.04 LTS).
* Security Group allowing inbound traffic on ports 22 (SSH), 80 (HTTP), and 443 (HTTPS).
* Internet connectivity.

**Steps:**

1.**Connect to your EC2 instance via SSH.**

2.**Clone this repository:**

```bash
git clone https://github.com/sin4ch/number_classification_api.git
cd number_classification_api
```

3.**Make the script executable:**

```bash
chmod +x deploy_api.sh
```

4.**Run the script:** Provide the public IP address or domain name associated with your EC2 instance as an argument.

```bash
./deploy_api.sh <your_ec2_public_ip_or_domain>
```

Example:

```bash
./deploy_api.sh 54.123.45.67
# OR
./deploy_api.sh api.yourdomain.com
```

The script will perform the following actions:

* Update system packages.
* Install Git, Docker, and Nginx.
* Configure Docker permissions.
* Clone the latest code from the repository.
* Build the Docker image.
* Stop/remove any previous container instance.
* Run the new Docker container, mapping port 8000 internally.
* Configure Nginx as a reverse proxy to forward requests from port 80 to the container.
* Enable the Nginx site and restart Nginx.

After the script completes, the API should be accessible via the public IP or domain name provided.

**Note:** You might need to log out and log back into your SSH session after the script runs for Docker group permissions to apply correctly to your user if you plan to run further `docker` commands manually. For HTTPS, you will still need to run `certbot` manually after deployment.
