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

    if ($_GET["naviera"]){
        $query = "SELECT * FROM Navieras WHERE lower(nnombre) LIKE lower(:nombre_naviera);";
        $statement = $db2 -> prepare($query);
        $statement -> bindValue(':nombre_naviera', '%'.$_GET["naviera"].'%');
        $statement -> execute();
    } else {
        $query = "SELECT * FROM Navieras;";
        $statement = $db2 -> prepare($query);
        $statement -> execute();
    }
    $navieras = $statement -> fetchAll();
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
        <h1 class="title has-text-centered">Navieras y Buques</h1>
        <h2 class="subtitle has-text-centered">En esta sección puedes ver el listado de todas las navieras. Haz click en el botón indicado para ver los buques correspondientes</h2>
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

<!-- Sección del buscador de navieras -->
<nav class="panel">
    <form action="navieras.php" method="get">
        <p class="panel-heading">
            Buscador de navieras: 
        </p>

        <div class="panel-block">
            <div class="control" style="margin-right: 20px;">
                <?php if ($_GET["naviera"]) {
                    $nnaviera = $_GET["naviera"];
                    echo "<input class='input' type='text' placeholder='Nombre naviera' value='$nnaviera' name='naviera' required>";
                } else {
                    echo "<input class='input' type='text' placeholder='Nombre naviera' name='naviera' required>";
                } ?>
            </div>
            <input class="button is-primary" type="submit" value="Buscar">
        </div>
    </form>
</nav>



<!-- Sección de la tabla de navieras -->
<div class="container">
    <div class="box">
        <table class="table is-bordered is-fullwidth">
            <thead class="has-background-danger">
                <tr>
                    <th class="has-text-white">Nombre</th>
                    <th class="has-text-white">País</th>
                    <th class="has-text-white">Descripción</th>
                    <th class="has-text-white">Acciones</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach($navieras as $n){
                    echo "<tr>
                    <td>$n[1]</td>
                    <td>$n[2]</td>
                    <td>$n[3]</td>
                    <td><a href='buques.php?naviera=$n[1]' class='button is-primary'>Ver Buques</a>";
                } ?>
            </tbody>
        </table>
    </div>
</div>