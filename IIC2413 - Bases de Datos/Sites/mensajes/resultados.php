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
        <h1 class="title has-text-centered">Mensajes</h1>
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
        <li><a href="enviar.php">Enviar mensaje</a></li>
        <li><a href="enviados.php">Mensajes enviados</a></li>
        <li><a href="recibidos.php">Mensajes recibidos</a></li>
        <li><a href="buscar.php">Buscar mensajes</a></li>
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
    # Debemos obtener el mongoid en caso de que aún no lo tengamos
    if (!$_SESSION["mongoid"]){
        # Obtenemos el nombre del usuario conectado
        $id_usuario = $_SESSION["uid"];
        require("../config/conexion.php");
        $query = "SELECT unombre FROM Usuarios WHERE uid = :id_usuario;";
        $statement = $db1 -> prepare($query);
        $statement -> bindValue(':id_usuario', $id_usuario);
        $statement -> execute();
        $nombre_usuario = $statement -> fetch();
        
        $options = array(
            'http' => array(
            'method'  => 'GET',
            'header'=>  "Content-Type: application/json\r\n" .
                        "Accept: application/json\r\n"
            )
        );
        
        $context  = stream_context_create( $options );
        $result = file_get_contents('https://proyectobdd-99.herokuapp.com/mongoid/'.rawurlencode($nombre_usuario[0]), false, $context);
        $response = json_decode($result, true);
        
        # Acá se podría redirigir en caso de error
        if ($response['success']){
            $_SESSION["mongoid"] = $response['mongoid'];
        }
    }

    # Text-search
    $desired = explode(",", $_POST['desired']);
    $required = explode(",",$_POST['required']);
    $forbidden =  explode(",", $_POST['forbidden']);

    $data = array(
        'desired' => array_filter($desired),
        'required' => array_filter($required),
        'forbidden' => array_filter($forbidden),
        'userId' => intval($_SESSION['mongoid'])
    );


    $options = array(
        'http' => array(
        'method'  => 'GET',
        'content' => json_encode( $data ),
        'header'=>  "Content-Type: application/json\r\n" .
                    "Accept: application/json\r\n"
        )
    );
    
    $context  = stream_context_create( $options );
    $result = file_get_contents( 'https://proyectobdd-99.herokuapp.com/text-search', false, $context );
    $messages_search = json_decode($result, true);
?>

<h1 class="title has-text-centered">Resultados de la búsqueda</h1>

<?php if (empty($messages_search)) {?>
    <h3 class="has-text-centered">La búsqueda no ha arrojado resultados</h3>
<?php } else { ?>
    <div class="columns">
        <div class="column"></div>
        <div class="column is-two-thirds">
            <?php foreach ($messages_search as $message) { ?>
                <div class="box">
                    <article class="media">
                    <div class="media-content">
                        <div class="content">
                            <p>
                            <?php 
                                # Obtenemos el nombre del usuario que recibió el mensaje
                                $ch = curl_init();
                                $url = 'https://proyectobdd-99.herokuapp.com/users/'.$message['receptant'];
                                curl_setopt($ch, CURLOPT_URL, $url);
                                curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                                $res = curl_exec($ch);
                                curl_close($ch);
                                $receptant = json_decode($res, true);
                            ?>
                            <?php echo "<strong>Para: ". $receptant['user_info'][0]['name'] . "</strong>";  ?>
                            <br>
                            <?php echo "<small><i>Fecha: </i>" . $message['date'] . "</small>"; ?>
                            <br>
                            <?php echo "<small><i>Coordenadas: </i>  " . $message['lat'] . ", " . $message['long'] . "</small>"; ?>
                            <br>
                            <?php echo "<i>Mensaje: </i>". $message['message']; ?>
                            </p>
                        </div>
                    </div>
                    </article>
                </div>
            <?php } ?>
        </div>
        <div class="column"></div>
    </div>
<?php } ?>

<br>
<div class="container">
    <form action="buscar.php" method="get">
        <div class="field is-grouped is-grouped-centered">
            <div class="control">
                <input class="button is-primary" type="submit" value="Volver">
            </div>
        </div>
    </form>
</div>
<br>
</body>
</html>