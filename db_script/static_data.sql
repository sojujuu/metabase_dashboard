USE db_airweather;

INSERT INTO city (name, province, country)
VALUES
  ('Jakarta', 'DKI Jakarta', 'Indonesia');
  
INSERT INTO location (city_id, station_code, station_type)
VALUES
  (1, 'DKI1', 'Bunderan HI'),
  (1, 'DKI2', 'Kelapa Gading'),
  (1, 'DKI3', 'Jagakarsa'),
  (1, 'DKI4', 'Lubang Buaya'),
  (1, 'DKI5', 'Kebon Jeruk');

INSERT INTO aqi_category (aqicat_name)
VALUES
  ('BAIK'),
  ('SEDANG'),
  ('TIDAK SEHAT'),
  ('SANGAT TIDAK SEHAT'),
  ('TIDAK ADA DATA');

INSERT INTO weather_attribute (weatherattr_code, weatherattr_name, weatherattr_unit)
VALUES
  ('TN',     'Temperatur Minimum Harian',       '°C'),
  ('TX',     'Temperatur Maksimum Harian',      '°C'),
  ('TAVG',   'Temperatur Rata-rata Harian',     '°C'),
  ('RH_AVG', 'Kelembapan Relatif Rata-rata',    '%'),
  ('RR',     'Curah Hujan Harian',              'mm'),
  ('SS',     'Durasi Penyinaran Matahari',      'jam'),
  ('FF_X',   'Kecepatan Angin Maksimum',        'm/s'),
  ('DDD_X',  'Arah Angin pada Kecepatan Maks',  'derajat'),
  ('FF_AVG', 'Kecepatan Angin Rata-rata',       'm/s');

INSERT INTO pollutant_attribute (pollutantattr_code, pollutantattr_name, pollutantattr_unit)
VALUES
  ('PM25', 'Particulate Matter ≤ 2.5 µm', 'µg/m³'),
  ('PM10', 'Particulate Matter ≤ 10 µm',  'µg/m³'),
  ('SO2',  'Sulfur Dioksida',             'ppm'),
  ('CO',   'Karbon Monoksida',            'ppm'),
  ('O3',   'Ozon Permukaan',              'ppm'),
  ('NO2',  'Nitrogen Dioksida',           'ppm');

SELECT * FROM aqi_category;