 with ssr as
 (select  s_store_id as store_id,
          sum(ss_ext_sales_price) as sales,
          sum(coalesce(sr_return_amt, 0)) as sreturns,
          sum(ss_net_profit - coalesce(sr_net_loss, 0)) as profit
  from store_sales left outer join store_returns on
         (ss_item_sk = sr_item_sk and ss_ticket_number = sr_ticket_number),
     date_dim,
     store,
     item,
     promotion
 where ss_sold_date_sk = d_date_sk
       and ss_sold_date_sk between 2451767 and 2451797
       and d_date between cast('2000-08-10' as timestamp)
                  --and (cast('2000-08-10' as timestamp) +  interval 30 days)
                  and cast(date_add('2000-08-10',30) as timestamp) 
       and ss_store_sk = s_store_sk
       and ss_item_sk = i_item_sk
       and i_current_price > 50
       and ss_promo_sk = p_promo_sk
       and p_channel_tv = 'N'
 group by s_store_id)
 ,
 csr as
 (select  cp_catalog_page_id as catalog_page_id,
          sum(cs_ext_sales_price) as sales,
          sum(coalesce(cr_return_amount, 0)) as sreturns,
          sum(cs_net_profit - coalesce(cr_net_loss, 0)) as profit
  from catalog_sales left outer join catalog_returns on
         (cs_item_sk = cr_item_sk and cs_order_number = cr_order_number),
     date_dim,
     catalog_page,
     item,
     promotion
 where cs_sold_date_sk = d_date_sk
       and cs_sold_date_sk between 2451767 and 2451797
       and d_date between cast('2000-08-10' as timestamp)
                  --and (cast('2000-08-10' as timestamp) + interval  30 days)
		  and cast(date_add('2000-08-10',30) as timestamp)
        and cs_catalog_page_sk = cp_catalog_page_sk
       and cs_item_sk = i_item_sk
       and i_current_price > 50
       and cs_promo_sk = p_promo_sk
       and p_channel_tv = 'N'
group by cp_catalog_page_id)
 ,
 wsr as
 (select  web_site_id,
          sum(ws_ext_sales_price) as sales,
          sum(coalesce(wr_return_amt, 0)) as sreturns,
          sum(ws_net_profit - coalesce(wr_net_loss, 0)) as profit
  from web_sales left outer join web_returns on
         (ws_item_sk = wr_item_sk and ws_order_number = wr_order_number),
     date_dim,
     web_site,
     item,
     promotion
 where ws_sold_date_sk = d_date_sk
       and ws_sold_date_sk between 2451767 and 2451797
       and d_date between cast('2000-08-10' as timestamp)
		  and cast(date_add('2000-08-10',30) as timestamp)
                  --and (cast('2000-08-10' as timestamp) +  interval 30 days)
        and ws_web_site_sk = web_site_sk
       and ws_item_sk = i_item_sk
       and i_current_price > 50
       and ws_promo_sk = p_promo_sk
       and p_channel_tv = 'N'
group by web_site_id)
,
results as
 (select channel
        , id
        , sum(sales) as sales
        , sum(sreturns) as sreturns
        , sum(profit) as profit
 from 
 (select 'store channel' as channel
        , concat('store' , store_id) as id
        , sales
        , sreturns
        , profit
 from   ssr
 union all
 select 'catalog channel' as channel
        , concat('catalog_page' , catalog_page_id) as id
        , sales
        , sreturns
        , profit
 from  csr
 union all
 select 'web channel' as channel
        , concat('web_site' , web_site_id) as id
        , sales
        , sreturns
        , profit
 from   wsr
 ) x
 group by channel, id)
 
 select channel
        , id
        , sales
        , sreturns
        , profit
 from (
   select channel, id, sales, sreturns, profit from  results
   union all
   select channel, NULL AS id, sum(sales) as sales, sum(sreturns) as sreturns, sum(profit) as profit from  results group by channel
   union all
   select NULL AS channel, NULL AS id, sum(sales) as sales, sum(sreturns) as sreturns, sum(profit) as profit from  results
 ) foo
 order by channel, id
 limit 100;

