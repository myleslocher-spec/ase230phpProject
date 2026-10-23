
#!/bin/bash

API_BASE_URL="http://localhost:8000"

#Venues Tests

#Test GET /venues
echo "Testing GET /venues..."

response=$(curl -s -w "\n%{http_code}" "$API_BASE_URL/venues")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [[ "$http_code" == "200" ]] && echo "$body" | grep -q '^\['; then
    echo "PASS: GET /venues"
else
    echo "FAIL: GET /venues"
    echo "HTTP Status: $http_code"
    echo "Response: $body"
fi



#Test POST /venues
echo "Testing POST /venues..."

new_venue_json='{
    "name": "CURL Test Venue",
    "address": "123 Testing Street",
    "capacity": 100
}'

response=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d "$new_venue_json" \
    "$API_BASE_URL/venues")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [[ "$http_code" == "201" ]] && echo "$body" | grep -q '"id":[0-9][0-9]*'; then

    CREATED_VENUE_ID=$(echo "$body" | grep -o '"id":[0-9][0-9]*' | grep -o '[0-9][0-9]*')

    echo "PASS: POST /venues"
    echo "Created venue ID: $CREATED_VENUE_ID"
else
    echo "FAIL: POST /venues"
    echo "HTTP Status: $http_code"
    echo "Response: $body"
fi



#Test GET /venues/{id}
echo "Testing GET /venues/{id}..."

if [[ -n "$CREATED_VENUE_ID" ]]; then

    response=$(curl -s -w "\n%{http_code}" \
        "$API_BASE_URL/venues/$CREATED_VENUE_ID")

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [[ "$http_code" == "200" ]] &&
       echo "$body" | grep -q "\"id\": *$CREATED_VENUE_ID," &&
       echo "$body" | grep -q '"name": "CURL Test Venue"'; then

        echo "PASS: GET /venues/$CREATED_VENUE_ID"
    else
        echo "FAIL: GET /venues/$CREATED_VENUE_ID"
        echo "HTTP Status: $http_code"
        echo "Response: $body"
    fi

else
    echo "SKIP: GET /venues/{id} - No venue ID available"
fi



#Test PUT /venues/{id}
echo "Testing PUT /venues/{id}..."

if [[ -n "$CREATED_VENUE_ID" ]]; then

    updated_venue_json='{
        "name": "Updated CURL Test Venue",
        "address": "456 Updated Street",
        "capacity": 250
    }'

    response=$(curl -s -w "\n%{http_code}" -X PUT \
        -H "Content-Type: application/json" \
        -d "$updated_venue_json" \
        "$API_BASE_URL/venues/$CREATED_VENUE_ID")

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [[ "$http_code" == "200" ]] &&
       echo "$body" | grep -q '"name": "Updated CURL Test Venue"'; then

        verify_response=$(curl -s -w "\n%{http_code}" \
            "$API_BASE_URL/venues/$CREATED_VENUE_ID")

        verify_code=$(echo "$verify_response" | tail -n1)
        verify_body=$(echo "$verify_response" | sed '$d')

        if [[ "$verify_code" == "200" ]] &&
           echo "$verify_body" | grep -q '"name": "Updated CURL Test Venue"' &&
           echo "$verify_body" | grep -q '"capacity": 250'; then

            echo "PASS: PUT /venues/$CREATED_VENUE_ID"
        else
            echo "FAIL: PUT /venues - Changes not saved"
        fi

    else
        echo "FAIL: PUT /venues/$CREATED_VENUE_ID"
        echo "HTTP Status: $http_code"
        echo "Response: $body"
    fi

else
    echo "SKIP: PUT /venues/{id} - No venue ID available"
fi



#Test DELETE /venues/{id}
echo "Testing DELETE /venues/{id}..."

