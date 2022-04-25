/**
  * Project: Návrh a implementace relační databáze
  *
  * File: xmikhe00_xkarev00.sql
  * Subject: IDS 2022
  *
  *@author: Vladislav Mikheda xmikhe00
  *@author: Denis Karev xkarev00
 */

-- region TABLE DELETION

DROP TABLE PATIENTS CASCADE CONSTRAINTS;
DROP TABLE EMPLOYEES CASCADE CONSTRAINTS;
DROP TABLE DOCTORS CASCADE CONSTRAINTS;
DROP TABLE DEPARTMENTS CASCADE CONSTRAINTS;
DROP TABLE DEPARTMENT_MANAGER_HISTORY CASCADE CONSTRAINTS;
DROP TABLE NURSES CASCADE CONSTRAINTS;
DROP TABLE DOCTORS_DEPARTMENTS CASCADE CONSTRAINTS;
DROP TABLE HOSPITALIZATIONS CASCADE CONSTRAINTS;
DROP TABLE NURSES_PATIENTS CASCADE CONSTRAINTS;
DROP TABLE INSPECTIONS_DESC CASCADE CONSTRAINTS;
DROP TABLE INSPECTIONS CASCADE CONSTRAINTS;
DROP TABLE DRUGS CASCADE CONSTRAINTS;
DROP TABLE DRUG_PRESCRIPTIONS CASCADE CONSTRAINTS;

-- endregion

-- region TABLE CREATION

CREATE TABLE PATIENTS
(
    id            INTEGER GENERATED ALWAYS as IDENTITY (START WITH 1 INCREMENT BY 1),
    insurance_num VARCHAR(11)  NOT NULL,
    first_name    VARCHAR(25)  NOT NULL,
    family_name   VARCHAR(25)  NOT NULL,
    birth_number  VARCHAR(11)  NOT NULL,
    phone_number  VARCHAR(13) CHECK (REGEXP_LIKE(phone_number, '\+[0-9]{12}')),
    city          VARCHAR(100) NOT NULL,
    street        VARCHAR(100) NOT NULL,
    house         VARCHAR(100) NOT NULL,

    CONSTRAINT PK_id PRIMARY KEY (id),
    CONSTRAINT AK_phone_number_pat UNIQUE (phone_number),
    CONSTRAINT AK_insurance_num UNIQUE (insurance_num),
    CONSTRAINT AK_birth_num_p UNIQUE (birth_number),
    CONSTRAINT check_insurance CHECK (REGEXP_LIKE(insurance_num,
                                                  '^[0-9]{2}?([0][1-9]|[1][0-2])?([012456][0-9]|[37][0-1])?\/?[0-9]{3,4}$')),
    CONSTRAINT check_birth_num_p CHECK (REGEXP_LIKE(birth_number,
                                                    '^[0-9]{2}?([025][1-9]|[136][0-2])?(0[1-9]|[12][0-9]|3[0-1])?\/?[0-9]{3,4}$'))
);

CREATE TABLE EMPLOYEES
(
    id           INTEGER GENERATED ALWAYS as IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,

    birth_number VARCHAR(11) NOT NULL,
    first_name   CHAR(255)   NOT NULL,
    family_name  CHAR(255)   NOT NULL,

    CONSTRAINT AK_birth_num_empl UNIQUE (birth_number),
    CONSTRAINT Check_birth_id CHECK (REGEXP_LIKE(birth_number,
                                                 '^[0-9]{2}?([025][1-9]|[136][0-2])?(0[1-9]|[12][0-9]|3[0-1])?\/?[0-9]{3,4}$'))
);

