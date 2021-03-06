/*==============================================================*/
/* Table: MEDICO                                                */
/*==============================================================*/
CREATE TABLE MEDICO (
    id_medico SERIAL NOT NULL PRIMARY KEY,
    cedula VARCHAR(9)  NULL,
    p_nombre VARCHAR(20) NOT NULL,
    s_nombre VARCHAR(20)  NULL,
    t_nombre Varchar(20) NULL,
    p_apellido VARCHAR(15) NOT NULL,
    s_apellido VARCHAR(15)  NULL,
    estatus BOOLEAN NOT NULL DEFAULT TRUE
);

/*==============================================================*/
/* Table: TELEFONO                                              */
/*==============================================================*/
CREATE TABLE TELEFONO (
    id_telefono SERIAL NOT NULL PRIMARY KEY,
    telefono VARCHAR(13) NULL,
    medico_id INTEGER NOT NULL,
    CONSTRAINT FK_TELEFONO_MEDICO FOREIGN KEY (medico_id) REFERENCES MEDICO (id_medico) ON DELETE CASCADE
);

/*==============================================================*/
/* Table: CORREO                                                */
/*==============================================================*/
CREATE TABLE CORREO (
    id_correo SERIAL NOT NULL PRIMARY KEY,
    correo VARCHAR(70) NOT NULL,
    medico_id INTEGER NOT NULL,
    CONSTRAINT FK_CORREO_MEDICO FOREIGN KEY (medico_id) REFERENCES MEDICO (id_medico) ON DELETE CASCADE
);

/*==============================================================*/
/* Table: ESPECIALIDAD                                          */
/*==============================================================*/
CREATE TABLE ESPECIALIDAD (
    id_especialidad SERIAL NOT NULL PRIMARY KEY,
    especialidad VARCHAR(100) NOT NULL
);

/*==============================================================*/
/* Table: CARGO                                                 */
/*==============================================================*/
CREATE TABLE CARGO (
    id_cargo SERIAL NOT NULL PRIMARY KEY,
    cargo VARCHAR(5) NOT NULL
);

/*==============================================================*/
/* Table: PERTENENCIA                                           */
/*==============================================================*/

CREATE TABLE PERTENENCIA(
    id_pertenencia SERIAL NOT NULL PRIMARY KEY,
    medico_id INTEGER NOT NULL,
    especialidad_id INTEGER NOT NULL,
    cargo_id INTEGER NOT NULL,
    e_secundaria VARCHAR(70) NULL,
    CONSTRAINT FK_PERTENENCIA_MEDICO FOREIGN KEY (medico_id) REFERENCES MEDICO (id_medico) ON DELETE CASCADE,
    CONSTRAINT FK_PERTENENCIA_CARGO FOREIGN KEY (cargo_id) REFERENCES CARGO (id_cargo) ON DELETE CASCADE,
    CONSTRAINT FK_PERTENENCIA_ESPECIALIDAD FOREIGN KEY (especialidad_id) REFERENCES ESPECIALIDAD (id_especialidad) ON DELETE CASCADE
);

/*==============================================================*/
/* Table: PISO                                                  */
/*==============================================================*/
CREATE TABLE PISO (
    id_piso SERIAL NOT NULL PRIMARY KEY,
    piso VARCHAR(20) NOT NULL,
    numero INTEGER NULL
);

/*==============================================================*/
/* Table: CONSULTORIO                                           */
/*==============================================================*/
CREATE TABLE CONSULTORIO(
    id_consultorio SERIAL NOT NULL PRIMARY KEY,
    numero VARCHAR(50) NOT NULL,
    referencia VARCHAR(70) NULL,
    piso_id INTEGER NOT NULL,
    CONSTRAINT FK_CONSULTORIO_PISO FOREIGN KEY (piso_id) REFERENCES PISO (id_piso) ON DELETE CASCADE 
);
/*==============================================================*/
/* Table: MEDICO_CONSULTORIO                                    */
/*==============================================================*/
CREATE TABLE MEDICO_CONSULTORIO(
    id_me_co SERIAL NOT NULL PRIMARY KEY,
    medico_id INTEGER NOT NULL,
    consultorio_id INTEGER NULL,
    CONSTRAINT FK_MECO_MEDICO FOREIGN KEY (medico_id) REFERENCES MEDICO (id_medico) ON DELETE CASCADE,
    CONSTRAINT FK_MECO_CONSULTORIO FOREIGN KEY (consultorio_id) REFERENCES CONSULTORIO (id_consultorio) ON DELETE CASCADE
);

/*==============================================================*/
/* Table: DIA                                                   */
/*==============================================================*/
CREATE TABLE DIA (
    id_dia SERIAL NOT NULL PRIMARY KEY,
    dia VARCHAR(10) NOT NULL
);

/*==============================================================*/
/* Table: HORA                                                  */
/*==============================================================*/
CREATE TABLE HORA(
    id_hora SERIAL NOT NULL PRIMARY KEY,
    desde TIME NOT NULL,
    hasta TIME NOT NULL
);

/*==============================================================*/
/* Table: ASISTENCIA                                            */
/*==============================================================*/
CREATE TABLE ASISTENCIA (
    id_asistencia SERIAL NOT NULL PRIMARY KEY,
    descripcion VARCHAR(50) NULL,
    dia_id INTEGER NOT NULL,
    medico_id INTEGER NOT NULL,
    hora_id INTEGER NULL,
    CONSTRAINT FK_ASISTENCIA_DIA FOREIGN KEY (dia_id) REFERENCES DIA (id_dia) ON DELETE CASCADE,
    CONSTRAINT FK_ASISTENCIA_MEDICO FOREIGN KEY (medico_id) REFERENCES MEDICO (id_medico) ON DELETE CASCADE,
    CONSTRAINT FK_ASISTENCIA_HORA FOREIGN KEY (hora_id) REFERENCES HORA (id_hora) ON DELETE CASCADE

);

/*==============================================================*/
/* Table: DIA_CONSULTORIO                                       */
/*==============================================================*/
CREATE TABLE DIA_CONSULTORIO (
    id_dia_con SERIAL NOT NULL PRIMARY KEY,
    dia_id INTEGER NOT NULL,
    consultorio_id INTEGER NOT NULL,
    CONSTRAINT FK_DIACON_DIA FOREIGN KEY (dia_id) REFERENCES DIA (id_dia) ON DELETE CASCADE,
    CONSTRAINT FK_DIACON_CONSULTORIO FOREIGN KEY (consultorio_id) REFERENCES CONSULTORIO (id_consultorio) ON DELETE CASCADE
);

/*==============================================================*/
/* Table: DIA_ESPECIALIDAD                                       */
/*==============================================================*/
CREATE TABLE DIA_ESPECIALIDAD(
    id_dia_esp SERIAL NOT NULL PRIMARY KEY,
    especialidad_id INTEGER NOT NULL,
    dia_id INTEGER NOT NULL,
    CONSTRAINT FK_DIAESP_DIA FOREIGN KEY (dia_id) REFERENCES DIA (id_dia) ON DELETE CASCADE,
    CONSTRAINT FK_DIACON_ESPECIALIDAD FOREIGN KEY (especialidad_id) REFERENCES ESPECIALIDAD (id_especialidad) ON DELETE CASCADE

);