if [[ -n "$CREATED_VENUE_ID" ]]; then

    response=$(curl -s -w "\n%{http_code}" -X DELETE \
        "$API_BASE_URL/venues/$CREATED_VENUE_ID")

    http_code=$(echo "$response" | tail -n1)

    if [[ "$http_code" == "401" ]]; then
        echo "PASS: DELETE without token"
    else
        echo "FAIL: DELETE without token"
    fi

    response=$(curl -s -w "\n%{http_code}" -X DELETE \
        -H "Authorization: Bearer wrong-token" \
        "$API_BASE_URL/venues/$CREATED_VENUE_ID")

    http_code=$(echo "$response" | tail -n1)

    if [[ "$http_code" == "401" ]]; then
        echo "PASS: DELETE with invalid token"
    else
        echo "FAIL: DELETE with invalid token"
    fi

    response=$(curl -s -w "\n%{http_code}" -X DELETE \
        -H "Authorization: Bearer admin-demo-token" \
        "$API_BASE_URL/venues/$CREATED_VENUE_ID")

    http_code=$(echo "$response" | tail -n1)

    if [[ "$http_code" == "200" ]]; then

        verify_response=$(curl -s -w "\n%{http_code}" \
            "$API_BASE_URL/venues/$CREATED_VENUE_ID")

        verify_code=$(echo "$verify_response" | tail -n1)

        if [[ "$verify_code" == "404" ]]; then
            echo "PASS: DELETE /venues/$CREATED_VENUE_ID"
        else
            echo "FAIL: Venue was not deleted"
        fi

    else
        echo "FAIL: DELETE with valid token"
        echo "HTTP Status: $http_code"
    fi

else
    echo "SKIP: DELETE /venues/{id} - No venue ID available"
fi



#Create separate venue for Events tests
echo "Creating venue for Events tests..."

event_venue_json='{
    "name": "Event Test Venue",
    "address": "789 Event Testing Street",
    "capacity": 100
}'

response=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d "$event_venue_json" \
    "$API_BASE_URL/venues")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [[ "$http_code" == "201" ]] && echo "$body" | grep -q '"id":[0-9][0-9]*'; then
    EVENT_VENUE_ID=$(echo "$body" | grep -o '"id":[0-9][0-9]*' | grep -o '[0-9][0-9]*')
    echo "Created venue for Events: $EVENT_VENUE_ID"
else
    echo "FAIL: Could not create venue for Events tests"
    echo "HTTP Status: $http_code"
    echo "Response: $body"
    exit 1
fi



#Events Tests

#Test GET /events
echo "Testing GET /events..."

response=$(curl -s -w "\n%{http_code}" "$API_BASE_URL/events")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [[ "$http_code" == "200" ]] && echo "$body" | grep -q '^\['; then
    echo "PASS: GET /events"
else
    echo "FAIL: GET /events"
    echo "HTTP Status: $http_code"
    echo "Response: $body"
fi



#Test POST /events
echo "Testing POST /events..."

new_event_json="{
    \"name\": \"CURL Test Event\",
    \"description\": \"Created by test_curl.sh\",
    \"event_date\": \"2026-12-10 10:00:00\",
    \"venue_id\": $EVENT_VENUE_ID
}"

response=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d "$new_event_json" \
    "$API_BASE_URL/events")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [[ "$http_code" == "201" ]] && echo "$body" | grep -q '"id":[0-9][0-9]*'; then

    CREATED_EVENT_ID=$(echo "$body" | grep -o '"id":[0-9][0-9]*' | grep -o '[0-9][0-9]*')

    echo "PASS: POST /events"
    echo "Created event ID: $CREATED_EVENT_ID"
else
    echo "FAIL: POST /events"
    echo "HTTP Status: $http_code"
    echo "Response: $body"
fi



#Test GET /events/{id}
echo "Testing GET /events/{id}..."

if [[ -n "$CREATED_EVENT_ID" ]]; then

    response=$(curl -s -w "\n%{http_code}" \
        "$API_BASE_URL/events/$CREATED_EVENT_ID")

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [[ "$http_code" == "200" ]] &&
       echo "$body" | grep -q "\"id\": *$CREATED_EVENT_ID," &&
       echo "$body" | grep -q '"name": "CURL Test Event"'; then

        echo "PASS: GET /events/$CREATED_EVENT_ID"
    else
        echo "FAIL: GET /events/$CREATED_EVENT_ID"
        echo "HTTP Status: $http_code"
        echo "Response: $body"
    fi

