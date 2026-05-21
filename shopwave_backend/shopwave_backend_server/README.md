# shopwave_backend_server

This is the starting point for your Serverpod server.

To run your server, you first need to start Postgres and Redis. It's easiest to do with Docker.

    docker compose up --build --detach

Then you can start the Serverpod server.

    dart bin/main.dart

When you are finished, you can shut down Serverpod with `Ctrl-C`, then stop Postgres and Redis.

    docker compose stop


--on loginroute:


// in the user model, we do need the password field, right?
// No — and you should actively avoid it. The serverpod_auth_idp_server package stores hashed passwords in its own internal IDP tables (separate from your user table). When emailIdp.login() is called, it validates the password against those tables automatically.

// Adding password to your User model would mean:

// You'd have to hash it yourself (duplicating what the IDP already does)
// Passwords would exist in two places, doubling the attack surface
// The IDP and your table could get out of sync
// Your User model only needs application-level profile data — name and email are the right fields. Credentials are entirely owned by the IDP.

Here's the curl request:


curl -X POST http://localhost:8082/login \
  -H "Content-Type: application/json" \
  -d '{"email": "john@example.com", "password": "yourpassword"}'
Expected success response (200):


{
  "id": 1,
  "name": "John Doe",
  "email": "user@example.com",
  "token": "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9..."
}
Error responses:

400 — missing/invalid fields
401 — wrong credentials (invalidCredentials) or user not found
500 — unexpected server error

-- on sign-up
curl -X POST http://localhost:8082/sign_up \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com", "password": "yourpassword"}'
Success 200:


{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "token": "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9..."
}
Email already registered 409:


{ "error": "Email already registered" }
Missing fields 400:


{ "error": "name, email and password are required" }
Invalid email 400:


{ "error": "Invalid email address" }
Make sure the route is registered in your server's main.dart — something like webServer.addRoute(SignUpRoute(), '/sign_up').


The logout flow:

Extracts the JWT from the Authorization: Bearer header
Validates it — if already expired or invalid, returns 401
Revokes that specific token ID so it can't be used again — even if it hasn't expired yet



# GET all orders for the logged-in user
curl http://localhost:8082/orders \
  -H "Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJkZXYuc2VydmVycG9kLnJlZnJlc2hUb2tlbklkIjoiMDE5ZTJmNDUtODdmMy03MzcwLTkwN2YtODI0MGVhNTNkMjJlIiwiaWF0IjoxNzc4OTA5NTQ2LCJleHAiOjE3Nzg5MTAxNDYsInN1YiI6IjAxOWUyYjFjLTQyMjEtNzc3MS1hNzQzLTZmZTM5OWU0ZGI1ZCIsImp0aSI6IjM4NTQ4Y2JlLTkxY2QtNDA2OS1iNDFjLTRjMTk3NWMwYmY4MyJ9.enPZ8pdr0Zh4x5Uq2QTb5LYouidgBigY6zWpIpqSt0hdiPIdJzeNBB5kV-MOia3vCDJwXEv_SiIdQHal2tfBDQ"

# GET a specific order by id
curl http://localhost:8082/orders/1 \
  -H "Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJkZXYuc2VydmVycG9kLnJlZnJlc2hUb2tlbklkIjoiMDE5ZTJjYzAtZTk2NC03MTkwLTlhMjEtM2QxMTA2NzE2OTMyIiwiaWF0IjoxNzc4ODY3MzAwLCJleHAiOjE3Nzg4Njc5MDAsInN1YiI6IjAxOWUyYjFjLTQyMjEtNzc3MS1hNzQzLTZmZTM5OWU0ZGI1ZCIsImp0aSI6IjRmMjMxZjgwLTBjODctNDQ5My04MmUxLWM1MGMzMjEyOWVkZiJ9.P3TQbnPw7Uv6nWl9RNuD2gtkKLID3ZsPR_VizRbzL8Fpjj0KK9LyBLMxKKHKsyquQRon4MbTG4SB6O2VobuSiQ"

# POST create an order (checkout)
curl -X POST http://localhost:8082/orders \
  -H "Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJkZXYuc2VydmVycG9kLnJlZnJlc2hUb2tlbklkIjoiMDE5ZTJjYzAtZTk2NC03MTkwLTlhMjEtM2QxMTA2NzE2OTMyIiwiaWF0IjoxNzc4ODY3MzAwLCJleHAiOjE3Nzg4Njc5MDAsInN1YiI6IjAxOWUyYjFjLTQyMjEtNzc3MS1hNzQzLTZmZTM5OWU0ZGI1ZCIsImp0aSI6IjRmMjMxZjgwLTBjODctNDQ5My04MmUxLWM1MGMzMjEyOWVkZiJ9.P3TQbnPw7Uv6nWl9RNuD2gtkKLID3ZsPR_VizRbzL8Fpjj0KK9LyBLMxKKHKsyquQRon4MbTG4SB6O2VobuSiQ" \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {
        "productId": 1,
        "productName": "Laptop",
        "quantity": 1,
        "priceAtPurchase": 999.99
      },
      {
        "productId": 2,
        "productName": "Mouse",
        "quantity": 2,
        "priceAtPurchase": 29.99
      }
    ],
    "total": 1059.97
  }'