<?php

declare(strict_types=1);

function get_db(): PDO
{
    $dsn = "mysql:host=localhost;dbname=eventdb;charset=utf8mb4";

    $pdo = new PDO($dsn, "ase230", "ase230pass", [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);

    return $pdo;
}