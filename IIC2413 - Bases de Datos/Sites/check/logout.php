<?php
    session_start();

    unset($_SESSION["uid"]);
    unset($_SESSION["rut_npas"]);
    unset($_SESSION["mongoid"]);
    $_SESSION["mensaje"] = "Has cerrado sesión exitosamente";
    echo("<script>location.href = '../index.php';</script>");
?>