CREATE OR REPLACE PROCEDURE main()
AS $$
DECLARE
    myrow RECORD;
    Cespecialidad CURSOR FOR SELECT CA.cargo, traermedico(ME.id_medico),traerespecialidad(ME.id_medico,CA.id_cargo,ES.id_especialidad),
                                    traertelefonos(ME.id_medico), traercorreos(ME.id_medico) 
                             FROM MEDICO ME, CARGO CA, ESPECIALIDAD ES, PERTENENCIA PE
                             WHERE ME.id_medico = PE.medico_id
                             AND PE.cargo_id = CA.id_cargo
                             AND PE.especialidad_id = ES.id_especialidad;
    
    tel VARCHAR(150);
    id INTEGER;
BEGIN
    RAISE NOTICE 'CREANDO CURSOR'; 
    OPEN Cespecialidad;
    FETCH Cespecialidad INTO myrow;
    LOOP
		RAISE NOTICE 'CONTENT: %',myrow; 
        FETCH Cespecialidad INTO myrow;
        EXIT WHEN NOT FOUND;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

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
        string:= string || datos.p_apellido || ' ' || datos.s_apellido;
    ELSE
        string:= string || datos.p_apellido;
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
            tel:= tel || ', ' || datos;
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

CREATE OR REPLACE FUNCTION traerespecialidad(cargo INTEGER, medico INTEGER, especialidad INTEGER) RETURNS VARCHAR
AS $$
DECLARE
BEGIN

END;
$$ LANGUAGE plpgsql;
