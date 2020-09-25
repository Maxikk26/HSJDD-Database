CREATE OR REPLACE FUNCTION traermedico(INTEGER) RETURNS VARCHAR
AS $$
DECLARE
    id ALIAS FOR $1;
    datos medico%ROWTYPE;
    string VARCHAR(150);
BEGIN
	SELECT * FROM MEDICO ME INTO datos
    WHERE ME.id_medico = id;
    IF datos.s_nombre IS NOT NULL THEN
        string:= datos.p_nombre || ' ' || datos.s_nombre || ',';
    ELSE
        string:= datos.p_nombre || ',';
    END IF; 
    IF datos.s_apellido IS NOT NULL THEN
        string:= string || ' ' || datos.p_apellido || ' ' || datos.s_apellido;
    ELSE
        string:= string || ' ' || datos.p_apellido;
    END IF; 
    RETURN string;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION traertelefonos(INTEGER) RETURNS VARCHAR 
AS $$
DECLARE
    id ALIAS FOR $1;
    datos VARCHAR(13);
    tel VARCHAR(75);
    cont INTEGER:= 0;
    Ctelefono CURSOR FOR SELECT TE.telefono FROM TELEFONO TE, MEDICO ME
                         WHERE ME.id_medico = TE.medico_id
                         AND ME.id_medico = id;
BEGIN

    OPEN Ctelefono;
    FETCH Ctelefono INTO datos;
    LOOP
		IF datos IS NULL THEN
			CLOSE Ctelefono;
			RETURN '-';
		END IF;
        IF cont = 0 THEN
            tel:= datos;
            cont:= cont + 1;
        ELSE
            tel:= tel || ' ' || datos;
        END IF;
        FETCH Ctelefono INTO datos;
        EXIT WHEN NOT FOUND;
    END LOOP;
    CLOSE Ctelefono;
    RETURN tel;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION traercorreos(INTEGER) RETURNS VARCHAR
AS $$
DECLARE
    id ALIAS FOR $1;
    Ccorreo CURSOR FOR SELECT CO.correo FROM CORREO CO, MEDICO ME
                       WHERE ME.id_medico = CO.medico_id
                       AND ME.id_medico = id;
    datos VARCHAR(70);
    cont INTEGER:= 0;
    correos VARCHAR (500);
BEGIN
    OPEN Ccorreo;
    FETCH Ccorreo INTO datos; 
    LOOP
        IF datos IS NULL THEN
            CLOSE Ccorreo;
            RETURN '-';
        END IF;
        IF cont = 0 THEN
            correos:= datos;
            cont:= cont + 1;
        ELSE
            correos:= correos || ', ' || datos;
        END IF;
        FETCH Ccorreo INTO datos;
        EXIT WHEN NOT FOUND;
    END LOOP;
    CLOSE Ccorreo;
    RETURN correos;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION traerespecialidad(medico INTEGER, idesp INTEGER) RETURNS VARCHAR
AS $$
DECLARE
    datos RECORD;
	str VARCHAR(70);
BEGIN
    SELECT ES.especialidad, PE.e_secundaria INTO datos
        FROM ESPECIALIDAD ES, PERTENENCIA PE, CARGO CA, MEDICO ME
        WHERE ME.id_medico = PE.medico_id
        AND CA.id_cargo = PE.cargo_id
        AND ES.id_especialidad = PE.especialidad_id
        AND ME.id_medico = medico
        AND ES.id_especialidad = idesp;
	str:= datos.especialidad;
	IF datos.e_secundaria IS NOT NULL THEN
		str:= str || ' ' || datos.e_secundaria;
	END IF;
    --RAISE NOTICE 'str especialidad: %',str;
    RETURN str;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION traerhorario(idmed INTEGER, idesp INTEGER) RETURNS VARCHAR
