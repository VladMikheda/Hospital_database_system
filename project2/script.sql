DROP TABLE Department CASCADE CONSTRAINTS;
DROP TABLE Patient CASCADE CONSTRAINTS;
DROP TABLE Employee CASCADE CONSTRAINTS;
DROP TABLE Doctors CASCADE CONSTRAINTS;
DROP TABLE Nurse CASCADE CONSTRAINTS;
DROP TABLE Hospitalization CASCADE CONSTRAINTS;
DROP TABLE Inspection_list CASCADE CONSTRAINTS;
DROP TABLE Inspection CASCADE CONSTRAINTS;
DROP TABLE Drug CASCADE CONSTRAINTS;
DROP TABLE Drug_prescription CASCADE CONSTRAINTS;
DROP TABLE Nurse_Patient CASCADE CONSTRAINTS;
DROP TABLE Doctor_Departments CASCADE CONSTRAINTS;

--[0-9][0-9](2[1-9]|3[0-2])(0[1-9]|[1-2][0-9]|3[0-1])\/?[0-9]{3,4}
CREATE TABLE Patient
(
    id            INTEGER GENERATED ALWAYS as IDENTITY (START WITH 1 INCREMENT BY 1),
    insurance_num VARCHAR(11)  NOT NULL,
    first_name    VARCHAR(25)  NOT NULL,
    family_name   VARCHAR(25)  NOT NULL,
    birth_number  VARCHAR(11)  NOT NULL,
    ph_number     VARCHAR(13) CHECK (REGEXP_LIKE(ph_number, '\+[0-9]{12}')),
    city          VARCHAR(100) NOT NULL,
    street        VARCHAR(100) NOT NULL,
    house         VARCHAR(100) NOT NULL,

    CONSTRAINT PK_id PRIMARY KEY (id),
    CONSTRAINT AK_insurance_num UNIQUE (insurance_num),
    CONSTRAINT AK_birth_num_p UNIQUE (birth_number),
    CONSTRAINT check_insurance CHECK (REGEXP_LIKE(insurance_num,
                                                  '^[0-9][0-9](0[1-9]|1[0-2])(4[1-9]|[5-6][0-9]|7[0-1])\/?[0-9]{3,4}$')),
    CONSTRAINT check_birth_num_p CHECK (REGEXP_LIKE(birth_number,
                                                    '^[0-9][0-9](2[1-9]|3[0-2])(0[1-9]|[1-2][0-9]|3[0-1])\/?[0-9]{3,4}$'))
);


CREATE TABLE Employee
(
    id           INTEGER GENERATED ALWAYS as IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,

    birth_number VARCHAR(11) NOT NULL,
    first_name   CHAR(255)   NOT NULL,
    family_name  CHAR(255)   NOT NULL,

    CONSTRAINT check_birth_id CHECK (REGEXP_LIKE(birth_number,
                                           '^[0-9][0-9](2[1-9]|3[0-2])(0[1-9]|[1-2][0-9]|3[0-1])\/?[0-9]{3,4}$'))
);
CREATE TABLE Doctors
(
    id           INTEGER PRIMARY KEY,

    medical_spec VARCHAR(255) NOT NULL CHECK (medical_spec IN
                                              ('ošetřující lékař', 'chirurg', 'neurolog', 'resuscitátor', 'kardiolog')),
    phone_number    VARCHAR(12) CHECK (REGEXP_LIKE(phone_number, '\+[0-9]{12}')),
    email        VARCHAR(255) CHECK (REGEXP_LIKE(email,
                                                 '^[A-Za-z0-9][-0-9A-Za-z\.]*[A-Za-z0-9]@[-a-zA-Z0-9\.]+\.[a-z]{2,}$')),

    CONSTRAINT doctor_id FOREIGN KEY (id) REFERENCES Employee (id)
);

CREATE TABLE Nurse
(
    id             INTEGER  PRIMARY KEY,
    specialization VARCHAR(255) NOT NULL CHECK (specialization IN
                                                ('staniční sestra', 'sestra na oddělení', 'sestra na ošetřovně')),

    CONSTRAINT id_numb_nurse FOREIGN KEY (id) REFERENCES Employee (id)
);

