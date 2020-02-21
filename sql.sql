/*
 IDS - 4. cast projektu
 Autori: xkovar82, xkocur02
 Datum: 28.4.2019
*/

SET SERVEROUTPUT ON;

-- Vymazani tabulek
DROP TABLE Uzivatel CASCADE CONSTRAINTS;
DROP TABLE Technika CASCADE CONSTRAINTS;
DROP TABLE Oddeleni CASCADE CONSTRAINTS;
DROP TABLE Mistnost CASCADE CONSTRAINTS;
DROP TABLE Ucebna CASCADE CONSTRAINTS;
DROP TABLE Misto_v_ucebne CASCADE CONSTRAINTS;
DROP TABLE R_spravuje CASCADE CONSTRAINTS;

-- Vymazani sekvenci
DROP SEQUENCE uzivatel_seq;
DROP SEQUENCE technika_seq;
DROP SEQUENCE misto_v_uc_seq;

-- INDEX: Pocet techniky, kterou pouziva uzivatel
DROP INDEX index_pocet_techniky;

DROP MATERIALIZED VIEW mv;

-- Vytvoreni tabulek --
CREATE TABLE Uzivatel (
    UserID int NOT NULL PRIMARY KEY,
    privilegia int NOT NULL,
    xlogin varchar(8) NOT NULL,
    jmeno varchar(20) NOT NULL,
    prijmeni varchar(30) NOT NULL,
    ulice varchar(255) NOT NULL,
    mesto varchar(255) NOT NULL,
    psc int NOT NULL,
    email varchar(255) NOT NULL
);

CREATE TABLE Technika (
    TechID int NOT NULL PRIMARY KEY,
    vyrobce varchar(255) NOT NULL,
    popis varchar(255) NOT NULL,
    datumPridani varchar(255) NOT NULL,
    UserID int,
    MistoID int,
    MistnostID int
);

CREATE TABLE Oddeleni(
    OddeleniID int NOT NULL PRIMARY KEY,
    popis varchar(255) NOT NULL,
    pocetMistnosti int NOT NULL
);

CREATE TABLE Mistnost(
    MistnostID varchar(5) NOT NULL PRIMARY KEY,
    typ varchar(255) NOT NULL,
    datumEditace DATE NOT NULL,
    OddeleniID int NOT NULL
);

CREATE TABLE Ucebna(
    UcebnaID varchar(5) NOT NULL PRIMARY KEY,
    pocetMist int,
    FK_MistnostID varchar(5), 
    FOREIGN KEY (FK_MistnostID) REFERENCES Mistnost
);

CREATE TABLE Misto_v_ucebne(
    MistoID int NOT NULL PRIMARY KEY,
    UcebnaID varchar(5) NOT NULL
);

-- Vytvoreni vztahu

ALTER TABLE Technika ADD CONSTRAINT FK_pouziva FOREIGN KEY (UserID) REFERENCES Uzivatel;

CREATE TABLE R_Spravuje(
    UserID int NOT NULL,
    TechID int
);
ALTER TABLE R_Spravuje ADD CONSTRAINT FK_uzivatel FOREIGN KEY (UserID) REFERENCES Uzivatel;
ALTER TABLE R_Spravuje ADD CONSTRAINT FK_technika FOREIGN KEY (TechID) REFERENCES Technika;
ALTER TABLE R_Spravuje ADD CONSTRAINT PK_spravuje PRIMARY KEY (UserID, TechID);

ALTER TABLE Technika ADD CONSTRAINT FK_patri_k FOREIGN KEY (MistoID) REFERENCES Misto_v_ucebne;

ALTER TABLE Technika ADD CONSTRAINT FK_je_umistena_v FOREIGN KEY (MistnostID) REFERENCES Mistnost;

ALTER TABLE Misto_v_ucebne ADD CONSTRAINT FK_je_soucasti FOREIGN KEY (UcebnaID) REFERENCES Ucebna;

ALTER TABLE Mistnost ADD CONSTRAINT FK_patri_do FOREIGN KEY (OddeleniID) REFERENCES Oddeleni;

-- Vytvoreni triggeru

-- Triggery pro automatickou inkrementaci

-- ID uzivatelu
CREATE SEQUENCE uzivatel_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER uzivatel_autoinc
BEFORE INSERT ON Uzivatel
FOR EACH ROW
BEGIN
    :new.UserID := uzivatel_seq.nextval;
END;
/

-- ID techniky
CREATE SEQUENCE technika_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER technika_autoinc
BEFORE INSERT ON Technika
FOR EACH ROW
BEGIN
    :new.TechID := technika_seq.nextval;
END;
/

-- ID mista
CREATE SEQUENCE misto_v_uc_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER misto_v_uc_autoinc
BEFORE INSERT ON Misto_v_ucebne
FOR EACH ROW
BEGIN
    :new.MistoID := misto_v_uc_seq.nextval;
