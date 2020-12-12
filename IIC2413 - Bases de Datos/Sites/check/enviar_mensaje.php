<?php
    session_start();
?>

<?php
    include('../templates/header.html');
?>

<?php
    $options = array(
        'http' => array(
        'method'  => 'GET',
        'header'=>  "Content-Type: application/json\r\n" .
                    "Accept: application/json\r\n"
        )
    );
    
    $context  = stream_context_create( $options );
    $result = file_get_contents('https://proyectobdd-99.herokuapp.com/mongoid/'.rawurlencode($_POST["name"]), false, $context);
    $response = json_decode($result, true);

    # Vemos si a quien queremos enviar el mensaje existe en la base de datos
    if ($response["success"]){
        $receptant = $response["mongoid"];
        $sender = $_SESSION["mongoid"];
        $message_content = $_POST["message"];
        $date = date('Y-m-d');

        # Vemos si el usuario ha enviado mensajes anteriormente
        $options = array(
            'http' => array(
            'method'  => 'GET',
            'header'=>  "Content-Type: application/json\r\n" .
                        "Accept: application/json\r\n"
            )
        );
    
        $context  = stream_context_create( $options );
        $result = file_get_contents( 'https://proyectobdd-99.herokuapp.com/messages', false, $context );
        $response = json_decode($result, true);
    
        if ($response['success']){
            $all_messages = $response['messages'];
            # Filtramos por los mensajes enviados por el usuario
            $sent_messages = array();
            foreach ($all_messages as $message) {
                if ($message['sender'] == $_SESSION['mongoid']){
                    array_push($sent_messages, $message);
                }
            }

            # Vemos si el usuario ha enviado mensajes anteriormente
            if ($sent_messages){
                $random_message = array_rand($sent_messages);
                $lat = $sent_messages[$random_message]["lat"];
                $long = $sent_messages[$random_message]["long"];
            } else {
                # En este caso debemos ver si el usuario es jefe, capitán o ninguno de los dos
                require("../config/conexion.php");
                $rut_pas = $_SESSION["rut_npas"];
                $query1 = "SELECT pid FROM personal WHERE pasaporte = :rut_pas";
                $statement1 = $db2 -> prepare($query1);
                $statement1 -> bindValue(':rut_pas', $rut_pas);
                $statement1 -> execute();
                $vacio_capitanes = empty($statement1 -> fetchAll());
            
                $query2 = "SELECT rut_jefe FROM jefes WHERE rut_jefe = :rut_pas;";
                $statement2 = $db1 -> prepare($query2);
                $statement2 -> bindValue(':rut_pas', $rut_pas);
                $statement2 -> execute();
                $vacio_jefes = empty($statement2 -> fetchAll());

                # Caso capitán
                if (!$vacio_capitanes){
                    $lat = -floor((-1)*(-50.291406 + lcg_value() * abs(-27.374641 - -50.291406))*1000000)/1000000;
                    $long = -floor((-1)*(-90.979990 + lcg_value() * abs(-90.276865 - -90.979990))*1000000)/1000000;
                } elseif (!$vacio_jefes){
                    # Obtenemos el puerto
                    $query3 = "SELECT nombre_puerto, tipo FROM instalacion, jefes WHERE instalacion.id_instalacion = jefes.id_instalacion AND rut_jefe = :rut_pas;";
                    $statement3 = $db1 -> prepare($query3);
                    $statement3 -> bindValue(':rut_pas', $rut_pas);
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
                } else {
                    # En el último caso usamos las coordenadas de Santiago
                    $lat = -33.4562406;
                    $long = -70.6517248;
                }
            }

            $data = array(
                'sender' => $sender,
                'receptant' => $receptant,
                'message' => $message_content,
                'date' => $date,
                'lat' => $lat,
                'long' => $long
            );
            $options = array(
                'http' => array(
                'method'  => 'POST',
                'content' => json_encode( $data ),
                'header'=>  "Content-Type: application/json\r\n" .
                            "Accept: application/json\r\n"
                )
            );
            $context  = stream_context_create( $options );
            $result = file_get_contents( 'https://proyectobdd-99.herokuapp.com/messages', false, $context );
            $response = json_decode($result, true);

            if ($response['success']){
                $_SESSION["mensaje"] = "El mensaje se ha enviado con éxito";
                echo("<script>location.href = '../mensajes/enviar.php?';</script>");
            } else {
                $_SESSION["mensaje"] = "Ha ocurrido un error al enviar el mensaje";
                echo("<script>location.href = '../mensajes/enviar.php?';</script>");
            }
        }

    } else {
        $_SESSION["mensaje"] = "No existe un usuario registrado con ese nombre";
        echo("<script>location.href = '../mensajes/enviar.php?';</script>");
    }
?>