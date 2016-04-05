clear screen

drop dimension TIME_SQL;

create dimension TIME_SQL
 level monthL is (TIME_MONTH.MONTHKEY)
 level quarterL is (TIME_QUARTER.QUARTERKEY)
 level yearL is (TIME_YEAR.CALYEAR)
 hierarchy prim(
  monthL child of 
  quarterL child of 
  yearL
  join key (TIME_MONTH.QUARTERKEY) references quarterL
  join key (TIME_QUARTER.CALYEAR) references yearL
 )
 attribute monthL determines (TIME_MONTH.MONTHNAME, TIME_MONTH.MONTHENDDATE)
 attribute quarterL determines (TIME_QUARTER.QUARTERNAME, TIME_QUARTER.QUARTERENDDATE)
 attribute yearL determines(TIME_YEAR.YEARNAME, TIME_YEAR.YEARENDDATE)
;

drop dimension PRODUCT_SQL;

create dimension PRODUCT_SQL
 level productL is (DIMPRODUCT.PRODUCTKEY)
 level subCatL is (DIMPRODUCTSUBCATEGORY.PRODUCTSUBCATEGORYKEY)
 hierarchy prim(
  productL child of
  subCatL
  join key (DIMPRODUCT.PRODUCTSUBCATEGORYKEY) references subCatL
 )
 attribute productL determines (DIMPRODUCT.ENGLISHPRODUCTNAME)
 attribute subCatL determines (DIMPRODUCTSUBCATEGORY.ENGLISHPRODUCTSUBCATEGORYNAME)
;

drop materialized view SALES_SQL;
create materialized view SALES_SQL build deferred
as
select m.MONTHNAME, p.ENGLISHPRODUCTNAME, SUM(f.SALESAMOUNT)
  from FACTINTERNETSALES f join
       DIMPRODUCT p on f.PRODUCTKEY = p.PRODUCTKEY join
       TIME_MONTH m on f.TIME_MONTH = m.MONTHKEY 
 group by m.MONTHNAME,
          p.ENGLISHPRODUCTNAME
;       

set serveroutput on;
declare
  myCubeMv varchar(32);
begin
  myCubeMv :=
  dbms_cube.create_mview(
    mvOwner => user,
    mvName => 'SALES_SQL',
    sam_parameters=>'logDest=serverout,build=immediate');
end;
/

execute dbms_dimension.describe_dimension('product_sql');
clear screen;
execute dbms_mview.refresh('SALES_SQL');