CREATE TABLE DOCTORS
(
    id           INTEGER PRIMARY KEY,

    medical_spec VARCHAR(255) NOT NULL CHECK (medical_spec IN
                                              ('ošetřující lékař', 'chirurg', 'neurolog', 'resuscitátor', 'kardiolog')),
    phone_number VARCHAR(13) CHECK (REGEXP_LIKE(phone_number, '\+[0-9]{12}')),
    email        VARCHAR(255) CHECK (REGEXP_LIKE(email,
                                                 '^[A-Za-z0-9][-0-9A-Za-z\.]*[A-Za-z0-9]@[-a-zA-Z0-9\.]+\.[a-z]{2,}$')),

    CONSTRAINT doctor_id FOREIGN KEY (id) REFERENCES EMPLOYEES (id),
    CONSTRAINT AK_phone_number_doc UNIQUE (phone_number),
    CONSTRAINT AK_email_doc UNIQUE (email)
);

CREATE TABLE DEPARTMENTS
(
    abbreviation CHAR(4) PRIMARY KEY,
    name         VARCHAR(255),
    bed_number   INTEGER NOT NULL,
    manager_id   INTEGER,

    FOREIGN KEY (manager_id) REFERENCES DOCTORS (id)
);

CREATE TABLE DEPARTMENT_MANAGER_HISTORY
(
    DEPARTMENT      CHAR(4),
    CHANGE_DATE     DATE,
    OLD_MANAGER     INTEGER,
    NEW_MANAGER     INTEGER,

    FOREIGN KEY (DEPARTMENT) REFERENCES DEPARTMENTS (ABBREVIATION),
    FOREIGN KEY (OLD_MANAGER) REFERENCES DOCTORS (ID),
    FOREIGN KEY (NEW_MANAGER) REFERENCES DOCTORS (ID)
);

CREATE TABLE NURSES
(
    id             INTEGER PRIMARY KEY,
    specialization VARCHAR(255) NOT NULL CHECK (specialization IN
                                                ('staniční sestra', 'sestra na oddělení', 'sestra na ošetřovně')),
    department     CHAR(4),

    CONSTRAINT id_numb_nurse FOREIGN KEY (id) REFERENCES EMPLOYEES (id),
    CONSTRAINT FK_id_department FOREIGN KEY (department) REFERENCES DEPARTMENTS (abbreviation)
);

CREATE TABLE DOCTORS_DEPARTMENTS
(
    doctor_id    INTEGER,
    abbreviation CHAR(4),

    CONSTRAINT PK_doc_depart PRIMARY KEY (doctor_id, abbreviation),
    CONSTRAINT FK_id_doctor_dep FOREIGN KEY (doctor_id) REFERENCES DOCTORS (id),
    CONSTRAINT FK_abbreviation_department FOREIGN KEY (abbreviation) REFERENCES DEPARTMENTS (abbreviation)
);

CREATE TABLE HOSPITALIZATIONS
(
    id         INTEGER GENERATED ALWAYS as IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,

    patient_id INTEGER NOT NULL,
    date_hosp  DATE    NOT NULL,
    diagnosis  VARCHAR(255),
    doctor_id  INTEGER,
    department CHAR(4),


    CONSTRAINT FK_id_patient FOREIGN KEY (patient_id) REFERENCES PATIENTS (id),
    CONSTRAINT FK_id_doc FOREIGN KEY (doctor_id) REFERENCES DOCTORS (id),
    CONSTRAINT FK_id_hospitalization_department FOREIGN KEY (department, doctor_id) REFERENCES DOCTORS_DEPARTMENTS (abbreviation, doctor_id)
);

CREATE TABLE NURSES_PATIENTS
(
    nurse_id           INTEGER,
    id_hospitalization INTEGER,

    CONSTRAINT PK_nurse_patient PRIMARY KEY (nurse_id, id_hospitalization),
    CONSTRAINT FK_id_nurse FOREIGN KEY (nurse_id) REFERENCES NURSES (id),
    CONSTRAINT FK_id_hospitalization FOREIGN KEY (id_hospitalization) REFERENCES HOSPITALIZATIONS (id)
);

CREATE TABLE INSPECTIONS_DESC
(
    abbreviation CHAR(4)      NOT NULL PRIMARY KEY,
    name         VARCHAR(255) NOT NULL
);

