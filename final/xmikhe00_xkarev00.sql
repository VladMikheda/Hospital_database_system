/**
  * Project: Návrh a implementace relační databáze
  *
  * File: xmikhe00_xkarev00.sql
  * Subject: IDS 2022
  *
  *@author: Vladislav Mikheda xmikhe00
  *@author: Denis Karev xkarev00
 */

----------------------------------------region TABLE DELETION-------------------------------------------

DROP TABLE PATIENTS CASCADE CONSTRAINTS;
DROP TABLE EMPLOYEES CASCADE CONSTRAINTS;
DROP TABLE DOCTORS CASCADE CONSTRAINTS;
DROP TABLE DEPARTMENTS CASCADE CONSTRAINTS;
DROP TABLE DEPARTMENT_MANAGER_HISTORY CASCADE CONSTRAINTS;
DROP TABLE NURSES CASCADE CONSTRAINTS;
DROP TABLE DOCTORS_DEPARTMENTS CASCADE CONSTRAINTS;
DROP TABLE DOCTOR_DEPARTMENT_HISTORY CASCADE CONSTRAINTS;
DROP TABLE HOSPITALIZATIONS CASCADE CONSTRAINTS;
DROP TABLE NURSES_PATIENTS CASCADE CONSTRAINTS;
DROP TABLE INSPECTIONS_DESC CASCADE CONSTRAINTS;
DROP TABLE INSPECTIONS CASCADE CONSTRAINTS;
DROP TABLE DRUGS CASCADE CONSTRAINTS;
DROP TABLE DRUG_PRESCRIPTIONS CASCADE CONSTRAINTS;
DROP MATERIALIZED VIEW PATIENTINSPECTIONS;
DROP MATERIALIZED VIEW COUNT_PATIENT;
-- DROP PROCEDURE CREATE_EMPLOYEE;
-- DROP PROCEDURE ASSIGN_DOCTORS;

----------------------------------------------endregion-------------------------------------------------


----------------------------------------region TABLE CREATION-------------------------------------------

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
    DEPARTMENT  CHAR(4),
    CHANGE_DATE DATE,
    OLD_MANAGER INTEGER,
    NEW_MANAGER INTEGER,

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

CREATE TABLE DOCTOR_DEPARTMENT_HISTORY
(
    DOCTOR_ID      INTEGER     NOT NULL,
    ACTION         VARCHAR(32) NOT NULL CHECK ( ACTION IN
                                                ('NEW', 'CHANGED', 'REMOVED')),
    DEPARTMENT     CHAR(4)     NOT NULL,
    OLD_DEPARTMENT CHAR(4),
    CHANGE_DATE    DATE        NOT NULL,

    CONSTRAINT FK_ID_DOCTOR_HISTORY FOREIGN KEY (DOCTOR_ID) REFERENCES DOCTORS (ID),
    CONSTRAINT FK_ID_DEPARTMENT_HISTORY FOREIGN KEY (DEPARTMENT) REFERENCES DEPARTMENTS (ABBREVIATION),
    CONSTRAINT FK_ID_OLD_DEPARTMENT_HISTORY FOREIGN KEY (OLD_DEPARTMENT) REFERENCES DEPARTMENTS (ABBREVIATION)
);

