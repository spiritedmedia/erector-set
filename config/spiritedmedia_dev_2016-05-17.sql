# ************************************************************
# Sequel Pro SQL dump
# Version 4541
#
# http://www.sequelpro.com/
# https://github.com/sequelpro/sequelpro
#
# Host: 127.0.0.1 (MySQL 5.5.5-10.1.14-MariaDB-1~trusty)
# Database: spiritedmedia_dev
# Generation Time: 2016-05-17 21:23:57 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table wp_blog_versions
# ------------------------------------------------------------

DROP TABLE IF EXISTS `wp_blog_versions`;

CREATE TABLE `wp_blog_versions` (
  `blog_id` bigint(20) NOT NULL DEFAULT '0',
  `db_version` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `last_updated` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`blog_id`),
  KEY `db_version` (`db_version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



# Dump of table wp_blogs
# ------------------------------------------------------------

DROP TABLE IF EXISTS `wp_blogs`;

CREATE TABLE `wp_blogs` (
  `blog_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `site_id` bigint(20) NOT NULL DEFAULT '0',
  `domain` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `path` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `registered` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `last_updated` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `public` tinyint(2) NOT NULL DEFAULT '1',
  `archived` tinyint(2) NOT NULL DEFAULT '0',
  `mature` tinyint(2) NOT NULL DEFAULT '0',
  `spam` tinyint(2) NOT NULL DEFAULT '0',
  `deleted` tinyint(2) NOT NULL DEFAULT '0',
  `lang_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`blog_id`),
  KEY `domain` (`domain`(50),`path`(5)),
  KEY `lang_id` (`lang_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

LOCK TABLES `wp_blogs` WRITE;
/*!40000 ALTER TABLE `wp_blogs` DISABLE KEYS */;

INSERT INTO `wp_blogs` (`blog_id`, `site_id`, `domain`, `path`, `registered`, `last_updated`, `public`, `archived`, `mature`, `spam`, `deleted`, `lang_id`)
VALUES
	(1,1,'spiritedmedia.dev','/','2016-05-16 21:31:54','0000-00-00 00:00:00',1,0,0,0,0,0),
	(2,1,'billypenn.spiritedmedia.dev','/','2016-05-17 15:16:47','2016-05-17 15:16:47',1,0,0,0,0,0),
	(3,1,'theincline.spiritedmedia.dev','/','2016-05-17 15:17:10','2016-05-17 15:17:10',1,0,0,0,0,0);

/*!40000 ALTER TABLE `wp_blogs` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table wp_domain_mapping
# ------------------------------------------------------------

DROP TABLE IF EXISTS `wp_domain_mapping`;

CREATE TABLE `wp_domain_mapping` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `blog_id` bigint(20) NOT NULL,
  `domain` varchar(255) NOT NULL,
  `active` tinyint(4) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `blog_id` (`blog_id`,`domain`,`active`),
  KEY `domain` (`domain`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES `wp_domain_mapping` WRITE;
/*!40000 ALTER TABLE `wp_domain_mapping` DISABLE KEYS */;

INSERT INTO `wp_domain_mapping` (`id`, `blog_id`, `domain`, `active`)
VALUES
	(1,2,'billypenn.dev',1),
	(2,3,'theincline.dev',1);

/*!40000 ALTER TABLE `wp_domain_mapping` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table wp_site
# ------------------------------------------------------------

DROP TABLE IF EXISTS `wp_site`;

CREATE TABLE `wp_site` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `domain` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `path` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `domain` (`domain`(140),`path`(51))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

LOCK TABLES `wp_site` WRITE;
/*!40000 ALTER TABLE `wp_site` DISABLE KEYS */;

INSERT INTO `wp_site` (`id`, `domain`, `path`)
VALUES
	(1,'spiritedmedia.dev','/');

/*!40000 ALTER TABLE `wp_site` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table wp_sitemeta
# ------------------------------------------------------------

DROP TABLE IF EXISTS `wp_sitemeta`;

CREATE TABLE `wp_sitemeta` (
  `meta_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `site_id` bigint(20) NOT NULL DEFAULT '0',
  `meta_key` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meta_value` longtext COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`meta_id`),
  KEY `meta_key` (`meta_key`(191)),
  KEY `site_id` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

LOCK TABLES `wp_sitemeta` WRITE;
/*!40000 ALTER TABLE `wp_sitemeta` DISABLE KEYS */;

INSERT INTO `wp_sitemeta` (`meta_id`, `site_id`, `meta_key`, `meta_value`)
VALUES
	(1,1,'site_name','spiritedmedia.dev Sites'),
	(2,1,'admin_email','product@billypenn.com'),
	(3,1,'admin_user_id','1'),
	(4,1,'registration','none'),
	(5,1,'upload_filetypes','jpg jpeg png gif mov avi mpg 3gp 3g2 midi mid pdf doc ppt odt pptx docx pps ppsx xls xlsx key mp3 ogg wma m4a wav mp4 m4v webm ogv wmv flv'),
	(6,1,'blog_upload_space','100'),
	(7,1,'fileupload_maxk','999999'),
	(8,1,'site_admins','a:1:{i:0;s:5:\"admin\";}'),
	(9,1,'allowedthemes','a:2:{s:13:\"twentysixteen\";b:1;s:8:\"pedestal\";b:1;}'),
	(10,1,'illegal_names','a:8:{i:0;s:3:\"www\";i:1;s:3:\"web\";i:2;s:4:\"root\";i:3;s:5:\"admin\";i:4;s:4:\"main\";i:5;s:6:\"invite\";i:6;s:13:\"administrator\";i:7;s:5:\"files\";}'),
	(11,1,'wpmu_upgrade_site','36686'),
	(12,1,'welcome_email','Howdy USERNAME,\r\n\r\nYour new SITE_NAME site has been successfully set up at:\r\nBLOG_URL\r\n\r\nYou can log in to the administrator account with the following information:\r\n\r\nUsername: USERNAME\r\nPassword: PASSWORD\r\nLog in here: BLOG_URLwp-login.php\r\n\r\nWe hope you enjoy your new site. Thanks!\r\n\r\n--The Team @ SITE_NAME'),
	(13,1,'first_post','Welcome to %s. This is your first post. Edit or delete it, then start blogging!'),
	(14,1,'siteurl','http://spiritedmedia.dev/'),
	(15,1,'add_new_users','0'),
	(16,1,'upload_space_check_disabled','1'),
	(17,1,'subdomain_install','1'),
	(18,1,'global_terms_enabled','0'),
	(19,1,'ms_files_rewriting','0'),
	(20,1,'initial_db_version','36686'),
	(21,1,'active_sitewide_plugins','a:3:{s:29:\"nginx-helper/nginx-helper.php\";i:1463434319;s:23:\"debug-bar/debug-bar.php\";i:1463515520;s:21:\"wp-redis/wp-redis.php\";i:1463516139;}'),
	(22,1,'WPLANG',''),
	(33,1,'user_count','1'),
	(34,1,'blog_count','3'),
	(35,1,'can_compress_scripts','0'),
	(36,1,'external_updates-tablepress-responsive-tables','O:8:\"stdClass\":3:{s:9:\"lastCheck\";i:1463515470;s:14:\"checkedVersion\";s:3:\"1.3\";s:6:\"update\";O:8:\"stdClass\":7:{s:2:\"id\";i:0;s:4:\"slug\";s:28:\"tablepress-responsive-tables\";s:7:\"version\";s:3:\"1.3\";s:8:\"homepage\";s:52:\"https://tablepress.org/extensions/responsive-tables/\";s:12:\"download_url\";s:72:\"https://tablepress.org/update/extension/tablepress-responsive-tables.zip\";s:14:\"upgrade_notice\";N;s:8:\"filename\";s:125:\"var/www/spiritedmedia.dev/htdocs/wp-content/themes/pedestal/lib/tablepress-responsive-tables/tablepress-responsive-tables.php\";}}'),
	(46,1,'registrationnotification','yes'),
	(47,1,'welcome_user_email','Howdy USERNAME,\r\n\r\nYour new account is set up.\r\n\r\nYou can log in with the following information:\r\nUsername: USERNAME\r\nPassword: PASSWORD\r\nLOGINLINK\r\n\r\nThanks!\r\n\r\n--The Team @ SITE_NAME'),
	(48,1,'menu_items','a:0:{}'),
	(49,1,'first_page',''),
	(50,1,'first_comment',''),
	(51,1,'first_comment_url',''),
	(52,1,'first_comment_author',''),
	(53,1,'limited_email_domains',''),
	(54,1,'banned_email_domains',''),
	(57,1,'recently_activated','a:0:{}');

/*!40000 ALTER TABLE `wp_sitemeta` ENABLE KEYS */;
UNLOCK TABLES;



/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
