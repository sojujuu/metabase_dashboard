USE db_airweather;

INSERT INTO city (name, province, country)
VALUES
  ('Jakarta', 'DKI Jakarta', 'Indonesia');
  
INSERT INTO location (city_id, station_code, station_name)
VALUES
  (1, 'DKI1', 'Bunderan HI'),
  (1, 'DKI2', 'Kelapa Gading'),
  (1, 'DKI3', 'Jagakarsa'),
  (1, 'DKI4', 'Lubang Buaya'),
  (1, 'DKI5', 'Kebon Jeruk'),
  (1, 'CITY_AGG_JKT', 'CITY_AGG_JAKARTA'); -- baru ditambahin unutk agregasi data kota

INSERT INTO aqi_category (aqicat_name)
VALUES
  ('BAIK'),
  ('SEDANG'),
  ('TIDAK SEHAT'),
  ('SANGAT TIDAK SEHAT'),
  ('TIDAK ADA DATA');

INSERT INTO correlation_flag (corrflag_id, corrflag_desc)
VALUES
  (1, 'STABLE'),
  (2, 'CONSISTENT_WEAKER'),
  (3, 'NONLINEAR_OR_OUTLIERS'),
  (4, 'UNRELIABLE'),
  (5, 'INCONCLUSIVE');

INSERT INTO weather_attribute (weatherattr_code, weatherattr_name, weatherattr_unit)
VALUES
  ('suhu_min',     'Temperatur Minimum Harian',       '°C'),
  ('suhu_max',     'Temperatur Maksimum Harian',      '°C'),
  ('suhu_avg',     'Temperatur Rata-rata Harian',     '°C'),
  ('kelembapan_avg',   'Kelembapan Relatif Rata-rata',    '%'),
  ('curah_hujan',  'Curah Hujan Harian',              'mm'),
  ('durasi_penyinaran', 'Durasi Penyinaran Matahari',      'jam'),
  ('kecepatan_angin_max',         'Kecepatan Angin Maksimum',        'm/s'),
  ('arah_angin_max',       'Arah Angin pada Kecepatan Maks',  'derajat'),
  ('kecepatan_angin_avg',     'Kecepatan Angin Rata-rata',       'm/s');

INSERT INTO pollutant_attribute (pollutantattr_code, pollutantattr_name, pollutantattr_unit)
VALUES
  ('PM25', 'Particulate Matter ≤ 2.5 µm', 'µg/m³'),
  ('PM10', 'Particulate Matter ≤ 10 µm',  'µg/m³'),
  ('SO2',  'Sulfur Dioksida',             'ppm'),
  ('CO',   'Karbon Monoksida',            'ppm'),
  ('O3',   'Ozon Permukaan',              'ppm'),
  ('NO2',  'Nitrogen Dioksida',           'ppm');

INSERT IGNORE INTO correlation_metrics (corrmet_code, corrmet_desc, weather_x, pollutant_y, is_active) -- 5
SELECT
  CONCAT('CORR_', wa.weatherattr_code, '__', pa.pollutantattr_code) AS corrmet_code,
  CONCAT('Pearson: ', wa.weatherattr_name, ' vs ', pa.pollutantattr_name) AS corrmet_desc,
  wa.weatherattr_id,
  pa.pollutantattr_id,
  1
