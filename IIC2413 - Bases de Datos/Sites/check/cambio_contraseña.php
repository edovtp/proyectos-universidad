<?php
    session_start();
?>
<?php
    include('../templates/header.html');
?>

<?php
    $nueva_contrasena = $_POST["nueva_contrasena"];
    $antigua_contrasena = $_POST["antigua_contrasena"];
    if ($_SESSION["contrasena"] != $antigua_contrasena) { 
        $_SESSION["mensaje"] = "La contraseña que ingresó no es correcta, intente nuevamente";
        echo("<script>location.href = '../perfil/cambio_contraseña.php';</script>");

    } elseif ($nueva_contrasena == $antigua_contrasena) {
        $_SESSION["mensaje"] = "Ingrese una contraseña diferente de la anterior";
        echo("<script>location.href = '../perfil/cambio_contraseña.php';</script>");
    } else {
        require('../config/conexion.php');
        $id_usuario = $_SESSION["uid"];
        $query = "UPDATE usuarios SET contraseña = :nueva_contrasena WHERE contraseña = :antigua_contrasena AND uid = :id_usuario;";
        $statement = $db1 -> prepare($query);
        $statement -> bindValue(':nueva_contrasena', $nueva_contrasena);
        $statement -> bindValue(':antigua_contrasena', $antigua_contrasena);
        $statement -> bindValue(':id_usuario', $id_usuario);
        
        if ($statement -> execute()) {
            $_SESSION["mensaje"] = "Se ha cambiado su contraseña";
            $_SESSION["contrasena"] = $nueva_contrasena;
            echo("<script>location.href = '../perfil/cambio_contraseña.php';</script>");
        } else {
            $_SESSION["mensaje"] = "La contraseña que ingresó no es correcta, intente nuevamente";
            echo("<script>location.href = '../perfil/cambio_contraseña.php';</script>");
        }
    }
?>