-- The company lacked a structured data model to understand:

-- Which films and categories drive the most revenue?
-- Which films have high demand but weak monetization / inefficient inventory?
-- What pricing and inventory actions could improve revenue?
-- The goal was to develop a data-driven strategy to improve revenue and operational efficiency.

- Revenue Mart
- to see 
  - 1. which film/ categories is revenue drivers
  - 2. which titles should be focused on
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

--------------------------------------------------------
- Demand Monetization Mart
- to see
  - 1. Which films have high demand but low return
  - 2. Which films may have price inefficiency
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
---------------------------------------------------------- 
- Inventory Efficiency Mart
- to see
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
- ROI Efficiency Mart 
  - to see
    - Which film have the highest investment efficiency
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
