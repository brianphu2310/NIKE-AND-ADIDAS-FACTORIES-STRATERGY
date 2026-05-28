-- =====================================================
-- NIKE vs ADIDAS - Global Supply Chain Analysis
-- PostgreSQL | Full schema + data + analytical queries
-- =====================================================

-- =====================================================
-- PART 1: SCHEMA DESIGN
-- =====================================================

DROP TABLE IF EXISTS factories CASCADE;

CREATE TABLE factories (
    factory_id      SERIAL PRIMARY KEY,
    brand           VARCHAR(20),
    factory_code    VARCHAR(20),
    country         VARCHAR(50),
    city            VARCHAR(50),
    year            INT,
    workers         INT,
    monthly_output  INT,
    production_cost DECIMAL(10,2),
    latitude        FLOAT,
    longitude       FLOAT
);

-- =====================================================
-- PART 2: DATA INSERT (42 factories, matches CSV exactly)
-- =====================================================

INSERT INTO factories (brand, factory_code, country, city, year, workers, monthly_output, production_cost, latitude, longitude) VALUES
-- VIETNAM (Nike: 5, Adidas: 5)
('Nike',   'NK-VN-01', 'Vietnam', 'Ho Chi Minh', 2023, 35000, 2500000, 45.50, 10.8231, 106.6297),
('Nike',   'NK-VN-02', 'Vietnam', 'Hanoi',       2023, 28000, 2200000, 41.20, 21.0285, 105.8542),
('Nike',   'NK-VN-03', 'Vietnam', 'Da Nang',     2024, 29000, 2400000, 43.50, 16.0544, 108.2022),
('Nike',   'NK-VN-04', 'Vietnam', 'Can Tho',     2024, 20000, 1800000, 38.00, 10.0452, 105.7469),
('Nike',   'NK-VN-05', 'Vietnam', 'Hai Phong',   2023, 22000, 1900000, 39.00, 20.8449, 106.6881),
('Adidas', 'AD-VN-01', 'Vietnam', 'Ho Chi Minh', 2023, 32000, 2300000, 44.00, 10.8231, 106.6297),
('Adidas', 'AD-VN-02', 'Vietnam', 'Hanoi',       2024, 34000, 2550000, 46.80, 21.0285, 105.8542),
('Adidas', 'AD-VN-03', 'Vietnam', 'Da Nang',     2023, 22000, 2000000, 40.00, 16.0544, 108.2022),
('Adidas', 'AD-VN-04', 'Vietnam', 'Bien Hoa',    2024, 25000, 2100000, 41.00, 10.9500, 106.8200),
('Adidas', 'AD-VN-05', 'Vietnam', 'Hai Phong',   2023, 21000, 1850000, 38.50, 20.8449, 106.6881),

-- INDONESIA (Nike: 3, Adidas: 3)
('Nike',   'NK-ID-01', 'Indonesia', 'Jakarta',  2023, 31000, 2400000, 41.00, -6.2088, 106.8456),
('Nike',   'NK-ID-02', 'Indonesia', 'Surabaya', 2024, 33000, 2600000, 43.50, -7.2575, 112.7521),
('Nike',   'NK-ID-03', 'Indonesia', 'Bandung',  2023, 24000, 2000000, 38.00, -6.9175, 107.6191),
('Adidas', 'AD-ID-01', 'Indonesia', 'Jakarta',  2023, 33000, 2600000, 43.50, -6.2088, 106.8456),
('Adidas', 'AD-ID-02', 'Indonesia', 'Surabaya', 2024, 35000, 2800000, 45.00, -7.2575, 112.7521),
('Adidas', 'AD-ID-03', 'Indonesia', 'Medan',    2023, 20000, 1700000, 35.00, 3.5952,  98.6722),

-- CHINA (Nike: 3, Adidas: 3)
('Nike',   'NK-CN-01', 'China', 'Shanghai',  2023, 30000, 2200000, 52.00, 31.2304, 121.4737),
('Nike',   'NK-CN-02', 'China', 'Guangzhou', 2024, 27000, 2000000, 49.50, 23.1291, 113.2644),
('Nike',   'NK-CN-03', 'China', 'Suzhou',    2023, 23000, 1900000, 47.00, 31.2990, 120.5853),
('Adidas', 'AD-CN-01', 'China', 'Shanghai',  2023, 22000, 1600000, 48.00, 31.2304, 121.4737),
('Adidas', 'AD-CN-02', 'China', 'Guangzhou', 2024, 19000, 1400000, 45.00, 23.1291, 113.2644),
('Adidas', 'AD-CN-03', 'China', 'Beijing',   2023, 18000, 1500000, 46.00, 39.9042, 116.4074),

-- THAILAND (Nike: 2, Adidas: 2)
('Nike',   'NK-TH-01', 'Thailand', 'Bangkok',  2023, 18000, 1500000, 32.00, 13.7367, 100.5231),
('Nike',   'NK-TH-02', 'Thailand', 'Chonburi', 2024, 19000, 1600000, 33.50, 13.3611, 100.9847),
('Adidas', 'AD-TH-01', 'Thailand', 'Bangkok',  2023, 17000, 1450000, 31.50, 13.7367, 100.5231),
('Adidas', 'AD-TH-02', 'Thailand', 'Chonburi', 2024, 18000, 1550000, 32.50, 13.3611, 100.9847),

