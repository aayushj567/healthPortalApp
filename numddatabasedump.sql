CREATE DATABASE  IF NOT EXISTS `patientportaldb` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `patientportaldb`;
-- MySQL dump 10.13  Distrib 8.0.34, for Win64 (x86_64)
--
-- Host: localhost    Database: patientportaldb
-- ------------------------------------------------------
-- Server version	8.0.34

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `appointments`
--

DROP TABLE IF EXISTS `appointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointments` (
  `AppointmentID` int NOT NULL AUTO_INCREMENT,
  `PatientID` int NOT NULL,
  `DoctorID` int NOT NULL,
  `AppointmentDate` datetime NOT NULL,
  `Reason` text,
  PRIMARY KEY (`AppointmentID`),
  UNIQUE KEY `unique_appointment_constraint` (`DoctorID`,`AppointmentDate`),
  KEY `PatientID` (`PatientID`),
  CONSTRAINT `appointments_ibfk_1` FOREIGN KEY (`PatientID`) REFERENCES `patients` (`PatientID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `appointments_ibfk_2` FOREIGN KEY (`DoctorID`) REFERENCES `doctors` (`DoctorID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointments`
--

LOCK TABLES `appointments` WRITE;
/*!40000 ALTER TABLE `appointments` DISABLE KEYS */;
INSERT INTO `appointments` (`AppointmentID`, `PatientID`, `DoctorID`, `AppointmentDate`, `Reason`) VALUES (1,3,2,'2023-01-15 10:00:00','Regular checkup'),(2,1,1,'2023-01-22 14:30:00','Follow-up appointment'),(3,2,3,'2023-02-10 09:45:00','Vaccination'),(4,1,2,'2023-03-05 11:20:00','Consultation for back pain'),(5,3,1,'2023-04-18 15:15:00','Post-surgery checkup'),(6,2,1,'2023-05-20 12:30:00','Eye examination'),(7,1,2,'2023-06-08 16:45:00','Pediatric checkup'),(8,2,1,'2023-07-12 13:00:00','Follow-up for allergy treatment'),(9,1,3,'2023-08-25 10:30:00','Urology consultation'),(10,3,1,'2023-09-30 14:00:00','Oncology screening'),(11,3,2,'2024-01-15 10:00:00','Regular checkup'),(12,1,1,'2024-01-22 14:30:00','Follow-up appointment'),(13,2,3,'2024-02-10 09:45:00','Vaccination'),(14,1,2,'2024-03-05 11:20:00','Consultation for back pain'),(15,3,1,'2024-04-18 15:15:00','Post-surgery checkup'),(16,2,1,'2024-05-20 12:30:00','Eye examination'),(17,1,2,'2024-06-08 16:45:00','Pediatric checkup'),(18,2,1,'2024-07-12 13:00:00','Follow-up for allergy treatment'),(19,1,3,'2024-08-25 10:30:00','Urology consultation'),(20,3,1,'2024-09-30 14:00:00','Oncology screening');
/*!40000 ALTER TABLE `appointments` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `before_insert_appointment` BEFORE INSERT ON `appointments` FOR EACH ROW BEGIN
    DECLARE patient_appointment_count INT;
    DECLARE doctor_appointment_count INT;
    DECLARE doctor_available_count INT;

    -- Check if the patient has another appointment at the same time
    SELECT COUNT(*) INTO patient_appointment_count
    FROM Appointments
    WHERE PatientID = NEW.PatientID
    AND AppointmentDate = NEW.AppointmentDate;

    IF patient_appointment_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Patient already has an appointment at the specified datetime';
    END IF;

    -- Check if there is already an appointment for the same doctor at the same datetime
    SELECT COUNT(*) INTO doctor_appointment_count
    FROM Appointments
    WHERE DoctorID = NEW.DoctorID
    AND AppointmentDate = NEW.AppointmentDate;

    IF doctor_appointment_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doctor already has an appointment at the specified datetime';
    END IF;

    -- Check if the doctor has available dates at the specified time
    SELECT COUNT(*) INTO doctor_available_count
    FROM DoctorAvailableDates
    WHERE DoctorID = NEW.DoctorID
    AND DAYNAME(AvailableDate) = DAYNAME(NEW.AppointmentDate)
    AND TIME(AvailableDate.TIME) = TIME(NEW.AppointmentDate);

    IF doctor_available_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doctor is not available at the specified datetime';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `before_update_appointment` BEFORE UPDATE ON `appointments` FOR EACH ROW BEGIN
    DECLARE doctor_appointment_count INT;
    DECLARE patient_appointment_count INT;
    DECLARE doctor_available_count INT;
    DECLARE appointment_exists_count INT;

	-- Check if the appointment being updated exists
    SELECT COUNT(*)
    INTO appointment_exists_count
    FROM Appointments
    WHERE AppointmentID = NEW.AppointmentID;

    IF appointment_exists_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Appointment being updated does not exist.';
    END IF;

    -- Check if the appointment slot is still available for the doctor after updating
    SELECT COUNT(*)
    INTO doctor_appointment_count
    FROM Appointments
    WHERE DoctorID = NEW.DoctorID
      AND AppointmentDate = NEW.AppointmentDate
      AND AppointmentID != NEW.AppointmentID;

    IF doctor_appointment_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Updated appointment slot is not available for the doctor.';
    END IF;

    -- Check if the patient has another appointment at the same time after updating
    SELECT COUNT(*)
    INTO patient_appointment_count
    FROM Appointments
    WHERE PatientID = NEW.PatientID
      AND AppointmentDate = NEW.AppointmentDate
      AND AppointmentID != NEW.AppointmentID;

    IF patient_appointment_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Updated appointment slot is not available for the patient.';
    END IF;

    -- Check if the doctor has available dates at the updated time
    SELECT COUNT(*)
    INTO doctor_available_count
    FROM DoctorAvailableDates
    WHERE DoctorID = NEW.DoctorID
    AND DAYNAME(AvailableDate) = DAYNAME(NEW.AppointmentDate)
    AND TIME(AvailableDate) = TIME(NEW.AppointmentDate);

    IF doctor_available_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doctor is not available at the updated time.';
    END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `billing`
--

DROP TABLE IF EXISTS `billing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `billing` (
  `BillID` int NOT NULL AUTO_INCREMENT,
  `RecordID` int NOT NULL,
  `Amount` decimal(10,2) NOT NULL,
  `BillDate` date NOT NULL,
  `PaymentStatus` enum('Pending','Paid') NOT NULL,
  PRIMARY KEY (`BillID`),
  KEY `RecordID` (`RecordID`),
  CONSTRAINT `billing_ibfk_1` FOREIGN KEY (`RecordID`) REFERENCES `medicalrecords` (`RecordID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `billing`
--

LOCK TABLES `billing` WRITE;
/*!40000 ALTER TABLE `billing` DISABLE KEYS */;
INSERT INTO `billing` (`BillID`, `RecordID`, `Amount`, `BillDate`, `PaymentStatus`) VALUES (1,1,236.55,'2023-12-08','Pending'),(2,2,609.80,'2023-12-08','Paid'),(3,3,384.00,'2023-12-08','Pending'),(4,4,76.50,'2023-12-08','Paid'),(5,5,76.50,'2023-12-08','Pending'),(6,6,286.50,'2023-12-08','Paid'),(7,7,66.00,'2023-12-08','Pending'),(8,8,76.50,'2023-12-08','Paid'),(9,9,90.00,'2023-12-08','Pending');
/*!40000 ALTER TABLE `billing` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctoravailabledates`
--

DROP TABLE IF EXISTS `doctoravailabledates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctoravailabledates` (
  `DoctorID` int NOT NULL,
  `AvailableDate` datetime NOT NULL,
  PRIMARY KEY (`DoctorID`,`AvailableDate`),
  CONSTRAINT `doctoravailabledates_ibfk_1` FOREIGN KEY (`DoctorID`) REFERENCES `doctors` (`DoctorID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctoravailabledates`
--

LOCK TABLES `doctoravailabledates` WRITE;
/*!40000 ALTER TABLE `doctoravailabledates` DISABLE KEYS */;
INSERT INTO `doctoravailabledates` (`DoctorID`, `AvailableDate`) VALUES (1,'2023-12-10 09:00:00'),(1,'2023-12-11 11:30:00'),(1,'2023-12-11 14:30:00'),(1,'2023-12-12 11:00:00'),(1,'2023-12-13 09:45:00'),(1,'2023-12-15 14:00:00'),(2,'2023-12-10 10:30:00'),(2,'2023-12-11 10:00:00'),(2,'2023-12-12 15:15:00'),(2,'2023-12-13 15:45:00'),(2,'2023-12-14 09:30:00'),(2,'2023-12-14 12:30:00'),(3,'2023-12-10 13:15:00'),(3,'2023-12-12 08:45:00'),(3,'2023-12-14 16:00:00');
/*!40000 ALTER TABLE `doctoravailabledates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctors`
--

DROP TABLE IF EXISTS `doctors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctors` (
  `DoctorID` int NOT NULL AUTO_INCREMENT,
  `UserID` int NOT NULL,
  `FirstName` varchar(50) NOT NULL,
  `LastName` varchar(50) NOT NULL,
  `SpecializationID` int NOT NULL,
  `ContactNumber` varchar(15) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `Address` text,
  PRIMARY KEY (`DoctorID`),
  UNIQUE KEY `UserID` (`UserID`),
  KEY `SpecializationID` (`SpecializationID`),
  CONSTRAINT `doctors_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `doctors_ibfk_2` FOREIGN KEY (`SpecializationID`) REFERENCES `specializations` (`SpecializationID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctors`
--

LOCK TABLES `doctors` WRITE;
/*!40000 ALTER TABLE `doctors` DISABLE KEYS */;
INSERT INTO `doctors` (`DoctorID`, `UserID`, `FirstName`, `LastName`, `SpecializationID`, `ContactNumber`, `Email`, `Address`) VALUES (1,2,'John','Doe',1,'1234567890','john.doe@example.com','123 Main St'),(2,3,'Sarah','Jones',4,'9876543210','sarah.jones@example.com','789 Elm St'),(3,4,'Michael','Clark',7,'8765432109','michael.clark@example.com','567 Pine St');
/*!40000 ALTER TABLE `doctors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `insurance`
--

DROP TABLE IF EXISTS `insurance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `insurance` (
  `InsuranceID` int NOT NULL AUTO_INCREMENT,
  `PatientID` int NOT NULL,
  `InsuranceProvider` varchar(100) NOT NULL,
  `PolicyNumber` varchar(50) NOT NULL,
  `ExpiryDate` date DEFAULT NULL,
  PRIMARY KEY (`InsuranceID`),
  UNIQUE KEY `PolicyNumber` (`PolicyNumber`),
  KEY `PatientID` (`PatientID`),
  CONSTRAINT `insurance_ibfk_1` FOREIGN KEY (`PatientID`) REFERENCES `patients` (`PatientID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `insurance`
--

LOCK TABLES `insurance` WRITE;
/*!40000 ALTER TABLE `insurance` DISABLE KEYS */;
INSERT INTO `insurance` (`InsuranceID`, `PatientID`, `InsuranceProvider`, `PolicyNumber`, `ExpiryDate`) VALUES (1,1,'HealthGuard Insurance','POL123','2024-01-01'),(2,2,'SecureCare Insurance','POL456','2023-12-15'),(3,3,'WellSure Insurance','POL789','2024-02-28'),(4,1,'MediShield Insurance','POL101','2023-11-30'),(5,1,'GuardianCare Insurance','POL112','2024-03-10');
/*!40000 ALTER TABLE `insurance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `insurancecoverage`
--

DROP TABLE IF EXISTS `insurancecoverage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `insurancecoverage` (
  `CoverageID` int NOT NULL AUTO_INCREMENT,
  `InsuranceID` int NOT NULL,
  `CoverageType` varchar(50) NOT NULL,
  `CoverageDetails` text,
  `Discount` decimal(10,3) DEFAULT NULL,
  PRIMARY KEY (`CoverageID`),
  KEY `InsuranceID` (`InsuranceID`),
  CONSTRAINT `insurancecoverage_ibfk_1` FOREIGN KEY (`InsuranceID`) REFERENCES `insurance` (`InsuranceID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `insurancecoverage`
--

LOCK TABLES `insurancecoverage` WRITE;
/*!40000 ALTER TABLE `insurancecoverage` DISABLE KEYS */;
INSERT INTO `insurancecoverage` (`CoverageID`, `InsuranceID`, `CoverageType`, `CoverageDetails`, `Discount`) VALUES (1,1,'Cardiology','Covers cardiology-related expenses',0.100),(2,1,'Diagnostics','Covers diagnostic procedures',0.050),(3,2,'Orthopedics','Covers orthopedics-related expenses',0.150),(4,2,'Surgery','Covers surgical procedures',0.080),(5,3,'Pediatrics','Covers pediatrics-related expenses',0.120),(6,3,'Vaccinations','Covers vaccination costs',0.070),(7,1,'Oncology','Covers oncology-related expenses',0.200),(8,1,'Chemotherapy','Covers chemotherapy costs',0.180),(9,2,'Dermatology','Covers dermatology-related expenses',0.250),(10,2,'Skin Tests','Covers costs of skin tests',0.130),(11,3,'Neurology','Covers neurology-related expenses',0.100),(12,3,'MRI Scans','Covers costs of MRI scans',0.080),(13,1,'Gastroenterology','Covers gastroenterology-related expenses',0.150),(14,1,'Endoscopy','Covers costs of endoscopy procedures',0.100),(15,2,'Urology','Covers urology-related expenses',0.120),(16,2,'Prostate Exams','Covers costs of prostate exams',0.090),(17,1,'Colonoscopy','Covers costs of colonoscopy',0.150),(18,2,'Appendectomy','Covers costs of appendectomy',0.100),(19,3,'Cataract Surgery','Covers costs of cataract surgery',0.120),(20,1,'Hernia Repair','Covers costs of hernia repair',0.080),(21,2,'Root Canal','Covers costs of root canal',0.100),(22,3,'Knee Replacement','Covers costs of knee replacement',0.180),(23,1,'Aspirin','Covers expenses for Aspirin',0.050),(24,2,'Ibuprofen','Covers expenses for Ibuprofen',0.080),(25,3,'Paracetamol','Covers expenses for Paracetamol',0.100),(26,1,'Amoxicillin','Covers expenses for Amoxicillin',0.070),(27,2,'Lipitor','Covers expenses for Lipitor',0.120),(28,3,'Ventolin','Covers expenses for Ventolin',0.060),(29,1,'Eye Exams','Covers costs of routine eye exams',0.090),(30,2,'Dental Cleanings','Covers costs of dental cleanings',0.120),(31,3,'Mammograms','Covers costs of mammograms',0.150),(32,1,'Pap Smears','Covers costs of pap smears',0.080),(33,2,'Chiropractic Care','Covers costs of chiropractic care',0.100),(34,3,'Physical Therapy','Covers costs of physical therapy',0.120),(35,1,'Psychiatry','Covers psychiatry-related expenses',0.180),(36,1,'Counseling','Covers costs of counseling sessions',0.150),(37,2,'Hearing Tests','Covers costs of hearing tests',0.070),(38,2,'Allergy Shots','Covers costs of allergy shots',0.100),(39,3,'Bone Density Tests','Covers costs of bone density tests',0.080),(40,3,'Flu Shots','Covers costs of flu shots',0.050),(41,1,'Insulin','Covers expenses for Insulin',0.120),(42,1,'Blood Pressure Medication','Covers expenses for blood pressure medication',0.090),(43,2,'Antibiotics','Covers expenses for antibiotics',0.080),(44,2,'Anti-inflammatory Medication','Covers expenses for anti-inflammatory medication',0.110),(45,3,'Antidepressants','Covers expenses for antidepressants',0.150),(46,3,'Birth Control Pills','Covers expenses for birth control pills',0.070),(47,1,'Wheelchair','Covers expenses for wheelchair',0.180),(48,2,'Crutches','Covers expenses for crutches',0.100),(49,3,'Hearing Aids','Covers expenses for hearing aids',0.120);
/*!40000 ALTER TABLE `insurancecoverage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `medicalrecords`
--

DROP TABLE IF EXISTS `medicalrecords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medicalrecords` (
  `RecordID` int NOT NULL AUTO_INCREMENT,
  `PatientID` int NOT NULL,
  `DoctorID` int NOT NULL,
  `RecordDate` date NOT NULL,
  `Diagnosis` text,
  PRIMARY KEY (`RecordID`),
  KEY `PatientID` (`PatientID`),
  KEY `DoctorID` (`DoctorID`),
  CONSTRAINT `medicalrecords_ibfk_1` FOREIGN KEY (`PatientID`) REFERENCES `patients` (`PatientID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `medicalrecords_ibfk_2` FOREIGN KEY (`DoctorID`) REFERENCES `doctors` (`DoctorID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medicalrecords`
--

LOCK TABLES `medicalrecords` WRITE;
/*!40000 ALTER TABLE `medicalrecords` DISABLE KEYS */;
INSERT INTO `medicalrecords` (`RecordID`, `PatientID`, `DoctorID`, `RecordDate`, `Diagnosis`) VALUES (1,1,1,'2023-01-15','Normal checkup (Results: Normal), Blood test (Results: Normal), X-ray (Results: Clear)'),(2,1,3,'2023-02-20','Flu (Results: Positive), Flu test (Results: Positive)'),(3,1,3,'2023-03-10','Sprained ankle (Results: No fractures), X-ray (Results: No abnormalities)'),(4,2,2,'2023-04-05','Routine checkup (Results: Normal), Blood test (Results: Normal), ECG (Results: Normal)'),(5,2,2,'2023-05-12','Allergy (Results: Positive), Allergy test (Results: Positive)'),(6,3,2,'2023-06-18','Broken arm (Results: Fracture detected), X-ray (Results: Fracture detected), MRI (Results: Detailed view of the fracture)'),(7,1,3,'2023-07-25','Pediatric checkup (Results: Normal), Physical examination (Results: Normal)'),(8,3,2,'2023-08-30','Cancer screening (Results: No abnormalities detected), Biopsy (Results: No cancer cells observed), CT scan (Results: No tumors found)'),(9,2,1,'2023-09-08','Digestive issues (Results: Abnormal), Endoscopy (Results: Inflammation detected), blood test (Results: Elevated levels of certain markers)'),(10,1,3,'2023-10-14','Rheumatoid arthritis (Results: Positive), Joint examination (Results: Joint inflammation detected), blood test (Results: Elevated levels of inflammatory markers)');
/*!40000 ALTER TABLE `medicalrecords` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `before_insert_MedicalRecords` BEFORE INSERT ON `medicalrecords` FOR EACH ROW BEGIN
	SET NEW.RecordDate = NOW();
 END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `medicine`
--

DROP TABLE IF EXISTS `medicine`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medicine` (
  `MedicineID` int NOT NULL,
  `MedicineName` varchar(255) NOT NULL,
  `Manufacturer` varchar(255) DEFAULT NULL,
  `ExpiryDate` date DEFAULT NULL,
  `DosageForm` varchar(50) DEFAULT NULL,
  `ActiveIngredient` varchar(100) DEFAULT NULL,
  `Price` decimal(10,2) DEFAULT NULL,
  `StockQuantity` int DEFAULT '0',
  `StorageConditions` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`MedicineID`),
  CONSTRAINT `chk_positive_stock_quantity` CHECK ((`StockQuantity` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medicine`
--

LOCK TABLES `medicine` WRITE;
/*!40000 ALTER TABLE `medicine` DISABLE KEYS */;
INSERT INTO `medicine` (`MedicineID`, `MedicineName`, `Manufacturer`, `ExpiryDate`, `DosageForm`, `ActiveIngredient`, `Price`, `StockQuantity`, `StorageConditions`) VALUES (1,'Aspirin','Bayer','2023-12-31','Tablet','Acetylsalicylic Acid',5.00,0,'Store in a cool, dry place'),(2,'Lipitor','Pfizer','2024-01-01','Tablet','Atorvastatin',10.00,0,'Store in a cool, dry place'),(3,'Advil','Pfizer','2023-12-01','Capsule','Ibuprofen',15.00,0,'Store away from sunlight'),(4,'Prozac','Lilly','2023-11-15','Liquid','Fluoxetine',8.00,0,'Keep refrigerated'),(5,'Viagra','Pfizer','2024-02-28','Tablet','Sildenafil',12.00,0,'Store in a cool, dry place'),(6,'Nexium','AstraZeneca','2023-10-10','Capsule','Esomeprazole',18.00,0,'Store away from sunlight'),(7,'Zyrtec','Johnson & Johnson','2023-12-20','Liquid','Cetirizine',7.00,0,'Keep refrigerated'),(8,'Tylenol','Johnson & Johnson','2024-03-15','Tablet','Acetaminophen',14.00,0,'Store in a cool, dry place'),(9,'Xanax','Pfizer','2023-09-01','Capsule','Alprazolam',20.00,0,'Store away from sunlight'),(10,'Benadryl','Johnson & Johnson','2023-11-30','Liquid','Diphenhydramine',6.00,0,'Keep refrigerated'),(11,'Ambien','Sanofi','2024-04-10','Tablet','Zolpidem',16.00,0,'Store in a cool, dry place'),(12,'Allegra','Sanofi','2023-08-25','Capsule','Fexofenadine',22.00,0,'Store away from sunlight'),(13,'Prilosec','AstraZeneca','2023-10-05','Liquid','Omeprazole',9.00,0,'Keep refrigerated'),(14,'Celebrex','Pfizer','2024-05-20','Tablet','Celecoxib',25.00,0,'Store in a cool, dry place'),(15,'Zantac','Sanofi','2023-07-15','Capsule','Ranitidine',30.00,0,'Store away from sunlight');
/*!40000 ALTER TABLE `medicine` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patients`
--

DROP TABLE IF EXISTS `patients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patients` (
  `PatientID` int NOT NULL AUTO_INCREMENT,
  `UserID` int NOT NULL,
  `FirstName` varchar(50) NOT NULL,
  `LastName` varchar(50) NOT NULL,
  `DateOfBirth` date DEFAULT NULL,
  `Gender` enum('Male','Female') DEFAULT NULL,
  `ContactNumber` varchar(15) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `Address` text,
  PRIMARY KEY (`PatientID`),
  UNIQUE KEY `UserID` (`UserID`),
  CONSTRAINT `patients_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patients`
--

LOCK TABLES `patients` WRITE;
/*!40000 ALTER TABLE `patients` DISABLE KEYS */;
INSERT INTO `patients` (`PatientID`, `UserID`, `FirstName`, `LastName`, `DateOfBirth`, `Gender`, `ContactNumber`, `Email`, `Address`) VALUES (1,5,'Jane','Smith','1990-05-15','Female','9876543210','jane.smith@example.com','456 Oak St'),(2,6,'Alex','Turner','1985-08-20','Male','7654321098','alex.turner@example.com','321 Cedar St'),(3,7,'Emily','Wright','1998-03-12','Female','6543210987','emily.wright@example.com','234 Birch St');
/*!40000 ALTER TABLE `patients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prescribedmedicine`
--

DROP TABLE IF EXISTS `prescribedmedicine`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prescribedmedicine` (
  `RecordID` int NOT NULL,
  `MedicineID` int NOT NULL,
  PRIMARY KEY (`RecordID`,`MedicineID`),
  KEY `MedicineID` (`MedicineID`),
  CONSTRAINT `prescribedmedicine_ibfk_1` FOREIGN KEY (`RecordID`) REFERENCES `medicalrecords` (`RecordID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `prescribedmedicine_ibfk_2` FOREIGN KEY (`MedicineID`) REFERENCES `medicine` (`MedicineID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prescribedmedicine`
--

LOCK TABLES `prescribedmedicine` WRITE;
/*!40000 ALTER TABLE `prescribedmedicine` DISABLE KEYS */;
INSERT INTO `prescribedmedicine` (`RecordID`, `MedicineID`) VALUES (1,1),(1,2),(2,2),(2,3),(1,4),(3,6);
/*!40000 ALTER TABLE `prescribedmedicine` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `procedures`
--

DROP TABLE IF EXISTS `procedures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `procedures` (
  `ProcedureID` int NOT NULL AUTO_INCREMENT,
  `ProcedureName` varchar(100) NOT NULL,
  `Cost` decimal(10,2) NOT NULL,
  PRIMARY KEY (`ProcedureID`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `procedures`
--

LOCK TABLES `procedures` WRITE;
/*!40000 ALTER TABLE `procedures` DISABLE KEYS */;
INSERT INTO `procedures` (`ProcedureID`, `ProcedureName`, `Cost`) VALUES (1,'Blood Test',50.00),(2,'X-Ray',75.00),(3,'CT Scan',250.00),(4,'MRI Scan',300.00),(5,'Ultrasound',120.00),(6,'EKG',100.00),(7,'Physical Examination',90.00),(8,'Colonoscopy',200.00),(9,'Dental Cleaning',70.00),(10,'Eye Exam',60.00);
/*!40000 ALTER TABLE `procedures` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proceduresperformed`
--

DROP TABLE IF EXISTS `proceduresperformed`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `proceduresperformed` (
  `RecordID` int NOT NULL,
  `ProcedureID` int NOT NULL,
  PRIMARY KEY (`RecordID`,`ProcedureID`),
  KEY `ProcedureID` (`ProcedureID`),
  CONSTRAINT `proceduresperformed_ibfk_1` FOREIGN KEY (`RecordID`) REFERENCES `medicalrecords` (`RecordID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `proceduresperformed_ibfk_2` FOREIGN KEY (`ProcedureID`) REFERENCES `procedures` (`ProcedureID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proceduresperformed`
--

LOCK TABLES `proceduresperformed` WRITE;
/*!40000 ALTER TABLE `proceduresperformed` DISABLE KEYS */;
INSERT INTO `proceduresperformed` (`RecordID`, `ProcedureID`) VALUES (1,1),(1,2),(2,3),(3,4),(6,5),(2,6),(6,7),(2,8);
/*!40000 ALTER TABLE `proceduresperformed` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `specializations`
--

DROP TABLE IF EXISTS `specializations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `specializations` (
  `SpecializationID` int NOT NULL AUTO_INCREMENT,
  `SpecializationName` varchar(100) NOT NULL,
  `ConsultationFee` decimal(10,2) NOT NULL,
  PRIMARY KEY (`SpecializationID`),
  UNIQUE KEY `SpecializationName` (`SpecializationName`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `specializations`
--

LOCK TABLES `specializations` WRITE;
/*!40000 ALTER TABLE `specializations` DISABLE KEYS */;
INSERT INTO `specializations` (`SpecializationID`, `SpecializationName`, `ConsultationFee`) VALUES (1,'Cardiology',100.00),(2,'Dermatology',80.00),(3,'Neurology',180.00),(4,'Orthopedics',90.00),(5,'Ophthalmology',85.00),(6,'Gastroenterology',95.00),(7,'Pediatrics',75.00),(8,'Oncology',120.00),(9,'Rheumatology',105.00),(10,'Urology',110.00);
/*!40000 ALTER TABLE `specializations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `UserID` int NOT NULL AUTO_INCREMENT,
  `Username` varchar(50) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `User_Type` enum('Admin','Doctor','Patient','Staff') NOT NULL,
  `AccountCreatedDate` datetime DEFAULT NULL,
  PRIMARY KEY (`UserID`),
  UNIQUE KEY `Username` (`Username`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`UserID`, `Username`, `Password`, `User_Type`, `AccountCreatedDate`) VALUES (1,'admin','84c7eae3ddbad4bb0aa05026b7bf1a601b467347374507b51fa0f8472d91df0f','Admin',NULL),(2,'doctor1','a256dffbe11529b50f5cc9a73fa14359b2987d41c3324cf3fe9b9673ac2f53cc','Doctor','2023-12-08 20:19:19'),(3,'doctor2','662ead4aa1e3350ea82d257befcdd7f602eabea1f05d604ccf9fad39e77a9410','Doctor','2023-12-08 20:19:19'),(4,'doctor3','b84896f6db27f0222569332b0a178d1ed9de1e4c45836cd21a38361ac252bdb5','Doctor','2023-12-08 20:19:19'),(5,'patient1','61ab79c401452716dad0d1054b5fa96b72d8154dd7fc6f0dce5415c26196c3c1','Patient','2023-12-08 20:19:19'),(6,'patient2','64d5f3bb8008c845c971a41d1bee64d32bfb77a3d36501c87f18b1d2b3ca07c5','Patient','2023-12-08 20:19:19'),(7,'patient3','6f39f9d78fac35cd8923a2b0928aa6e1fc80fe879d1b7405537d7f625f57f9c7','Patient','2023-12-08 20:19:19'),(8,'staff1','b2b536f868428ef4e2d55241fb7ded99e98d020dd4e8a37abb4e6215cbcabcff','Staff','2023-12-08 20:19:19');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'patientportaldb'
--
/*!50003 DROP FUNCTION IF EXISTS `CalculateBillingAmount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `CalculateBillingAmount`(
	p_RecordID INT
) RETURNS decimal(10,2)
    DETERMINISTIC
BEGIN
    DECLARE row_not_found BOOLEAN DEFAULT FALSE;
    DECLARE item_name VARCHAR(255);
    DECLARE item_cost DECIMAL(10, 2) DEFAULT 0;
    DECLARE total_amount DECIMAL(10, 2) DEFAULT 0;
    DECLARE counter INT DEFAULT 0;
    
    -- Declare a cursor for the itemized bill
    DECLARE itemized_cursor CURSOR FOR
       SELECT Item, Cost FROM (WITH
      cte1 AS (
        SELECT S.SpecializationName AS Item, S.ConsultationFee AS Cost
        FROM Doctors D
        JOIN MedicalRecords MR ON D.DoctorID = MR.DoctorID
        JOIN Specializations S ON D.SpecializationID = S.SpecializationID
        WHERE MR.RecordID = p_RecordID
      ),
      cte2 AS (
        SELECT P.ProcedureName AS Item, P.Cost AS Cost
        FROM ProceduresPerformed PP
        JOIN Procedures P ON PP.ProcedureID = P.ProcedureID
        WHERE PP.RecordID = p_RecordID
      ),
      cte3 AS (
        SELECT M.MedicineName AS Item, M.Price AS Cost
        FROM PrescribedMedicine PM
        JOIN Medicine M ON PM.MedicineID = M.MedicineID
        JOIN MedicalRecords MR ON PM.RecordID = MR.RecordID
        WHERE MR.RecordID = p_RecordID
      )
    SELECT * FROM cte1
    UNION ALL
    SELECT * FROM cte2
    UNION ALL
    SELECT * FROM cte3) ItemizedBill;
       
    -- Declare handlers for exceptions
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET row_not_found = TRUE;

    -- Open the cursor
    OPEN itemized_cursor;
	
    -- Fetch each row and apply insurance coverage discount
    FETCH itemized_cursor INTO item_name, item_cost;
    WHILE row_not_found = FALSE DO
        SET total_amount = total_amount + (item_cost * (1 - COALESCE((SELECT Discount FROM InsuranceCoverage  AS IC 
																			INNER JOIN Insurance AS I ON IC.InsuranceID = I.InsuranceID
                                                                            WHERE PatientID = I.PatientID
                                                                            AND CoverageType = item_name), 0)));
		SET counter = counter +1;
        FETCH itemized_cursor INTO item_name, item_cost;
    END WHILE;

    -- Close the cursor
    CLOSE itemized_cursor;
    
    -- Output the total amount
    RETURN total_amount;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `ValidateUsernamePassword` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `ValidateUsernamePassword`(
    p_Username VARCHAR(50),
    p_Password VARCHAR(255)
) RETURNS tinyint(1)
    DETERMINISTIC
BEGIN
    DECLARE is_valid BOOLEAN;

    SELECT EXISTS (
        SELECT *
        FROM Users
        WHERE Username = p_Username AND Password = SHA2(CONCAT(p_Password, "salt"), 256)
    ) INTO is_valid;
    IF is_valid <> 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Incorrect username or password';
    END IF;
	RETURN is_valid;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddProceduresAndMedicine` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddProceduresAndMedicine`(
	IN p_RecordID INT,
    IN p_ItemName VARCHAR(100)
)
BEGIN
	DECLARE is_procedure INT DEFAULT 0;
    DECLARE is_medicine INT DEFAULT 0;
    DECLARE v_ItemID INT;
    
	SELECT COUNT(ProcedureID) INTO is_procedure FROM Procedures WHERE ProcedureName = p_ItemName; 
    SELECT COUNT(MedicineID) INTO is_medicine FROM Medicine WHERE MedicineName = p_ItemName;
    
    IF is_procedure > 0 THEN
		SELECT ProcedureID INTO v_ItemID FROM Procedures WHERE ProcedureName = p_ItemName; 
        INSERT INTO ProceduresPerformed (RecordID, ProcedureID)
        VALUES (p_RecordID, v_ItemID);
	ELSEIF is_medicine > 0 THEN
		SELECT MedicineID INTO v_ItemID FROM Medicine WHERE MedicineName = p_ItemName;
        INSERT INTO PrescribedMedicine (RecordID, MedicineID)
        VALUES (p_RecordID, v_ItemID);
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateAppointment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateAppointment`(
    IN p_PatientID INT,
    IN p_DoctorID INT,
    IN p_SpecializationName VARCHAR(100),
    IN p_AppointmentDate DATETIME,
    IN p_Reason TEXT
)
BEGIN
	DECLARE doctor_available INT;
	DECLARE v_DoctorID INT;
    DECLARE v_AppointmentTIME DATETIME;
    DECLARE v_new_datetime DATETIME;
    
	SELECT COUNT(*) INTO doctor_available FROM Doctors AS D 
		INNER JOIN DoctorAvailableDates AS DA ON D.DoctorID = DA.DoctorID
        WHERE D.DoctorID = p_DoctorID
		AND DAYNAME(DA.AvailableDate) = DAYNAME(p_AppointmentDate);
		-- AND TIME(DA.AvailableDate) = TIME(p_AppointmentDate);
    
    SELECT D.DoctorID, DA.AvailableDate INTO v_DoctorID, v_AppointmentTIME FROM Doctors AS D
			INNER JOIN Specializations AS S ON D.SpecializationID = S.SpecializationID 
			INNER JOIN DoctorAvailableDates AS DA ON D.DoctorID = DA.DoctorID
			WHERE S.SpecializationName = p_SpecializationName
			AND DAYNAME(DA.AvailableDate) = DAYNAME(p_AppointmentDate);
			-- AND TIME(DA.AvailableDate) = TIME(p_AppointmentDate);
	
    SET v_new_datetime = CONCAT(DATE(p_AppointmentDate), ' ', TIME(v_AppointmentTIME));

    
	IF p_DoctorID IS NOT NULL AND doctor_available > 0 THEN
		INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, Reason)
		VALUES (p_PatientID, p_DoctorID, p_AppointmentDate, p_Reason);
	ELSEIF v_DoctorID IS NOT NULL THEN
		INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, Reason)
		VALUES (p_PatientID, v_DoctorID, v_new_datetime, p_Reason);
	ELSE
		SELECT 'Available doctor or specialist not found' AS Message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateBill` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateBill`(
    IN p_RecordID INT,
    IN p_Amount DECIMAL(10, 2),
    IN p_PaymentStatus ENUM('Pending', 'Paid')
)
BEGIN
	DECLARE v_Amount INT DEFAULT 0;
	SET v_Amount = CalculateBillingAmount(p_RecordID);
    INSERT INTO Billing (RecordID, Amount, BillDate, PaymentStatus)
    VALUES (p_RecordID, v_Amount, NOW(), p_PaymentStatus);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateDoctor` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateDoctor`(
    IN p_UserID INT,
    IN p_FirstName VARCHAR(50),
    IN p_LastName VARCHAR(50),
    IN p_SpecializationName VARCHAR(100),
    IN p_ContactNumber VARCHAR(15),
    IN p_Email VARCHAR(100),
    IN p_Address TEXT
)
BEGIN
    DECLARE user_exists INT;
    DECLARE specialization_exists INT;
 
    -- Check if the specified user exists
    SELECT COUNT(*)
    INTO user_exists
    FROM Users
    WHERE UserID = p_UserID;
    
    SELECT SpecializationID
    INTO specialization_exists
    FROM Specializations
    WHERE SpecializationName = p_SpecializationName;
    
    IF user_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User does not exist.';
    ELSEIF specialization_exists IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Specialization does not exist.';
	ELSE
        -- User exists, proceed with creating the doctor
        INSERT INTO Doctors (UserID, FirstName, LastName, SpecializationID, ContactNumber, Email, Address)
        VALUES (p_UserID, p_FirstName, p_LastName, specialization_exists, p_ContactNumber, p_Email, p_Address);
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateMedicalRecord` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateMedicalRecord`(
    IN p_PatientID INT,
    IN p_DoctorID INT,
    IN p_RecordDate DATE,
    IN p_Diagnosis TEXT
)
BEGIN
    INSERT INTO MedicalRecords (PatientID, DoctorID, RecordDate, Diagnosis)
    VALUES (p_PatientID, p_DoctorID, p_RecordDate, p_Diagnosis);
    IF ROW_COUNT() > 0 THEN
		SELECT LAST_INSERT_ID() AS Message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreatePatient` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreatePatient`(
    IN p_UserID INT,
    IN p_FirstName VARCHAR(50),
    IN p_LastName VARCHAR(50),
    IN p_DateOfBirth DATE,
    IN p_Gender VARCHAR(10),
    IN p_ContactNumber VARCHAR(15),
    IN p_Email VARCHAR(100),
    IN p_Address TEXT
)
BEGIN
    DECLARE user_exists INT;

    -- Check if the specified user exists
    SELECT COUNT(*)
    INTO user_exists
    FROM Users
    WHERE UserID = p_UserID;
    
    IF user_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User does not exist.';
    ELSE
        -- User exists, proceed with creating the patient
        INSERT INTO Patients (UserID, FirstName, LastName, DateOfBirth, Gender, ContactNumber, Email, Address)
        VALUES (p_UserID, p_FirstName, p_LastName, p_DateOfBirth, p_Gender, p_ContactNumber, p_Email, p_Address);
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateUser` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateUser`(
    IN p_Username VARCHAR(50),
    IN p_Password VARCHAR(255),
    IN p_UserType ENUM('Admin', 'Doctor', 'Patient', 'Staff')
)
BEGIN
    DECLARE user_count INT;

    -- Check if the user already exists
    SELECT COUNT(*) INTO user_count
    FROM Users
    WHERE Username = p_Username;
    
    -- Check if the username and password meet the length requirements
    IF LENGTH(p_Username) < 6 OR LENGTH(p_Password) < 6 THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Username and password must be at least 6 characters long';
    END IF;

    -- Check if the user type is valid
    IF p_UserType NOT IN ('Admin', 'Doctor', 'Patient', 'Staff') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid user type';
    END IF;

    IF user_count = 0 THEN
		-- Generate a random salt
        -- SET salt = UNHEX(SHA2(RAND(), 256));

        -- Hash the password with the salt
        -- SET p_Password = SHA2(CONCAT(p_Password, salt), 256);
        INSERT INTO Users (Username, Password, User_Type, AccountCreatedDate)
        VALUES (p_Username, SHA2(CONCAT(p_Password, "salt"), 256), p_UserType, NULL);
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User with the same username already exists';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllUserInfo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllUserInfo`(IN p_Username VARCHAR(255))
BEGIN
    DECLARE v_UserID INT;
    DECLARE v_Username VARCHAR(255);
    DECLARE v_UserType VARCHAR(50);
    DECLARE v_ID INT;
 
    -- Get UserID, Username, and UserType from Users table
    SELECT UserID, Username, User_Type
    INTO v_UserID, v_Username, v_UserType
    FROM Users
    WHERE Username = p_Username;
 
    -- Determine ID based on UserType
    IF v_UserType = 'Patient' THEN
        -- If UserType is Patient, get PatientID
        SELECT PatientID INTO v_ID
        FROM Patients
        WHERE UserID = v_UserID;
    ELSEIF v_UserType = 'Doctor' THEN
        -- If UserType is Doctor, get DoctorID
        SELECT DoctorID INTO v_ID
        FROM Doctors
        WHERE UserID = v_UserID;
    ELSE
        -- Handle other UserType values if needed
        SET v_ID = NULL;
    END IF;
 
    -- Return the result
    SELECT v_UserID AS UserID, p_Username AS Username, v_UserType AS UserType, v_ID AS ID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetItemizedBill` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetItemizedBill`(p_RecordID INT)
BEGIN
    WITH
      cte1 AS (
        SELECT S.SpecializationName AS Item, S.ConsultationFee AS Cost
        FROM Doctors D
        JOIN MedicalRecords MR ON D.DoctorID = MR.DoctorID
        JOIN Specializations S ON D.SpecializationID = S.SpecializationID
        WHERE MR.RecordID = p_RecordID
      ),
      cte2 AS (
        SELECT P.ProcedureName AS Item, P.Cost AS Cost
        FROM ProceduresPerformed PP
        JOIN Procedures P ON PP.ProcedureID = P.ProcedureID
        WHERE PP.RecordID = p_RecordID
      ),
      cte3 AS (
        SELECT M.MedicineName AS Item, M.Price AS Cost
        FROM PrescribedMedicine PM
        JOIN Medicine M ON PM.MedicineID = M.MedicineID
        JOIN MedicalRecords MR ON PM.RecordID = MR.RecordID
        WHERE MR.RecordID = p_RecordID
      )
    SELECT * FROM cte1
    UNION ALL
    SELECT * FROM cte2
    UNION ALL
    SELECT * FROM cte3;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetMedicalRecords` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMedicalRecords`(IN p_PatientID INT)
BEGIN
    SELECT MR.RecordID, MR.DoctorID,
           CONCAT(D.FirstName, ' ', D.LastName) AS DoctorName,
           MR.PatientID,
           CONCAT(P.FirstName, ' ', P.LastName) AS PatientName,
           MR.RecordDate,
           MR.Diagnosis
    FROM MedicalRecords AS MR
    INNER JOIN Doctors AS D ON MR.DoctorID = D.DoctorID
    INNER JOIN Patients AS P ON MR.PatientID = P.PatientID
    WHERE MR.PatientID = p_PatientID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetPatientPrescribedMedicines` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetPatientPrescribedMedicines`(
    IN p_PatientID INT
)
BEGIN
    -- Retrieve prescribed medicines for the specified PatientID
    SELECT
        M.MedicineID,
        M.MedicineName,
        M.Manufacturer,
        M.ExpiryDate,
        M.DosageForm,
        M.ActiveIngredient,
        M.Price,
        M.StorageConditions
    FROM Medicine M
    JOIN PrescribedMedicine PM ON M.MedicineID = PM.MedicineID
    JOIN MedicalRecords MR ON PM.RecordID = MR.RecordID
    JOIN Patients P ON MR.PatientID = P.PatientID
    WHERE P.PatientID = p_PatientID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetUpcomingVisits` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUpcomingVisits`(
		IN p_ID INT, IN p_UserType VARCHAR(50))
BEGIN
    IF p_UserType = 'Patient' THEN		
		SELECT A.AppointmentID, CONCAT(P.FirstName, P.LastName) as PatientName, P.DateOfBirth, P.Gender, CONCAT(D.FirstName, D.LastName) as DoctorName, A.AppointmentDate, A.Reason 
			FROM Appointments as A
			inner join Patients as P
			on A.PatientID = P.PatientID
			inner join Doctors as D
			on D.DoctorID = A.DoctorID
			where A.PatientID = p_ID and A.AppointmentDate > curdate()
			order by A.AppointmentDate;
	ELSEIF p_UserType = 'Doctor' THEN		
		SELECT A.AppointmentID, CONCAT(P.FirstName, P.LastName) as PatientName, P.DateOfBirth, P.Gender, CONCAT(D.FirstName, D.LastName) as DoctorName, A.AppointmentDate, A.Reason 
			FROM Appointments as A
			inner join Patients as P
			on A.PatientID = P.PatientID
			inner join Doctors as D
			on D.DoctorID = A.DoctorID
			where A.DoctorID = p_ID and A.AppointmentDate > curdate()
			order by A.AppointmentDate;
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateAppointment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateAppointment`(
    IN p_AppointmentID INT,
    IN p_PatientID INT,
    IN p_DoctorID INT,
    IN p_SpecializationName VARCHAR(100),
    IN p_AppointmentDate DATETIME,
    IN p_Reason TEXT
)
BEGIN
	DECLARE doctor_available INT;
	DECLARE v_DoctorID INT;
    
	SELECT COUNT(*) INTO doctor_available FROM Doctors AS D 
		INNER JOIN DoctorAvailableDates AS DA ON D.DoctorID = DA.DoctorID
        WHERE D.DoctorID = p_DoctorID
		AND DAYNAME(DA.AvailableDate) = DAYNAME(p_AppointmentDate)
		AND TIME(DA.AvailableDate) = TIME(p_AppointmentDate);
    
    SELECT D.DoctorID INTO v_DoctorID FROM Doctors AS D
		INNER JOIN Specializations AS S ON D.SpecializationID = S.SpecializationID 
		INNER JOIN DoctorAvailableDates AS DA ON D.DoctorID = DA.DoctorID
		WHERE S.SpecializationName = p_SpecializationName
		AND DAYNAME(DA.AvailableDate) = DAYNAME(p_AppointmentDate)
		AND TIME(DA.AvailableDate) = TIME(p_AppointmentDate);
    
	IF p_DoctorID IS NOT NULL AND doctor_available THEN
		UPDATE Appointments
		SET PatientID = p_PatientID, DoctorID = p_DoctorID, AppointmentDate = p_AppointmentDate, Reason = p_Reason
		WHERE AppointmentID = p_AppointmentID;
	ELSEIF v_DoctorID IS NOT NULL THEN
		UPDATE Appointments
		SET PatientID = p_PatientID, DoctorID = v_DoctorID, AppointmentDate = p_AppointmentDate, Reason = p_Reason
		WHERE AppointmentID = p_AppointmentID;
	ELSE
		SELECT 'Unable to update appointment' AS Message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateBillingPaymentStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateBillingPaymentStatus`(
    IN p_BillingID INT,
    IN p_NewPaymentStatus ENUM('Pending', 'Paid')
)
BEGIN
    -- Update the billing payment status
    UPDATE Billing
    SET PaymentStatus = p_NewPaymentStatus
    WHERE BillID = p_BillingID;

    -- Check if the update was successful
    IF ROW_COUNT() > 0 THEN
        SELECT CONCAT('Billing payment status updated successfully. New payment status: ', p_NewPaymentStatus) AS Message;
    ELSE
        SELECT 'Billing not found. No update performed.' AS Message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-12-08 20:21:42
