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
        <h1 class="title has-text-centered">Mapa</h1>
        <?php if ($_POST['name']) {
            echo "<h3 class='subtitle has-text-centered'>A continuación se muestra el mapa con los resultados de tu búsqueda para el usuario " . $_POST["name"] . "</h3>";
        } else 
            echo "<h3 class='subtitle has-text-centered'>A continuación se muestra el mapa con los resultados de tu búsqueda</h3>";
        ?>
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

#mapid { height: 600px; }

</style>

<?php
    # Obtenemos primero todos los mensajes usando text-search
    $desired = explode(",", $_POST['desired']);
    $required = explode(",",$_POST['required']);
    $forbidden =  explode(",", $_POST['forbidden']);
    $userId = array();

    $data = array(
        'desired' => array_filter($desired),
        'required' => array_filter($required),
        'forbidden' => array_filter($forbidden),
        'userId' => $userId
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
    $messages = json_decode($result, true);

    # Acá filtramos los mensajes que estén dentro del rango de fechas indicadas
    $li_date = date('Y-m-d', strtotime($_POST['fecha_inicial']));
    $ls_date = date('Y-m-d', strtotime($_POST['fecha_final']));

    $date_filtered_messages = array();
    if ($messages){
        foreach ($messages as $message){
            $as_date_message = date('Y-m-d', strtotime($message['date']));
            if ($li_date <= $as_date_message && $as_date_message <= $ls_date ) {
                array_push($date_filtered_messages, $message);
            }
        }
    }
?>

<?php 
    # Acá vemos si el usuario es jefe de instalación o capitán (solamente si se entrega un nombre)
    if ($_POST['name']){
        require("../config/conexion.php");
        $nombre = $_POST['name'];
        $query1 = "SELECT pasaporte FROM personal WHERE pnombre = :nombre";
        $statement1 = $db2 -> prepare($query1);
        $statement1 -> bindValue(':nombre', $nombre);
        $statement1 -> execute();
        $result = $statement1 -> fetch();
        $rut_pas1 = $result['pasaporte'];
        $vacio_capitanes = empty($result);
    
        $query2 = "SELECT rut FROM personal WHERE nombre = :nombre;";
        $statement2 = $db1 -> prepare($query2);
        $statement2 -> bindValue(':nombre', $nombre);
        $statement2 -> execute();
        $result = $statement2 -> fetch();
        $rut_pas2 = $result['rut'];
        $vacio_jefes = empty($result);
    
        $lista_coordenadas_trabajo = array();
        # Caso capitán
        if (!$vacio_capitanes){
            # Buscar los puertos por los que ha basado el buque del capitán
            $query5 = "SELECT buques.patente_internacional, buques.bnombre, buques.tipo, navieras.nnombre, buques.bid FROM personal, capitanes, capitanea, buques, posee, navieras WHERE personal.pasaporte = :rut_pas AND capitanes.pid = personal.pid AND capitanes.pid = capitanea.pid AND capitanea.bid = buques.bid AND posee.bid = buques.bid AND posee.nid = navieras.nid;";
            $statement5 = $db2 -> prepare($query5);
            $statement5 -> bindValue(':rut_pas', $rut_pas1);
            $statement5 -> execute();
            $buques = $statement5 -> fetchAll();
            $id_barco = $buques[0][4];
        
            $query6 = "SELECT anombre_puerto FROM tiene, historial_atraques WHERE tiene.bid = :id_barco2 AND tiene.aid = historial_atraques.aid;";
            $statement6 = $db2 -> prepare($query6);
            $statement6 -> bindValue(':id_barco2', $id_barco);
            $statement6 -> execute();
            $lugares = $statement6 -> fetchAll($fetch_style = PDO::FETCH_COLUMN);
            $lugares = array_unique($lugares);

            foreach ($lugares as $lugar) {
                if ($lugar == 'nombre'){
                    $lat = -62.1947619;
                    $long = -58.9875484;
                    array_push($lista_coordenadas_trabajo, array("lat" => $lat, "long" => $long));
                } else {
                    $query7 = "SELECT latitud, longitud FROM coordenadas_puertos WHERE lower(puerto) = lower(:puerto);"; 
                    $statement7 = $db1 -> prepare($query7);
                    $statement7 -> bindValue(':puerto', $lugar);
                    $statement7 -> execute();
                    $datos = $statement7 -> fetch();

                    $lat = floatval($datos[0]);
                    $long = floatval($datos[1]);
                    array_push($lista_coordenadas_trabajo, array("lat" => $lat, "long" => $long));
                }
            }
        } elseif (!$vacio_jefes){
            # Obtenemos el puerto
            $query3 = "SELECT nombre_puerto, tipo FROM instalacion, jefes WHERE instalacion.id_instalacion = jefes.id_instalacion AND rut_jefe = :rut_pas;";
            $statement3 = $db1 -> prepare($query3);
            $statement3 -> bindValue(':rut_pas', $rut_pas2);
            $statement3 -> execute();
            $puertos = $statement3 -> fetchAll();
            $puerto = $puertos[0][0];
            
            # Buscamos las coordenadas dadas por puerto
            $query4 = "SELECT latitud, longitud FROM coordenadas_puertos WHERE lower(puerto) = lower(:puerto);";
            $statement4 = $db1 -> prepare($query4);
            $statement4 -> bindValue(':puerto', $puerto);
            $statement4 -> execute();
            $datos = $statement4 -> fetch();
    
            $lat = floatval($datos[0]);
            $long = floatval($datos[1]);
            array_push($lista_coordenadas_trabajo, array("lat" => $lat, "long" => $long));
        }
    }
?>

<?php 
    # Acá filtramos por usuario si es que se entregó un nombre
    if ($_POST['name']){
        # Obtenemos el mongoid
        $options = array(
            'http' => array(
            'method'  => 'GET',
            'header'=>  "Content-Type: application/json\r\n" .
                        "Accept: application/json\r\n"
            )
        );
        
        $context  = stream_context_create( $options );
        $result = file_get_contents('https://proyectobdd-99.herokuapp.com/mongoid/'.rawurlencode($_POST['name']), false, $context);
        $response = json_decode($result, true);
        $userId = $response['mongoid'];

        # Filtramos
        $sent_messages = array();
        $received_messages = array();
        foreach ($date_filtered_messages as $message){
            if ($message['sender'] == $userId){
                $datos = $message['lat'] . ',' . $message['long'];
                array_push($sent_messages, $datos);
            }}
        
        $sent_messages_locations = array_unique($sent_messages);

        foreach($date_filtered_messages as $message){
            if ($message['receptant'] == $userId){
                # Caso que sí se hayan enviado mensajes antes
                if (!empty($sent_messages_locations)){
                    $datos = array_rand($sent_messages_locations);
                    array_push($received_messages, $sent_messages_locations[$datos]);
                } else {
                    # Caso que no se hayan enviado mensajes antes
                    if (!$vacio_capitanes){
                        $message['lat'] = -floor((-1)*(-50.291406 + lcg_value() * abs(-27.374641 - -50.291406))*1000000)/1000000;
                        $message['long'] = -floor((-1)*(-90.979990 + lcg_value() * abs(-90.276865 - -90.979990))*1000000)/1000000;
                    } elseif (!$vacio_jefes){
                        $message['lat'] = $lat;
                        $message['long'] = $long;
                    } else {
                        $message['lat'] = -33.4562406;
                        $message['long'] = -70.6517248;
                    }
                    $datos = $message['lat'] . ',' . $message['long'];
                    array_push($received_messages, $datos);
                }
            }
        }

        $received_messages_locations = array_unique($received_messages);

        $received_and_sent_messages = array_intersect($sent_messages_locations, $received_messages_locations);
        $unique_sent_messages = array_diff($sent_messages_locations, $received_and_sent_messages);
        $unique_received_messages = array_diff($received_messages_locations, $received_and_sent_messages);
    }
?>

<br>
<div class="columns">
    <div class="column"></div>
    <div class="column is-10">
        <div id="mapid"></div>
    </div>
    <div class="column"></div>
</div>


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

<script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js"
      integrity="sha512-XQoYMqMTK8LvdxXYG3nZ448hOEQiglfqkJs1NOQV44cWnUrBc8PkAOcXy20w0vlaXaVUearIOBhiXZ5V3ynxwA=="
      crossorigin=""></script>
<script>
    var mymap = L.map('mapid').setView([-37, -70.6517248], 4);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(mymap);

    var yellowIcon = new L.Icon({
        iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-yellow.png',
        shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
        iconSize: [25, 41],
        iconAnchor: [12, 41],
        popupAnchor: [1, -34],
        shadowSize: [41, 41]});
    
    var greenIcon = new L.Icon({
        iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png',
        shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
        iconSize: [25, 41],
        iconAnchor: [12, 41],
        popupAnchor: [1, -34],
        shadowSize: [41, 41]});

    <?php if ($_POST['name']){
        foreach($unique_sent_messages as $message){
            $data = explode(",", $message);
            echo
            'L.marker([' . $data[0] . ',' . $data[1] . ']).addTo(mymap);';
        }
        foreach($unique_received_messages as $message){
            $data = explode(",", $message);
            echo
            'L.marker([' . $data[0] . ',' . $data[1] . '], {icon: yellowIcon}).addTo(mymap);';
        }
        foreach($received_and_sent_messages as $both){
            $data = explode(",", $both); 
            echo
            'L.marker([' . $data[0] . ',' . $data[1] . '], {icon: greenIcon}).addTo(mymap);';
        }
        foreach($lista_coordenadas_trabajo as $coordenada){
            echo
            'L.circle([' . $coordenada["lat"] . ',' . $coordenada["long"] . '], {
                color: \'red\',
                fillColor: \'#f03\',
                fillOpacity: 0.5,
                radius: 50000
            }).addTo(mymap);';}
        if (!empty($lista_coordenadas_trabajo)){
            echo
            'mymap.setView(new L.LatLng(' . $lista_coordenadas_trabajo[0]["lat"] . ',' . $lista_coordenadas_trabajo[0]["long"] . '), 6)';
        }
    } else {
        foreach ($date_filtered_messages as $message) {
            echo
            'L.marker([' . $message["lat"] . ',' . $message["long"] . ']).addTo(mymap);';
        }
    }
    ?>
</script>

</html>