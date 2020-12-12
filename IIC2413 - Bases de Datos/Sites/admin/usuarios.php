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

<!-- Sección del header -->
<?php
    include('../templates/header.html');
?>

<?php
    require('../config/conexion.php');

    $query_usuarios = "SELECT uid, unombre, unacionalidad, sexo, uedad, upasaporte_rut FROM Usuarios;";
    $statement = $db1 -> prepare($query_usuarios);
    $statement -> execute();
    $usuarios = $statement -> fetchAll();

    $query_pasaportes = "SELECT pasaporte FROM Capitanes, Personal WHERE Capitanes.pid = Personal.pid;";
    $statement = $db2 -> prepare($query_pasaportes);
    $statement -> execute();
    $pasaportes = $statement -> fetchAll($fetch_style = PDO::FETCH_COLUMN);

    $query_ruts = "SELECT rut FROM instalacion, jefes, personal WHERE instalacion.id_instalacion = jefes.id_instalacion AND jefes.rut_jefe = personal.rut;";
    $statement = $db1 -> prepare($query_ruts);
    $statement -> execute();
    $ruts = $statement -> fetchAll($fetch_style = PDO::FETCH_COLUMN);

    $usuarios_finales = [];
    foreach ($usuarios as $usuario){
        if (!in_array($usuario[5], $pasaportes) && !in_array($usuario[5], $ruts) && $usuario[5] != "hackerman"){
            $usuarios_finales[] = $usuario;
        }
    }
?>

<body>
<!-- Sección del navbar -->
<script defer src="https://use.fontawesome.com/releases/v5.3.1/js/all.js"></script>
<section class="hero is-danger">
    <nav class="navbar is-spaced" role="navigation" aria-label="main navigation">
        <div class="container">
            <div class="navbar-menu">
                <div class="navbar-start">  
                    <span class="icon">
                        <i class="fas fa-anchor is-size-3"></i>
                    </span>
                    <span style="padding-left: 7px;">
                        <a href="../index.php" class="navbar-item has-text-white is-size-4" style="font-weight:bold;">Cochrane Ports</a>
                    </span>
                    <?php if ($_SESSION["uid"]) { ?>
                        <span style="padding-left: 7px;">
                            <a href="../navieras.php" class="navbar-item has-text-white is-size-4">Navieras y Buques</a>
                        </span>
                        <span style="padding-left: 7px;">
                            <a href="../puertos.php" class="navbar-item has-text-white is-size-4">Puertos</a>
                        </span>
                        <span style="padding-left: 7px;">
                            <a href="../mensajes/enviar.php" class="navbar-item has-text-white is-size-4">Mensajes</a>
                        </span>
                        <span style="padding-left: 7px;">
                            <a href="../mapa/buscar.php" class="navbar-item has-text-white is-size-4">Mapa</a>
                        </span>
                    <?php } ?>
                </div>
                <div class="navbar-end">
                    <div class="buttons">
                        <?php if ($_SESSION["rut_npas"] == "hackerman") {?>
                            <a href="usuarios.php" class="button is-info is-size-6">Administrar</a>
                        <?php } ?>
                        <?php if ($_SESSION["uid"]){ ?>
                            <a href="../perfil/info_personal.php" class="button is-primary is-size-6">Mi perfil</a>
                            <a href="../check/logout.php" class="button is-link is-size-6">Cerrar Sesión</a>
                        <?php } ?>
                        <?php if (!$_SESSION["uid"]) { ?>
                            <a href="../registrarse.php" class="button is-link is-size-6">Registrarse</a>
                        <?php } ?>
                    </div>
                </div>
            </div>
        </div>
    </nav>
</section>

<!-- Sección del hero -->
<section class="hero is-danger">
    <div class="hero-body">
        <h1 class="title has-text-centered">Administrar</h1>
        <h2 class="subtitle has-text-centered">En esta sección puedes eliminar usuarios que no sean capitanes ni jefes de instalación</h2>
    </div>
</section>

<!-- Sección del notice -->
<?php
    if ($_SESSION["mensaje"] && !$redirigir) {
        $message = $_SESSION["mensaje"];
        echo "<section class='notification is-danger is-light is-radiusless', style='margin-bottom:0;'>
                <p id='notice' class='has-text-centered'><strong>$message</strong></p>
              </section>";
        unset($_SESSION["mensaje"]);
    }
?>

<!-- Sección de los tabs -->
<div class="tabs is-centered">
    <ul>
        <li class="is-active"><a href="usuarios.php">Eliminar usuarios</a></li>
        <li><a href="migrar.php">Migración de usuarios</a></li>
    </ul>
</div>

<!-- Sección de la tabla de usuarios -->
<div class="container">
    <div class="box">
        <table class="table is-bordered is-fullwidth">
            <thead class="has-background-danger">
                <tr>
                    <th class="has-text-white">uid</th>
                    <th class="has-text-white">Nombre</th>
                    <th class="has-text-white">Nacionalidad</th>
                    <th class="has-text-white">Sexo</th>
                    <th class="has-text-white">Edad</th>
                    <th class="has-text-white">Pasaporte o rut</th>
                    <th class="has-text-white">Acciones</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach($usuarios_finales as $usuario){
                    echo "<tr>
                    <td>$usuario[0]</td>
                    <td>$usuario[1]</td>
                    <td>$usuario[2]</td>
                    <td>$usuario[3]</td>
                    <td>$usuario[4]</td>
                    <td>$usuario[5]</td>
                    <td><a href='../check/eliminar_usuario.php?usuario=$usuario[0]' class='button is-primary'>Eliminar Usuario</a>";
                } ?>
            </tbody>
        </table>
    </div>
</div>
