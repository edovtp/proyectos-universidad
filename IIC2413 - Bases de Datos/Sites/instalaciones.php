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
        $puerto_pedido = $_GET["puerto"];
        $query = "SELECT * FROM Puerto WHERE nombre = :n_puerto";
        $statement = $db1 -> prepare($query);
        $statement -> bindValue(':n_puerto', $puerto_pedido);
        $statement -> execute();
        $result = $statement -> fetchAll();

        if (empty($result)){
            echo("<script>location.href = 'puertos.php';</script>");
            $redirigir = true;
        }
    } else {
        echo("<script>location.href = 'puertos.php';</script>");
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
        <h1 class="title has-text-centered">Puertos e Instalaciones</h1>
        <h2 class="subtitle has-text-centered">A continuación se muestran forms, donde podrá buscar información de las instalaciones correspondientes al puerto con nombre <?php echo $puerto_pedido;?></h2>
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
    <div class="column is-4">   
        <div class="box">
            <h3 class="title is-size-2 has-text-centered">Capacidad de Instalaciones</h3>
                <form action="resultados_puertos/resultado-1.php" method="post">
                    <div class="field">
                        <label class="label">Fecha Inicio:</label>
                            <div class="control has-icons-left">
                                <input class="input" type="date" name="fecha_inicial" placeholder="Fecha inicial" required>
                                    <span class="icon is-small is-left">
                                        <i class="fas fa-calendar-alt"></i>
                                    </span>
                            </div>
                    </div>

                    <div class="field">
                        <label class="label">Fecha Final:</label>
                            <div class="control has-icons-left">
                                <input class="input" type="date" name="fecha_final" placeholder="Fecha final" required>
                                <span class="icon is-small is-left">
                                    <i class="fas fa-calendar-alt"></i>
                                </span>
                            </div>
                    </div>
                    
                    <div class="field">
                        <div class="control">
                            <input type="hidden" name="nombre_puerto" value="<?php echo $puerto_pedido; ?>">
                        </div>
                    </div>

                    <div class="field is-grouped is-grouped-centered">
                        <div class="control">
                            <input class="button is-primary" type="submit" value="Ir"> 
                        </div>
                    </div>

                </form>
            </div>
        </div>
    <div class="column is-8">
       <div class="box">
       <h1 class="title has-text-centered is-size-2">Permisos</h1>
        <div class="columns">
          <div class="column is-6">
              <h3 class="title has-text-centered">Ingrese Valores Para Muelle</h3>
                <form action="resultados_puertos/resultado-2.php" method="post">
                    <div class="field">
                        <label class="label">Fecha Atraque:</label>
                            <div class="control has-icons-left">
                                <input class="input" type="date" name="fecha_muelle" placeholder="Fecha" required>
                                    <span class="icon is-small is-left">
                                        <i class="fas fa-calendar-alt"></i>
                                    </span>
                            </div>
                    </div>

                    <div class="field">
                        <label class="label">Patente Barco:</label>
                            <div class="control has-icons-left">
                                <input class="input" type="text" name="patente_barco_muelle" placeholder="Patente barco" required>
                                    <span class="icon is-small is-left">
                                        <i class="fas fa-ship"></i>
                                    </span>
                            </div>
                    </div>
                    
                    <div class="field">
                        <div class="control">
                            <input type="hidden" name="nombre_puerto" value="<?php echo $puerto_pedido; ?>">
                        </div>
                    </div>

                    <div class="field is-grouped is-grouped-centered">
                        <div class="control">
                            <input class="button is-primary" type="submit" value="Ir"> 
                        </div>
                    </div>

                </form>
          </div>
          <div class="column is-6">
              <h3 class="title has-text-centered">Ingrese Valores Para Astillero</h3>
            <form action="resultados_puertos/resultado-2.php" method="post">
                <div class="field">
                    <label class="label">Fecha Atraque:</label>
                        <div class="control has-icons-left">
                            <input class="input" type="date" name="fecha_atraque_astillero" placeholder="Fecha atraque" required>
                            <span class="icon is-small is-left">
                                <i class="fas fa-calendar-alt"></i>
                            </span>
                        </div>
                </div>

                <div class="field">
                    <label class="label">Fecha Salida:</label>
                        <div class="control has-icons-left">
                            <input class="input" type="date" name="fecha_salida_astillero" placeholder="Fecha salida" required>
                            <span class="icon is-small is-left">
                                <i class="fas fa-calendar-alt"></i>
                            </span>
                        </div>
                </div>

                <div class="field">
                    <label class="label">Patente Barco:</label>
                        <div class="control has-icons-left">
                            <input class="input" type="text" name="patente_barco_astillero" placeholder="Patente barco" required>
                            <span class="icon is-small is-left">
                                <i class="fas fa-ship"></i>
                            </span>
                        </div>
                </div>

                <div class="field">
                    <div class="control">
                        <input type="hidden" name="nombre_puerto" value="<?php echo $puerto_pedido; ?>">
                    </div>
                </div>

                <div class="field is-grouped is-grouped-centered">
                    <div class="control">
                        <input class="button is-primary" type="submit" value="Ir"> 
                    </div>
                </div>

            </form>
              
          </div>
           </div>  
           </div>
            
        </div>  
        
</div>
<br>
<div class="container">
    <form action="puertos.php" method="get">
        <div class="field is-grouped is-grouped-centered">
            <div class="control">
                <input class="button is-primary" type="submit" value="Volver">
            </div>
        </div>
    </form>
</div>
<br>