CREATE TABLE HOSPITALIZATIONS
(
    id         INTEGER GENERATED ALWAYS as IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,

    patient_id INTEGER NOT NULL,
    date_hosp  DATE    NOT NULL,
    date_disch DATE,
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

----------------------------------------------endregion-------------------------------------------------

-----------------------------------region PROCEDURES (2 procedures)-------------------------------------

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
        FROM HOSPITALIZATIONS
        WHERE DOCTOR_ID IS NULL;
BEGIN
    OPEN C_HOSP;

    LOOP
        FETCH C_HOSP INTO C_HOSP_ID, C_DOCTOR_ID, C_DEPARTMENT;
        EXIT WHEN C_HOSP%NOTFOUND;
        SELECT DOCTOR_ID
        INTO ASSIGNED_DOCTOR
        FROM (SELECT *
              FROM DOCTORS
                       JOIN DOCTORS_DEPARTMENTS DD on DOCTORS.ID = DD.DOCTOR_ID
              WHERE DD.ABBREVIATION = C_DEPARTMENT
              ORDER BY DBMS_RANDOM.RANDOM())
        WHERE ROWNUM = 1;

        UPDATE HOSPITALIZATIONS SET DOCTOR_ID = ASSIGNED_DOCTOR WHERE ID = C_HOSP_ID;
    END LOOP;

    CLOSE C_HOSP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected exception in the ASSIGN_DOCTORS procedure.');
END;
/

/**
  Creates a doctor or a nurse, depending on the IN_IS_DOCTOR value.
 */
CREATE OR REPLACE PROCEDURE CREATE_EMPLOYEE(
    IN_IS_DOCTOR BOOLEAN,
    IN_BIRTH_NUMBER EMPLOYEES.BIRTH_NUMBER%TYPE,
    IN_FIRST_NAME EMPLOYEES.FIRST_NAME%TYPE,
    IN_FAMILY_NAME EMPLOYEES.FAMILY_NAME%TYPE,
    IN_SPECIALIZATION VARCHAR,
    IN_DEPARTMENT DEPARTMENTS.ABBREVIATION%TYPE,
    IN_PHONE_NUMBER DOCTORS.PHONE_NUMBER%TYPE DEFAULT NULL,
    IN_EMAIL DOCTORS.EMAIL%TYPE DEFAULT NULL
) IS
    EMPLOYEE_ID EMPLOYEES.ID%TYPE;
BEGIN
    INSERT INTO EMPLOYEES(BIRTH_NUMBER, FIRST_NAME, FAMILY_NAME)
    VALUES (IN_BIRTH_NUMBER, IN_FIRST_NAME, IN_FAMILY_NAME);

    SELECT ID
    INTO EMPLOYEE_ID
    FROM EMPLOYEES
    WHERE BIRTH_NUMBER = IN_BIRTH_NUMBER
      AND FIRST_NAME = IN_FIRST_NAME
      AND FAMILY_NAME = IN_FAMILY_NAME;

    IF IN_IS_DOCTOR THEN
        INSERT INTO DOCTORS(ID, MEDICAL_SPEC, PHONE_NUMBER, EMAIL)
        VALUES (EMPLOYEE_ID, IN_SPECIALIZATION, IN_PHONE_NUMBER, IN_EMAIL);

        INSERT INTO DOCTORS_DEPARTMENTS(DOCTOR_ID, ABBREVIATION)
        VALUES (EMPLOYEE_ID, IN_DEPARTMENT);
    ELSE
        INSERT INTO NURSES(ID, SPECIALIZATION, DEPARTMENT)
        VALUES (EMPLOYEE_ID, IN_SPECIALIZATION, IN_DEPARTMENT);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected exception in the CREATE_EMPLOYEE procedure.');
END;
/

----------------------------------------------endregion-------------------------------------------------

-------------------------------------region TRIGGERS (2 triggers)---------------------------------------

CREATE OR REPLACE TRIGGER DEPARTMENT_MANAGER_HISTORY_T
    AFTER UPDATE OF MANAGER_ID
    ON DEPARTMENTS
    FOR EACH ROW
BEGIN
    INSERT INTO DEPARTMENT_MANAGER_HISTORY(DEPARTMENT, CHANGE_DATE, OLD_MANAGER, NEW_MANAGER)
    VALUES (:NEW.ABBREVIATION, SYSDATE, :OLD.MANAGER_ID, :NEW.MANAGER_ID);
END;
/

CREATE OR REPLACE TRIGGER DOCTOR_DEPARTMENT_HISTORY
    AFTER INSERT OR
        UPDATE OF ABBREVIATION OR
        DELETE
    ON DOCTORS_DEPARTMENTS
    FOR EACH ROW
DECLARE
    DOC_ID  INTEGER;
    OP_TYPE VARCHAR(32);
    DEP_VAL CHAR(4);
    OLD_VAL CHAR(4) := NULL;
BEGIN
    CASE
        WHEN INSERTING THEN DEP_VAL := :NEW.ABBREVIATION;
                            DOC_ID := :NEW.DOCTOR_ID;
                            OP_TYPE := 'NEW';
        WHEN UPDATING THEN DEP_VAL := :NEW.ABBREVIATION;
                           DOC_ID := :NEW.DOCTOR_ID;
                           OLD_VAL := :OLD.ABBREVIATION;
                           OP_TYPE := 'CHANGED';
        WHEN DELETING THEN DEP_VAL := :OLD.ABBREVIATION;
                           DOC_ID := :OLD.DOCTOR_ID;
                           OP_TYPE := 'REMOVED';
        END CASE;

    INSERT INTO DOCTOR_DEPARTMENT_HISTORY(DOCTOR_ID, ACTION, DEPARTMENT, OLD_DEPARTMENT, CHANGE_DATE)
    VALUES (DOC_ID, OP_TYPE, DEP_VAL, OLD_VAL, SYSDATE);
END;
/

----------------------------------------------endregion-------------------------------------------------

---------------------------------------region TABLE POPULATION------------------------------------------

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
VALUES ('1205211234', 'Milena', 'Veselá', '651231/4321', '+420123426739', 'Brno', 'Vídeňská', '7');
INSERT INTO PATIENTS (INSURANCE_NUM, FIRST_NAME, FAMILY_NAME, BIRTH_NUMBER, PHONE_NUMBER, CITY, STREET, HOUSE)
VALUES ('1105211234', 'Milena', 'Mudrá', '621231/4321', '+420123426737', 'Brno', 'Masarykova ', '10');

INSERT INTO HOSPITALIZATIONS (PATIENT_ID, DATE_HOSP, DATE_DISCH, DIAGNOSIS, DEPARTMENT)
VALUES (1, TO_DATE('2019-03-25 20:03:44', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2019-04-20 07:04:44', 'YYYY-MM-DD HH24:MI:SS'), 'Bolesti hlavy, migrena', 'NEUR');
INSERT INTO HOSPITALIZATIONS (PATIENT_ID, DATE_HOSP, DATE_DISCH, DIAGNOSIS, DEPARTMENT)
VALUES (2, TO_DATE('2020-04-21 07:04:55', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2020-04-28 07:03:18', 'YYYY-MM-DD HH24:MI:SS'), 'Žlučníkové kameny', 'CHIR');
INSERT INTO HOSPITALIZATIONS (PATIENT_ID, DATE_HOSP, DIAGNOSIS, DEPARTMENT)
VALUES (3, SYSDATE, 'Žlučníkové kameny', 'CHIR');

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
VALUES (1, 'KRBI', TO_DATE('2019-03-26 21:12:23', 'YYYY-MM-DD HH24:MI:SS'), NULL);
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

----------------------------------------------endregion-------------------------------------------------

-------------------------------------region TRIGGER DEMONSTRATION---------------------------------------

-- Table is empty
SELECT *
FROM DEPARTMENT_MANAGER_HISTORY;

-- Make a change
UPDATE DEPARTMENTS
SET MANAGER_ID = 2
WHERE ABBREVIATION = 'NEUR';

-- Table includes information about the change
SELECT *
FROM DEPARTMENT_MANAGER_HISTORY;

-- Table contains only NEW actions
SELECT *
FROM DOCTOR_DEPARTMENT_HISTORY;

-- Make an update
UPDATE DOCTORS_DEPARTMENTS
SET ABBREVIATION = 'NEUR'
WHERE DOCTOR_ID = 4;

-- Make a deletion
DELETE
FROM DOCTORS_DEPARTMENTS
WHERE DOCTOR_ID = 4;

-- Table contains all types of actions
SELECT *
FROM DOCTOR_DEPARTMENT_HISTORY;

----------------------------------------------endregion-------------------------------------------------

------------------------------------region PROCEDURE DEMONSTRATION--------------------------------------

-- Both IDs are NULL
SELECT DOCTOR_ID
FROM HOSPITALIZATIONS;

-- There are no employees with birth numbers 760425/1237 and 122222/1237.
SELECT *
FROM EMPLOYEES
WHERE BIRTH_NUMBER = '760425/1237'
   OR BIRTH_NUMBER = '122222/1237';

-- Run procedures
BEGIN
    ASSIGN_DOCTORS();

    CREATE_EMPLOYEE(TRUE, '760425/1237', 'John',
                    'Dow', 'chirurg', 'NEUR', '+420123456789', '1234@123.cz');

    CREATE_EMPLOYEE(FALSE, '122222/1237', 'Jakub',
                    'Cerny', 'sestra na oddělení', 'NEUR');
END;
/
-- Both IDs are not NULL and contain a random doctor from the correct department
SELECT H.ID, H.DOCTOR_ID, H.DEPARTMENT AS HOSP_DEPARTMENT, DD.ABBREVIATION AS DOC_DEPARTMENT
FROM HOSPITALIZATIONS H
         JOIN DOCTORS_DEPARTMENTS DD ON H.DOCTOR_ID = DD.DOCTOR_ID
WHERE H.DEPARTMENT = DD.ABBREVIATION
ORDER BY H.ID;

-- There is a new doctor "John Dow"
SELECT E.ID,
       E.BIRTH_NUMBER,
       E.FIRST_NAME,
       E.FAMILY_NAME,
       D.MEDICAL_SPEC,
       D.PHONE_NUMBER,
       D.EMAIL,
       DD.ABBREVIATION
FROM EMPLOYEES E
         JOIN DOCTORS D on E.ID = D.ID
         JOIN DOCTORS_DEPARTMENTS DD on D.ID = DD.DOCTOR_ID
WHERE BIRTH_NUMBER = '760425/1237';

-- There is a new nurse "Jakub Cerny"
SELECT E.ID, E.BIRTH_NUMBER, E.FIRST_NAME, E.FAMILY_NAME, N.SPECIALIZATION, N.DEPARTMENT
FROM EMPLOYEES E
         JOIN NURSES N on E.ID = N.ID
WHERE BIRTH_NUMBER = '122222/1237';


-- Both IDs are not NULL and contain a random doctor from the correct department
SELECT H.ID, H.DOCTOR_ID, H.DEPARTMENT AS HOSP_DEPARTMENT, DD.ABBREVIATION AS DOC_DEPARTMENT
FROM HOSPITALIZATIONS H
         JOIN DOCTORS_DEPARTMENTS DD ON H.DOCTOR_ID = DD.DOCTOR_ID
WHERE H.DEPARTMENT = DD.ABBREVIATION
ORDER BY H.ID;

----------------------------------------------endregion-------------------------------------------------

----------------------------------------region Access rights--------------------------------------------

GRANT SELECT, INSERT, UPDATE, DELETE ON PATIENTS TO xkarev00;
GRANT SELECT, INSERT, UPDATE, DELETE ON EMPLOYEES TO xkarev00;
GRANT SELECT, INSERT, UPDATE, DELETE ON DOCTORS TO xkarev00;
GRANT SELECT, INSERT, UPDATE, DELETE ON DEPARTMENTS TO xkarev00;
GRANT SELECT, INSERT, UPDATE, DELETE ON DEPARTMENT_MANAGER_HISTORY TO xkarev00;
GRANT SELECT, INSERT, UPDATE, DELETE ON NURSES TO xkarev00;
GRANT SELECT, INSERT, UPDATE, DELETE ON DOCTORS_DEPARTMENTS TO xkarev00;
GRANT SELECT, INSERT, UPDATE, DELETE ON DOCTOR_DEPARTMENT_HISTORY TO xkarev00;
GRANT SELECT, INSERT, UPDATE, DELETE ON HOSPITALIZATIONS TO xkarev00;
GRANT SELECT, INSERT, UPDATE, DELETE ON NURSES_PATIENTS TO xkarev00;
GRANT SELECT, INSERT, UPDATE, DELETE ON INSPECTIONS_DESC TO xkarev00;
GRANT SELECT, INSERT, UPDATE, DELETE ON INSPECTIONS TO xkarev00;
GRANT SELECT, INSERT, UPDATE, DELETE ON DRUGS TO xkarev00;
GRANT SELECT, INSERT, UPDATE, DELETE ON DRUG_PRESCRIPTIONS TO xkarev00;
GRANT EXECUTE ON ASSIGN_DOCTORS TO xkarev00;
GRANT EXECUTE ON CREATE_EMPLOYEE TO xkarev00;

----------------------------------------------endregion-------------------------------------------------

---------------------------------------------region VIEW------------------------------------------------

-- the first view will show how many patients will be examined today
CREATE MATERIALIZED VIEW PatientInspections BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND AS
SELECT P.family_name, P.first_name, P.birth_number, I.abbreviation
FROM XMIKHE00.INSPECTIONS I
         JOIN XMIKHE00.HOSPITALIZATIONS H ON I.id_hosp = H.id
         JOIN XMIKHE00.PATIENTS P ON P.id = H.patient_id
WHERE TO_CHAR(date_inspect, 'YYYY-MM-DD') = TO_CHAR(SYSDATE, 'YYYY-MM-DD');


-- functionality demonstration
    -- create materialized view
    -- select
    SELECT *
    FROM  PATIENTINSPECTIONS;
    --add new info
    INSERT INTO XMIKHE00.INSPECTIONS (ID_HOSP, ABBREVIATION, DATE_INSPECT, DESCRIPTION)
    VALUES (3, 'KRBI', SYSDATE, NULL);
    -- select (materialized view not refresh)
    SELECT *
    FROM  PATIENTINSPECTIONS;
    -- refresh view
    BEGIN
        dbms_mview.refresh('PatientInspections', 'C');
    END;
    /
    -- select (materialized view refresh)
    SELECT *
    FROM  PATIENTINSPECTIONS;
--------------------------------------

-- the second view displays the number of patients for the entire work of the hospital
CREATE MATERIALIZED VIEW count_patient BUILD IMMEDIATE REFRESH COMPLETE ON COMMIT AS
SELECT COUNT(*) AS count_patient
FROM XMIKHE00.PATIENTS;

SELECT *
FROM COUNT_PATIENT;

INSERT INTO XMIKHE00.PATIENTS (INSURANCE_NUM, FIRST_NAME, FAMILY_NAME, BIRTH_NUMBER, PHONE_NUMBER, CITY, STREET, HOUSE)
VALUES ('1105211231', 'Alena', 'Dobrá', '611231/4321', '+420123423737', 'Brno', 'Masarykova ', '10');

-- select (materialized view not refresh)
SELECT *
FROM COUNT_PATIENT;

--commit
COMMIT;

 -- select (materialized view refresh)
SELECT *
FROM COUNT_PATIENT;


----------------------------------------------endregion-------------------------------------------------

---------------------------------------------region INDEX------------------------------------------------

/**
  How many prescriptions does every drug have
  Example usage: how many drugs should the hospital order.
 */
EXPLAIN PLAN SET STATEMENT_ID = 'table1' INTO plan_table FOR
SELECT DP.abbreviation AS drug_name, COUNT(*) AS pacient_number
FROM HOSPITALIZATIONS H
         JOIN DRUG_PRESCRIPTIONS DP ON H.id = DP.id_hosp
WHERE date_disch is null
GROUP BY DP.ABBREVIATION;

SELECT *
FROM TABLE (DBMS_XPLAN.DISPLAY('PLAN_TABLE', 'table1'));

-- create an index for "inspection" that will join multiple columns to speed up searches
CREATE INDEX hosp_index ON HOSPITALIZATIONS (date_disch, id);
CREATE INDEX drug_pre_index ON DRUG_PRESCRIPTIONS (ABBREVIATION, id_hosp);

EXPLAIN PLAN SET STATEMENT_ID = 'table1' INTO plan_table FOR
SELECT DP.abbreviation AS drug_name, COUNT(*) AS pacient_number
FROM HOSPITALIZATIONS H
         JOIN DRUG_PRESCRIPTIONS DP ON H.id = DP.id_hosp
WHERE date_disch is null
GROUP BY DP.ABBREVIATION;

SELECT *
FROM TABLE (DBMS_XPLAN.DISPLAY('PLAN_TABLE', 'table1'));

-- drop index
DROP INDEX drug_pre_index;
DROP INDEX hosp_index;

----------------------------------------------endregion-------------------------------------------------
