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
                            <a href="info_personal.php" class="button is-primary is-size-6">Mi perfil</a>
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
        <h1 class="title has-text-centered">Mi Perfil</h1>
        <h2 class="subtitle has-text-centered">En esta sección puedes ver tu información personal, información adicional, y puedes cambiar tu contraseña</h2>
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
        <li><a href="info_personal.php">Información personal</a></li>
        <li class="is-active"><a href="info_adicional.php">Información adicional</a></li>
        <li><a href="cambio_contraseña.php">Cambiar contraseña</a></li>
    </ul>
</div>

<!-- Sección principal -->
<style>
body, html {
  height: 100%;
  margin: 0;
}

.bg {
  /* The image used */
  background-image: url("images/ports.jpg");

  /* Full height */
  height: 100%; 

  /* Center and scale the image nicely */
  background-position: center;
  background-repeat: no-repeat;
  background-size: cover;
}
</style>

<?php
    require("../config/conexion.php");
    $rut_pas = $_SESSION["rut_npas"];
    $query = "SELECT pid FROM personal WHERE pasaporte = :rut_pas";
    $statement = $db2 -> prepare($query);
    $statement -> bindValue(':rut_pas', $rut_pas);
    $statement -> execute();
    $vacio_capitanes = empty($statement -> fetchAll());

    $query1 = "SELECT rut_jefe FROM jefes WHERE rut_jefe = :rut_pas;";
    $statement1 = $db1 -> prepare($query1);
    $statement1 -> bindValue(':rut_pas', $rut_pas);
    $statement1 -> execute();
    $vacio_jefes = empty($statement1 -> fetchAll());

    if (!$vacio_capitanes) {
    $query2 = "SELECT buques.patente_internacional, buques.bnombre, buques.tipo, navieras.nnombre, buques.bid FROM personal, capitanes, capitanea, buques, posee, navieras WHERE personal.pasaporte = :rut_pas AND capitanes.pid = personal.pid AND capitanes.pid = capitanea.pid AND capitanea.bid = buques.bid AND posee.bid = buques.bid AND posee.nid = navieras.nid;";
    $statement2 = $db2 -> prepare($query2);
    $statement2 -> bindValue(':rut_pas', $rut_pas);
    $statement2 -> execute();
    $buques = $statement2 -> fetchAll();
    $buque = $buques[0];

    $id_barco = $buques[0][4];
    $query3 = "SELECT fecha_estimada_llegada, pnombre_puerto FROM agenda, proximo_itinerario WHERE agenda.bid = :id_barco AND proximo_itinerario.prid = agenda.prid ORDER BY fecha_estimada_llegada ASC LIMIT 1;";
    $statement3 = $db2 -> prepare($query3);
    $statement3 -> bindValue(':id_barco', $id_barco);
    $statement3 -> execute();
    $itinerario = $statement3 -> fetchAll();
    $vacio_itinerario = empty($itinerario);

    $query4 = "SELECT fecha_atraque, fecha_salida, anombre_puerto FROM tiene, historial_atraques WHERE tiene.bid = :id_barco2 AND tiene.aid = historial_atraques.aid ORDER BY fecha_salida DESC LIMIT 5;";
    $statement4 = $db2 -> prepare($query4);
    $statement4 -> bindValue(':id_barco2', $id_barco);
    $statement4 -> execute();
    $lugares = $statement4 -> fetchAll();
    $vacio_lugares = empty($lugares);
?>

<section class="section">
    <div class="columns">
        <div class="column is-1"></div>
        <div class="column is-3">
            <div class="box">
                <h1 class="title has-text-centered">Información del buque que capitaneas</h1>
                <article class="media">
                    <div class="media-content">
                        <div class="content">
                            <p><center>
                                <strong>Patente Internacional: </strong> <?php echo $buque[0];?>
                            </center></p>

                            <p><center>
                                <strong>Nombre Buque: </strong> <?php echo $buque[1];?>
                            </center></p>

                            <p><center>
                                <strong>Tipo Buque: </strong> <?php echo $buque[2];?>
                            </center></p>

                            <p><center>
                                <strong>Nombre Naviera: </strong> <?php echo $buque[3];?>
                            </center></p>
                        </div>
                    </div>
                </article>
            </div>
        </div>
        <div class="column is-3">
            <div class="box">
                <h1 class="title has-text-centered">Próximo itinerario</h1>
                <?php if (!$vacio_itinerario){ ?>
                    <table class="table is-bordered is-striped is-fullwidth">
                        <thead class="has-background-danger">
                            <tr>
                                <th class="has-text-white">Fecha estimada de llegada</th>
                                <th class="has-text-white">Nombre Puerto</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php
                            foreach ($itinerario as $i) {
                                echo "<tr>
                                <td>$i[0]</td>
                                <td>$i[1]</td>
                                </tr>";
                            } ?>
                        </tbody>
                    </table>
                <?php } else { ?>
                    <h3 class="has-text-centered">Este buque no tiene próximo itinerario</h3>
                <?php } ?>
            </div>
        </div>
        <div class="column is-4">
            <div class="box">
                <h1 class="title has-text-centered">Últimos atraques</h1>
                <?php if (!$vacio_lugares) { ?>
                    <table class="table is-bordered is-striped is-fullwidth">
                        <thead class="has-background-danger">
                            <tr>
                                <th class="has-text-white">Fecha Atraque</th>
                                <th class="has-text-white">Fecha Salida</th>
                                <th class="has-text-white">Nombre Puerto</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php 
                            foreach ($lugares as $l){
                                echo "<tr>
                                <td>$l[0]</td>
                                <td>$l[1]</td>
                                <td>$l[2]</td>
                                </tr>";
                            }
                            ?>
                        </tbody>
                    </table>
                <?php } else { ?> 
                    <h3 class="has-text-centered">Este buque no ha atracado en ningún puerto</h3>
                <?php } ?>
            </div>
        </div>
    </div>
</section>
<?php } ?>

<?php if (!$vacio_jefes) {
$rut_pas = $_SESSION["rut_npas"];
$query5 = "SELECT nombre_puerto, tipo FROM instalacion, jefes WHERE instalacion.id_instalacion = jefes.id_instalacion AND rut_jefe = :rut_pas;";
$statement5 = $db1 -> prepare($query5);
$statement5 -> bindValue(':rut_pas', $rut_pas);
$statement5 -> execute();
$puertos = $statement5 -> fetchAll();
$puerto = $puertos[0];
?>

<div class="container">
    <div class="columns">
        <div class="column is-6 is-offset-3">
            <div class="box">
                <h1 class="title has-text-centered">Información de la instalación</h1>
                <article class="media">
                    <div class="media-content">
                        <div class="content">
                            <p><center>
                                <strong>Nombre Puerto: </strong> <?php echo $puerto[0];?>
                            </center></p>

                            <p><center>
                                <strong>Tipo de Instalación: </strong> <?php echo $puerto[1];?>
                            </center></p>
                        </div>
                    </div>
                </article>
            </div>
        </div>
    </div>
</div>
<?php } ?>

<?php if ($vacio_capitanes && $vacio_jefes) { ?>
    <h3 class="title is-3 has-text-centered">Usted no es capitán ni jefe de instalación.</h3>
<?php } ?>
</body>
</html>