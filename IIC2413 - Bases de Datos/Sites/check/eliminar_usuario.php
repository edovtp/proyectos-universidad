<?php
    session_start();

    if (!$_SESSION["uid"]) {
        $_SESSION["mensaje"] = "No puedes acceder a esta página";
        echo("<script>location.href = '../index.php';</script>");
        $redirigir = true;
    } elseif ($_SESSION["rut_npas"] != "hackerman") {
        $_SESSION["mensaje"] = "No puedes acceder a esta página";
        echo("<script>location.href = '../perfil/info_personal.php';</script>");
        $redirigir = true;
    } else {
        $redirigir = false;
    }
?>

<?php
    require("../config/conexion.php");

    if ($_SESSION["rut_npas"] == "hackerman"){
        if ($_GET["usuario"]){
            $id_usuario = $_GET["usuario"];
            $query = "DELETE FROM Usuarios WHERE uid = :id_usuario;";
            $statement = $db1 -> prepare($query);
            $statement -> bindValue(':id_usuario', $id_usuario);
            if ($statement -> execute()) {
                $_SESSION["mensaje"] = "Se ha eliminado el usuario exitosamente";
                echo("<script>location.href = '../admin/usuarios.php';</script>");
            } else {
                $_SESSION["mensaje"] = "Ha ocurrido un error";
                echo("<script>location.href = '../admin/usuarios.php';</script>");
            }
        } else {
            $_SESSION["mensaje"] = "Se debe ingresar un usuario";
            echo("<script>location.href = '../admin/usuarios.php';</script>");
        }
    }
?>