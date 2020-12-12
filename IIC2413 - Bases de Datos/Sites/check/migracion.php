<?php
    session_start();

    if (!$_SESSION["uid"]) {
        $_SESSION["mensaje"] = "No puedes acceder a esta página";
        echo("<script>location.href = '../index.php';</script>");
        $redirigir = true;
    } elseif ($_SESSION["rut_npas"] != "hackerman") {
        $_SESSION["mensaje"] = "No puedes acceder a esta página";
        echo("<script>location.href = '../perfil/info_personal.php';</script>");
        $redirigir = true;
    } else {
        $redirigir = false;
    }
?>

<?php
    session_start();

    if (!$redirigir){
        require('../config/conexion.php');

        $contador = 0;

        $query1 = "SELECT pnombre, nacionalidad, genero, edad, pasaporte FROM Capitanes, Personal WHERE Capitanes.pid = Personal.pid;";
        $result1 = $db2 -> prepare($query1);
        $result1 -> execute();
        $capitanes = $result1 -> fetchAll();
    
        $query_pasaportes = "SELECT upasaporte_rut FROM Usuarios;";
        $statement_pasaportes = $db1 -> prepare($query_pasaportes);
        $statement_pasaportes -> execute();
        $pasaportes = $statement_pasaportes -> fetchAll($fetch_style = PDO::FETCH_COLUMN);
        
        foreach ($capitanes as $capitan) {
            if (!in_array($capitan[4], $pasaportes)) {
                $query = "INSERT INTO Usuarios (unombre, unacionalidad, sexo, uedad, upasaporte_rut, contraseña) 
                VALUES (:nombre, :nacionalidad, :sexo, :edad, :pasaporte, :contrasena);";
                $usuario = $db1 -> prepare($query);
                $usuario -> bindValue(':nombre', $capitan[0]);
                $usuario -> bindValue(':nacionalidad', $capitan[1]);
                $usuario -> bindValue(':sexo', $capitan[2]);
                $usuario -> bindValue(':edad', $capitan[3]);
                $usuario -> bindValue(':pasaporte', $capitan[4]);
                $usuario -> bindValue(':contrasena', $capitan[4]);
                $usuario -> execute();

                $contador = $contador + 1;
            }
        }
    
        $query2 = "SELECT nombre, sexo, edad, rut FROM instalacion, jefes,
        personal WHERE instalacion.id_instalacion=jefes.id_instalacion AND jefes.rut_jefe = personal.rut;";
        $result2 = $db1 -> prepare($query2);
        $result2 -> execute();
        $jefes = $result2 -> fetchAll();
    
        foreach ($jefes as $jefe) {
            $nacionalidad = "CHILENA";
            if (!in_array($jefe[3], $pasaportes)){
                $query = "INSERT INTO Usuarios (unombre, unacionalidad, sexo, uedad, upasaporte_rut, contraseña)
                VALUES (:nombre, :nacionalidad, :sexo, :edad, :pasaporte, :contrasena);";
                $usuario = $db1 -> prepare($query);
                $usuario -> bindValue(':nombre', $jefe[0]);
                $usuario -> bindValue(':nacionalidad', $nacionalidad);
                $usuario -> bindValue(':sexo', $jefe[1]);
                $usuario -> bindValue(':edad', $jefe[2]);
                $usuario -> bindValue(':pasaporte', $jefe[3]);
                $usuario -> bindValue(':contrasena', $jefe[3]);
                $usuario -> execute();

                $contador = $contador + 1;
            }
        }
    
        echo("<script>location.href = '../admin/migrar.php';</script>");
        $_SESSION["mensaje"] = "Los usuarios han sido cargados exitosamente. Se han añadido $contador usuarios nuevos."; 
    }
?>