SELECT ME.p_nombre, PI.piso, CO.numero, DI.dia
FROM MEDICO ME, PISO PI, CONSULTORIO CO, MEDICO_CONSULTORIO MC, DIA DI, CONDICION CD 
WHERE ME.id_medico = MC.medico_id
AND CO.id_consultorio = MC.consultorio_id
AND CD.medico_id = ME.id_medico
AND CD.dia_id = DI.id_dia

