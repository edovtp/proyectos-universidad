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
        <li class="is-active"><a href="info_personal.php">Información personal</a></li>
        <li><a href="info_adicional.php">Información adicional</a></li>
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
$id_usuario = $_SESSION["uid"];
require("../config/conexion.php");
$query = "SELECT unombre, uedad, sexo, upasaporte_rut, unacionalidad FROM Usuarios WHERE uid = :id_usuario;";
$statement = $db1 -> prepare($query);
$statement -> bindValue(':id_usuario', $id_usuario);
$statement -> execute();
$datos_perfil = $statement -> fetch();

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

?>

<div class="container">
    <div class="columns">
        <div class="column is-6 is-offset-3">
            <div class="box">
            <h1 class="title has-text-centered is-size-2">Datos Personales</h1>
            <article class="media">
                <div class="media-content">
                    <div class="content">
                        <p><center>
                            <strong>Nombre: </strong> <?php echo $datos_perfil[0];?>
                        </center></p>

                        <p><center>
                            <strong>Edad: </strong> <?php echo $datos_perfil[1];?>
                        </center>
                        </p>

                        <p><center>
                            <strong>Género: </strong><?php echo $datos_perfil[2];?>
                        </center>
                        </p>
                        <?php if (!$vacio_capitanes) { ?>
                        <p><center>
                            <strong>Cargo: </strong>Capitán de Buque
                        </center>
                        <p><center>
                            <strong>Número de Pasaporte: </strong><?php echo $datos_perfil[3];?>
                        </center>
                        </p>
                        <?php } ?>

                        <?php if (!$vacio_jefes) {?>
                        <p><center>
                            <strong>Cargo: </strong>Jefe de Instalación                  
                        </center>
                        <p><center>
                            <strong>Rut: </strong><?php echo $datos_perfil[3];?>
                        </center>
                        </p>
                        <?php } ?>

                        <?php if($vacio_capitanes && $vacio_jefes) {?>
                        <p><center>
                            <strong>Cargo: </strong>Ninguno
                        </center>
                        <p><center>
                            <strong>Rut o Número de Pasaporte: </strong><?php echo $datos_perfil[3];?>
                        </center>
                        </p>
                        <?php } ?>

                        <p><center>
                            <strong>Nacionalidad: </strong><?php echo $datos_perfil[4];?>
                        </center>
                        </p>
                    </div>
                </div>
            </article>
            </div>
        </div>
    </div>
</div>
</body>
</html>