AS $$
DECLARE
    Cconsultorio CURSOR FOR SELECT DI.dia, to_char(HO.desde,'HH12:MI') AS desde, to_char(HO.hasta,'HH12:MI') AS hasta
                                FROM MEDICO ME, DIA_ESPECIALIDAD DE, ESPECIALIDAD ES, DIA DI, ASISTENCIA AI, HORA HO
                                WHERE ES.id_especialidad = DE.especialidad_id
                                AND DI.id_dia = DE.dia_id
                                AND ME.id_medico = AI.medico_id
                                AND DI.id_dia = AI.dia_id
                                AND HO.id_hora = AI.hora_id
                                AND ME.id_medico = idmed
                                AND ES.id_especialidad = idesp ORDER BY HO.desde;
    consulta RECORD;
    datos RECORD;
    str VARCHAR(200);
    cont INTEGER := 0;
BEGIN
    OPEN Cconsultorio;
    FETCH Cconsultorio INTO consulta;
    LOOP
        IF cont <> 0 THEN
            IF datos.desde = consulta.desde THEN
                str:= str || ', ' || consulta.dia;
                cont:=1;
            ELSE
                str:= str || ' ' || datos.desde || '-' || datos.hasta || ' y ' || consulta.dia ;
                cont:= 2;
            END IF;
        ELSE
            str:= consulta.dia;
            cont:= 1;
        END IF;
        datos:= consulta;
        FETCH Cconsultorio INTO consulta;
        EXIT WHEN NOT FOUND;
    END LOOP;
    IF cont = 2 THEN
        str:= datos.dia || ' ' || datos.desde || '-' || datos.hasta;
    ELSE
        str:= str || ' ' || datos.desde || '-' || datos.hasta;
    END IF;
    --RAISE NOTICE 'str horario: %',str;
    CLOSE Cconsultorio;
    cont:= 0;
    IF str IS NULL THEN
        str:= '-';
    END IF;
    RETURN str;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION traerconsultorio(idmed INTEGER) RETURNS VARCHAR
AS $$
DECLARE
    Cconsulta CURSOR FOR SELECT CO.numero, PI.piso, PI.numero AS pisonumero, CO.referencia
                            FROM CONSULTORIO CO, PISO PI, MEDICO ME, MEDICO_CONSULTORIO MC
                            WHERE CO.id_consultorio = MC.consultorio_id
                            AND PI.id_piso = CO.piso_id
                            AND ME.id_medico = MC.medico_id
                            AND ME.id_medico = idmed;
    datos RECORD;
    str VARCHAR(75);
    cont INTEGER := 0;
BEGIN
    OPEN Cconsulta;
    FETCH Cconsulta INTO datos;
    LOOP
        IF cont = 0 THEN
            str:= datos.numero || E'\n' || datos.piso ;
            cont:= 1;
        ELSE
            str:= str || ' y ' || datos.numero || E'\n'  || datos.piso;
        END IF;
        IF datos.pisonumero IS NOT NULL THEN
            str:= str || ' ' || datos.pisonumero || E'\n';
        ELSEIF datos.referencia IS NOT NULL THEN
            str:= str || '. ' || datos.referencia || E'\n';
        END IF;
        --RAISE NOTICE 'str consultorio: %', str;
        FETCH Cconsulta INTO datos;
        EXIT WHEN NOT FOUND;
    END LOOP;
    CLOSE Cconsulta;
    IF str IS NULL THEN
        str:= '-';
    END IF;
    RETURN str;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reporte() RETURNS TABLE(MEDICO TEXT, ESPECIALIDAD VARCHAR, HORARIO VARCHAR, CONSULTORIO VARCHAR, TELEFONO VARCHAR, CORREO VARCHAR)