FROM (
  SELECT 'SUHU_MIN','pm25' UNION ALL
  SELECT 'SUHU_MIN','pm10' UNION ALL
  SELECT 'SUHU_MIN','so2'  UNION ALL
  SELECT 'SUHU_MIN','co'   UNION ALL
  SELECT 'SUHU_MIN','o3'   UNION ALL 
  SELECT 'SUHU_MIN','no2'  UNION ALL
	
  SELECT 'SUHU_MAX','pm25' UNION ALL
  SELECT 'SUHU_MAX','pm10' UNION ALL
  SELECT 'SUHU_MAX','so2'  UNION ALL
  SELECT 'SUHU_MAX','co'   UNION ALL
  SELECT 'SUHU_MAX','o3'   UNION ALL 
  SELECT 'SUHU_MAX','no2'  UNION ALL
  
  SELECT 'SUHU_AVG','pm25' UNION ALL
  SELECT 'SUHU_AVG','pm10' UNION ALL
  SELECT 'SUHU_AVG','so2'  UNION ALL
  SELECT 'SUHU_AVG','co'   UNION ALL
  SELECT 'SUHU_AVG','o3'   UNION ALL 
  SELECT 'SUHU_AVG','no2'  UNION ALL
    
  SELECT 'KELEMBAPAN_AVG','pm25' UNION ALL
  SELECT 'KELEMBAPAN_AVG','pm10' UNION ALL
  SELECT 'KELEMBAPAN_AVG','so2'  UNION ALL
  SELECT 'KELEMBAPAN_AVG','co'   UNION ALL
  SELECT 'KELEMBAPAN_AVG','o3'   UNION ALL 
  SELECT 'KELEMBAPAN_AVG','no2'  UNION ALL
  
  SELECT 'CURAH_HUJAN','pm25'    UNION ALL
  SELECT 'CURAH_HUJAN','pm10'    UNION ALL
  SELECT 'CURAH_HUJAN','so2'  UNION ALL
  SELECT 'CURAH_HUJAN','co'   UNION ALL
  SELECT 'CURAH_HUJAN','o3'   UNION ALL 
  SELECT 'CURAH_HUJAN','no2'  UNION ALL
  
  SELECT 'DURASI_PENYINARAN','pm25'   UNION ALL
  SELECT 'DURASI_PENYINARAN','pm10' UNION ALL
  SELECT 'DURASI_PENYINARAN','so2'  UNION ALL
  SELECT 'DURASI_PENYINARAN','co'   UNION ALL
  SELECT 'DURASI_PENYINARAN','o3'   UNION ALL 
  SELECT 'DURASI_PENYINARAN','no2'  UNION ALL
  
  SELECT 'KECEPATAN_ANGIN_MAX','pm25' UNION ALL
  SELECT 'KECEPATAN_ANGIN_MAX','pm10' UNION ALL
  SELECT 'KECEPATAN_ANGIN_MAX','so2'  UNION ALL
  SELECT 'KECEPATAN_ANGIN_MAX','co'   UNION ALL
  SELECT 'KECEPATAN_ANGIN_MAX','o3'   UNION ALL 
  SELECT 'KECEPATAN_ANGIN_MAX','no2'  UNION ALL
  
  SELECT 'ARAH_ANGIN_MAX','pm25' UNION ALL
  SELECT 'ARAH_ANGIN_MAX','pm10' UNION ALL
  SELECT 'ARAH_ANGIN_MAX','so2'  UNION ALL
  SELECT 'ARAH_ANGIN_MAX','co'   UNION ALL
  SELECT 'ARAH_ANGIN_MAX','o3'   UNION ALL 
  SELECT 'ARAH_ANGIN_MAX','no2'  UNION ALL
  
  SELECT 'KECEPATAN_ANGIN_AVG','pm25' UNION ALL
  SELECT 'KECEPATAN_ANGIN_AVG','pm10' UNION ALL
  SELECT 'KECEPATAN_ANGIN_AVG','so2'  UNION ALL
  SELECT 'KECEPATAN_ANGIN_AVG','co'   UNION ALL
  SELECT 'KECEPATAN_ANGIN_AVG','o3'   UNION ALL 
  SELECT 'KECEPATAN_ANGIN_AVG','no2'  
  
) AS pairs(wx_code, py_code)
JOIN weather_attribute wa  ON wa.weatherattr_code = pairs.wx_code
JOIN pollutant_attribute pa ON pa.pollutantattr_code = pairs.py_code;

