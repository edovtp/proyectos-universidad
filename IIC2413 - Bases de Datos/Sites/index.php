<?php
    session_start();

    if ($_SESSION["uid"]) {
        $_SESSION["mensaje"] = "Ya has iniciado sesión";
        echo("<script>location.href = 'perfil/info_personal.php';</script>");
        $redirigir = true;
    } else {
        $redirigir = false;
    }
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
                            <a href="mapa/buscar.php" class="navbar-item has-text-white is-size-4">Mapa</a>
                        </span>
                    <?php } ?>
                </div>
                <div class="navbar-end">
                    <div class="buttons">
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

<section class="section bg">
<div class="container">
    <div class="column is-6 is-offset-3">   
        <div class="box">
            <h3 class="title is-size-2 has-text-centered">Iniciar Sesión</h3>
            <form action="check/inicio_sesion.php" method="post">
                <div class="field">
                    <label class="label">Rut o Número de Pasaporte:</label>
                    <div class="control has-icons-left">
                        <input class="input" type="text" placeholder="Rut o Número de Pasaporte" name="rut_npas" required>
                        <span class="icon is-small is-left">
                            <i class="fas fa-address-card"></i>
                        </span>
                    </div>
                </div>

                <div class="field">
                    <label class="label">Contraseña:</label>
                    <div class="control has-icons-left">
                        <input class="input" type="password" name="contrasena" placeholder="Contraseña" required>
                        <span class="icon is-small is-left">
                            <i class="fas fa-key"></i>
                        </span>
                    </div>
                </div>

                <div class="field is-grouped is-grouped-centered">
                    <div class="control">
                        <input class="button is-primary" type="submit" value="Iniciar Sesión"> 
                    </div>
                </div>
                
                <p class="has-text-centered">
                    ¿No tienes una cuenta?
                    <a href="registrarse.php">Regístrate</a>
                </p>
            </form>
        </div>
    </div>
</div>
</section>

</body>
</html>