END;
/


-- Kontrola spravnosti xloginu
CREATE OR REPLACE TRIGGER uzivatel_check_xlog
BEFORE INSERT OR UPDATE OF xlogin ON Uzivatel
FOR EACH ROW
BEGIN
  IF NOT REGEXP_LIKE(:new.xlogin, '^x[a-zA-Z]{5}[0-9a-f]{2}$') THEN
    RAISE_APPLICATION_ERROR(-20000, 'Chyba - spatny format xloginu');
  END IF;
END;
/

-- Kontrola spravnosti emailu

DROP TRIGGER uzivatel_check_email;
CREATE OR REPLACE TRIGGER uzivatel_check_email
BEFORE INSERT OR UPDATE OF email ON Uzivatel
FOR EACH ROW
BEGIN
  IF NOT REGEXP_LIKE(:new.email, '^\S+@\S+.\S+$') THEN
    RAISE_APPLICATION_ERROR(-20001, 'Chyba - spatny format emailove adresy');
  END IF;
END;
/

-- Definice proceur

-- uzivatele se spatnym formatem psc
CREATE OR REPLACE PROCEDURE check_psc AS
CURSOR uzivatele IS SELECT * FROM Uzivatel;
pocet INTEGER;
u uzivatele%ROWTYPE;
BEGIN
	pocet := 0;
	dbms_output.put_line('Uzivatele se spatnym psc: ');
	OPEN uzivatele;
	LOOP
		FETCH uzivatele INTO u ;
		EXIT WHEN uzivatele%NOTFOUND;
		IF LENGTH(to_char(u.psc)) != 5 THEN
			dbms_output.put_line('Uzivatel: ' || u.jmeno || ' ' || u.prijmeni || ' ' || u.xlogin || ' PSC:' || u.psc);
			pocet := pocet +1;
		END IF;
	END LOOP;
	dbms_output.put_line('Celkem: ' || pocet);
	CLOSE uzivatele;
EXCEPTION
	WHEN OTHERS THEN
		RAISE_APPLICATION_ERROR(-20005, 'chyba procedury');
END;
/

-- Percentualni vypis dle zastoupenosti jednotlivych vyrobcu techniky
CREATE OR REPLACE PROCEDURE tech_perc AS
CURSOR veskera_tech IS SELECT vyrobce FROM Technika;
CURSOR jednotliva_tech IS SELECT DISTINCT vyrobce FROM Technika;
pocet_vyskytu INTEGER;
pocet_zar INTEGER;
percentualni_zastoupeni INTEGER;
nazev_vyrobce VARCHAR(255);
nazev_vyrobce_porov VARCHAR(255);
    
BEGIN
    OPEN jednotliva_tech;
    SELECT COUNT(*) INTO pocet_zar FROM Technika;
    
    dbms_output.put_line('Nazev vyrobce' || CHR(9) || '|' || CHR(9) || 'Percentualni zastoupeni');
    
    LOOP
        OPEN veskera_tech;
        pocet_vyskytu := 0;
        FETCH jednotliva_tech INTO nazev_vyrobce;
        EXIT WHEN jednotliva_tech%NOTFOUND;
        LOOP
            FETCH veskera_tech INTO nazev_vyrobce_porov;
            EXIT WHEN veskera_tech%NOTFOUND;
            IF nazev_vyrobce = nazev_vyrobce_porov THEN
                pocet_vyskytu := pocet_vyskytu + 1;
            END IF;
        END LOOP;
        
        percentualni_zastoupeni := (pocet_vyskytu * 100) / pocet_zar;

        dbms_output.put_line(nazev_vyrobce || CHR(9) || '|' || CHR(9) || percentualni_zastoupeni || '%');
        CLOSE veskera_tech;
    END LOOP;

    CLOSE jednotliva_tech;
    
EXCEPTION WHEN ZERO_DIVIDE THEN
    RAISE_APPLICATION_ERROR(-20010, 'chyba deleni nulou');
END;
/

-- Naplneni daty --

INSERT INTO Uzivatel (privilegia, xlogin, jmeno, prijmeni, ulice, mesto, psc, email) 
VALUES (2, 'xcerny01', 'Jan', 'Èerný', 'Božetìchova 2', 'Brno', '617600', 'xjance01@stud.fit.vutbr.cz');

INSERT INTO Uzivatel (privilegia, xlogin, jmeno, prijmeni, ulice, mesto, psc, email) 
VALUES (1, 'xnovot32', 'Marek', 'Novotný', 'Dlouhá 19', 'Olomouc', '77900', 'xnovot32@stud.fit.vutbr.cz');

INSERT INTO Uzivatel (privilegia, xlogin, jmeno, prijmeni, ulice, mesto, psc, email) 
VALUES (1, 'xhruby01', 'Rudolf', 'Hrubý', 'Krátká 1', 'Praha', '22900', 'xhruby01@stud.fit.vutbr.cz');

