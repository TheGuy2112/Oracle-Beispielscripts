drop view CustTest;
create view CustTest as
select c.CustomerKey, c.LastName, g.City, g.StateProvinceName, SalesTerritoryRegion, SalesTerritoryCountry , t.salesterritorygroup
  from dimcustomer c join
       dimgeography g on c.geographykey = g.geographykey join
       dimsalesterritory t on g.SalesTerritoryKey = t.SalesTerritoryKey;

select f.ProductKey, 
       t.TIMEKEY,
       t.DAYNUMBEROFMONTH || '.' || t.MONTHNUMBEROFYEAR || '.' || t.CALENDARYEAR "ORDER",
       t2.DAYNUMBEROFMONTH || '.' || t2.MONTHNUMBEROFYEAR || '.' || t2.CALENDARYEAR "ORDER"
  from FACTINTERNETSALES f join
       DIMTIME t on f.orderdatekey = t.TIMEKEY join
       DIMTIME t2 on f.shipdatekey = t2.timekey;

select * from FACTINTERNETSALES;

drop table TIME_YEAR;
create table TIME_YEAR(
  calYear int primary key,
  yearName char(4),
  yearTimespan number(5),
  yearEndDate date
);

drop table TIME_QUARTER;
create table TIME_QUARTER(
  quarterKey varchar(30) primary key,
  calYear int references TIME_YEAR,
  calQuarter int,
  quarterName char(1),
  quarterTimespan number(5),
  quarterEndDate date
);

drop table TIME_MONTH;
create table TIME_MONTH(
  monthKey varchar(30) primary key,
  calYear int,
  calQuarter int,
  calMonth int,
  monthName varchar(30),
  monthTimespan number(5),
  monthEndDate date,
  quarterKey varchar(30) references TIME_QUARTER
);

drop table TIME_DAY;
create table TIME_DAY(
  timeKey int,
  calYear int,
  calQuarter int,
  calMonth int,
  calDay int,
  dayName varchar(30),
  dayTimespan number(5),
  dayEndDate date,
  monthKey varchar(30) references TIME_MONTH
);

select * from DIMTIME;

drop view TIME_YEAR;
create view TIME_YEAR as
select distinct 
       TO_NUMBER(CALENDARYEAR) calYear,
       CALENDARYEAR yearName,
       add_months(trunc(FULLDATEALTERNATEKEY,'YYYY'),12) -trunc(FULLDATEALTERNATEKEY,'YYYY') yearTimespan,
       TO_DATE(CALENDARYEAR || '-12-31', 'yyyy-mm-dd') yearEndDate
  from DIMTIME
 order by calYear asc;

