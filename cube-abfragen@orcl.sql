select * from SALES_CUBE2_VIEW;

select * from DIM_CUSOTMER_PRIMARY_VIEW;
select * from DIM_PRODUCT_PRIMARY_VIEW;
select distinct LEVEL_NAME from DIM_TIME_TIME_VIEW;

select p.category_long_descriptio product_category,
       c.salesgroup_long_descript customer_salesgroup,
       t.quarter year_quarter,
       sales_amount,
       total_product_cost,
       profit
  from sales_cube2_view s join
       dim_product_primary_view p on s.dim_product = p.dim_key join
       dim_cusotmer_view c on s.dim_cusotmer = c.dim_key join
       dim_time_time_view t on s.dim_time = t.dim_key
 where p.level_name = 'CATEGORY' and
       c.level_name = 'SALESGROUP' and
       t.level_name = 'QUARTER' and
       t.year = 'YEAR_2003'
;