CREATE TABLE INSPECTIONS
(
    id           INTEGER GENERATED ALWAYS as IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    id_hosp      INTEGER NOT NULL,
    abbreviation CHAR(4) NOT NULL,
    date_inspect DATE    NOT NULL,
    description  VARCHAR(255),

    CONSTRAINT FK_id_hosp_insp FOREIGN KEY (id_hosp) REFERENCES HOSPITALIZATIONS (id),
    CONSTRAINT FK_abbreviation_insp FOREIGN KEY (abbreviation) REFERENCES INSPECTIONS_DESC (abbreviation)
);

CREATE TABLE DRUGS
(
    abbreviation      CHAR(4)      NOT NULL PRIMARY KEY,
    name              VARCHAR(255) NOT NULL,
    active_dose       CHAR(6)      NOT NULL,
    maximal_dose      CHAR(6)      NOT NULL,
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
    id_hosp       INTEGER NOT NULL,
    app_time      VARCHAR(50),
    app_frequency VARCHAR(50),
    dose          CHAR(6) NOT NULL,

    CONSTRAINT FK_id_hosp_dp FOREIGN KEY (id_hosp) REFERENCES HOSPITALIZATIONS (id),
    CONSTRAINT FK_abbreviation_drug FOREIGN KEY (abbreviation) REFERENCES DRUGS (abbreviation)
);

-- endregion

-- region PROCEDURES (2 procedures)

/*
    For each hospitalization, where no doctor is assigned,
    this procedure will pick a random doctor from the correct department
    and assign him to the patient.
 */
CREATE OR REPLACE PROCEDURE ASSIGN_DOCTORS IS
    C_HOSP_ID       HOSPITALIZATIONS.ID%TYPE;
    C_DOCTOR_ID     HOSPITALIZATIONS.DOCTOR_ID%TYPE;
    C_DEPARTMENT    HOSPITALIZATIONS.DEPARTMENT%TYPE;
    ASSIGNED_DOCTOR INTEGER;
    CURSOR C_HOSP IS
        SELECT ID, DOCTOR_ID, DEPARTMENT
        FROM HOSPITALIZATIONS;
BEGIN
    OPEN C_HOSP;

    LOOP
        FETCH C_HOSP INTO C_HOSP_ID, C_DOCTOR_ID, C_DEPARTMENT;
        EXIT WHEN C_HOSP%NOTFOUND;
        IF C_DOCTOR_ID IS NULL THEN
            SELECT DOCTOR_ID
            INTO ASSIGNED_DOCTOR
            FROM (SELECT *
                  FROM DOCTORS
                           JOIN DOCTORS_DEPARTMENTS DD on DOCTORS.ID = DD.DOCTOR_ID
                  WHERE DD.ABBREVIATION = C_DEPARTMENT
                  ORDER BY DBMS_RANDOM.RANDOM())
            WHERE ROWNUM = 1;

            UPDATE HOSPITALIZATIONS SET DOCTOR_ID = ASSIGNED_DOCTOR WHERE ID = C_HOSP_ID;
        END IF;
    END LOOP;

    CLOSE C_HOSP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR');
END;
-- endregion

-- region TRIGGERS (2 triggers)
CREATE OR REPLACE TRIGGER DEPARTMENT_MANAGER_HISTORY_T
    AFTER UPDATE OF MANAGER_ID ON DEPARTMENTS
    FOR EACH ROW
BEGIN
    INSERT INTO DEPARTMENT_MANAGER_HISTORY(DEPARTMENT, CHANGE_DATE, OLD_MANAGER, NEW_MANAGER)
    VALUES (:NEW.ABBREVIATION, SYSDATE, :OLD.MANAGER_ID, :NEW.MANAGER_ID);
END;

-- endregion

-- region TABLE POPULATION

