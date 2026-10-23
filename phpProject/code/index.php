<?php

declare(strict_types=1);

require_once __DIR__ . "/db.php";
require_once __DIR__ . "/auth.php";

header('Content-Type: application/json');

$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$path = trim($path, '/');
$segments = explode('/', $path);
$resource = $segments[0] ?? '';
$id = $segments[1] ?? null;

// GET /events
if ($method === 'GET' && $resource === 'events' && $id === null) {
    $pdo = get_db();

    $sql = "SELECT * FROM events";

    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    $events = $stmt->fetchAll();

    echo json_encode($events, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

    exit;
}


// GET /events/{id}
if ($method === 'GET' && $resource === 'events' && $id !== null) {

    if (!ctype_digit($id)) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid event ID']);
        exit;
    }

    $pdo = get_db();

    $sql = "SELECT * FROM events WHERE id = :id";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([':id' => (int)$id]);

    $event = $stmt->fetch();

    if (!$event) {
        http_response_code(404);
        echo json_encode(['error' => 'Event not found']);
        exit;
    }

    echo json_encode($event, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

    exit;
}

// POST /events
if ($method === 'POST' && $resource === 'events' && $id === null) {
    $rawBody = file_get_contents('php://input');
    $data = json_decode($rawBody, true);

    if (!is_array($data)) {
        http_response_code(400);
        echo json_encode([
            'error' => 'Invalid request body data'
        ]);

        exit;
    }

    
    foreach (['name', 'description', 'event_date', 'venue_id'] as $field) {
        if (!array_key_exists($field, $data)) {
            http_response_code(400);
            echo json_encode(['error' => "$field is required"]);
            exit;
        }
    }

    if (!is_string($data['name']) || trim($data['name']) === '' ||
        !is_string($data['description']) ||
        !is_string($data['event_date']) || trim($data['event_date']) === '' ||
        !is_int($data['venue_id']) || $data['venue_id'] < 1) {

        http_response_code(400);
        echo json_encode(['error' => 'Invalid event data']);
        exit;
    }


    $pdo = get_db();

    $sql = "INSERT INTO events
            (name, description, event_date, venue_id)
            VALUES (:name, :description, :event_date, :venue_id)";

    $stmt = $pdo->prepare($sql);

    $stmt->execute([
        ':name' => $data['name'],
        ':description' => $data['description'],
        ':event_date' => $data['event_date'],
        ':venue_id' => $data['venue_id']
    ]);

    $eventId = (int) $pdo->lastInsertId();

    http_response_code(201);
    echo json_encode([
        'id' => $eventId,
        'message' => 'Event created'
    ]);

    exit;
}



 // PUT /events/{id}
if ($method === 'PUT' && $resource === 'events' && $id !== null) {

    if (!ctype_digit($id)) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid event ID']);
        exit;
    }

    $rawBody = file_get_contents('php://input');
    $data = json_decode($rawBody, true);

    if (!is_array($data)) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid request body data']);
        exit;
    }

    foreach (['name', 'description', 'event_date', 'venue_id'] as $field) {
        if (!array_key_exists($field, $data)) {
            http_response_code(400);
            echo json_encode(['error' => "$field is required"]);
            exit;
        }
    }

    if (!is_string($data['name']) || trim($data['name']) === '' ||
        !is_string($data['description']) ||
        !is_string($data['event_date']) || trim($data['event_date']) === '' ||
        !is_int($data['venue_id']) || $data['venue_id'] < 1) {

        http_response_code(400);
        echo json_encode(['error' => 'Invalid event data']);
        exit;
    }

    $pdo = get_db();

    $sql = "UPDATE events
            SET name = :name,
                description = :description,
                event_date = :event_date,
                venue_id = :venue_id
            WHERE id = :id";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        ':id' => (int)$id,
        ':name' => trim($data['name']),
        ':description' => $data['description'],
        ':event_date' => $data['event_date'],
        ':venue_id' => $data['venue_id']
    ]);

    $stmt = $pdo->prepare("SELECT * FROM events WHERE id = :id");
    $stmt->execute([':id' => (int)$id]);

    $event = $stmt->fetch();

    if (!$event) {
        http_response_code(404);
        echo json_encode(['error' => 'Event not found']);
        exit;
    }

    echo json_encode($event, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    exit;
}


// DELETE /events/{id}
if ($method === 'DELETE' && $resource === 'events' && $id !== null) {

    requireAuth();

    if (!ctype_digit($id)) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid event ID']);
        exit;
    }

    $pdo = get_db();

    $stmt = $pdo->prepare("SELECT * FROM events WHERE id = :id");
    $stmt->execute([':id' => (int)$id]);

    $event = $stmt->fetch();

    if (!$event) {
        http_response_code(404);
        echo json_encode(['error' => 'Event not found']);
        exit;
    }

    $stmt = $pdo->prepare("DELETE FROM events WHERE id = :id");
    $stmt->execute([':id' => (int)$id]);

    echo json_encode([
        'message' => 'Event deleted successfully'
    ]);

    exit;
}


