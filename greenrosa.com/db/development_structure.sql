CREATE TABLE `alternatives` (
  `id` int(11) NOT NULL auto_increment,
  `application_name` varchar(50) NOT NULL,
  `application_description` varchar(255) NOT NULL,
  `source_url` varchar(255) default NULL,
  `file_name` varchar(255) default NULL,
  `content_type` varchar(255) default NULL,
  `file_size` varchar(255) default NULL,
  `ruby_version` varchar(50) NOT NULL,
  `rails_version` varchar(50) NOT NULL,
  `application_ide` varchar(50) NOT NULL,
  `application_status` int(11) NOT NULL,
  `approved` tinyint(1) default '0',
  `remote_ip` varchar(45) NOT NULL,
  `user_id` varchar(40) default '',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `user_id_index` (`user_id`),
  KEY `alternative_id_index` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `collaborate` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` varchar(40) default '',
  `alternative_id` varchar(40) NOT NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `collaborate_id_index` (`id`),
  KEY `user_id_index` (`user_id`),
  KEY `alternative_id_index` (`alternative_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `features` (
  `id` int(11) NOT NULL auto_increment,
  `alternative_id` varchar(40) NOT NULL,
  `record_text` varchar(100) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `alternative_id_index` (`alternative_id`),
  KEY `feature_id_index` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL auto_increment,
  `session_id` varchar(255) NOT NULL,
  `data` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

CREATE TABLE `users` (
  `user_id` varchar(40) NOT NULL default '0',
  `username` varchar(40) NOT NULL,
  `email` varchar(100) NOT NULL,
  `first_name` varchar(24) NOT NULL,
  `mi` varchar(1) default NULL,
  `last_name` varchar(24) NOT NULL,
  `user_alias` varchar(24) NOT NULL,
  `role` varchar(8) NOT NULL default 'guest',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `remote_ip` varchar(255) default NULL,
  `approved` tinyint(1) default '0',
  `crypted_password` varchar(40) default NULL,
  `salt` varchar(40) default NULL,
  `remember_token` varchar(255) default NULL,
  `remember_token_expires_at` datetime default NULL,
  `activation_code` varchar(40) default NULL,
  `reset_code` varchar(40) default NULL,
  `activated_at` datetime default NULL,
  `display_name` int(11) default NULL,
  KEY `uuid_index` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

