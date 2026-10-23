# Events and Venues REST API

## Endpoints

| # | Method | Endpoint | Auth |
|---|---|---|---|
| 1 | GET | /events | public |
| 2 | GET | /events/{id} | public |
| 3 | POST | /events | public |
| 4 | PUT | /events/{id} | public |
| 5 | DELETE | /events/{id} | Bearer token |
| 6 | GET | /venues | public |
| 7 | GET | /venues/{id} | public |
| 8 | POST | /venues | public |
| 9 | PUT | /venues/{id} | public |
| 10 | DELETE | /venues/{id} | Bearer token |

## How to Run

Prerequisites: PHP with `pdo_mysql`, MySQL server, and cURL. Ensure MySQL is running before starting.

### Step 1: Initialize the Database

From the **`phpProject/`** directory, ensure MySQL is running:

**sudo service mysql start**

Create the project database and import the initial schema:

```bash
sudo mysql < code/schema.sql
```

This app uses MySQL user 'ase230'. If it does not exist already, create it and grant it access with:

```bash
sudo mysql -e "CREATE USER IF NOT EXISTS 'ase230'@'localhost' IDENTIFIED BY 'ase230pass'; GRANT ALL PRIVILEGES ON eventdb.* TO 'ase230'@'localhost';"
```

> [!NOTE]
> `code/schema.sql` creates 'eventdb' database, 'events' and 'venues' tables.
> It does not insert any sample records.

### Step 2: Start the PHP Server

From the **`phpProject/`** directory:

```bash
cd code

php -S localhost:8000

```

The API is now running at `http://localhost:8000/`. Keep this terminal open while running tests.

### Step 3: Run Tests

In a **second terminal window**, from the **`phpProject/`** directory:

- **Automated cURL Tests**:
  ```bash
  bash code/test_curl.sh
  ```
- **Browser Test Client**:
  Open the following address in your browser:
  ```text
  http://localhost:8000/test_client.html
  ```
  > [!WARNING]
  > **Never** open `test_client.html` directly from your operating system file manager (`file:///...`). Browser security blocks API requests from local file URLs. Always access it through `http://localhost:8000/test_client.html` while the server is running.

### Step 4: Stop the Server

When finished testing, return to the first terminal where the PHP server is running and press **`Ctrl+C`**.

## References

### Course Materials

| Section | PDF | Page/Pages |
|---|---|---|
| REST API | 2. Building REST API Server with PHP and JSON.pdf | 15-16, 33 |
| REST API | 3. Connecting REST API Server to MySQL with PDO.pdf | 11, 15, 20 |
| REST API | 4. Testing REST API Server.pdf | 8, 25 |
| Frontend with JavaScript | 1. Frontend with JavaScript.pdf | 38-39, 45 |
| Security / Basics | 3. Bearer Token Authentication.pdf | 9-11 |
| Web Server Using NGINX | 2. Setting up NGINX for PHP.pdf | 16, 19 |

| Section | Code File |
|---|---|
| RESTAPI | /api/index.php |
| RESTAPI | /api/database.php |
| RESTAPI | /api/handlers_pdo.php |
| RESTAPI | /api/student_api_test.html |
| RESTAPI | /api_tests/curl/test_runner_curl.sh |
| Security / Basics | /bearer/bearer_auth.php |
| Webserver Using NGINX | /nginx.conf |
| Project 1 | /project1_overview.md |
| Project 1 | /submission_example/code/test_client.html |
| Project 1 | /submission_example/README.md |

### AI Assistance

ChatGPT was used to explain concepts, debug issues in code, and troubleshoot MySQL and NGINX configuration. For example helping identify a JavaScript function issue regarding the already existing 'createEvent()' function and NGINX configuration.

---