INSERT INTO EMPLOYEES (BIRTH_NUMBER, FIRST_NAME, FAMILY_NAME)
VALUES ('670114/1084', 'Adam', 'Novotny');
INSERT INTO EMPLOYEES (BIRTH_NUMBER, FIRST_NAME, FAMILY_NAME)
VALUES ('630329/0015', 'Jakub', 'Kubát');
INSERT INTO EMPLOYEES (BIRTH_NUMBER, FIRST_NAME, FAMILY_NAME)
VALUES ('622930/0015', 'Karína', 'Kubátová');
INSERT INTO EMPLOYEES (BIRTH_NUMBER, FIRST_NAME, FAMILY_NAME)
VALUES ('560423/1125', 'Maria', 'Procházková');
INSERT INTO EMPLOYEES (BIRTH_NUMBER, FIRST_NAME, FAMILY_NAME)
VALUES ('780313/1325', 'Jan', 'Horák');

INSERT INTO DOCTORS (ID, MEDICAL_SPEC, PHONE_NUMBER, EMAIL)
VALUES (1, 'neurolog', '+420111222333', '123@123.cz');
INSERT INTO DOCTORS (ID, MEDICAL_SPEC, PHONE_NUMBER, EMAIL)
VALUES (2, 'chirurg', '+420121212343', '1231@123.cz');
INSERT INTO DOCTORS (ID, MEDICAL_SPEC, PHONE_NUMBER, EMAIL)
VALUES (4, 'chirurg', '+420221212343', '11231@123.cz');

INSERT INTO DEPARTMENTS (ABBREVIATION, NAME, BED_NUMBER, MANAGER_ID)
VALUES ('NEUR', 'Neurologie', 50, 1);
INSERT INTO DEPARTMENTS (ABBREVIATION, NAME, BED_NUMBER, MANAGER_ID)
VALUES ('CHIR', 'Chirurgie', 50, 2);

INSERT INTO NURSES (ID, SPECIALIZATION, DEPARTMENT)
VALUES (3, 'sestra na oddělení', 'NEUR');
INSERT INTO NURSES (ID, SPECIALIZATION, DEPARTMENT)
VALUES (5, 'sestra na ošetřovně', 'CHIR');

INSERT INTO DOCTORS_DEPARTMENTS (DOCTOR_ID, ABBREVIATION)
VALUES (1, 'NEUR');
INSERT INTO DOCTORS_DEPARTMENTS (DOCTOR_ID, ABBREVIATION)
VALUES (2, 'CHIR');
INSERT INTO DOCTORS_DEPARTMENTS (DOCTOR_ID, ABBREVIATION)
VALUES (2, 'NEUR');
INSERT INTO DOCTORS_DEPARTMENTS (DOCTOR_ID, ABBREVIATION)
VALUES (4, 'CHIR');

INSERT INTO PATIENTS (INSURANCE_NUM, FIRST_NAME, FAMILY_NAME, BIRTH_NUMBER, PHONE_NUMBER, CITY, STREET, HOUSE)
VALUES ('1201411234', 'David', 'Černý', '481016/123', '+420123456789', 'Brno', 'Husitská', '23');
INSERT INTO PATIENTS (INSURANCE_NUM, FIRST_NAME, FAMILY_NAME, BIRTH_NUMBER, PHONE_NUMBER, CITY, STREET, HOUSE)
VALUES ('1205211234', '	Milena', 'Veselá', '651231/4321', '+420123426739', 'Brno', 'Vídeňská', '7');

INSERT INTO HOSPITALIZATIONS (PATIENT_ID, DATE_HOSP, DIAGNOSIS, DEPARTMENT)
VALUES (1, TO_DATE('2019-03-25 20:03:44', 'YYYY-MM-DD HH24:MI:SS'), 'Bolesti hlavy, migrena', 'NEUR');
INSERT INTO HOSPITALIZATIONS (PATIENT_ID, DATE_HOSP, DIAGNOSIS, DEPARTMENT)
VALUES (2, TO_DATE('2020-04-21 07:04:55', 'YYYY-MM-DD HH24:MI:SS'), 'Žlučníkové kameny', 'CHIR');

