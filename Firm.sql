SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema kompanija
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `kompanija` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `kompanija` ;

-- -----------------------------------------------------
-- Table `kompanija`.`zaposlenik`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `kompanija`.`zaposlenik` (
  `idKorisnik` INT NOT NULL AUTO_INCREMENT,
  `Ime` VARCHAR(45) NOT NULL,
  `Prezime` VARCHAR(45) NOT NULL,
  `korisnickoime` VARCHAR(45) NOT NULL,
  `kratkabiografija` VARCHAR(150) NOT NULL,
  `fotografija` INT NULL DEFAULT NULL,
  `datum_rodjenja` DATE,
  `mesto_rodjenja` VARCHAR(100),
  PRIMARY KEY (`idKorisnik`))
ENGINE = InnoDB
AUTO_INCREMENT = 4
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

-- -----------------------------------------------------
-- Table `kompanija`.`korespodencija`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `kompanija`.`korespodencija` (
  `porukeID` INT NOT NULL AUTO_INCREMENT,
  `posiljalacID` INT NOT NULL,
  `primalacID` INT NOT NULL,
  `naslov` VARCHAR(45) NULL DEFAULT NULL,
  `tekst` VARCHAR(180) NOT NULL,
  `procitana` SET('yes', 'no') NOT NULL,
  `datumslanja` DATETIME NOT NULL,
  PRIMARY KEY (`porukeID`),
  INDEX `posiljalacID_idx` (`posiljalacID` ASC) VISIBLE,
  INDEX `primalacID_idx` (`primalacID` ASC) VISIBLE,
  CONSTRAINT `posiljalacID`
    FOREIGN KEY (`posiljalacID`)
    REFERENCES `kompanija`.`zaposlenik` (`idKorisnik`),
  CONSTRAINT `primalacID`
    FOREIGN KEY (`primalacID`)
    REFERENCES `kompanija`.`zaposlenik` (`idKorisnik`))
ENGINE = InnoDB
AUTO_INCREMENT = 5
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

