
SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

/********************************** DATABASE **********************************/
DROP DATABASE IF EXISTS fractum;
CREATE DATABASE fractum DEFAULT CHARACTER
SET utf8 COLLATE utf8_spanish_ci; USE fractum;
/********************************** DATABASE **********************************/

/*********************************** USERS ************************************/
GRANT USAGE ON *.* TO 'fractum'@'localhost';
DROP USER 'fractum'@'localhost';
CREATE USER 'fractum'@'localhost' IDENTIFIED BY 'fractum';
GRANT USAGE ON * . * TO  'fractum'@'localhost' IDENTIFIED BY  'fractum'
WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;
GRANT ALL PRIVILEGES ON  fractum . * TO  'fractum'@'localhost' WITH GRANT OPTION;
/*********************************** USERS ************************************/

/********************************* CREATES ************************************/
CREATE TABLE `permissions` (
	`id` varchar(4) NOT NULL,
	`type` varchar(20) NOT NULL,
	`actor` varchar(20) NOT NULL,
	`action` varchar(20) NOT NULL,
	`value` int(1) NOT NULL,
	PRIMARY KEY (`type`,`actor`,`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

CREATE TABLE `user` (
	`type` varchar(20) NOT NULL,
	`dni` varchar(15) NOT NULL,
	`pass` varchar(20) NOT NULL,
	`name` varchar(20) NOT NULL,
	`surname` varchar(20) NOT NULL,
	`prefix` varchar(5),
	`phone` int(9),
	`mail` varchar(50),
	PRIMARY KEY (`dni`),
	CONSTRAINT `user_fk_1` FOREIGN KEY (`type`) REFERENCES `permissions` (`type`) on delete set null
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

CREATE TABLE `acces` (
	`user` varchar(15) NOT NULL,
	`token` varchar(15) NOT NULL,
	PRIMARY KEY (`user`,`token`),
	CONSTRAINT `acces_fk_1` FOREIGN KEY (`user`) REFERENCES `user` (`dni`) on delete cascade
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

CREATE TABLE `definedRules` (
	`rule` varchar(20) NOT NULL,
	`action` varchar(20) NOT NULL,
	`field` varchar(40) NOT NULL,
	`data` varchar(40) NOT NULL,
	PRIMARY KEY (`rule`,`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

CREATE TABLE `rulesPerUser` (
	`dni` varchar(15) NOT NULL,
	`rule` varchar(20) NOT NULL,
	PRIMARY KEY (`dni`,`rule`),
	CONSTRAINT `rulesperuser_fk_1` FOREIGN KEY (`dni`) REFERENCES `user` (`dni`) on delete cascade,
	CONSTRAINT `rulesperuser_fk_2` FOREIGN KEY (`rule`) REFERENCES `definedRules` (`rule`) on delete cascade
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

CREATE TABLE `line` (
	`id` varchar(4) NOT NULL,
	`name` varchar(25) NOT NULL,
	`description` varchar(350) NOT NULL,
	`status` tinyint(1) NOT NULL,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

CREATE TABLE `company` (
	`cif` varchar(15) NOT NULL,
	`name` varchar(25) NOT NULL,
	`prefix` varchar(4) NOT NULL,
	`phone` int(9) NOT NULL,
	`mail` varchar(50) NOT NULL,
	`address` varchar(150),
	PRIMARY KEY (`cif`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

CREATE TABLE `upkeep` (
	`id` varchar(4) NOT NULL,
	`name` varchar(25) NOT NULL,
	`company` varchar(15) NOT NULL,
	`time` int(2) NOT NULL,
	`unit` tinyint(1) NOT NULL, /*(0:semanas, 1:meses, 2:años)*/
	`cost` decimal(5,2) NOT NULL,
	`date` datetime NOT NULL,
	`description` varchar(350),
	PRIMARY KEY (`id`),
	CONSTRAINT `upkeep_fk_1` FOREIGN KEY (`company`) REFERENCES `company` (`cif`) on delete cascade
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

CREATE TABLE `device` (
	`serialNumber` varchar(50) NOT NULL,
	`name` varchar(25) NOT NULL,
	`upkeep` varchar(4),
	`description` varchar(350) DEFAULT NULL,
	`date` datetime NOT NULL,
	`cost` decimal(7,2) NOT NULL,
	`line` varchar(4) DEFAULT NULL,
	PRIMARY KEY (`serialNumber`),
	CONSTRAINT `device_fk_1` FOREIGN KEY (`line`) REFERENCES `line` (`id`) on delete set null,
	CONSTRAINT `device_fk_2` FOREIGN KEY (`upkeep`) REFERENCES `upkeep` (`id`) on delete set null
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

CREATE TABLE `issue` (
	`id` varchar(4) NOT NULL,
	`title` varchar(35) NOT NULL,
	`description` varchar(350) DEFAULT NULL,
	`status` tinyint(1) NOT NULL,
	`owner` varchar(15),
	`device` varchar(50),
	`company` varchar(15),
	`openDate` datetime, /*Automática*/
	`closeDate` datetime, /*Automática*/
	PRIMARY KEY (`id`),
	CONSTRAINT `issue_fk_1` FOREIGN KEY (`owner`) REFERENCES `user` (`dni`) on delete set null,
	CONSTRAINT `issue_fk_2` FOREIGN KEY (`company`) REFERENCES `company` (`cif`) on delete set null,
	CONSTRAINT `issue_fk_3` FOREIGN KEY (`device`) REFERENCES `device` (`serialNumber`) on delete set null
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

CREATE TABLE `commit` (
	`id` varchar(4) NOT NULL,
	`title` varchar(35) NOT NULL,
	`description` varchar(350) DEFAULT NULL,
	`cost` decimal(5,2) NOT NULL,
	`owner` varchar(15),
	`issue` varchar(4),
	`date` datetime NOT NULL, /*Automática*/
	PRIMARY KEY (`id`),
	CONSTRAINT `commit_fk_1` FOREIGN KEY (`owner`) REFERENCES `user` (`dni`) on delete set null,
	CONSTRAINT `commit_fk_2` FOREIGN KEY (`issue`) REFERENCES `issue` (`id`) on delete set null
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

CREATE TABLE `lineManagers` (
	`manager` varchar(15) NOT NULL,
	`line` varchar(4) NOT NULL,
	PRIMARY KEY (`manager`,`line`),
	CONSTRAINT `lineManagers_fk_1` FOREIGN KEY (`manager`) REFERENCES `user` (`dni`) on delete cascade,
	CONSTRAINT `lineManagers_fk_2` FOREIGN KEY (`line`) REFERENCES `line` (`id`) on delete cascade
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;
/********************************* CREATES ************************************/

/********************************** INSERTS ***********************************/
INSERT INTO `permissions` VALUES ('_adm','admin','Commit','Creator',1),('_adm','admin','Commit','Eraser',1),('_adm','admin','Commit','Puller',1),('_adm','admin','Commit','Reader',1),('_adm','admin','Commit','Seeker',1),('_adm','admin','Commit','Updater',1),('_adm','admin','Company','Creator',1),('_adm','admin','Company','Eraser',1),('_adm','admin','Company','Puller',1),('_adm','admin','Company','Reader',1),('_adm','admin','Company','Seeker',1),('_adm','admin','Company','Updater',1),('_adm','admin','Device','Creator',1),('_adm','admin','Device','Eraser',1),('_adm','admin','Device','Puller',1),('_adm','admin','Device','Reader',1),('_adm','admin','Device','Seeker',1),('_adm','admin','Device','Updater',1),('_adm','admin','Issue','Creator',1),('_adm','admin','Issue','Eraser',1),('_adm','admin','Issue','Puller',1),('_adm','admin','Issue','Reader',1),('_adm','admin','Issue','Seeker',1),('_adm','admin','Issue','Updater',1),('_adm','admin','Line','Creator',1),('_adm','admin','Line','Eraser',1),('_adm','admin','Line','Puller',1),('_adm','admin','Line','Reader',1),('_adm','admin','Line','Seeker',1),('_adm','admin','Line','Updater',1),('_adm','admin','Permissions','Creator',1),('_adm','admin','Permissions','Eraser',1),('_adm','admin','Permissions','Puller',1),('_adm','admin','Permissions','Updater',1),('_adm','admin','Upkeep','Creator',1),('_adm','admin','Upkeep','Eraser',1),('_adm','admin','Upkeep','Puller',1),('_adm','admin','Upkeep','Reader',1),('_adm','admin','Upkeep','Seeker',1),('_adm','admin','Upkeep','Updater',1),('_adm','admin','User','Creator',1),('_adm','admin','User','Eraser',1),('_adm','admin','User','Puller',1),('_adm','admin','User','Reader',1),('_adm','admin','User','Seeker',1),('_adm','admin','User','Updater',1);
INSERT INTO `user` VALUES (586366414,'admin','admin','admin','admin','admin','+',0,'admin@domain.com');
INSERT INTO `company` VALUES ('default','default','0',0,'default@default.com','default');
INSERT INTO `upkeep` VALUES ('none','default','default',0,0,0.00,'0001-01-01 01:01:01',null);
/********************************** INSERTS ***********************************/

/*********************************** VIEW *************************************/
CREATE OR REPLACE VIEW device_view AS
	SELECT d.name, d.line,
	(SELECT is1.title FROM issue is1
	WHERE is1.device LIKE d.serialNumber
	ORDER BY is1.openDate DESC LIMIT 1) as lastIssue,
	(SELECT co.owner FROM commit co NATURAL JOIN issue is2
	WHERE is2.device like d.serialNumber AND co.issue like is2.id) as lastWorker
	FROM device d NATURAL JOIN issue i NATURAL JOIN commit c ORDER BY d.date desc;

CREATE OR REPLACE VIEW issue_view AS
	SELECT i.title, i.status, i.device, i.company,
	(SELECT co.title FROM commit co NATURAL JOIN issue is1
	WHERE co.issue like is1.id) as lastCommit
	FROM issue i ORDER BY i.openDate desc;
/*********************************** VIEW *************************************/
