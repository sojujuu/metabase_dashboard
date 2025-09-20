-- Create Metabase application DB with required charset/collation
CREATE DATABASE IF NOT EXISTS `db_dashboard`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Ensure Metabase app user uses mysql_native_password (MariaDB driver compat)
ALTER USER 'metabase'@'%' IDENTIFIED WITH mysql_native_password BY 'metabase';

-- Metabase app DB needs full privileges
GRANT ALL PRIVILEGES ON `db_dashboard`.* TO 'metabase'@'%';
FLUSH PRIVILEGES;

-- (Optional) Ensure your analytics DB (created by env) is utf8mb4 as well
-- ALTER DATABASE `dashboard`
--  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
