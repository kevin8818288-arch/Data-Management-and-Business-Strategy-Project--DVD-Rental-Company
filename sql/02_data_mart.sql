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
      rental_count / NULLIF(inventory_count, 0) AS rentals_per_inventory,
      DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
      CASE
          WHEN rental_count / NULLIF(inventory_count, 0) >= 4 THEN 'Demand-Driven'
          WHEN inventory_count >= 7 AND rental_count / NULLIF(inventory_count, 0) < 3 THEN 'Supply-Supported'
          ELSE 'Balanced'
      END AS revenue_driver_type
  FROM movie_performance_dw;

-- ------------------------------------------------------
-- Demand Monetization Mart
-- Purpose:
  -- 1. Compare demand (rental volume) with revenue contribution
  -- 2. Identify films with high demand but low monetization efficiency
  -- 3. Detect potential pricing inefficiencies

  CREATE VIEW demand_monetization_mart AS
  WITH ranked AS (
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
      FROM movie_performance_dw
  )
  SELECT
      film_id,
      title,
      category,
      rental_rate,
      rental_count,
      total_revenue,
      revenue_per_rental,
      demand_rank,
      revenue_rank,
      CAST(revenue_rank AS SIGNED) - CAST(demand_rank AS SIGNED) AS monetization_gap,
      CASE
          WHEN demand_rank <= 10 AND revenue_rank > demand_rank
              THEN 'High Demand / Low Revenue'
          ELSE 'Other'
      END AS monetization_flag,
      CASE
          WHEN rental_count >= 30 THEN 'Very High Demand'
          WHEN rental_count >= 20 THEN 'High Demand'
          WHEN rental_count >= 10 THEN 'Moderate Demand'
          ELSE 'Low Demand'
      END AS demand_band,
      CASE
          WHEN revenue_per_rental >= 4 THEN 'High Monetization'
          WHEN revenue_per_rental >= 3 THEN 'Medium Monetization'
          ELSE 'Low Monetization'
      END AS monetization_band
  FROM ranked;
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
      rental_count / NULLIF(inventory_count, 0) AS rentals_per_inventory,
      total_revenue / NULLIF(inventory_count, 0) AS revenue_per_inventory,
      CASE
          WHEN inventory_count <= 3 AND rental_count > 20 THEN 'Understocked'
          WHEN inventory_count >= 6 AND rental_count / NULLIF(inventory_count, 0) < 3 THEN 'Overstocked'
          ELSE 'Balanced'
      END AS inventory_flag,
      CASE
          WHEN rental_count / NULLIF(inventory_count, 0) >= 5 THEN 'High Utilization'
          WHEN rental_count / NULLIF(inventory_count, 0) >= 3 THEN 'Medium Utilization'
          ELSE 'Low Utilization'
      END AS utilization_band,
      CASE
          WHEN total_revenue / NULLIF(inventory_count, 0) >= 25 THEN 'High Productivity'
          WHEN total_revenue / NULLIF(inventory_count, 0) >= 15 THEN 'Medium Productivity'
          ELSE 'Low Productivity'
      END AS inventory_productivity_band
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
      total_revenue / NULLIF((replacement_cost * inventory_count), 0) AS roi_proxy,
      CASE
          WHEN total_revenue / NULLIF((replacement_cost * inventory_count), 0) >= 2 THEN 'High ROI'
          WHEN total_revenue / NULLIF((replacement_cost * inventory_count), 0) >= 1 THEN 'Medium ROI'
          ELSE 'Low ROI'
      END AS roi_band,
      CASE
          WHEN total_revenue / NULLIF((replacement_cost * inventory_count), 0) < 1 THEN 'Low Capital Efficiency'
          ELSE 'Efficient'
      END AS capital_flag
  FROM movie_performance_dw;