-- -----------------------------------------------------
-- Table `kompanija`.`plate`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `kompanija`.`plate` (
  `idplate` INT NOT NULL AUTO_INCREMENT,
  `korisnikID` INT NOT NULL,
  `Iznos` DECIMAL(10,2) NOT NULL,
  `datumisplate` DATETIME NOT NULL,
  `Isplacena` SET('yes', 'no') NOT NULL,
  `ugovor` SET('odredjeno', 'neodredjeno') NOT NULL,
  PRIMARY KEY (`idplate`),
  INDEX `korisnikID_idx` (`korisnikID` ASC) VISIBLE,
  CONSTRAINT `korisnikID`
    FOREIGN KEY (`korisnikID`)
    REFERENCES `kompanija`.`zaposlenik` (`idKorisnik`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 4
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

INSERT INTO kompanija.zaposlenik
VALUES 
    (1, "Samir", "Hasic", "Samke", "Zaposlen. Imam 34 godine", 0, NULL, NULL ),
    (2, "Adnan", "Omić", "Ado", "student. Imam 22 godine", 0, NULL, NULL ),
    (3, "Sead", "SEMIĆ", "Sejo", "penzioner. Imam 64 godine", 0, NULL, NULL );

INSERT INTO kompanija.plate
VALUES
    (1, 1, 1500, "2024-02-02 00:00:00", 'yes', 'neodredjeno'),
    (2, 2, 1000, "2024-02-03 00:00:00", 'no', 'odredjeno'),
    (3, 3, 1600, "2024-02-03 00:00:00", 'no', 'odredjeno');

INSERT INTO kompanija.korespodencija
VALUES
    (1, 2, 1, "", "Da li je legla plata", 'yes', '2024-02-02 10:00:00'),
    (2, 1, 2, "Odgovor", "Nije", 'yes', '2024-02-02 10:30:00'),
    (3, 3, 1, "", "Kad ce plata?", 'no', '2024-02-03 08:00:00');

-- Definisanje indeksa, pogleda i uskladištenih procedura
CREATE INDEX idx_zaposlenik_ime_prezime ON zaposlenik (Ime, Prezime);
CREATE FULLTEXT INDEX idx_korespodencija_tekst ON korespodencija (tekst);
CREATE VIEW osnovne_informacije_o_korisniku AS
SELECT Ime, Prezime, CONCAT(datum_rodjenja, ', ', mesto_rodjenja) AS datum_i_mesto_rodjenja FROM zaposlenik;

DELIMITER //

CREATE PROCEDURE unos_zaposlenika(IN ime VARCHAR(45), IN prezime VARCHAR(45), IN korisnicko_ime VARCHAR(45), IN kratka_biografija VARCHAR(150), IN fotografija INT)
BEGIN
    INSERT INTO zaposlenik (Ime, Prezime, korisnickoime, kratkabiografija, fotografija)
    VALUES (ime, prezime, korisnicko_ime, kratka_biografija, fotografija);
END //

CREATE PROCEDURE brisanje_zaposlenika (IN idKorisnik INT)
BEGIN
    DELETE FROM zaposlenik WHERE idKorisnik = idKorisnik;
END //

CREATE PROCEDURE izmena_zaposlenika (IN idKorisnik INT, IN ime VARCHAR(45), IN prezime VARCHAR(45), IN korisnicko_ime VARCHAR(45), IN kratka_biografija VARCHAR(150), IN fotografija INT)
BEGIN
    UPDATE zaposlenik 
    SET Ime = ime, Prezime = prezime, korisnickoime = korisnicko_ime, kratkabiografija = kratka_biografija,
    fotografija = fotografija
    WHERE idKorisnik = idKorisnik;
END //

DELIMITER //

CREATE PROCEDURE Unos_korisnika (
    IN ime VARCHAR(45),
    IN prezime VARCHAR(45),
    IN korisnicko_ime VARCHAR(45),
    IN kratka_biografija VARCHAR(150),
    IN fotografija INT
)
BEGIN
    INSERT INTO zaposlenik (Ime, Prezime, korisnickoime, kratkabiografija, fotografija)
    VALUES (ime, prezime, korisnicko_ime, kratka_biografija, fotografija);
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE brisanje_korisnika (
    IN idKorisnik INT
)
BEGIN
    DELETE FROM zaposlenik WHERE idKorisnik = idKorisnik;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE izmena_korisnika (
    IN idKorisnik INT,
    IN novo_ime VARCHAR(45),
    IN novo_prezime VARCHAR(45),
    IN novo_korisnicko_ime VARCHAR(45),
    IN nova_kratka_biografija VARCHAR(150),
    IN nova_fotografija INT
)
BEGIN
    UPDATE zaposlenik 
    SET Ime = novo_ime, Prezime = novo_prezime, korisnickoime = novo_korisnicko_ime, 
        kratkabiografija = nova_kratka_biografija,
   END

DELIMITER ;

DELIMITER //

CREATE PROCEDURE unos_plate (
    IN korisnikID INT,
    IN iznos DECIMAL(10,2),
    IN datum_isplate DATETIME,
    IN isplacena ENUM('yes', 'no'),
    IN ugovor ENUM('odredjeno', 'neodredjeno')
)
BEGIN
    INSERT INTO plate (korisnikID, Iznos, datumisplate, Isplacena, ugovor)
    VALUES (korisnikID, iznos, datum_isplate, isplacena, ugovor);
END //

DELIMITER ;


DELIMITER //

CREATE PROCEDURE brisanje_plate (
    IN idPlate INT
)
BEGIN
    DELETE FROM plate WHERE idplate = idPlate;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE izmena_plate (
    IN idPlate INT,
    IN novi_iznos DECIMAL(10,2),
    IN novi_datum_isplate DATETIME,
    IN nova_isplacena ENUM('yes', 'no'),
    IN novi_ugovor ENUM('odredjeno', 'neodredjeno')
)
BEGIN
    UPDATE plate 
    SET Iznos = novi_iznos, datumisplate = novi_datum_isplate, 
        Isplacena = nova_isplacena, ugovor = novi_ugovor
    WHERE idplate = idPlate;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE unos_poruke (
    IN posiljalacID INT,
    IN primalacID INT,
    IN naslov VARCHAR(45),
    IN tekst VARCHAR(180),
    IN procitana ENUM('yes', 'no'),
    IN datum_slanja DATETIME
)
BEGIN
    INSERT INTO korespodencija (posiljalacID, primalacID, naslov, tekst, procitana, datumslanja)
    VALUES (posiljalacID, primalacID, naslov, tekst, procitana, datum_slanja);
END //

DELIMITER ;


DELIMITER //

CREATE PROCEDURE brisanje_poruke (
    IN idPoruke INT
)
BEGIN
    DELETE FROM korespodencija WHERE porukeID = idPoruke;
END //

DELIMITER ;



DELIMITER //

CREATE PROCEDURE izmena_poruke (
    IN idPoruke INT,
    IN novi_naslov VARCHAR(45),
    IN novi_tekst VARCHAR(180),
    IN nova_procitana ENUM('yes', 'no'),
    IN novi_datum_slanja DATETIME
)
BEGIN
    UPDATE korespodencija 
    SET naslov = novi_naslov, tekst = novi_tekst, 
        procitana = nova_procitana, datumslanja = novi_datum_slanja
    WHERE porukeID = idPoruke;
END //

DELIMITER ;