AS $func$
BEGIN
	RETURN QUERY SELECT CA.cargo || ' ' || traermedico(ME.id_medico) AS  MEDICO,traerespecialidad(ME.id_medico,ES.id_especialidad) AS ESPECIALIDAD,traerhorario(ME.id_medico,ES.id_especialidad) AS HORARIO,
                                    traerconsultorio(ME.id_medico) AS CONSULTORIO ,traertelefonos(ME.id_medico) AS TELEFONO, traercorreos(ME.id_medico) AS CORREO
                             FROM MEDICO ME, CARGO CA, ESPECIALIDAD ES, PERTENENCIA PE
                             WHERE ME.id_medico = PE.medico_id
                             AND PE.cargo_id = CA.id_cargo
                             AND PE.especialidad_id = ES.id_especialidad ORDER BY ES.especialidad;
END;
$func$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--FUNCIONES DE LA APP

CREATE OR REPLACE FUNCTION eliminarMedicoId(idmed INTEGER) RETURNS BOOLEAN
AS $$
DECLARE
    medicoRow RECORD;
BEGIN
    SELECT * FROM medico ME INTO medicoRow WHERE ME.id_medico = idmed AND ME.estatus = true;
    IF medicoRow.id_medico <> 0 THEN
        UPDATE medico SET estatus = false WHERE id_medico = idmed;
        RETURN true;
    ELSE
        RETURN false;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insertarMedico(ced VARCHAR, pnombre VARCHAR, snombre VARCHAR, papellido VARCHAR, sapellido VARCHAR) RETURNS INTEGER
AS $$
DECLARE
    idmed INTEGER;
    status BOOLEAN;
BEGIN  
    SELECT ME.id_medico INTO idmed FROM medico ME WHERE ME.cedula = ced;
    IF idmed IS NULL THEN
        INSERT INTO MEDICO(cedula,p_nombre,s_nombre,p_apellido,s_apellido) VALUES (ced,pnombre,snombre,papellido,sapellido);
        RETURN 1;
    ELSE
        IF idmed > 0 THEN
            SELECT ME.estatus INTO status FROM medico ME WHERE ME.id_medico = idmed;
            IF status = FALSE THEN
                UPDATE medico SET estatus = true WHERE id_medico = idmed;
                RETURN 2;
            ELSE
                RETURN 3;
            END IF;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insertarTelefono(ced VARCHAR, tel VARCHAR) RETURNS BOOLEAN
AS $$
DECLARE
    idmed INTEGER;
BEGIN
    SELECT ME.id_medico INTO idmed FROM MEDICO ME WHERE ME.cedula = ced LIMIT 1;
    INSERT INTO TELEFONO(telefono,medico_id) VALUES(tel,idmed);
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insertarCorreo(ced VARCHAR, cor VARCHAR) RETURNS BOOLEAN
AS $$
DECLARE
    idmed INTEGER;
BEGIN
    SELECT ME.id_medico INTO idmed FROM MEDICO ME WHERE ME.cedula = ced LIMIT 1;
    INSERT INTO CORREO(correo,medico_id) VALUES(cor,idmed);
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insertarMedicoConsultorio(ced VARCHAR, con VARCHAR) RETURNS BOOLEAN
AS $$
DECLARE
    idmed INTEGER;
    idcon INTEGER;
BEGIN
    SELECT ME.id_medico INTO idmed FROM medico ME WHERE ME.cedula = ced LIMIT 1;
    SELECT CO.id_consultorio INTO idcon FROM consultorio CO WHERE CO.numero = con;
    INSERT INTO MEDICO_CONSULTORIO(medico_id,consultorio_id) VALUES(idmed,idcon);
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insertarPertenencia(ced VARCHAR, car VARCHAR,esp VARCHAR,esec VARCHAR) RETURNS BOOLEAN
AS $$
DECLARE
    idmed INTEGER;
    idcar INTEGER;
    idesp INTEGER;
