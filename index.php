<?php
// asa se include autoload.php daca folosim composer
//require __DIR__.'/vendor/autoload.php';

$password = "secret";

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['password']) && $_POST['password'] === $password) {
        echo "parola corecta";
    } else {
        echo "parola incorecta";
    }
} else {
    echo '<form method="POST">
            Password: <input type="password" name="password">
            <input type="submit" value="Submit">
          </form>';
}
?>