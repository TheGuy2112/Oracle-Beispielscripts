select * from sales_sql_c1_view;
select * from time_sql_d2_prim_view;
select * from product_sql_d1_view;

select p.englishproductname, t.quartername, t.monthname , s.SUM_SALESAMOUNT
  from product_sql_d1_view p join
       sales_sql_c1_view s on s.product_sql_d1 = p.dim_key join
       time_sql_d2_view t on s.TIME_SQL_D2 = t.DIM_KEY
 where p.englishproductsubcategor = 'Helmets'
   and t.yearname = 2003
;