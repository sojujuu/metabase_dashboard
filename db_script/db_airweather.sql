-- ================================================================
-- Database: db_airweather (generic, no ENGINE hints)
-- ================================================================
CREATE DATABASE IF NOT EXISTS db_airweather;
USE db_airweather;

SET FOREIGN_KEY_CHECKS = 0;

-- =======================
-- DIMENSIONS / MASTER
-- =======================

CREATE TABLE IF NOT EXISTS city (
  city_id     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name        VARCHAR(100) NOT NULL,
  province    VARCHAR(100) NULL,
  country     VARCHAR(100) NULL,
  PRIMARY KEY (city_id)
);

CREATE TABLE IF NOT EXISTS location (
  location_id  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  city_id      INT UNSIGNED NOT NULL,
  name         VARCHAR(150) NOT NULL,
  station_code VARCHAR(40) NOT NULL,
  station_type VARCHAR(50) NULL,
  is_active    TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (location_id),
  UNIQUE KEY uq_location_station_code (station_code),
  KEY idx_location_city (city_id),
  CONSTRAINT fk_location_city
    FOREIGN KEY (city_id) REFERENCES city(city_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS date_dim (
  date_id  INT UNSIGNED NOT NULL,
  `year`   SMALLINT NOT NULL,
  `month`  TINYINT  NOT NULL,
  `day`    TINYINT  NOT NULL,
  dow      TINYINT  NOT NULL,
  `week`   TINYINT  NOT NULL,
  PRIMARY KEY (date_id),
  KEY idx_date_y_m (year, month),
  KEY idx_date_week (year, week)
);

CREATE TABLE IF NOT EXISTS pollutant (
  pollutant_id   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  code           VARCHAR(10) NOT NULL,
  pollutant_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (pollutant_id),
  UNIQUE KEY uq_pollutant_code (code)
);

CREATE TABLE IF NOT EXISTS aqi_category (
  aqi_cat_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`     VARCHAR(60) NOT NULL,
  color_hex  CHAR(7) NOT NULL,  -- e.g. #00E400
  PRIMARY KEY (aqi_cat_id)
);

-- =======================
-- FACT / OBSERVATIONS
-- =======================

CREATE TABLE IF NOT EXISTS weather_observation (
  weather_id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  location_id        INT UNSIGNED NOT NULL,
  date_id            INT UNSIGNED NOT NULL,
  temp_min           DECIMAL(5,2)  NULL,
  temp_max           DECIMAL(5,2)  NULL,
  temp_avg           DECIMAL(5,2)  NULL,
  humidity_pct       DECIMAL(5,2)  NULL,
  rainfall           DECIMAL(7,2)  NULL,
  sunshine_hours     DECIMAL(5,2)  NULL,
  wind_speed_max     DECIMAL(6,2)  NULL,
  wind_speed_avg     DECIMAL(6,2)  NULL,
  wind_dir_max_deg   DECIMAL(6,2)  NULL,
  wind_dir_cardinal  VARCHAR(8)    NULL,
  quality_flag       TINYINT(1)    NULL,
  PRIMARY KEY (weather_id),
  UNIQUE KEY uq_weather_loc_date (location_id, date_id),
  KEY idx_weather_date (date_id),
  CONSTRAINT fk_weather_location
    FOREIGN KEY (location_id) REFERENCES location(location_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_weather_date
    FOREIGN KEY (date_id) REFERENCES date_dim(date_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS pollutant_observation (
  poll_obs_id  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  location_id  INT UNSIGNED NOT NULL,
  date_id      INT UNSIGNED NOT NULL,
  pollutant_id INT UNSIGNED NOT NULL,
  sub_index    INT NULL,
  quality_flag TINYINT(1) NULL,
  PRIMARY KEY (poll_obs_id),
  UNIQUE KEY uq_pollobs_loc_date_pollutant (location_id, date_id, pollutant_id),
  KEY idx_pollobs_date (date_id),
  KEY idx_pollobs_pollutant (pollutant_id),
  CONSTRAINT fk_pollobs_location
    FOREIGN KEY (location_id) REFERENCES location(location_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_pollobs_date
    FOREIGN KEY (date_id) REFERENCES date_dim(date_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_pollobs_pollutant
    FOREIGN KEY (pollutant_id) REFERENCES pollutant(pollutant_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS aqi_daily (
  aqi_daily_id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  location_id           INT UNSIGNED NOT NULL,
  date_id               INT UNSIGNED NOT NULL,
  aqi_cat_id            INT UNSIGNED NOT NULL,
  dominant_pollutant_id INT UNSIGNED NULL,
  aqi_value    INT NULL,
  quality_flag TINYINT(1) NULL,
  PRIMARY KEY (aqi_daily_id),
  UNIQUE KEY uq_aqi_loc_date (location_id, date_id),
  KEY idx_aqi_date (date_id),
  KEY idx_aqi_cat (aqi_cat_id),
  KEY idx_aqi_dom_pollutant (dominant_pollutant_id),
  CONSTRAINT fk_aqi_location
    FOREIGN KEY (location_id) REFERENCES location(location_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_aqi_date
    FOREIGN KEY (date_id) REFERENCES date_dim(date_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_aqi_category
    FOREIGN KEY (aqi_cat_id) REFERENCES aqi_category(aqi_cat_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_aqi_dom_pollutant
    FOREIGN KEY (dominant_pollutant_id) REFERENCES pollutant(pollutant_id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

-- =======================
-- QUEUE / CONTROL
-- =======================

CREATE TABLE IF NOT EXISTS processing_request (
  processing_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  period_start  DATE NOT NULL,
  period_end    DATE NOT NULL,
  method        VARCHAR(50) NOT NULL,           -- ex: 'pearson','spearman'
  status        VARCHAR(50) NOT NULL DEFAULT 'queued',
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (processing_id),
  KEY idx_processing_period (period_start, period_end),
  KEY idx_processing_status (status, created_at)
);

-- =======================
-- RESULTS
-- =======================

CREATE TABLE IF NOT EXISTS correlation_result (
  corr_id       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  location_id   INT  UNSIGNED   NOT NULL,
  pollutant_id  INT  UNSIGNED   NOT NULL,
  period_start  DATE NOT NULL,
  period_end    DATE NOT NULL,
  weather_metric VARCHAR(50) NOT NULL,          -- ex: 'temp_avg','rainfall', etc.
  method         VARCHAR(50) NOT NULL,          -- ex: 'pearson','spearman'
  r_value       DECIMAL(10,6) NOT NULL,
  p_value       DECIMAL(12,10) NULL,
  n_samples     INT UNSIGNED   NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (corr_id),
  KEY idx_corr_lookup (location_id, period_start, period_end, pollutant_id, method),
  KEY idx_corr_pollutant (pollutant_id),
  CONSTRAINT fk_corr_location
    FOREIGN KEY (location_id) REFERENCES location(location_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_corr_pollutant
    FOREIGN KEY (pollutant_id) REFERENCES pollutant(pollutant_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

SET FOREIGN_KEY_CHECKS = 1;
