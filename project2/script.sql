DROP TABLE DEPARTMENTS CASCADE CONSTRAINTS;
DROP TABLE PATIENTS CASCADE CONSTRAINTS;
DROP TABLE EMPLOYEES CASCADE CONSTRAINTS;
DROP TABLE DOCTORS CASCADE CONSTRAINTS;
DROP TABLE NURSES CASCADE CONSTRAINTS;
DROP TABLE HOSPITALIZATIONS CASCADE CONSTRAINTS;
DROP TABLE INSPECTIONS_DESC CASCADE CONSTRAINTS;
DROP TABLE INSPECTIONS CASCADE CONSTRAINTS;
DROP TABLE DRUGS CASCADE CONSTRAINTS;
DROP TABLE DRUG_PRESCRIPTIONS CASCADE CONSTRAINTS;
DROP TABLE NURSES_PATIENTS CASCADE CONSTRAINTS;
DROP TABLE DOCTORS_DEPARTMENTS CASCADE CONSTRAINTS;

CREATE TABLE PATIENTS
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
                                                    '[0-9]{2} ?([05][1-9]|[16][02]) ?(0[1-9]|[12][0-9]|3[0-1]) ?\/?[0-9]{3,4}'))
);

CREATE TABLE EMPLOYEES
(
    id           INTEGER GENERATED ALWAYS as IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,

    birth_number VARCHAR(11) NOT NULL,
    first_name   CHAR(255)   NOT NULL,
    family_name  CHAR(255)   NOT NULL,

    CONSTRAINT check_birth_id CHECK (REGEXP_LIKE(birth_number,
                                           '[0-9]{2} ?([05][1-9]|[16][02]) ?(0[1-9]|[12][0-9]|3[0-1]) ?\/?[0-9]{3,4}'))
);

CREATE TABLE DOCTORS
(
    id           INTEGER PRIMARY KEY,

    medical_spec VARCHAR(255) NOT NULL CHECK (medical_spec IN
                                              ('ošetřující lékař', 'chirurg', 'neurolog', 'resuscitátor', 'kardiolog')),
    phone_number    VARCHAR(13) CHECK (REGEXP_LIKE(phone_number, '\+[0-9]{12}')),
    email        VARCHAR(255) CHECK (REGEXP_LIKE(email,
                                                 '^[A-Za-z0-9][-0-9A-Za-z\.]*[A-Za-z0-9]@[-a-zA-Z0-9\.]+\.[a-z]{2,}$')),

    CONSTRAINT doctor_id FOREIGN KEY (id) REFERENCES EMPLOYEES (id)
);

CREATE TABLE NURSES
(
    id             INTEGER  PRIMARY KEY,
    specialization VARCHAR(255) NOT NULL CHECK (specialization IN
                                                ('staniční sestra', 'sestra na oddělení', 'sestra na ošetřovně')),

    CONSTRAINT id_numb_nurse FOREIGN KEY (id) REFERENCES EMPLOYEES (id)
);

CREATE TABLE HOSPITALIZATIONS
(
    id            INTEGER GENERATED ALWAYS as IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,

    patient_id    INTEGER NOT NULL,
    date_hosp     DATE    NOT NULL,
    diagnosis     VARCHAR(255),
    doctor_id     INTEGER,

    CONSTRAINT FK_id_patient FOREIGN KEY (patient_id) REFERENCES PATIENTS (id),
    CONSTRAINT FK_id_doc FOREIGN KEY (doctor_id) REFERENCES DOCTORS (id)
);

CREATE TABLE DEPARTMENTS
(
    abbreviation CHAR(4) PRIMARY KEY,
    name         VARCHAR(255),
    bed_number   INTEGER NOT NULL,
    manager_id   INTEGER,

    FOREIGN KEY (manager_id) REFERENCES DOCTORS (id)
);

CREATE TABLE NURSES_PATIENTS
(
    nurse_id           INTEGER,
    id_hospitalization INTEGER,

    CONSTRAINT PK_nurse_patient PRIMARY KEY (nurse_id, id_hospitalization),
    CONSTRAINT FK_id_nurse FOREIGN KEY (nurse_id) REFERENCES NURSES (id),
    CONSTRAINT FK_id_hospitalization FOREIGN KEY (id_hospitalization) REFERENCES HOSPITALIZATIONS (id)
);

CREATE TABLE DOCTORS_DEPARTMENTS
(
    doctor_id    INTEGER,
    abbreviation CHAR(4),

    CONSTRAINT PK_doc_depart PRIMARY KEY (doctor_id, abbreviation),
    CONSTRAINT FK_id_doctor_dep FOREIGN KEY (doctor_id) REFERENCES DOCTORS (id),
    CONSTRAINT FK_abbreviation_department FOREIGN KEY (abbreviation) REFERENCES DEPARTMENTS (abbreviation)
);