drop view TIME_QUARTER;
create view TIME_QUARTER as 
select distinct
       TO_NUMBER(CALENDARYEAR) calYear,
       CALENDARQUARTER calQuarter,
       TO_CHAR(CALENDARQUARTER) quarterName,
       to_date(CALENDARYEAR || '-' || case CALENDARQUARTER
                                        when 1 then '03-31'
                                        when 2 then '06-30'
                                        when 3 then '09-30'
                                        when 4 then '12-31'
                                      end,
                                       'yyyy-mm-dd') - 
        to_date(CALENDARYEAR || '-' || case CALENDARQUARTER
                                        when 1 then '01-01'
                                        when 2 then '04-01'
                                        when 3 then '07-01'
                                        when 4 then '10-01'
                                      end,
                                      'yyyy-mm-dd') +1 quarterTimespan,
        to_date(CALENDARYEAR || '-' || case CALENDARQUARTER
                                        when 1 then '03-31'
                                        when 2 then '06-30'
                                        when 3 then '09-30'
                                        when 4 then '12-31'
                                      end,
                                       'yyyy-mm-dd') quarterEndDate,
        TO_NUMBER(CALENDARYEAR) par,
        CALENDARYEAR || '-' || CALENDARQUARTER QuarterKey
  from DIMTIME
 order by calYear, calQuarter asc;
 
 drop view TIME_MONTH;
 create view TIME_MONTH as 
 select distinct
        TO_NUMBER(CALENDARYEAR) calYear,
        CALENDARQUARTER calQuarter,
        MONTHNUMBEROFYEAR calMonth,
        ENGLISHMONTHNAME monthName,
        LAST_DAY(FULLDATEALTERNATEKEY) - to_date(CALENDARYEAR || '-' || MONTHNUMBEROFYEAR || '-01','yyyy-mm-dd') +1 monthTimespan,
        LAST_DAY(FULLDATEALTERNATEKEY) monthEndDate,
        CALENDARYEAR || '-' || CALENDARQUARTER par,
        CALENDARYEAR || '-' || CALENDARQUARTER || '-' || MONTHNUMBEROFYEAR MonthKey
   from DIMTIME
 order by calYear, calQuarter, calMonth asc;
 
 select * from TIME_DAY;
 
 drop view TIME_DAY;
 create view TIME_DAY as 
 select distinct
        TIMEKEY,
        TO_NUMBER(CALENDARYEAR) calYear,
        CALENDARQUARTER calQuarter,
        MONTHNUMBEROFYEAR calMonth,
        DAYNUMBEROFMONTH calDay,
        1 "dayTimespan",
        FULLDATEALTERNATEKEY dayEndDate,
        CALENDARYEAR || '-' || CALENDARQUARTER || '-' || MONTHNUMBEROFYEAR par
   from DIMTIME
 order by calYear, calQuarter, calMonth asc;
 
 insert into TIME_YEAR
 select distinct 
       TO_NUMBER(CALENDARYEAR) calYear,
       CALENDARYEAR yearName,
       add_months(trunc(FULLDATEALTERNATEKEY,'YYYY'),12) -trunc(FULLDATEALTERNATEKEY,'YYYY') yearTimespan,
       TO_DATE(CALENDARYEAR || '-12-31', 'yyyy-mm-dd') yearEndDate
  from DIMTIME
 order by calYear asc;
 
 select * from TIME_YEAR;
 
 desc TIME_QUARTER;
 insert into TIME_QUARTER
 select distinct
       CALENDARYEAR || '-' || CALENDARQUARTER QuarterKey,
       TO_NUMBER(CALENDARYEAR) calYear,
       CALENDARQUARTER calQuarter,
       TO_CHAR(CALENDARQUARTER) quarterName,
       to_date(CALENDARYEAR || '-' || case CALENDARQUARTER
                                        when 1 then '03-31'
                                        when 2 then '06-30'
                                        when 3 then '09-30'
                                        when 4 then '12-31'
                                      end,
                                       'yyyy-mm-dd') - 
        to_date(CALENDARYEAR || '-' || case CALENDARQUARTER
                                        when 1 then '01-01'
                                        when 2 then '04-01'
                                        when 3 then '07-01'
                                        when 4 then '10-01'
                                      end,
                                      'yyyy-mm-dd') +1 quarterTimespan,
        to_date(CALENDARYEAR || '-' || case CALENDARQUARTER
                                        when 1 then '03-31'
                                        when 2 then '06-30'
                                        when 3 then '09-30'
                                        when 4 then '12-31'
                                      end,
                                       'yyyy-mm-dd') quarterEndDate
  from DIMTIME;
  
  desc TIME_MONTH;
  
  insert into TIME_MONTH
  select distinct
        CALENDARYEAR || '-' || CALENDARQUARTER || '-' || MONTHNUMBEROFYEAR MonthKey,
        TO_NUMBER(CALENDARYEAR) calYear,
        CALENDARQUARTER calQuarter,
        MONTHNUMBEROFYEAR calMonth,
        ENGLISHMONTHNAME monthName,
        LAST_DAY(FULLDATEALTERNATEKEY) - to_date(CALENDARYEAR || '-' || MONTHNUMBEROFYEAR || '-01','yyyy-mm-dd') +1 monthTimespan,
        LAST_DAY(FULLDATEALTERNATEKEY) monthEndDate,
        CALENDARYEAR || '-' || CALENDARQUARTER QuarterKey
   from DIMTIME;
   
   delete TIME_DAY;
   desc TIME_DAY;
   insert into TIME_DAY
   select distinct
        TIMEKEY,
        TO_NUMBER(CALENDARYEAR) calYear,
        CALENDARQUARTER calQuarter,
        MONTHNUMBEROFYEAR calMonth,
        DAYNUMBEROFMONTH calDay,
        CALENDARYEAR || '-' || CALENDARQUARTER || '-' || DAYNUMBEROFMONTH dayName,
        1 "dayTimespan",
        FULLDATEALTERNATEKEY dayEndDate,
        CALENDARYEAR || '-' || CALENDARQUARTER || '-' || MONTHNUMBEROFYEAR monthKey
   from DIMTIME;
   
   
 select * from TIME_DAY;
 
 select * from FACTINTERNETSALES;
 
ALTER TABLE FACTINTERNETSALES
  ADD TIME_MONTH varchar(30);
 
update FACTINTERNETSALES f set TIME_MONTH = (select CALENDARYEAR || '-' || CALENDARQUARTER || '-' || MONTHNUMBEROFYEAR from DIMTIME d where f.DUEDATEKEY = d.TimeKey);
commit;
select * from FACTINTERNETSALES;

alter table DIMTIME
  ADD MONTH_ID varchar(30);

update DIMTIME f set MONTH_ID = (select EnglishMonthName || '-' || CalendarYear from DIMTIME d where f.TimeKey = d.TimeKey);

select * from DIMTIME;

commit;

select * from FACTINTERNETSALES;