<img width="952" height="752" alt="image" src="https://github.com/user-attachments/assets/8b9a4cf6-57e6-41d2-9fc8-d27baed40a3e" />
https://public.tableau.com/app/profile/brian.ma5935/viz/BrianNikeAdidas/Dashboard1
# Nike vs Adidas – Factory Footprint

I built this project to compare where Nike and Adidas put their factories around the world.

I made the data myself, cleaned it with PostgreSQL, and built a dashboard in Tableau Public.

---

## What this shows

Two maps side by side. One for Nike, one for Adidas.

Hover over any dot and you see:
- factory code
- city and country
- number of workers
- monthly output
- production cost

Bigger dot = more workers.
Darker color = higher output.

---

## Tools

- PostgreSQL 18 on Mac M4
- Tableau Public
- psql in terminal

---

## Data

42 factories across 11 countries.

Countries included:
Vietnam, Indonesia, China, Thailand, USA, Germany, Japan, South Korea, India, Brazil, Mexico.

Each row has:
- brand (Nike or Adidas)
- factory code
- city, country
- year (2023 or 2024)
- workers
- monthly output
- production cost (million USD)
- latitude and longitude

---

## How I built it

### 1. PostgreSQL

Created a database and a table called `factories`.

Inserted 42 rows manually. Each row has real city names and real coordinates.

I ran into a problem: all factories showed up as one dot on the map because every row had the same coordinates. Fixed it by updating each city with its own lat/long.

### 2. Export to CSV

```sql
COPY factories TO '/tmp/nike_adidas_150.csv' DELIMITER ',' CSV HEADER;