INSERT INTO Uzivatel (privilegia, xlogin, jmeno, prijmeni, ulice, mesto, psc, email) 
VALUES (1, 'xkrump32', 'Petr', 'Krum', 'Úzká 42', 'Brno', '77900', 'xkrump32@stud.fit.vutbr.cz');


INSERT INTO Technika (vyrobce, popis, datumPridani)
VALUES ('Benq', 'Monitor 23, s.c: 23432E214', to_date('01-05-2018','MM-DD-YYYY'));

INSERT INTO Technika (vyrobce, popis, datumPridani)
VALUES ('Acer', 'PC, Core i5, 8GB RAM, 256GB SSD', to_date('06-05-2018','MM-DD-YYYY'));

INSERT INTO Technika (vyrobce, popis, datumPridani)
VALUES ('Acer', 'PC, Core i5, 8GB RAM, 256GB SSD', to_date('08-05-2018','MM-DD-YYYY'));

INSERT INTO Technika (vyrobce, popis, datumPridani)
VALUES ('Acer', 'PC, Core i5, 8GB RAM, 256GB SSD', to_date('09-05-2018','MM-DD-YYYY'));

INSERT INTO Technika (vyrobce, popis, datumPridani)
VALUES ('HP', 'projektor sn:1223232:2017', to_date('11-05-2018','MM-DD-YYYY'));

INSERT INTO Technika (vyrobce, popis, datumPridani)
VALUES ('HP', 'projektor sn:0723532:2017', to_date('11-05-2018','MM-DD-YYYY'));


INSERT INTO Oddeleni (OddeleniID, popis, pocetMistnosti) 
VALUES (4, 'Blok D', 3);

INSERT INTO Oddeleni (OddeleniID, popis, pocetMistnosti) 
VALUES (14, 'Blok N', 8);

INSERT INTO Oddeleni (OddeleniID, popis, pocetMistnosti) 
VALUES (13, 'Blok M', 8);


INSERT INTO Mistnost (MistnostID, typ, datumEditace, OddeleniID) 
VALUES ('D105', 'Pøednášková místnost', to_date('01-01-2018','MM-DD-YYYY'), 4);

INSERT INTO Ucebna (UcebnaID, pocetMist) 
VALUES ('N204', 20);


INSERT INTO Misto_v_ucebne (UcebnaID) 
VALUES ('N204');
INSERT INTO Misto_v_ucebne (UcebnaID) 
VALUES ('N204');
INSERT INTO Misto_v_ucebne (UcebnaID)
VALUES ('N204');
INSERT INTO Misto_v_ucebne (UcebnaID) 
VALUES ('N204');

---------------------------------------------------------------------

-- Prideleni prav dalsimu uzivateli
GRANT ALL ON Uzivatel TO xkocur02;
GRANT ALL ON Technika TO xkocur02;
GRANT ALL ON Oddeleni TO xkocur02;
GRANT ALL ON Mistnost TO xkocur02;
GRANT ALL ON Ucebna TO xkocur02;
GRANT ALL ON Misto_v_ucebne TO xkocur02;
GRANT ALL ON R_Spravuje TO xkocur02;

GRANT EXECUTE ON check_psc TO xkocur02;
GRANT EXECUTE ON tech_perc TO xkocur02;

-- Spusteni procedur
EXECUTE check_psc;
EXECUTE tech_perc;


-- Explain plan

-- INDEX: Pocet techniky, kterou pouziva uzivatel
DROP INDEX index_pocet_techniky;

EXPLAIN PLAN FOR
  SELECT u.UserID, u.prijmeni, count(*) AS pocet_techniky
  FROM Uzivatel u, Technika t
  WHERE u.UserID = t.UserID
  GROUP BY u.UserID, u.prijmeni;
SELECT plan_table_output FROM table (dbms_xplan.display());

CREATE INDEX index_pocet_techniky ON Technika(UserID); 

EXPLAIN PLAN FOR
  SELECT u.UserID, u.prijmeni, count(*) AS pocet_techniky
  FROM Uzivatel u, Technika t
  WHERE u.UserID = t.UserID
  GROUP BY u.UserID, u.prijmeni;
SELECT plan_table_output FROM table (dbms_xplan.display());

-- Materialized view

CREATE MATERIALIZED VIEW mv
NOLOGGING
CACHE
BUILD IMMEDIATE
REFRESH ON COMMIT
AS SELECT *
FROM Uzivatel;

GRANT ALL ON mv TO xkocur02;

SELECT * FROM mv;

INSERT INTO XKOVAR82.Uzivatel (privilegia, xlogin, jmeno, prijmeni, ulice, mesto, psc, email) 
VALUES (2, 'xpepaj00', 'Josef', 'Pepa', 'kopec 5', 'Brno', '61600', 'xpepaj00@stud.fit.vutbr.cz');

COMMIT;
SELECT * FROM mv;