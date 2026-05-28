<img width="2048" height="1207" alt="content" src="https://github.com/user-attachments/assets/b697eeaa-dee8-4beb-ae24-e24d2fe32df5" />


# Nike vs Adidas — Global Supply Chain Analysis
PostgreSQL + Tableau | Factory-level competitive intelligence across 11 countries

![Dashboard](https://private-user-images.githubusercontent.com/243076453/599347968-b697eeaa-dee8-4beb-ae24-e24d2fe32df5.png)

Live dashboard: https://public.tableau.com/app/profile/brian.ma5935/viz/BrianNikeAdidas/Dashboard1

---

## Why I built this

I flip my sneakers a lot. One day I noticed my Nike Air Max said "Made in Vietnam" and my Adidas Ultraboost said "Made in Indonesia." That gap between what a brand projects and where the product actually comes from started bothering me.

I looked for a side-by-side breakdown of Nike vs Adidas manufacturing locations. Nothing good existed. So I built one myself — factory by factory, city by city, with real coordinates and real numbers behind each dot on the map.

---

## Business questions

These are the five questions I actually wanted to answer before I wrote a single line of SQL:

1. Where are Nike and Adidas most concentrated geographically, and do they overlap?
2. Which brand runs higher-output factories — and does that change by country?
3. Does workforce size reliably predict monthly output, or do some factories punch above their weight?
4. How does production cost vary between countries and between the two brands?
5. Did factory output and workforce grow or shrink between 2023 and 2024?

Everything in the dashboard — every chart, every filter, every colour choice — traces back to one of these.

---

## Dataset

File: `nike_adidas_150.csv`  
150 rows, 11 columns, covering factories across Vietnam, Indonesia, China, Thailand, USA, Germany, Japan, South Korea, India, Brazil, and Mexico.

| Column | Description |
|---|---|
| factory_id | Surrogate key, auto-incremented |
| brand | Nike or Adidas |
| factory_code | Human-readable ID — brand + country + sequence (e.g. NK-VN-01) |
| country | Country of factory location |
| city | City-level precision |
| year | 2023 or 2024 |
| workers | Total headcount at that facility |
| monthly_output | Units produced per month |
| production_cost | Normalised cost index per factory (USD) |
| latitude / longitude | Exact coordinates for Tableau mapping |

---

## SQL — what I did and why

The script went through four iterations. Here is the cleaned-up version with the reasoning behind each decision.

### Schema design

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
```

Separating country from city matters because the dashboard needs both — country for aggregations and cross-tabs, city for the individual map markers. factory_code is a business key that a human can read; factory_id is just for the database.

### Why I stopped using generate_series

My first version used a recursive CTE and generate_series to auto-populate rows. It looked clever but created a real problem: city assignments ended up clustering wrong — every Nike row for Vietnam landed in the same city regardless of which factory it was supposed to represent. Once I switched to hardcoded VALUES I had full control, and the map became accurate.

### Final data insert (abbreviated)

```sql
INSERT INTO factories (brand, factory_code, country, city, year, workers,
                       monthly_output, production_cost, latitude, longitude)
VALUES
  ('Nike',   'NK-VN-01', 'Vietnam',   'Ho Chi Minh', 2023, 35000, 2500000, 45.5,  10.8231,  106.6297),
  ('Nike',   'NK-VN-02', 'Vietnam',   'Hanoi',       2023, 28000, 2200000, 41.2,  21.0285,  105.8542),
  ('Nike',   'NK-VN-03', 'Vietnam',   'Da Nang',     2024, 29000, 2400000, 43.5,  16.0544,  108.2022),
  ('Nike',   'NK-VN-04', 'Vietnam',   'Can Tho',     2024, 20000, 1800000, 38.0,  10.0452,  105.7469),
  ('Nike',   'NK-VN-05', 'Vietnam',   'Hai Phong',   2023, 22000, 1900000, 39.0,  20.8449,  106.6881),
  ('Nike',   'NK-ID-01', 'Indonesia', 'Jakarta',     2023, 31000, 2400000, 41.0,  -6.2088,  106.8456),
  ('Nike',   'NK-ID-02', 'Indonesia', 'Surabaya',    2024, 33000, 2600000, 43.5,  -7.2575,  112.7521),
  ('Nike',   'NK-ID-03', 'Indonesia', 'Bandung',     2023, 24000, 2000000, 38.0,  -6.9175,  107.6191),
  ('Nike',   'NK-CN-01', 'China',     'Shanghai',    2023, 30000, 2200000, 52.0,  31.2304,  121.4737),
  ('Nike',   'NK-CN-02', 'China',     'Guangzhou',   2024, 27000, 2000000, 49.5,  23.1291,  113.2644),
  ('Nike',   'NK-TH-01', 'Thailand',  'Bangkok',     2023, 18000, 1500000, 32.0,  13.7367,  100.5231),
  ('Nike',   'NK-US-01', 'USA',       'Portland',    2023,  5000,  470000, 45.0,  45.5152, -122.6784),
  ('Nike',   'NK-US-02', 'USA',       'Memphis',     2024,  4800,  450000, 43.0,  35.1495,  -90.0490),
  ('Adidas', 'AD-VN-01', 'Vietnam',   'Ho Chi Minh', 2023, 32000, 2300000, 44.0,  10.8231,  106.6297),
  ('Adidas', 'AD-VN-02', 'Vietnam',   'Hanoi',       2024, 34000, 2550000, 46.8,  21.0285,  105.8542),
  ('Adidas', 'AD-VN-03', 'Vietnam',   'Da Nang',     2023, 22000, 2000000, 40.0,  16.0544,  108.2022),
  ('Adidas', 'AD-ID-01', 'Indonesia', 'Jakarta',     2023, 33000, 2600000, 43.5,  -6.2088,  106.8456),
  ('Adidas', 'AD-ID-02', 'Indonesia', 'Surabaya',    2024, 35000, 2800000, 45.0,  -7.2575,  112.7521),
  ('Adidas', 'AD-CN-01', 'China',     'Shanghai',    2023, 22000, 1600000, 48.0,  31.2304,  121.4737),
  ('Adidas', 'AD-CN-02', 'China',     'Guangzhou',   2024, 19000, 1400000, 45.0,  23.1291,  113.2644),
  ('Adidas', 'AD-DE-01', 'Germany',   'Berlin',      2023,  5000,  500000, 55.0,  52.5200,   13.4050),
  ('Adidas', 'AD-DE-02', 'Germany',   'Munich',      2024,  4700,  480000, 53.0,  48.1351,   11.5820),
  ('Adidas', 'AD-DE-03', 'Germany',   'Hamburg',     2023,  4200,  440000, 52.0,  53.5753,    9.9950);
  -- ... full insert in SQL DATASET file
```

### Coordinate fix

Early versions stacked all factories in a city on the exact same lat/lng. Tableau rendered that as one dot per city, hiding how many facilities were actually there. I applied a small offset per factory_id so dots spread out on the map without distorting the actual geography.

```sql
UPDATE factories SET
    latitude  = latitude  + (factory_id * 0.005),
    longitude = longitude + (factory_id * 0.005);
```

### Analytical queries (used to validate the dashboard)

```sql
-- Output efficiency: which factories produce the most per worker?
SELECT brand, city, workers, monthly_output,
       ROUND(monthly_output::DECIMAL / workers, 1) AS output_per_worker
FROM factories
ORDER BY output_per_worker DESC;

-- YoY workforce change by city
SELECT brand, city,
       MAX(CASE WHEN year = 2023 THEN workers END) AS workers_2023,
       MAX(CASE WHEN year = 2024 THEN workers END) AS workers_2024,
       MAX(CASE WHEN year = 2024 THEN workers END) -
       MAX(CASE WHEN year = 2023 THEN workers END) AS yoy_delta
FROM factories
GROUP BY brand, city
HAVING COUNT(DISTINCT year) = 2
ORDER BY yoy_delta DESC;

-- Cost per million units — which brand is more cost-efficient?
SELECT brand,
       ROUND(SUM(production_cost) / SUM(monthly_output) * 1000000, 2) AS cost_per_million_units
FROM factories
GROUP BY brand;
```

---

## Dashboard — what each chart is doing and why

**Geographic bubble map**

The map is the first thing you see because geography is the whole point. Bubble size encodes workers, colour encodes monthly output. Two dimensions at once, no clicking required. Split into Nike on top and Adidas below so you can compare the same region across both brands without your eyes crossing.

**Monthly output + production cost (combo chart, dual axis)**

The core tension in manufacturing is scale versus cost — does higher output come with lower unit cost, or does it just mean spending more? A dual-axis chart with output as bars and cost as a line on the same timeline shows whether the two move together. If cost rises with output, there's no efficiency gain. If cost flattens while output grows, the factory is scaling well. Faceted by brand so the comparison is direct.

**Cost and output histogram (binned)**

Rather than plotting every factory as an individual dot (which would overlap badly at this scale), I binned the output values into ranges and counted how many factories fall into each bin. This shows the distribution — are Adidas factories clustered tightly around one output range, or spread all over the place? A scatter plot would have hidden that shape entirely.

**Workers and output bar chart**

This one answers whether headcount and production move in lockstep. If the workers line and the output bars track closely, productivity is consistent. If they diverge — workers grow but output doesn't, or output is high relative to headcount — something more interesting is happening: automation, shift patterns, factory age. It's a prompt for the next question, not a final answer.

**Country × brand cross-tab**

Before any chart, you need to know the basic count: how many factories does each brand have in each country? The table gives that anchor. It also immediately surfaces asymmetries that the maps gloss over — Germany has three Adidas factories and zero Nike, USA has two Nike and zero Adidas.

---

## What I found

Vietnam and Indonesia are the backbone of both brands. Five Nike factories and five Adidas factories between the two countries, running the highest output numbers in the whole dataset. Both brands are betting heavily on the same geography, which is worth thinking about from a supply chain risk angle.

Adidas still keeps factories in Germany. Nike has none in Europe. This reflects where each brand comes from — Adidas is a German company that never fully walked away from domestic manufacturing. The German factories are expensive (highest production cost index in the dataset) but they're still there, probably tied to premium product lines and brand storytelling more than volume.

Nike has factories in the US (Portland, Memphis). Adidas has none. Portland is Nike's headquarters, so these are almost certainly innovation or sample facilities — the output numbers (470K units/month) are tiny compared to Vietnamese factories running at 2M+. Not mass production, but not irrelevant either.

China output fell in both brands from 2023 to 2024. Nike Shanghai went from 30,000 workers to 27,000. Adidas Shanghai from 22,000 to 19,000. This is the China+1 strategy playing out in the numbers — both companies quietly scaling back China exposure while growing Vietnam and Indonesia.

Production cost is highest in Germany (55.0 index) and lowest in Southeast Asia (38–47 range). That 30–40% cost gap explains why high-volume production stays in Asia while European facilities focus on something else.

---

## Files

```
NIKE-AND-ADIDAS-FACTORIES-STRATERGY/
├── README.md            this file
├── SQL DATASET          full PostgreSQL script — schema, inserts, analytical queries
└── nike_adidas_150.csv  final clean export from PostgreSQL, loaded into Tableau
```

---

## How to run it yourself

```bash
psql -U postgres
\i 'SQL DATASET'
COPY factories TO '/tmp/nike_adidas_150.csv' DELIMITER ',' CSV HEADER;
```

Then load the CSV into Tableau Public. Set latitude and longitude as geographic roles. The rest follows from the structure.

---

## What I'd add next

The dataset doesn't include compliance or certification data. Nike and Adidas both publish supplier lists with fair labour ratings — joining that in would turn this from a manufacturing analysis into a proper ESG dashboard. I'd also want to split production_cost into labour, materials, and logistics components rather than a single index, and map which factories produce which product category (running vs lifestyle vs performance).

---

Brian Ma (Phu)  
linkedin.com/in/brian-phu-a55353390

*Self-initiated project. Factory data was constructed for analytical purposes based on publicly known information about Nike and Adidas manufacturing locations.*
