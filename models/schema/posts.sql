CREATE TABLE IF NOT EXISTS `posts` (
			 id 	  	INT NOT NULL AUTO_INCREMENT,
			 text  	  VARCHAR(512),
			 spawn		INT,
			 is_admin TINYINT(1),
			 PRIMARY KEY(id)
);
