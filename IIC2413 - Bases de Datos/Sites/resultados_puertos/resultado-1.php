<?php
    session_start();

    if (!$_SESSION["uid"]) {
        $_SESSION["mensaje"] = "No has iniciado sesión";
        echo("<script>location.href = '../index.php';</script>");
        $redirigir = true;
    } else {
        $redirigir = false;
    }
?>

<!-- Sección de consultas -->
<?php
    require("../config/conexion.php");
    $nom_puerto = $_POST["nombre_puerto"];
    $fecha_inicial = $_POST["fecha_inicial"];
    $fecha_final = $_POST["fecha_final"];
    $query = "SELECT * FROM capacidad_instalaciones(:fecha_inicial, :fecha_final, :nom_puerto);";
    $statement = $db1 -> prepare($query);
    $statement -> bindValue(':fecha_inicial', $fecha_inicial);
    $statement -> bindValue(':fecha_final', $fecha_final);
    $statement -> bindValue(':nom_puerto', $nom_puerto);
    $statement -> execute();
    $dias_porcentaje = $statement -> fetchAll();
?>

<!-- Sección del header -->
<?php
    include('../templates/header.html');
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
                            <a href="../admin/usuarios.php" class="button is-info is-size-6">Administrar</a>
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
        <h1 class="title has-text-centered">Puertos e Instalaciones</h1>
        <h2 class="subtitle has-text-centered">A continuación se muestran todas las instalaciones del puerto <?php echo $nom_puerto; ?>, junto a los días donde la capacidad no está agotada, y, el porcentaje promedio de ocupación entre las fechas <?php echo $fecha_inicial; ?> y <?php echo $fecha_final; ?></h2>
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

<!-- Sección Principal -->
<div class="columns">
    <div class="column is-4 is-offset-4">
        <?php if (!empty($dias_porcentaje)) { 
            foreach ($dias_porcentaje as $dp) { ?>
               <div class="box" >
                   <h1 class="title has-text-centered">Instalación <?php echo $dp[0]; ?></h1>
                    <h1 class="subtitle has-text-centered">El porcentaje promedio de ocupación en este intervalo es <?php echo $dp[2]; ?>%</h1>
                    <?php 
                        $fechas_libres = explode("/", $dp[1]);
                    ?>
                    <table class="table is-bordered-is-striped is-fullwidth">
                        <thead class="has-background-danger">
                        <tr>
                            <th class="has-text-white">Fechas Libres</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach($fechas_libres as $fl){
                            echo "<tr>
                            <td>$fl</td>
                            </tr>";
                        } ?>
                    </tbody>
                </table>
               </div>
           <?php } ?>
        <?php } else { ?>
            <h3 class="has-text-centered">Entre esas fechas no hay capacidad disponible en ninguna instalación del puerto <?php echo $nom_puerto; ?></h3>
        <?php } ?>
    </div>
</div>
<br>
<div class="container">
    <center>
        <?php echo "<a href='../instalaciones.php?puerto=$nom_puerto' class='button is-primary'>Volver</a>"; ?>
    </center>
</div>
<br>