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
    if ($_POST["fecha_muelle"]){
        $nom_puerto = $_POST["nombre_puerto"];
        $fecha = $_POST["fecha_muelle"];
        $fecha_inicio = $fecha . " 00:00:00";
        $fecha_final = $fecha . " 23:59:59";
        $patente = $_POST["patente_barco_muelle"];
        $query = "SELECT i1.id_instalacion, (SELECT COUNT(p2.id_permiso) FROM permiso p2, instalacion i2 WHERE i2.id_instalacion = p2. id_instalacion_permiso AND fecha_atraque BETWEEN :fecha_inicio AND :fecha_final AND i2.tipo = 'muelle' AND i1. id_instalacion = i2. id_instalacion) as contador FROM instalacion i1, permiso p1 WHERE i1.nombre_puerto = :nom_puerto AND i1.id_instalacion = p1.id_instalacion_permiso AND i1.tipo = 'muelle' AND i1.capacidad > (SELECT COUNT(p2.id_permiso) FROM permiso p2, instalacion i2 WHERE i2.id_instalacion = p2. id_instalacion_permiso AND fecha_atraque BETWEEN :fecha_inicio AND :fecha_final AND i2.tipo = 'muelle' AND i1. id_instalacion = i2. id_instalacion) GROUP BY i1.id_instalacion ORDER BY contador DESC;";
        $statement = $db1 -> prepare($query);
        $statement -> bindValue(':nom_puerto', $nom_puerto);
        $statement -> bindValue(':fecha_inicio', $fecha_inicio);
        $statement -> bindValue(':fecha_final', $fecha_final);
        $statement -> execute();
        $instalaciones = $statement -> fetchAll();
        $query_cierre_instalaciones = "SELECT id_instalacion_cierre FROM cierre_instalacion WHERE fecha_cierre <= :fecha_inicio AND fecha_apertura >= :fecha_final;";
        $statement = $db1 -> prepare($query_cierre_instalaciones);
        $statement -> bindValue(':fecha_inicio', $fecha_inicio);
        $statement -> bindValue(':fecha_final', $fecha_final);
        $statement -> execute();
        $instalaciones_cerradas = $statement -> fetchAll($fetch_style = PDO::FETCH_COLUMN);
        $instalaciones_no_cerradas = [];
        foreach ($instalaciones as $i){
            if (!in_array($i[0], $instalaciones_cerradas)){
                $instalaciones_no_cerradas[] = $i;
            }
        }
        $instalaciones = $instalaciones_no_cerradas;

        if (!empty($instalaciones)) {
            $id_instalacion = $instalaciones[0][0];
            $descripcion = "se debe cargar petroleo";
            $carga_descarga = "carga/descarga";
            $query_agregar_permiso = "INSERT INTO Permiso (fecha_atraque, tipo, patente_barco, id_instalacion_permiso) VALUES (:fecha_inicio, :carga_descarga, :patente, :id_instalacion);";
            $statement = $db1 -> prepare($query_agregar_permiso);
            $statement -> bindValue(':fecha_inicio', $fecha_inicio);
            $statement -> bindValue(':carga_descarga', $carga_descarga);
            $statement -> bindValue(':patente', $patente);
            $statement -> bindValue(':id_instalacion', $id_instalacion);
            if ($statement -> execute()){
                $query_ultimo_id = "SELECT id_permiso FROM permiso ORDER BY id_permiso DESC LIMIT 1;";
                $statement = $db1 -> prepare($query_ultimo_id);
                $statement -> execute();
                $id_permiso = $statement -> fetchColumn();
                $query_agregar_permiso_muelle = "INSERT INTO permiso_carga_descarga (id_permiso, descripcion) VALUES (:id_permiso, :descripcion);";
                $statement = $db1 -> prepare($query_agregar_permiso_muelle);
                $statement -> bindValue(':id_permiso', $id_permiso);
                $statement -> bindValue(':descripcion', $descripcion);
                $statement -> execute();
                $_SESSION["mensaje"] = "Se ha generado un permiso para su barco en el muelle con id $id_instalacion";
            } else {
                $_SESSION["mensaje"] = "La patente ingresada no existe";
                $nom_puerto = $_POST["nombre_puerto"];
                echo("<script>location.href = '../instalaciones.php?puerto=$nom_puerto';</script>");
                $redirigir = true;  
            }
        } else {
            $_SESSION["mensaje"] = "No hay muelles disponibles a esa fecha, por lo que no se ha generado un permiso";
        }
    } else {
        $nom_puerto = $_POST["nombre_puerto"];
        $fecha_atraque = $_POST["fecha_atraque_astillero"];
        $fecha_atraque_inicio = $fecha_atraque . " 00:00:00";
        $fecha_atraque_final = $fecha_atraque . " 23:59:59";
        $fecha_salida = $_POST["fecha_salida_astillero"];
        $fecha_salida_inicio = $fecha_salida . " 00:00:00";
        $fecha_salida_final = $fecha_salida . " 23:59:59";
        $patente = $_POST["patente_barco_astillero"];
        $query = "SELECT i1.id_instalacion, (SELECT COUNT(p2.id_permiso) FROM permiso p2, instalacion i2 WHERE i2.id_instalacion = p2. id_instalacion_permiso AND fecha_atraque BETWEEN :fecha_atraque_inicio AND :fecha_atraque_final AND i2.tipo = 'astillero' AND i1.id_instalacion = i2. id_instalacion) as Contador_entrada, (SELECT COUNT(p3.id_permiso) FROM permiso p3, instalacion i3, permiso_astillero WHERE i3.id_instalacion = p3. id_instalacion_permiso AND p3.id_permiso = permiso_astillero.id_permiso AND fecha_salida BETWEEN :fecha_salida_inicio AND :fecha_salida_final AND i1.id_instalacion = i3.id_instalacion) as Contador_Salida FROM instalacion i1, permiso p1 WHERE i1.id_instalacion = p1.id_instalacion_permiso AND i1.tipo = 'astillero' AND i1.nombre_puerto = :nom_puerto AND i1.capacidad > (SELECT COUNT(p2.id_permiso) FROM permiso p2, instalacion i2 WHERE i2.id_instalacion = p2. id_instalacion_permiso AND fecha_atraque BETWEEN :fecha_atraque_inicio AND :fecha_atraque_final AND i2.tipo = 'astillero' AND i1. id_instalacion = i2. id_instalacion) AND i1.capacidad > (SELECT COUNT(p3.id_permiso) FROM permiso p3, instalacion i3, permiso_astillero WHERE i3.id_instalacion = p3.id_instalacion_permiso AND p3.id_permiso = permiso_astillero.id_permiso AND fecha_salida BETWEEN :fecha_salida_inicio AND :fecha_salida_final) GROUP BY i1.id_instalacion ORDER BY Contador_entrada DESC;";
        $statement = $db1 -> prepare($query);
        $statement -> bindValue(':fecha_atraque_inicio', $fecha_atraque_inicio);
        $statement -> bindValue(':fecha_atraque_final', $fecha_atraque_final);
        $statement -> bindValue(':fecha_salida_inicio', $fecha_salida_inicio);
        $statement -> bindValue(':fecha_salida_final', $fecha_salida_final);
        $statement -> bindValue(':nom_puerto', $nom_puerto);
        $statement -> execute();
        $instalaciones = $statement -> fetchAll();
        $query_cierre_instalaciones = "SELECT id_instalacion_cierre FROM cierre_instalacion WHERE fecha_cierre <= :fecha_inicio AND fecha_apertura >= :fecha_final;";
        $statement = $db1 -> prepare($query_cierre_instalaciones);
        $statement -> bindValue(':fecha_inicio', $fecha_atraque_inicio);
        $statement -> bindValue(':fecha_final', $fecha_atraque_final);
        $statement -> execute();
        $instalaciones_cerradas = $statement -> fetchAll($fetch_style = PDO::FETCH_COLUMN);
        $instalaciones_no_cerradas = [];
        foreach ($instalaciones as $i){
            if (!in_array($i[0], $instalaciones_cerradas)){
                $instalaciones_no_cerradas[] = $i;
            }
        }
        $instalaciones = $instalaciones_no_cerradas;
        
        if (!empty($instalaciones)){
            $id_instalacion = $instalaciones[0][0];
            $astillero = "astillero";
            $query_agregar_permiso = "INSERT INTO Permiso (fecha_atraque, tipo, patente_barco, id_instalacion_permiso) VALUES (:fecha_atraque, :astillero, :patente, :id_instalacion);";
            $statement = $db1 -> prepare($query_agregar_permiso);
            $statement -> bindValue(':fecha_atraque', $fecha_atraque_inicio);
            $statement -> bindValue(':patente', $patente);
            $statement -> bindValue(':astillero', $astillero);
            $statement -> bindValue(':id_instalacion', $id_instalacion);
            if ($statement -> execute()) {
                $query_ultimo_id = "SELECT id_permiso FROM permiso ORDER BY id_permiso DESC LIMIT 1;";
                $statement = $db1 -> prepare($query_ultimo_id);
                $statement -> execute();
                $id_permiso = $statement -> fetchColumn();
                $query_agregar_permiso_astillero = "INSERT INTO permiso_astillero (id_permiso, fecha_salida) VALUES (:id_permiso, :fecha_salida);";
                $statement = $db1 -> prepare($query_agregar_permiso_astillero);
                $statement -> bindValue(':id_permiso', $id_permiso);
                $statement -> bindValue(':fecha_salida', $fecha_salida_inicio);
                $statement -> execute();
                $_SESSION["mensaje"] = "Se ha generado un permiso para su barco en el astillero con id $id_instalacion";
            } else {
                $_SESSION["mensaje"] = "La patente ingresada no existe";
                $nom_puerto = $_POST["nombre_puerto"];
                echo("<script>location.href = '../instalaciones.php?puerto=$nom_puerto';</script>");
                $redirigir = true;
            }
        } else {
            $_SESSION["mensaje"] = "No hay astilleros disponibles a esa fecha, por lo que no se ha generado un permiso";
        }
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
        <h1 class="title has-text-centered">Puertos e Instalaciones</h1>
        <h2 class="subtitle has-text-centered">A continuación se muestran todos los id de las instalaciones del puerto <?php echo $nom_puerto;?> que tienen capacidad para su barco en la fecha ingresada</h2>
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
<?php if ($_POST["fecha_muelle"]) { ?> 
    <div class="column">
        <div class="box">
        <h1 class="title has-text-centered">Muelles con capacidad en la fecha <?php echo $fecha; ?>:</h1>
            <?php if (!empty($instalaciones)) { ?>
                <table class="table is-bordered-is-striped is-fullwidth">
                    <thead class="has-background-danger">
                        <tr>
                            <th class="has-text-white">id muelle</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach($instalaciones as $i){
                            echo "<tr>
                            <td>$i[0]</td>
                            </tr>";
                        } ?>
                    </tbody>
                </table>
            <?php } else { ?>
                <h3 class="has-text-centered">Ningún muelle tiene capacidad para ese barco en esa fecha</h3>
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
<?php } else { ?>
    <div class="column">
            <div class="box">
            <h1 class="title has-text-centered">Astilleros con capacidad en la fecha <?php echo $fecha_atraque; ?>:</h1>
                <?php if (!empty($instalaciones)) { ?>
                    <table class="table is-bordered-is-striped is-fullwidth">
                        <thead class="has-background-danger">
                            <tr>
                                <th class="has-text-white">id astillero</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach($instalaciones as $i){
                                echo "<tr>
                                <td>$i[0]</td>
                                </tr>";
                            } ?>
                        </tbody>
                    </table>
                <?php } else { ?>
                    <h3 class="has-text-centered">Ningún astillero tiene capacidad para ese barco en esa fecha</h3>
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
<?php } ?>