CREATE TABLE INSPECTIONS_DESC
(
    abbreviation CHAR(4)      NOT NULL PRIMARY KEY,
    name         VARCHAR(255) NOT NULL
);

CREATE TABLE INSPECTIONS
(
    id           INTEGER GENERATED ALWAYS as IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY ,
    id_patient   INTEGER NOT NULL,
    abbreviation CHAR(4) NOT NULL,
    date_inspect DATE    NOT NULL,
    description  VARCHAR(255),

    CONSTRAINT FK_id_patient_insp FOREIGN KEY (id_patient) REFERENCES PATIENTS (id),
    CONSTRAINT FK_abbreviation_insp FOREIGN KEY (abbreviation) REFERENCES INSPECTIONS_DESC (abbreviation)
);

CREATE TABLE DRUGS
(
    abbreviation      CHAR(4)      NOT NULL PRIMARY KEY,
    name              VARCHAR(255) NOT NULL,
    active_dose       CHAR(4)      NOT NULL,
    maximal_dose      CHAR(4)      NOT NULL,
    application_form  VARCHAR(16)  NOT NULL CHECK (application_form IN
                                                   ('tablety', 'infuzemi', 'masti', 'extrakty', 'aerosoly', 'kapky')),
    Contraindications VARCHAR(250) NOT NULL,
    Strength          VARCHAR(250) NOT NULL,
    Manufacturer      VARCHAR(250) NOT NULL
);

CREATE TABLE DRUG_PRESCRIPTIONS
(
    id            INTEGER GENERATED ALWAYS as IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    abbreviation  CHAR(4),
    id_patient    INTEGER NOT NULL,
    app_time      VARCHAR(50),
    app_frequency VARCHAR(50),
    dose          CHAR(4)     NOT NULL,

    CONSTRAINT FK_id_patient_drug FOREIGN KEY (id_patient) REFERENCES PATIENTS (id),
    CONSTRAINT FK_abbreviation_drug FOREIGN KEY (abbreviation) REFERENCES DRUGS (abbreviation)
);

-- Inserting data
INSERT INTO EMPLOYEES (BIRTH_NUMBER, FIRST_NAME, FAMILY_NAME) VALUES ('670114/1084', 'Adam', 'Novotny');

INSERT INTO EMPLOYEES (BIRTH_NUMBER, FIRST_NAME, FAMILY_NAME) VALUES ('630329/0015', 'Jakub', 'Kubat');

INSERT INTO DOCTORS (ID, MEDICAL_SPEC, PHONE_NUMBER, EMAIL) VALUES (1, 'neurolog', '+420111222333', '123@123.cz');

INSERT INTO NURSES (ID, SPECIALIZATION) VALUES (1, 'sestra na oddělení');

INSERT INTO DEPARTMENTS (ABBREVIATION, NAME, BED_NUMBER, MANAGER_ID) VALUES ('NEUR', 'Neurologie', 50, 1);

INSERT INTO DOCTORS_DEPARTMENTS (DOCTOR_ID, ABBREVIATION) VALUES (1, 'NEUR');

INSERT INTO PATIENTS (INSURANCE_NUM, FIRST_NAME, FAMILY_NAME, BIRTH_NUMBER, PH_NUMBER, CITY, STREET, HOUSE)
VALUES ('1201411234', 'David', 'Černý', '481016/123', '+420123456789', 'Brno', 'Husitská', '23');

INSERT INTO HOSPITALIZATIONS (PATIENT_ID, DATE_HOSP, DIAGNOSIS, DOCTOR_ID)
VALUES (1, TO_DATE('2019-03-25 20:03:44', 'YYYY-MM-DD HH24:MI:SS'), 'NEUR-123', 1);

INSERT INTO NURSES_PATIENTS (NURSE_ID, ID_HOSPITALIZATION) VALUES (1, 1);

INSERT INTO INSPECTIONS_DESC (ABBREVIATION, NAME) VALUES ('KRV1', 'Krev');

INSERT INTO INSPECTIONS (ID_PATIENT, ABBREVIATION, DATE_INSPECT, DESCRIPTION)
VALUES (1, 'KRV1', TO_DATE('2019-03-25 21:12:23', 'YYYY-MM-DD HH24:MI:SS'), NULL);

INSERT INTO DRUGS (ABBREVIATION, NAME, ACTIVE_DOSE, MAXIMAL_DOSE, APPLICATION_FORM, CONTRAINDICATIONS, STRENGTH, MANUFACTURER)
VALUES ('TAB1', 'Tableta 1', '15mg', '30mg', 'tablety', 'Nejsou', 'Slabá', 'Supertablety');

INSERT INTO DRUG_PRESCRIPTIONS (ABBREVIATION, ID_PATIENT, APP_TIME, APP_FREQUENCY, DOSE)
VALUES ('TAB1', 1, 'Ráno', '1/den', '15mg');