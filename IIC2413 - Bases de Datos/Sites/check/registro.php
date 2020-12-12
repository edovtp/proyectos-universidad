<?php
    session_start();
?>

<?php
    include('../templates/header.html');
?>

<?php
    $rut_npas = $_POST["rut_npas"];

    require("../config/conexion.php");

    $query = "SELECT upasaporte_rut FROM Usuarios WHERE upasaporte_rut = :rut_npas;";
    $statement = $db1 -> prepare($query);
    $statement -> bindValue(':rut_npas', $rut_npas);
    $statement -> execute();

    $unico = empty($statement -> fetchAll());

    if (!$unico) {
        $_SESSION["mensaje"] = "El número de pasaporte o RUT ya está en uso";
        echo("<script>location.href = '../registrarse.php?';</script>");
    } else {
        $query = "INSERT INTO Usuarios (unombre, uedad, sexo, unacionalidad, upasaporte_rut, contraseña)
        VALUES (:nombre, :edad, :sexo, :nacionalidad, :rut_npas, :contrasena);";
        $statement = $db1 -> prepare($query);
        $statement -> bindValue(':nombre', $_POST["nombre"]);
        $statement -> bindValue(':edad', $_POST["edad"]);
        $statement -> bindValue(':sexo', $_POST["sexo"]);
        $statement -> bindValue(':nacionalidad', $_POST["nacionalidad"]);
        $statement -> bindValue(':rut_npas', $_POST["rut_npas"]);
        $statement -> bindValue(':contrasena', $_POST["contrasena"]);

        if ($statement -> execute()) {
            $_SESSION["mensaje"] = "Te has registrado con éxito. Inicia sesión";
            $description = "Usuario creado";
            $data = array(
                'name' => strval($_POST["nombre"]),
                'age' => intval($_POST["edad"]),
                'description' => $description,
            );
            $options = array(
                'http' => array(
                'method'  => 'POST',
                'content' => json_encode( $data ),
                'header'=>  "Content-Type: application/json\r\n" .
                            "Accept: application/json\r\n"
                )
            );
            $context  = stream_context_create( $options );
            $result = file_get_contents( 'https://proyectobdd-99.herokuapp.com/user', false, $context );
            $response = json_decode($result, true);
            echo("<script>location.href = '../index.php?';</script>");
        } else {
            $_SESSION["mensaje"] = "Ha ocurrido un error. Inténtalo Nuevamente";
            echo("<script>location.href = '../registrarse.php?';</script>");
        }
    }
?> 