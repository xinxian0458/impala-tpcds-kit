with ss as (
 select
          i.i_manufact_id,sum(ss_ext_sales_price) total_sales
 from
  store_sales,
  date_dim,
         customer_address,
         item i
 where
         i.i_manufact_id in (select
  i1.i_manufact_id
from
 item i1
where i1.i_category in ('Books'))
 and     ss_item_sk              = i_item_sk
 and     ss_sold_date_sk         = d_date_sk
 and ss_sold_date_sk between 2450874 and 2450904
 and     d_year                  = 1998
 and     d_moy                   = 3
 and     ss_addr_sk              = ca_address_sk
 and     ca_gmt_offset           = -6 
 group by i_manufact_id),
 cs as (
 select
          i2.i_manufact_id,sum(cs_ext_sales_price) total_sales
 from
  catalog_sales,
  date_dim,
         customer_address,
         item i2
 where
         i2.i_manufact_id               in (select
  i_manufact_id
from
 item
where i_category in ('Books'))
 and     cs_item_sk              = i_item_sk
 and     cs_sold_date_sk         = d_date_sk
 and cs_sold_date_sk between 2450874 and 2450904
 and     d_year                  = 1998
 and     d_moy                   = 3
 and     cs_bill_addr_sk         = ca_address_sk
 and     ca_gmt_offset           = -6 
 group by i_manufact_id),
 ws as (
 select
          i3.i_manufact_id,sum(ws_ext_sales_price) total_sales
 from
  web_sales,
  date_dim,
         customer_address,
         item i3
 where
         i3.i_manufact_id               in (select
  i_manufact_id
from
 item
where i_category in ('Books'))
 and     ws_item_sk              = i_item_sk
 and     ws_sold_date_sk         = d_date_sk
 and ws_sold_date_sk between 2450874 and 2450904
 and     d_year                  = 1998
 and     d_moy                   = 3
 and     ws_bill_addr_sk         = ca_address_sk
 and     ca_gmt_offset           = -6
 group by i_manufact_id)
 select  i_manufact_id ,sum(total_sales) total_sales
 from  (select * from ss 
        union all
        select * from cs 
        union all
        select * from ws) tmp1
 group by i_manufact_id
 order by total_sales
 limit 100;