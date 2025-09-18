<?php
// asa se include autoload.php daca folosim composer
//require __DIR__.'/vendor/autoload.php';

$password = "secret";

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['password']) && $_POST['password'] === $password) {
        echo "Bravo! Ai acces!";
    } else {
        echo "Mai incearca!";
    }
} else {
    echo '<body style="text-align: center; margin-top: 20%;">
            <h1> Bun venit la aplicația mea de ... </h1>
            <form method="POST" style="display: inline-block; text-align: left;">
                Parola: <input type="password" name="password">
                <input type="submit" value="Trimite">
            </form>
          </body>  
            ';
}
?>