BEGIN
    SELECT ME.id_medico INTO idmed FROM medico ME WHERE ME.cedula = ced LIMIT 1;
    SELECT CA.id_cargo INTO idcar FROM cargo CA WHERE CA.cargo = car;
    SELECT ES.id_especialidad INTO idesp FROM especialidad ES WHERE ES.especialidad = esp;
    INSERT INTO PERTENENCIA(medico_id,especialidad_id,cargo_id,e_secundaria) VALUES(idmed,idesp,idcar,esec);
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insertarPertenencia2(ced VARCHAR, car VARCHAR,esp VARCHAR) RETURNS BOOLEAN
AS $$
DECLARE
    idmed INTEGER;
    idcar INTEGER;
    idesp INTEGER;
BEGIN
    SELECT ME.id_medico INTO idmed FROM medico ME WHERE ME.cedula = ced LIMIT 1;
    SELECT CA.id_cargo INTO idcar FROM cargo CA WHERE CA.cargo = car;
    SELECT ES.id_especialidad INTO idesp FROM especialidad ES WHERE ES.especialidad = esp;
    INSERT INTO PERTENENCIA(medico_id,especialidad_id,cargo_id) VALUES(idmed,idesp,idcar);
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insertarAsistencia(ced VARCHAR, desd VARCHAR,hast VARCHAR,di VARCHAR) RETURNS BOOLEAN
AS $$
DECLARE
    idmed INTEGER;
    idia INTEGER;
    idhora INTEGER;
	h1 TIME;
	h2 TIME;
BEGIN
	h1:= to_timestamp(desd, 'HH12:MI');
	h2:= to_timestamp(hast, 'HH12:MI');
	--RAISE NOTICE 'str h1: %', h1;	
	--RAISE NOTICE 'str h2: %', h2;
    SELECT ME.id_medico INTO idmed FROM medico ME WHERE ME.cedula = ced LIMIT 1;
    SELECT DA.id_dia INTO idia FROM dia DA WHERE DA.dia = di;
    SELECT HO.id_hora INTO idhora FROM hora HO WHERE HO.desde = h1 AND HO.hasta = h2;
    INSERT INTO ASISTENCIA(hora_id,dia_id,medico_id) VALUES(idhora,idia,idmed);
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insertarEspecialidad(esp VARCHAR) RETURNS BOOLEAN
AS $$
DECLARE
    idesp INTEGER;
BEGIN
    INSERT INTO ESPECIALIDAD(especialidad) VALUES(esp);
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insertarDiaEspecialidad(esp VARCHAR) RETURNS BOOLEAN
AS $$
DECLARE
    idesp INTEGER;
BEGIN
    SELECT ES.id_especialidad INTO idesp FROM especialidad ES WHERE ES.especialidad = esp;
    IF idesp IS NOT NULL THEN
        INSERT INTO DIA_ESPECIALIDAD(especialidad_id,dia_id) VALUES(idesp,1);
        INSERT INTO DIA_ESPECIALIDAD(especialidad_id,dia_id) VALUES(idesp,2);
        INSERT INTO DIA_ESPECIALIDAD(especialidad_id,dia_id) VALUES(idesp,3);
        INSERT INTO DIA_ESPECIALIDAD(especialidad_id,dia_id) VALUES(idesp,4);
        INSERT INTO DIA_ESPECIALIDAD(especialidad_id,dia_id) VALUES(idesp,5);
        RETURN FOUND;
    END IF;
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validarConsultorio(con VARCHAR) RETURNS BOOLEAN
AS $$
DECLARE
    cons RECORD;
BEGIN
    SELECT * INTO cons FROM consultorio CO WHERE CO.numero = con;
    IF cons IS NULL THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insertarConsultorio(con VARCHAR, pis VARCHAR) RETURNS BOOLEAN
AS $$
DECLARE
    idpiso INTEGER;
BEGIN
    SELECT PI.id_piso INTO idpiso FROM piso PI WHERE PI.piso = pis;
    --RAISE NOTICE 'str idpiso: %', idpiso;	
    INSERT INTO CONSULTORIO(numero,piso_id) VALUES(con,idpiso);
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