// GET /venues
if ($method === 'GET' && $resource === 'venues' && $id === null) {

    $pdo = get_db();

    $sql = "SELECT * FROM venues";

    $stmt = $pdo->prepare($sql);
    $stmt->execute();

    $venues = $stmt->fetchAll();

    echo json_encode($venues, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

    exit;
}


// GET /venues/{id}
if ($method === 'GET' && $resource === 'venues' && $id !== null) {

    if (!ctype_digit($id)) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid venue ID']);
        exit;
    }

    $pdo = get_db();

    $sql = "SELECT * FROM venues WHERE id = :id";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([':id' => (int)$id]);

    $venue = $stmt->fetch();

    if (!$venue) {
        http_response_code(404);
        echo json_encode(['error' => 'Venue not found']);
        exit;
    }

    echo json_encode($venue, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

    exit;
}


// POST /venues
if ($method === 'POST' && $resource === 'venues' && $id === null) {

    $rawBody = file_get_contents('php://input');
    $data = json_decode($rawBody, true);

    if (!is_array($data)) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid request body data']);
        exit;
    }

    foreach (['name', 'address', 'capacity'] as $field) {
        if (!array_key_exists($field, $data)) {
            http_response_code(400);
            echo json_encode(['error' => "$field is required"]);
            exit;
        }
    }

    if (!is_string($data['name']) || trim($data['name']) === '' ||
        !is_string($data['address']) || trim($data['address']) === '' ||
        !is_int($data['capacity']) || $data['capacity'] < 1) {

        http_response_code(400);
        echo json_encode(['error' => 'Invalid venue data']);
        exit;
    }

    $pdo = get_db();

    $sql = "INSERT INTO venues
            (name, address, capacity)
            VALUES (:name, :address, :capacity)";

    $stmt = $pdo->prepare($sql);

    $stmt->execute([
        ':name' => trim($data['name']),
        ':address' => trim($data['address']),
        ':capacity' => $data['capacity']
    ]);

    $venueId = (int) $pdo->lastInsertId();

    http_response_code(201);
    echo json_encode([
        'id' => $venueId,
        'message' => 'Venue created'
    ]);

    exit;
}


// PUT /venues/{id}
if ($method === 'PUT' && $resource === 'venues' && $id !== null) {

    if (!ctype_digit($id)) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid venue ID']);
        exit;
    }

    $rawBody = file_get_contents('php://input');
    $data = json_decode($rawBody, true);

    if (!is_array($data)) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid request body data']);
        exit;
    }

    foreach (['name', 'address', 'capacity'] as $field) {
        if (!array_key_exists($field, $data)) {
            http_response_code(400);
            echo json_encode(['error' => "$field is required"]);
            exit;
        }
    }

    if (!is_string($data['name']) || trim($data['name']) === '' ||
        !is_string($data['address']) || trim($data['address']) === '' ||
        !is_int($data['capacity']) || $data['capacity'] < 1) {

        http_response_code(400);
        echo json_encode(['error' => 'Invalid venue data']);
        exit;
    }

    $pdo = get_db();

    $sql = "UPDATE venues
            SET name = :name,
                address = :address,
                capacity = :capacity
            WHERE id = :id";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        ':id' => (int)$id,
        ':name' => trim($data['name']),
        ':address' => trim($data['address']),
        ':capacity' => $data['capacity']
    ]);

    $stmt = $pdo->prepare("SELECT * FROM venues WHERE id = :id");
    $stmt->execute([':id' => (int)$id]);

    $venue = $stmt->fetch();

    if (!$venue) {
        http_response_code(404);
        echo json_encode(['error' => 'Venue not found']);
        exit;
    }

    echo json_encode($venue, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    exit;
}



// DELETE /venues/{id}
if ($method === 'DELETE' && $resource === 'venues' && $id !== null) {

    requireAuth();

    if (!ctype_digit($id)) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid venue ID']);
        exit;
    }

    $pdo = get_db();

    $stmt = $pdo->prepare("SELECT * FROM venues WHERE id = :id");
    $stmt->execute([':id' => (int)$id]);

    $venue = $stmt->fetch();

    if (!$venue) {
        http_response_code(404);
        echo json_encode(['error' => 'Venue not found']);
        exit;
    }

    $stmt = $pdo->prepare("DELETE FROM venues WHERE id = :id");
    $stmt->execute([':id' => (int)$id]);

    echo json_encode([
        'message' => 'Venue deleted successfully'
    ]);

    exit;
}


http_response_code(404);
echo json_encode(['error' => 'Not Found'
]);