INSERT INTO NURSES_PATIENTS (NURSE_ID, ID_HOSPITALIZATION)
VALUES (3, 1);
INSERT INTO NURSES_PATIENTS (NURSE_ID, ID_HOSPITALIZATION)
VALUES (5, 1);

INSERT INTO INSPECTIONS_DESC (ABBREVIATION, NAME)
VALUES ('KRBI', 'Biochemická analýza krve');
INSERT INTO INSPECTIONS_DESC (ABBREVIATION, NAME)
VALUES ('UZBR', 'Ultrazvuk břicha');
INSERT INTO INSPECTIONS_DESC (ABBREVIATION, NAME)
VALUES ('KRGL', 'Glukóza v krvi');

INSERT INTO INSPECTIONS (ID_HOSP, ABBREVIATION, DATE_INSPECT, DESCRIPTION)
VALUES (1, 'KRBI', TO_DATE('2019-03-25 21:12:23', 'YYYY-MM-DD HH24:MI:SS'), NULL);
INSERT INTO INSPECTIONS (ID_HOSP, ABBREVIATION, DATE_INSPECT, DESCRIPTION)
VALUES (2, 'UZBR', TO_DATE('2020-04-22 07:00:00', 'YYYY-MM-DD HH24:MI:SS'), NULL);
INSERT INTO INSPECTIONS (ID_HOSP, ABBREVIATION, DATE_INSPECT, DESCRIPTION)
VALUES (2, 'KRGL', TO_DATE('2020-04-22 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Hladina glukózy v krvi je normální');

INSERT INTO DRUGS (ABBREVIATION, NAME, ACTIVE_DOSE, MAXIMAL_DOSE, APPLICATION_FORM, CONTRAINDICATIONS, STRENGTH,
                   MANUFACTURER)
VALUES ('EREN', 'Erenumabum', '70mg', '140mg', 'tablety', 'Nejsou', 'Slabá', 'Supertablety');
INSERT INTO DRUGS (ABBREVIATION, NAME, ACTIVE_DOSE, MAXIMAL_DOSE, APPLICATION_FORM, CONTRAINDICATIONS, STRENGTH,
                   MANUFACTURER)
VALUES ('NOSA', 'NO-SPA', '40mg', '240mg', 'tablety', 'Nejsou', 'Slabá', 'Supertablety');

INSERT INTO DRUG_PRESCRIPTIONS (ABBREVIATION, ID_HOSP, APP_TIME, APP_FREQUENCY, DOSE)
VALUES ('EREN', 1, 'Ráno', '1/den', '70mg');
INSERT INTO DRUG_PRESCRIPTIONS (ABBREVIATION, ID_HOSP, APP_TIME, APP_FREQUENCY, DOSE)
VALUES ('NOSA', 2, 'Ráno,Večer', '2/den', '40mg');

-- endregion

-- region TRIGGER DEMONSTRATION

-- Table is empty
SELECT * FROM DEPARTMENT_MANAGER_HISTORY;

-- Make a change
UPDATE DEPARTMENTS
SET MANAGER_ID = 2
WHERE ABBREVIATION = 'NEUR';

-- Table includes information about the change
SELECT * FROM DEPARTMENT_MANAGER_HISTORY;
-- endregion

-- region PROCEDURE DEMONSTRATION

-- Both IDs are NULL
SELECT DOCTOR_ID FROM HOSPITALIZATIONS;

-- Run the procedure
BEGIN
    ASSIGN_DOCTORS();
END;

-- Both IDs are not NULL and contain a random doctor from the correct department
SELECT H.DOCTOR_ID, H.DEPARTMENT AS HOSP_DEPARTMENT, DD.ABBREVIATION AS DOC_DEPARTMENT
FROM HOSPITALIZATIONS H
JOIN DOCTORS_DEPARTMENTS DD ON H.DOCTOR_ID = DD.DOCTOR_ID
WHERE H.DEPARTMENT = DD.ABBREVIATION;

-- endregion
