CREATE DATABASE IF NOT EXISTS db_airweather;
USE db_airweather;
SET FOREIGN_KEY_CHECKS = 0;

-- =======================
-- DIMENSIONS / MASTER
-- =======================

CREATE TABLE IF NOT EXISTS city (
  city_id     INT NOT NULL AUTO_INCREMENT,
  name        VARCHAR(100) NOT NULL,
  province    VARCHAR(100) NULL,
  country     VARCHAR(100) NULL,

  PRIMARY KEY (city_id)
);

CREATE TABLE IF NOT EXISTS location (
  location_id  INT NOT NULL AUTO_INCREMENT,
  city_id      INT NOT NULL,
  station_code VARCHAR(50) NOT NULL,
  station_type VARCHAR(50) NULL,

  PRIMARY KEY (location_id),
  UNIQUE KEY uq_location_station_code (station_code),
  KEY idx_location_city (city_id),
  CONSTRAINT fk_location_city
    FOREIGN KEY (city_id) REFERENCES city(city_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS pollutant_attribute (
  pollutantattr_id   INT NOT NULL AUTO_INCREMENT,
  pollutantattr_code VARCHAR(10) NOT NULL,
  pollutantattr_name VARCHAR(100) NOT NULL,
  pollutantattr_unit VARCHAR(50) NOT NULL,

  PRIMARY KEY (pollutantattr_id),
  UNIQUE KEY uq_pollutantattr_code (pollutantattr_code)
);

CREATE TABLE IF NOT EXISTS weather_attribute (
  weatherattr_id    INT NOT NULL AUTO_INCREMENT,
  weatherattr_code  VARCHAR(10) NOT NULL,
  weatherattr_name  VARCHAR(100) NOT NULL,
  weatherattr_unit  VARCHAR(50) NOT NULL,

  PRIMARY KEY (weatherattr_id),
  UNIQUE KEY uq_weatherattr_code (weatherattr_code)
);

CREATE TABLE IF NOT EXISTS aqi_category (
  aqicat_id INT NOT NULL AUTO_INCREMENT,
  aqicat_name  VARCHAR(50) NOT NULL,

  PRIMARY KEY (aqicat_id)
);

-- =======================
-- FACT / OBSERVATIONS
-- =======================

CREATE TABLE IF NOT EXISTS weather_observation (
  weatherobs_id         INT NOT NULL AUTO_INCREMENT,
  location_id           INT NOT NULL,
  weatherobs_date       DATE NOT NULL,
  weatherattr_id        INT  NOT NULL,
  weatherobs_value      DECIMAL(5,1) NULL,

  PRIMARY KEY (weatherobs_id),
  UNIQUE KEY uq_weather_loc_date (location_id, weatherobs_date, weatherattr_id),
  KEY idx_weather_date (weatherobs_date),
  KEY idx_weatherobs_weather (weatherattr_id),

  CONSTRAINT fk_weatherobs_location
    FOREIGN KEY (location_id) REFERENCES location(location_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
    
  CONSTRAINT fk_weatherobs_weatherattr
    FOREIGN KEY (weatherattr_id) REFERENCES weather_attribute(weatherattr_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS pollutant_observation (
  pollobs_id  INT  NOT NULL AUTO_INCREMENT,
  location_id  INT  NOT NULL,
  pollobs_date DATE NOT NULL,
  pollutantattr_id INT  NOT NULL,
  pollobs_value DECIMAL(5,1) NULL,

  PRIMARY KEY (pollobs_id),
  UNIQUE KEY uq_pollobs_loc_date_pollutant (location_id, pollobs_date, pollutantattr_id),
  KEY idx_pollobs_date (pollobs_date),
  KEY idx_pollobs_pollutant (pollutantattr_id),

  CONSTRAINT fk_pollobs_location
    FOREIGN KEY (location_id) REFERENCES location(location_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,

  CONSTRAINT fk_pollobs_pollutantattr
    FOREIGN KEY (pollutantattr_id) REFERENCES pollutant_attribute(pollutantattr_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS aqi_daily (
  aqidaily_id           INT  NOT NULL AUTO_INCREMENT,
  location_id           INT  NOT NULL,
  aqidaily_date         DATE NOT NULL,
  aqicat_id             INT  NOT NULL,
  dominant_pollobs_id   INT  NULL,

  PRIMARY KEY (aqidaily_id),
  UNIQUE KEY uq_aqi_loc_date (location_id, aqidaily_date),
  KEY idx_aqi_date (aqidaily_date),
  KEY idx_aqi_cat (aqicat_id),
  KEY idx_aqi_dom_pollobs (dominant_pollobs_id),

  CONSTRAINT fk_aqi_location
    FOREIGN KEY (location_id) REFERENCES location(location_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,

  CONSTRAINT fk_aqi_category
    FOREIGN KEY (aqicat_id) REFERENCES aqi_category(aqicat_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,

  CONSTRAINT fk_aqi_dom_pollobs
    FOREIGN KEY (dominant_pollobs_id) REFERENCES pollutant_observation(pollobs_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS correlation_metrics (
  corrmet_id     INT NOT NULL AUTO_INCREMENT,
  corrmet_code   VARCHAR(50) NOT NULL, 
  corrmet_desc   VARCHAR(100) NOT NULL,       
  weather_x      INT NULL,       
  pollutant_y    INT NULL,      
  is_active      TINYINT NOT NULL DEFAULT 1,

  PRIMARY KEY (corrmet_id),
  UNIQUE KEY uq_corrmet_code (corrmet_code),

  CONSTRAINT fk_corrmet_weatherattr
    FOREIGN KEY (weather_x) REFERENCES weather_attribute(weatherattr_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,

  CONSTRAINT fk_corrmet_pollutantattr
    FOREIGN KEY (pollutant_y) REFERENCES pollutant_attribute(pollutantattr_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS correlation_result (
  corres_id      INT  NOT NULL AUTO_INCREMENT,
  location_id    INT  NOT NULL,
  corrmet_id     INT  NOT NULL, 
  period_name    VARCHAR(50) NOT NULL,
  processing_date DATE NOT NULL,
  r_value        DECIMAL(5,1) NULL,
  n_samples      INT  NOT NULL,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (corres_id),
  KEY idx_corres_period (period_name),
  KEY idx_corres_processing_date (processing_date),

  CONSTRAINT fk_corr_location
    FOREIGN KEY (location_id) REFERENCES location(location_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
    
  CONSTRAINT fk_corr_corrmet
    FOREIGN KEY (corrmet_id) REFERENCES correlation_metrics(corrmet_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

SET FOREIGN_KEY_CHECKS = 1;
