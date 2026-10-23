---
marp: true
theme: default
paginate: true
---

# Project 1: Events and Venues REST API
### API Tutorial

Student: Myles Locher
ASE 230

---

## What this API does

This is a REST API for managine events and their respective venues using PHP and MySQL.

10 endpoints total: 5 for `/events`, 5 for `/venues`. 2 of them
(the DELETE endpoints) require a Bearer token.

---

## Endpoints

| # | Method | Endpoint | Auth |
|---|---|---|---|
| 1 | GET | /events | none |
| 2 | GET | /events/{id} | none |
| 3 | POST | /events | none |
| 4 | PUT | /events/{id} | none |
| 5 | DELETE | /events/{id} | Bearer token |

---

## Endpoints (continued)

| # | Method | Endpoint | Auth |
|---|---|---|---|
| 6 | GET | /venues | none |
| 7 | GET | /venues/{id} | none |
| 8 | POST | /venues | none |
| 9 | PUT | /venues/{id} | none |
| 10 | DELETE | /venues/{id} | Bearer token |

---

## Database

Table: `events` — id, name, description, event_date, venue_id
Table: `venues` — id, name, address, capacity

See `code/schema.sql`.

---

## GET /events

Request:
```bash
curl http://localhost:8000/events
```

Response:
```json
[{"id":1,"name":"Career Fair","description":"Fall career fair","event_date":"2026-10-15 13:00:00","venue_id":1}]
```

---

## GET /events/{id}

Request:
```bash
curl http://localhost:8000/events/1
```

Response:
```json
{"id":1,"name":"Career Fair","description":"Fall career fair","event_date":"2026-10-15 13:00:00","venue_id":1}
```

Returns 404 if the event doesn't exist.

---

## POST /events

Request:
```bash
curl -X POST http://localhost:8000/events \
  -H "Content-Type: application/json" \
  -d '{"name":"NKU Fall Orientation","description":"Orientation for new students in the fall semester of 2027","event_date":"2027-08-21 08:00:00", "venue_id":1}'
```

Response:
```json
{"id":2,"message":"Event created"}
```

---

## PUT /events/{id}

Request:
```bash
curl -X PUT http://localhost:8000/events/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Career Fair","description":"Spring Career Fair","event_date":"2027-4-12 12:00:00","venue_id":1}'
```

Response (timestamps omitted for example):
```json
{
    "id": 1,
    "name": "Career Fair",
    "description": "Spring Career Fair",
    "event_date": "2027-04-12 12:00:00",
    "venue_id": 1
}
```

---

## DELETE /events/{id} (secured)

Needs a Bearer token in the Authorization header.

```bash
curl -X DELETE http://localhost:8000/events/2 \
  -H "Authorization: Bearer admin-demo-token"
```

Without a valid token, the server returns 401.

---

## GET /venues, GET /venues/{id}

These follow the same pattern as the events, only using the 'venues' table.

```bash
curl http://localhost:8000/venues
curl http://localhost:8000/venues/1
```

---

GET /venues/1 Example Response (timestamps omitted for example):
```json
{
  "id": 1,
  "name": "NKU Student Union",
  "address": "20 Kenton Drive, Highland Heights, KY",
  "capacity": 500
}
```

---

## POST /venues, PUT /venues/{id}

```bash
curl -X POST http://localhost:8000/venues \
  -H "Content-Type: application/json" \
  -d '{"name":"Myles Music Hall","address":"4756 Robinson Rd", "capacity":300}'

curl -X PUT http://localhost:8000/venues/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"NKU Auditorium","address":"200 Nunn Dr","capacity":1000}'
```

---

## POST /venues Response

```bash
{
  "id": 2,
  "message": "Venue created"
}
```

---

## PUT /venues{id} Response

```bash
{
  "id": 2,
  "name": "NKU Auditorium",
  "address": "200 Nunn Dr",
  "capacity": 1000
}
```

---

## DELETE /venues/{id} (secured)

Same Bearer token requirement as `DELETE /events/{id}`.

```bash
curl -X DELETE http://localhost:8000/venues/1 \
  -H "Authorization: Bearer admin-demo-token"
```

---

## Delete /venues/{id} Response

```bash
{
  "message": "Venue deleted successfully"
}
```

## How authentication works

Both DELETE endpoints are protected with `requireAuth()`.
`auth.php` uses `require Auth()` checks the `Authorization` header for `Bearer (admin-demo-token`).
If it doesn't match, is missing, or invalid the request is rejected with a 401 error before touching the database.

---

## Testing

Two testing methods:

- `code/test_curl.sh` — command line tests for all 10 endpoints
- `code/test_client.html` — browser test page for all 10 endpoints

---

# Thank you
