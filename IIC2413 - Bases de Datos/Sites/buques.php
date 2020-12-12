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
        $naviera_pedida = $_GET["naviera"];
        $query_id_naviera = "SELECT nid FROM Navieras WHERE nnombre = :n_naviera;";
        $statement = $db2 -> prepare($query_id_naviera);
        $statement -> bindValue(':n_naviera', $naviera_pedida);
        $statement -> execute();
        $result = $statement -> fetchAll($fetch_style = PDO::FETCH_COLUMN);

        if (!empty($result)) {
            $id_naviera = $result[0];
            $query_buques_naviera = "SELECT Buques.bid
            FROM Navieras, Posee, Buques
            WHERE Navieras.nid = :id_naviera AND Navieras.nid = Posee.nid AND Buques.bid = Posee.bid;";
            $statement = $db2 -> prepare($query_buques_naviera);
            $statement -> bindValue(':id_naviera', $id_naviera);
            $statement -> execute();
            $buques = $statement -> fetchAll($fetch_style = PDO::FETCH_COLUMN);

            # Código sacado de https://phpdelusions.net/pdo#in
            $in = str_repeat('?,', count($buques) - 1) . '?';
            $query_buques_pesqueros = "SELECT Buques.bnombre, Buques.patente_internacional
                        FROM Buques, Buques_Pesqueros
                        WHERE Buques.bid = Buques_Pesqueros.bid AND Buques.bid IN($in);";
            $statement = $db2 -> prepare($query_buques_pesqueros);
            $statement -> execute($buques);
            $buques_pesqueros = $statement -> fetchAll();

            $query_buques_carga = "SELECT Buques.bnombre, Buques.patente_internacional
                    FROM Buques, Buques_Carga
                    WHERE Buques.bid = Buques_Carga.bid AND Buques.bid IN($in);";
            $statement = $db2 -> prepare($query_buques_carga);
            $statement -> execute($buques);
            $buques_carga = $statement -> fetchAll();

            $query_buques_petroleros = "SELECT Buques.bnombre, Buques.patente_internacional
                        FROM Buques, Buques_Petroleros
                        WHERE Buques.bid = Buques_Petroleros.bid AND Buques.bid IN($in);";
            $statement = $db2 -> prepare($query_buques_petroleros);
            $statement -> execute($buques);
            $buques_petroleros = $statement -> fetchAll();
        } else {
            echo("<script>location.href = 'navieras.php';</script>");
            $redirigir = true;
        }
    } else {
        echo("<script>location.href = 'navieras.php';</script>");
        $redirigir = true;
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
        <h2 class="subtitle has-text-centered">A continuación se muestran todos los buques correspondientes a la naviera <?php echo $naviera_pedida;?></h2>
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

<div class="container">
    <div class="columns">
        <div class="column">
            <div class="box">
                <h1 class="title has-text-centered">Buques de Carga</h1>
                <?php if (!empty($buques_carga)) { ?>
                    <table class="table is-bordered is-fullwidth">
                        <thead class="has-background-danger">
                            <tr>
                                <th class="has-text-white">Nombre buque</th>
                                <th class="has-text-white">Patente Internacional</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach($buques_carga as $bc){
                                echo "<tr>
                                <td>$bc[0]</td>
                                <td>$bc[1]</td>
                                </tr>";
                            } ?>
                        </tbody>
                    </table>
                <?php } else { ?>
                    <h3 class="has-text-centered">Esta naviera no posee buques de carga</h3>
                <?php } ?>
            </div>
        </div>
        <div class="column">
            <div class="box">
                <h1 class="title has-text-centered">Buques de Pesca</h1>
                <?php if (!empty($buques_pesqueros)) { ?>
                    <table class="table is-bordered is-fullwidth">
                        <thead class="has-background-danger">
                            <tr>
                                <th class="has-text-white">Nombre buque</th>
                                <th class="has-text-white">Patente Internacional</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach($buques_pesqueros as $bpq){
                                echo "<tr>
                                <td>$bpq[0]</td>
                                <td>$bpq[1]</td>
                                </tr>";
                            } ?>
                        </tbody>
                    </table>
                <?php } else { ?>
                    <h3 class="has-text-centered">Esta naviera no posee buques pesqueros</h3>
                <?php } ?>
            </div>
        </div>
        <div class="column">
            <div class="box">
                <h1 class="title has-text-centered">Buques Petroleros</h1>
                <?php if (!empty($buques_petroleros)) { ?>
                    <table class="table is-bordered is-fullwidth">
                        <thead class="has-background-danger">
                            <tr>
                                <th class="has-text-white">Nombre buque</th>
                                <th class="has-text-white">Patente Internacional</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach($buques_petroleros as $bpt){
                                echo "<tr>
                                <td>$bpt[0]</td>
                                <td>$bpt[1]</td>
                                </tr>";
                            } ?>
                        </tbody>
                    </table>
                <?php } else { ?>
                    <h3 class="has-text-centered">Esta naviera no posee buques petroleros</h3>
                <?php } ?>
            </div>
        </div>
    </div>
</div>

<br>
<div class="container">
    <form action="navieras.php" method="get">
        <div class="field is-grouped is-grouped-centered">
            <div class="control">
                <input class="button is-primary" type="submit" value="Volver">
            </div>
        </div>
    </form>
</div>
<br>