else
    echo "SKIP: GET /events/{id} - No event ID available"
fi



#Test PUT /events/{id}
echo "Testing PUT /events/{id}..."

if [[ -n "$CREATED_EVENT_ID" ]]; then

    updated_event_json="{
        \"name\": \"Updated CURL Test Event\",
        \"description\": \"Updated by test_curl.sh\",
        \"event_date\": \"2026-12-15 14:00:00\",
        \"venue_id\": $EVENT_VENUE_ID
    }"

    response=$(curl -s -w "\n%{http_code}" -X PUT \
        -H "Content-Type: application/json" \
        -d "$updated_event_json" \
        "$API_BASE_URL/events/$CREATED_EVENT_ID")

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [[ "$http_code" == "200" ]] &&
       echo "$body" | grep -q '"name": "Updated CURL Test Event"'; then

        # Verify the changes were saved.
        verify_response=$(curl -s -w "\n%{http_code}" \
            "$API_BASE_URL/events/$CREATED_EVENT_ID")

        verify_code=$(echo "$verify_response" | tail -n1)
        verify_body=$(echo "$verify_response" | sed '$d')

        if [[ "$verify_code" == "200" ]] &&
           echo "$verify_body" | grep -q '"name": "Updated CURL Test Event"'; then
            echo "PASS: PUT /events/$CREATED_EVENT_ID"
        else
            echo "FAIL: PUT /events - Changes not saved"
        fi

    else
        echo "FAIL: PUT /events/$CREATED_EVENT_ID"
        echo "HTTP Status: $http_code"
        echo "Response: $body"
    fi

else
    echo "SKIP: PUT /events/{id} - No event ID available"
fi



#Test DELETE /events/{id}
echo "Testing DELETE /events/{id}..."

if [[ -n "$CREATED_EVENT_ID" ]]; then

    response=$(curl -s -w "\n%{http_code}" -X DELETE \
        "$API_BASE_URL/events/$CREATED_EVENT_ID")

    http_code=$(echo "$response" | tail -n1)

    if [[ "$http_code" == "401" ]]; then
        echo "PASS: DELETE without token"
    else
        echo "FAIL: DELETE without token"
    fi

    response=$(curl -s -w "\n%{http_code}" -X DELETE \
        -H "Authorization: Bearer wrong-token" \
        "$API_BASE_URL/events/$CREATED_EVENT_ID")

    http_code=$(echo "$response" | tail -n1)

    if [[ "$http_code" == "401" ]]; then
        echo "PASS: DELETE with invalid token"
    else
        echo "FAIL: DELETE with invalid token"
    fi

    response=$(curl -s -w "\n%{http_code}" -X DELETE \
        -H "Authorization: Bearer admin-demo-token" \
        "$API_BASE_URL/events/$CREATED_EVENT_ID")

    http_code=$(echo "$response" | tail -n1)

    if [[ "$http_code" == "200" ]]; then

        verify_response=$(curl -s -w "\n%{http_code}" \
            "$API_BASE_URL/events/$CREATED_EVENT_ID")

        verify_code=$(echo "$verify_response" | tail -n1)

        if [[ "$verify_code" == "404" ]]; then
            echo "PASS: DELETE /events/$CREATED_EVENT_ID"
        else
            echo "FAIL: Event was not deleted"
        fi

    else
        echo "FAIL: DELETE with valid token"
        echo "HTTP Status: $http_code"
    fi

else
    echo "SKIP: DELETE /events/{id} - No event ID available"
fi



# Delete seperate venue
echo "Cleaning up Events test venue..."

response=$(curl -s -w "\n%{http_code}" -X DELETE \
    -H "Authorization: Bearer admin-demo-token" \
    "$API_BASE_URL/venues/$EVENT_VENUE_ID")

http_code=$(echo "$response" | tail -n1)

if [[ "$http_code" == "200" ]]; then
    echo "Cleanup complete: Deleted venue $EVENT_VENUE_ID"
else
    echo "FAIL: Could not delete Events test venue"
    echo "HTTP Status: $http_code"
fi
