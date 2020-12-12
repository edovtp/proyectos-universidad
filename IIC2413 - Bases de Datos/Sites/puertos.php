<?php
    session_start();

    if (!$_SESSION["uid"]) {
        $_SESSION["mensaje"] = "No has iniciado sesión";
        echo("<script>location.href = 'index.php';</script>");
        $redirigir = true;
    } else {
        $redirigir = false;
    }
?>

<?php
    require("config/conexion.php");

    if ($_GET["puerto"]){
        $query = "SELECT * FROM Puerto WHERE lower(nombre) LIKE lower(:nombre_puerto);";
        $statement = $db1 -> prepare($query);
        $statement -> bindValue(':nombre_puerto', '%'.$_GET["puerto"].'%');
        $statement -> execute();
    } else {
        $query = "SELECT * FROM Puerto;";
        $statement = $db1 -> prepare($query);
        $statement -> execute();
    }
    $puertos = $statement -> fetchAll();
?>

<!-- Sección del header -->
<?php
    include('templates/header.html');
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
                        <a href="index.php" class="navbar-item has-text-white is-size-4" style="font-weight:bold;">Cochrane Ports</a>
                    </span>
                    <?php if ($_SESSION["uid"]) { ?>
                        <span style="padding-left: 7px;">
                            <a href="navieras.php" class="navbar-item has-text-white is-size-4">Navieras y Buques</a>
                        </span>
                        <span style="padding-left: 7px;">
                            <a href="puertos.php" class="navbar-item has-text-white is-size-4">Puertos</a>
                        </span>
                        <span style="padding-left: 7px;">
                            <a href="mensajes/enviar.php" class="navbar-item has-text-white is-size-4">Mensajes</a>
                        </span>
                        <span style="padding-left: 7px;">
                            <a href="mapa/buscar.php" class="navbar-item has-text-white is-size-4">Mapa</a>
                        </span>
                    <?php } ?>
                </div>
                <div class="navbar-end">
                    <div class="buttons">
                        <?php if ($_SESSION["rut_npas"] == "hackerman") {?>
                            <a href="admin/usuarios.php" class="button is-info is-size-6">Administrar</a>
                        <?php } ?>
                        <?php if ($_SESSION["uid"]){ ?>
                            <a href="perfil/info_personal.php" class="button is-primary is-size-6">Mi perfil</a>
                            <a href="check/logout.php" class="button is-link is-size-6">Cerrar Sesión</a>
                        <?php } ?>
                        <?php if (!$_SESSION["uid"]) { ?>
                            <a href="registrarse.php" class="button is-link is-size-6">Registrarse</a>
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
        <h1 class="title has-text-centered">Puertos e Instalaciones</h1>
        <h2 class="subtitle has-text-centered">En esta sección puedes ver el listado de todos los puertos</h2>
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

<!-- Sección del buscador de puertos -->
<nav class="panel">
    <form action="puertos.php" method="get">
        <p class="panel-heading">
            Buscador de puertos: 
        </p>

        <div class="panel-block">
            <div class="control" style="margin-right: 20px;">
                <?php if ($_GET["puerto"]) {
                    $npuerto = $_GET["puerto"];
                    echo "<input class='input' type='text' placeholder='Nombre puerto' value='$npuerto' name='puerto' required>";
                } else {
                    echo "<input class='input' type='text' placeholder='Nombre puerto' name='puerto' required>";
                } ?>
            </div>
            <input class="button is-primary" type="submit" value="Buscar">
        </div>
    </form>
</nav>

<!-- Sección de la tabla de puertos -->
<div class="container">
    <div class="box">
        <table class="table is-bordered is-fullwidth">
            <thead class="has-background-danger">
                <tr>
                    <th class="has-text-white">Nombre</th>
                    <th class="has-text-white">Ciudad</th>
                    <th class="has-text-white">Región</th>
                    <th class="has-text-white">Acciones</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach($puertos as $p){
                    echo "<tr>
                    <td>$p[0]</td>
                    <td>$p[1]</td>
                    <td>$p[2]</td>
                    <td><a href='instalaciones.php?puerto=$p[0]' class='button is-primary'>Ver Instalaciones</a>";
                } ?>
            </tbody>
        </table>
    </div>
</div>