
<img width="1000" height="610" alt="image" src="https://github.com/user-attachments/assets/3a327ba2-f612-4fa4-8211-14e62f25358b" />


# Nike vs Adidas — Global Supply Chain Analysis
PostgreSQL + Tableau | Factory-level competitive intelligence across 11 countries

<img width="2048" height="1207" alt="content" src="https://github.com/user-attachments/assets/b697eeaa-dee8-4beb-ae24-e24d2fe32df5" />

[![Tableau](https://img.shields.io/badge/Tableau-Dashboard-purple?style=for-the-badge&logo=tableau&logoColor=white)](https://public.tableau.com/app/profile/brian.ma5935/viz/BrianNikeAdidas/Dashboard4)
[![GitHub](https://img.shields.io/badge/GitHub-brianphu2310-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/brianphu2310)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Brian%20Phu-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/brian-phu-data-analysta55353390/)

---

## Why I built this

I flip my sneakers a lot. One day I noticed my Nike Air Max said "Made in Vietnam" and my Adidas Ultraboost said "Made in Indonesia." That gap between what a brand projects and where the product actually comes from started bothering me.

I looked for a side-by-side breakdown of Nike vs Adidas manufacturing locations. Nothing good existed. So I built one myself — factory by factory, city by city, with coordinates and numbers behind each dot on the map.

---

## Business questions

1. Where are Nike and Adidas most concentrated geographically?
2. Which brand runs higher-output factories, and does that change by country?
3. Does workforce size reliably predict monthly output?
4. How does production cost vary between countries and brands?
5. Did factory output and workforce grow or shrink between 2023 and 2024?

---

## Dataset

**File:** `nike_adidas.csv`  
**42 rows, 11 columns**, covering 11 countries: Vietnam, Indonesia, China, Thailand, USA, Germany, Japan, South Korea, India, Brazil, Mexico.

| Column | Description |
|--------|-------------|
| factory_id | Surrogate key |
| brand | Nike or Adidas |
| factory_code | Human-readable ID (e.g. NK-VN-01) |
| country | Factory location |
| city | City-level precision |
| year | 2023 or 2024 |
| workers | Headcount |
| monthly_output | Units per month |
| production_cost | Normalised cost index (USD) |
| latitude / longitude | Coordinates for mapping |

**Factory count:** 21 Nike, 21 Adidas

---

## SQL Pipeline

### Schema

```sql
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
Data insert (abbreviated)

sql
INSERT INTO factories (brand, factory_code, country, city, year, workers, monthly_output, production_cost, latitude, longitude) VALUES
('Nike',   'NK-VN-01', 'Vietnam', 'Ho Chi Minh', 2023, 35000, 2500000, 45.50, 10.8231, 106.6297),
('Nike',   'NK-VN-02', 'Vietnam', 'Hanoi',       2023, 28000, 2200000, 41.20, 21.0285, 105.8542),
('Nike',   'NK-VN-03', 'Vietnam', 'Da Nang',     2024, 29000, 2400000, 43.50, 16.0544, 108.2022),
('Adidas', 'AD-VN-01', 'Vietnam', 'Ho Chi Minh', 2023, 32000, 2300000, 44.00, 10.8231, 106.6297),
('Adidas', 'AD-VN-02', 'Vietnam', 'Hanoi',       2024, 34000, 2550000, 46.80, 21.0285, 105.8542),
('Adidas', 'AD-DE-01', 'Germany', 'Berlin',      2023, 5000,  500000,  55.00, 52.5200, 13.4050),
('Adidas', 'AD-DE-02', 'Germany', 'Munich',      2024, 5200,  530000,  56.00, 48.1351, 11.5820);
-- Full insert has 42 rows
Coordinate jitter (so dots don't stack in Tableau)

sql
SELECT setseed(0.42);

UPDATE factories SET
    latitude  = latitude  + (random() * 0.09 - 0.045),
    longitude = longitude + (random() * 0.09 - 0.045) / cos(radians(latitude));
The jitter spreads factories within ~5km of their city centre. setseed(0.42) makes it reproducible.

Analytical queries

sql
-- Output per worker
SELECT brand, city, workers, monthly_output,
       ROUND(monthly_output::DECIMAL / workers, 1) AS output_per_worker
FROM factories ORDER BY output_per_worker DESC;

-- YoY workforce change
SELECT brand, city,
       MAX(CASE WHEN year = 2023 THEN workers END) AS workers_2023,
       MAX(CASE WHEN year = 2024 THEN workers END) AS workers_2024,
       MAX(CASE WHEN year = 2024 THEN workers END) - MAX(CASE WHEN year = 2023 THEN workers END) AS yoy_delta
FROM factories GROUP BY brand, city HAVING COUNT(DISTINCT year) = 2;

-- Cost per million units
SELECT brand, ROUND(SUM(production_cost) / SUM(monthly_output) * 1000000, 2) AS cost_per_million_units
FROM factories GROUP BY brand;
Dashboard charts

Chart	Purpose
Geographic bubble map	Size = workers, colour = output. Shows concentration at a glance.
Combo chart (output bars + cost line)	Tests if higher output means higher cost.
Binned histogram	Shows distribution of factory output ranges.
Workers vs output dual-axis	Checks if headcount and production move together.
Country x brand cross-tab	Basic count: how many factories per country per brand.
Key findings

Vietnam and Indonesia are the backbone. Both brands have 5 factories in Vietnam, 3 in Indonesia. High output, low cost.

Adidas keeps German factories; Nike has none in Europe. German cost index is highest (55-56), but Adidas maintains domestic production for premium lines.

Nike has US factories (Portland, Memphis); Adidas has one. Low output (~500K units/month) compared to Asia (2M+). Likely innovation/sample facilities.

China output declined from 2023 to 2024. Nike Shanghai: 30,000 → 27,000 workers. Adidas Shanghai: 22,000 → 19,000. China+1 strategy in action.

Cost gap is real. Germany: 55. Southeast Asia: 32-46. That 30-40% difference keeps volume production in Asia.

Files

text
nike-adidas-supply-chain/
├── README.md
├── SQL_DATASET.sql
└── nike_adidas.csv
How to run

bash
psql -U postgres
\i 'SQL_DATASET.sql'
COPY factories TO '/tmp/nike_adidas.csv' DELIMITER ',' CSV HEADER;
Load the CSV into Tableau Public. Set latitude/longitude as geographic roles.

What's next

Add supplier compliance data (fair labour ratings) for ESG analysis. Split production_cost into labour, materials, logistics. Map product category (running vs lifestyle vs performance) to each factory.

Brian Ma (Brian)
[![GitHub](https://img.shields.io/badge/GitHub-brianphu2310-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/brianphu2310)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Brian%20Phu-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/brian-phu-data-analysta55353390/)


*Self-initiated project. Factory data was constructed for analytical purposes based on publicly known information about Nike and Adidas manufacturing locations.*