-- USA (Nike: 2, Adidas: 1)
('Nike',   'NK-US-01', 'USA', 'Portland', 2023, 5000, 500000, 55.00, 45.5152, -122.6784),
('Nike',   'NK-US-02', 'USA', 'Memphis',  2024, 5200, 550000, 56.00, 35.1495, -90.0490),
('Adidas', 'AD-US-01', 'USA', 'Portland', 2023, 4800, 480000, 54.00, 45.5152, -122.6784),

-- GERMANY (Adidas: 3, Nike: 0)
('Adidas', 'AD-DE-01', 'Germany', 'Berlin',          2023, 5000, 500000, 55.00, 52.5200, 13.4050),
('Adidas', 'AD-DE-02', 'Germany', 'Munich',          2024, 5200, 530000, 56.00, 48.1351, 11.5820),
('Adidas', 'AD-DE-03', 'Germany', 'Herzogenaurach',  2023, 4500, 470000, 53.00, 49.5667, 10.8833),

-- JAPAN (Nike: 1, Adidas: 1)
('Nike',   'NK-JP-01', 'Japan', 'Tokyo', 2023, 8000, 700000, 48.00, 35.6895, 139.6917),
('Adidas', 'AD-JP-01', 'Japan', 'Osaka', 2024, 7500, 680000, 47.00, 34.6937, 135.5023),

-- SOUTH KOREA (Nike: 1, Adidas: 1)
('Nike',   'NK-KR-01', 'South Korea', 'Seoul', 2023, 7000, 650000, 46.00, 37.5665, 126.9780),
('Adidas', 'AD-KR-01', 'South Korea', 'Busan', 2024, 6800, 620000, 45.00, 35.1796, 129.0756),

-- INDIA (Nike: 1, Adidas: 1)
('Nike',   'NK-IN-01', 'India', 'Mumbai',    2023, 12000, 900000, 35.00, 19.0760, 72.8777),
('Adidas', 'AD-IN-01', 'India', 'Bangalore', 2024, 11000, 850000, 34.00, 12.9716, 77.5946),

-- BRAZIL (Nike: 1, Adidas: 1)
('Nike',   'NK-BR-01', 'Brazil', 'Sao Paulo',       2023, 10000, 800000, 42.00, -23.5505, -46.6333),
('Adidas', 'AD-BR-01', 'Brazil', 'Rio de Janeiro',  2024, 9500,  780000, 41.00, -22.9068, -43.1729),

-- MEXICO (Nike: 1, Adidas: 1)
('Nike',   'NK-MX-01', 'Mexico', 'Mexico City',   2023, 15000, 1100000, 37.00, 19.4326, -99.1332),
('Adidas', 'AD-MX-01', 'Mexico', 'Guadalajara',   2024, 14000, 1050000, 36.00, 20.6597, -103.3496);

-- =====================================================
-- PART 3: COORDINATE JITTER (so Tableau doesn't stack dots)
-- =====================================================

-- Seed for reproducible randomness
SELECT setseed(0.42);

-- Apply jitter: ~5km radius (0.045 deg lat, longitude scaled by cos(lat))
UPDATE factories SET
    latitude  = latitude  + (random() * 0.09 - 0.045),
    longitude = longitude + (random() * 0.09 - 0.045) / cos(radians(latitude));

-- =====================================================
-- PART 4: ANALYTICAL QUERIES (used to validate dashboard)
-- =====================================================

-- Q1: Total factories per brand
SELECT brand, COUNT(*) AS factory_count
FROM factories
GROUP BY brand;

-- Q2: Output by country and brand
SELECT country, brand, 
       SUM(monthly_output) AS total_output,
       ROUND(AVG(production_cost), 2) AS avg_cost
FROM factories
GROUP BY country, brand
ORDER BY total_output DESC;

-- Q3: Output per worker efficiency
SELECT brand, city, workers, monthly_output,
       ROUND(monthly_output::DECIMAL / workers, 1) AS output_per_worker
FROM factories
ORDER BY output_per_worker DESC
LIMIT 10;

-- Q4: YoY workforce change (2023 vs 2024)
SELECT brand, city,
       MAX(CASE WHEN year = 2023 THEN workers END) AS workers_2023,
       MAX(CASE WHEN year = 2024 THEN workers END) AS workers_2024,
       MAX(CASE WHEN year = 2024 THEN workers END) - 
       MAX(CASE WHEN year = 2023 THEN workers END) AS yoy_change
FROM factories
GROUP BY brand, city
HAVING COUNT(DISTINCT year) = 2
ORDER BY yoy_change DESC;

-- Q5: Cost per million units
SELECT brand,
       ROUND(SUM(production_cost) / SUM(monthly_output) * 1000000, 2) AS cost_per_million_units
FROM factories
GROUP BY brand;

-- Q6: Which country has the most factories (by brand)
SELECT country, 
       COUNT(CASE WHEN brand = 'Nike' THEN 1 END) AS nike_factories,
       COUNT(CASE WHEN brand = 'Adidas' THEN 1 END) AS adidas_factories,
       COUNT(*) AS total
FROM factories
GROUP BY country
ORDER BY total DESC;

-- =====================================================
-- PART 5: EXPORT TO CSV (for Tableau)
-- =====================================================

COPY factories TO '/tmp/nike_adidas_150.csv' DELIMITER ',' CSV HEADER;

-- =====================================================
-- PART 6: VERIFICATION (check row count)
-- =====================================================

SELECT COUNT(*) AS total_rows FROM factories;  -- Should return 42
SELECT brand, COUNT(*) FROM factories GROUP BY brand;
