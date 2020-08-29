CREATE OR REPLACE PROCEDURE main()
AS $$
DECLARE
    myrow medico%ROWTYPE;
    Cmedico CURSOR FOR SELECT * FROM MEDICO;
BEGIN
    RAISE NOTICE 'CREANDO CURSOR'; 
    OPEN Cmedico;
    FETCH Cmedico INTO myrow;
    LOOP
        FETCH Cmedico INTO myrow; 
        
        RAISE NOTICE 'LOOP: %',myrow;
        EXIT WHEN NOT FOUND;
    END LOOP;
END;
$$ LANGUAGE plpgsql;