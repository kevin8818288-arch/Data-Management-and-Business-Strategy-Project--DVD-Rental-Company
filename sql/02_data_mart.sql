-- Revenue Mart
-- Purpose:
  -- 1. Identify top revenue-generating films and categories
  -- 2. Evaluate revenue concentration and key business drivers
CREATE VIEW revenue_mart AS
SELECT
    film_id,
    title,
    category,
    total_revenue,
    rental_count,
    inventory_count,
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM movie_performance_dw;

-- ------------------------------------------------------
-- Demand Monetization Mart
-- Purpose:
  -- 1. Compare demand (rental volume) with revenue contribution
  -- 2. Identify films with high demand but low monetization efficiency
  -- 3. Detect potential pricing inefficiencies

CREATE VIEW demand_monetization_mart AS
SELECT
    film_id,
    title,
    category,
    rental_rate,
    rental_count,
    total_revenue,
    revenue_per_rental,
    DENSE_RANK() OVER (ORDER BY rental_count DESC) AS demand_rank,
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM movie_performance_dw;
-- -------------------------------------------------------- 
-- Inventory Efficiency Mart
-- Purpose:
  - 1. Which films have bad inventory allocation efficiency
  - 2. Which films do not have sufficient inventory to meet the demand
  - 3. Which films are oversupply
CREATE VIEW inventory_efficiency_mart AS
SELECT
    film_id,
    title,
    category,
    inventory_count,
    rental_count,
    total_revenue,
    rentals_per_inventory,
    revenue_per_inventory
FROM movie_performance_dw;
-------------------------------------------------------------
-- ROI Efficiency Mart 
  -- Purpose: 
    -- 1. Estimate capital efficiency using replacement cost as a proxy
    -- 2. Identify films with high or low return relative to inventory investment

CREATE VIEW roi_efficiency_mart AS
SELECT
    film_id,
    title,
    category,
    total_revenue,
    inventory_count,
    replacement_cost,
    (replacement_cost * inventory_count) AS total_cost_proxy,
    total_revenue / NULLIF((replacement_cost * inventory_count), 0) AS roi_proxy
FROM movie_performance_dw;