CREATE TABLE Hospitalization
(
    id            INTEGER GENERATED ALWAYS as IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,

    patient_id    INTEGER NOT NULL,
    date_hosp     DATE    NOT NULL,
    diagnosis     VARCHAR(255),
    doctor_id     INTEGER,

    CONSTRAINT FK_id_patient FOREIGN KEY (patient_id) REFERENCES Patient (id),
    CONSTRAINT FK_id_doc FOREIGN KEY (doctor_id) REFERENCES Doctors (id)
);

CREATE TABLE Department
(
    abbreviation CHAR(4) PRIMARY KEY,
    name         VARCHAR(255),
    bed_number   INTEGER NOT NULL,
    manager_id   INTEGER,

    FOREIGN KEY (manager_id) REFERENCES Doctors (id)
);

CREATE TABLE Nurse_Patient
(
    nurse_id           INTEGER,
    id_hospitalization INTEGER,

    CONSTRAINT PK_nurse_patient PRIMARY KEY (nurse_id, id_hospitalization),
    CONSTRAINT FK_id_nurse FOREIGN KEY (nurse_id) REFERENCES Nurse (id),
    CONSTRAINT FK_id_hospitalization FOREIGN KEY (id_hospitalization) REFERENCES Hospitalization (id)
);

CREATE TABLE Doctor_Departments
(
    doctor_id    INTEGER,
    abbreviation CHAR(4),

    CONSTRAINT PK_doc_depart PRIMARY KEY (doctor_id, abbreviation),
    CONSTRAINT FK_id_doctor_dep FOREIGN KEY (doctor_id) REFERENCES Doctors (id),
    CONSTRAINT FK_abbreviation_department FOREIGN KEY (abbreviation) REFERENCES Department (abbreviation)
);

CREATE TABLE Inspection_list
(
    abbreviation CHAR(4)      NOT NULL PRIMARY KEY,
    name         VARCHAR(255) NOT NULL
);

CREATE TABLE Inspection
(
    id           INTEGER GENERATED ALWAYS as IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY ,
    id_patient   INTEGER NOT NULL,
    abbreviation CHAR(4) NOT NULL,
    date_inspect DATE    NOT NULL,
    description  VARCHAR(255),

    CONSTRAINT FK_id_patient_insp FOREIGN KEY (id_patient) REFERENCES Patient (id),
    CONSTRAINT FK_abbreviation_insp FOREIGN KEY (abbreviation) REFERENCES Inspection_list (abbreviation)
);

CREATE TABLE Drug
(
    abbreviation      CHAR(4)      NOT NULL PRIMARY KEY,
    name              VARCHAR(255) NOT NULL,
    active_dose       CHAR(4)      NOT NULL CHECK (REGEXP_LIKE(active_dose, '^[0-9]+E$')),
    maximal_dose      CHAR(4)      NOT NULL CHECK (REGEXP_LIKE(maximal_dose, '^[0-9]+E$')),
    application_form  VARCHAR(16)  NOT NULL CHECK (application_form IN
                                                   ('tablety', 'infuzemi', 'masti', 'extrakty', 'aerosoly', 'kapky')),
    Contraindications VARCHAR(250) NOT NULL,
    Strength          VARCHAR(250) NOT NULL,
    Manufacturer      VARCHAR(250) NOT NULL
);

CREATE TABLE Drug_prescription
(
    id            INTEGER GENERATED ALWAYS as IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    abbreviation  CHAR(4),
    id_patient    INTEGER NOT NULL,
    app_time      VARCHAR(50),
    app_frequency VARCHAR(50),
    dose          CHAR(4)     NOT NULL CHECK (REGEXP_LIKE(dose, '^[0-9]+E$')),

    CONSTRAINT FK_id_patient_drug FOREIGN KEY (id_patient) REFERENCES Patient (id),
    CONSTRAINT FK_abbreviation_drug FOREIGN KEY (abbreviation) REFERENCES Drug (abbreviation)
);