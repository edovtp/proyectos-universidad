<?php 
    session_start();
?>

<?php 
    include('../templates/header.html');
?>

<?php

# La mayor parte de este código fue sacado de https://informaticajmca.blogspot.com/2013/01/hacer-un-login-con-php-y-postgres.html

$conex = "host=localhost port=5432 dbname='grupo99e3' user=grupo99 password='Veterinario'";
$cnx = pg_connect($conex) or die ("<h1>Error de conexion.</h1> ". pg_last_error());

if(trim($_POST["rut_npas"]) != "" && trim($_POST["contrasena"]) != ""){
    $usuario = htmlentities($_POST["rut_npas"], ENT_QUOTES);
    $password = $_POST["contrasena"];
    $result = pg_query('SELECT uid, contraseña, upasaporte_rut FROM usuarios WHERE upasaporte_rut=\''.$usuario.'\'');
    if($row = pg_fetch_array($result)){
        if(trim($row["contraseña"]) == $password){
            $_SESSION["contrasena"] = $row["contraseña"];
            $_SESSION["uid"] = $row["uid"];
            $_SESSION["rut_npas"] = $row["upasaporte_rut"];
            $_SESSION["mensaje"] = 'Has iniciado sesión correctamente';
            echo("<script>location.href = '../perfil/info_personal.php';</script>");
        }else{    
            $_SESSION["mensaje"] =  'Password incorrecto';
            echo("<script>location.href = '../index.php';</script>");
        }
    }else{
        $_SESSION["mensaje"] = 'Usuario no existente en la base de datos';
        echo("<script>location.href = '../index.php';</script>");
    }
}else{
 $_SESSION["mensaje"] = 'Debe especificar un usuario y contraseña';
 echo("<script>location.href = '../index.php';</script>");
}
?>