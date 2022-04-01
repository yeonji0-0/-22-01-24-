use eda_cart;

######## order table ####################################################
select * from orders;
# 잠시) eval_set컬럼에 있는 종류와 각 종류가 몇 건인지 쿼리문 작성 
select distinct eval_set from orders;
select eval_set , count(*) from orders group by eval_set;

######## order_products__prior ###########################################
select * from order_products__prior;

######## products table ##################################################
select * from products;
select * from products where product_id = 40174;

######## departments table ###############################################
select * from departments;
select * from departmemts where department_id = 16;

######## 세부 상품군 ########################################################
select * from aisles;
select * from aisles where aisle_id = 84;

# Q) 전체 주문 건수
select count(order_number) as `전체 주문 건수` from orders;
select count(*) as CNT, count(distinct order_id) as `dist_orderid` from orders;
# Q) 구매자 수 
select count(*) as CNT, count(distinct user_id) as `dist_userid` from orders; 
# Q) 상품별 주문 건수
# -> 메인 : order_product_prior / 참조 : products
select P.product_name , count(O.order_id) as CNT from order_products__prior O 
				left join  products P on O.product_id = P.product_id
                group by P.product_name;
select P.product_name , count(distinct O.order_id) as CNT from order_products__prior O 
				left join  products P on O.product_id = P.product_id
                group by P.product_name
                order by CNT desc;

# Q) 카트에 가장 먼저 넣는 상품 10개
# order_product_prior에서 상품 id 1번 담긴 횟수
select * from order_products__prior where add_to_cart_order = 1 limit 10; -- ME
select product_id, sum(case when add_to_cart_order = 1 then 1 else 0 end ) as F_1st from order_products__prior 
		group by product_id
        order by F_1st desc limit 10;
create temporary table proranktbl as
select product_id, sum(case when add_to_cart_order = 1 then 1 else 0 end ) as F_1st from order_products__prior 
		group by product_id
        order by F_1st desc limit 10;
select * from proranktbl;
select PR.product_id, P.product_name, PR.F_1st from proranktbl PR left join products P on PR.product_id = P.priduct_id
		order by PR.F_1st desc;
# Q) 시간대별 주문 건수
select order_hour_of_day,order_number from orders group by order_hour_of_day order by order_hour_of_day; -- ME
select order_hour_of_day,count(distinct order_id) from orders group by order_hour_of_day order by order_hour_of_day; 
# Q) 첫 구매 후 다음 구매까지 걸린 평균 일수
# -> 두번째 구매자의 주문 간격
select avg(days_since_prior_order) from orders where order_number = 2; 
# Q) 주문 건당 평균 구매 상품의 수 UPT : Unit Per Transacion
# -> 2개의 정보 : 상품구매 id -> 그때 몇 개의 상품을 사는지 (order_products__prior에서 확인) 
# --> order_id에 몇 개의 평균적으로 product_id가 있는가 (number of product_id / number of * 유니크한 * order_id
select count(product_id)/count( distinct order_id) UPT from order_product_prior;
# Q) 인당 평균 주문 건수
# -> 고객 1명이 몇 건의 주문을 하는지 ( 주문 건수 / 회원의 수)
select count(distinct user_id)/count(distinct user_id) as AVG_F from orders;
# Q) 재구매율이 가장 높은 상품 10개 (한 번보다 step으로 진행)
select product_id, count(*) from order_products__prior where reordered = 1 group by product_id order by count(*) desc limit 10; -- ME
select product_id, sum(case when reordered = 1 then 1 else 0 end) /count(*) as RET_RATIO from order_products__prior group by 1 order by 2 desc; -- 숫자는 몇 번째 컬럼인지
# -> 상위 랭킹을 부여해서 위의 테이블을 기반으로
select * from (select *, row_number() over(order by RET_RATIO desc) RNK 
		from (select product_id, sum(case when reordered = 1 then 1 else 0 end) /count(*) as RET_RATIO from order_products__prior group by 1) A 
			   ) A 
               where RNK between  1 and 10;
#재구매율이 높은 상품의 id, 이름(-> products), 재구매율, 주문건수(-> order_products__prior)
#-> 위의 문제와 다른 부분은 2개의 테이블에서 정보를 합쳐야 함
select * from order_products__prior A left join products B on A.product_id = B.product_id;
select A.product_id, B.product_name, sum(A.reordered)/sum(1) as Reorder_Rate, count(distinct order_id) as F
		from order_products__prior A left join products B on A.product_id = B.product_id
        group by A.product_id, B.product_name;
#주문 건수가 10개 이상이 경우 제한 조건 select A.product_id, B.product_name, sum(A.reordered)/sum(1) as Reorder_Rate, count(distinct order_id) as F
select A.product_id, B.product_name, sum(A.reordered)/sum(1) as Reorder_Rate, count(distinct order_id) as F
		from order_products__prior A left join products B on A.product_id = B.product_id
        group by A.product_id, B.product_name
        having count(distinct order_id) > 10
        order by Reorder_Rate desc;
