use sqldb;
select * from usertbl;

#고객 중에서 키가 180~183 사이의 사람들을 찾고 싶다. 이름, 키를 보자
select name, height from usertbl where height between 180 and 183;
select name, height from usertbl where (height >= 180) and (height <= 183);

#in () 사용 예쩨
#지역이 "경남" 또는 "전남"인 고객들의 이름과 지역을 보자
select name, addr from usertbl where addr = "경남" or addr = "전남";
select name, addr from usertbl where addr in ( "경남" ,"전남");
#지역이 경기,서울,뉴욕인 고객들의 이름과 지역을 보자
select name, addr from usertbl where addr in ("서울","경기","뉴욕");

#문자열 검색
# 1)조로 시작하는 이름을 가진 고객들의 이름과 지역을 출력 : % -> 글자수 제한은 없음
select name, addr from usertbl where name like "조%";
# 2)1글자 명시할 때 : _
select name, addr from usertbl where name like "_종신";
# 3)이름중에 이름 두번째가 용의글자를 사용하는 고객은?
#   -> (~)용(~~~~) : _용%
select name, addr from usertbl where name like "_용%";
#충남, 충청조, 충청남도, 충북, 충청북도 : 충%
#서울시 _구 : 서울시 _ 구

####### 서브 쿼리 #################################################
select name, height from usertbl where height > 177;
#고객 중 김경호의 키보다 큰 고객들은 누구?
# --> A고객 보다 실적이 더 큰 고객은 누구?
select height from usertbl where name = "김경호"; -- 177인 것을 보고 
select height from usertbl where height > 177; 
select name, height from usertbl where height > (select height from usertbl where name = "김경호");

#키가 177이상인 사람의 이름과 키
select name, height from usertbl where height >= 177;
#이승기보다 키가 큰 사람의 이름과 키
select name, height from usertbl where height > (select height from usertbl where name = "이승기");
#지역이 경남인 사람의 키보다 큰 사람의 이름과 키를 찾아보세요
select name, height from usertbl where addr = "경남";  -- 170, 173
select name, height from usertbl where height > (select min(height) from usertbl where addr = "경남"); -- 지역이 경남인 사람중 가작 작은 사람보다 큰 사람
#좀 더 구체화) 지역의 경남인 사람들의 키가 여러값일 것인데 그 중에서 가장 큰 사람보다 큰 사람을 찾고 싶다
select name, height from usertbl where height > all(select height from usertbl where addr = "경남");
#좀 더 구체화) 지역의 경남인 사람들의 제일 작은 사람보다 큰 사람을 찾고 싶다
select name, height from usertbl where height > any(select height from usertbl where addr = "경남");
#부등 아니라 등호 : 키가 170, 173인 사람들을 찾아주세요
select name, height from usertbl where height = any (select height from usertbl where addr = "경남");
#in하고 동일
select name, height from usertbl where height in (170, 173);
select name, height from usertbl where height in (select height from usertbl where addr = "경남");

######## order by #######################################################
# 1)고객들에서 가입한 날짜별로 고객의 이름과 가입날짜를 보고싶다 (최신을 앞에 올드를 뒤에)
select name, mDate from usertbl order by mDate; -- 초기 가입 순
select name, mDate from usertbl order by mDate desc; -- 최신 가입 수
# 2)고객들의 이름과 키의 정보들을 보고 싶은데, 키는 큰 사람을 먼저, 혹시 키가 같다면 이름은 사전순서대로 보고자 함
select name, height from usertbl order by height desc, name asc;
# 3)키는 순서대로 정렬을 해서 보는데, 볼 것은 userID만 보고자 한다 -> 정렬기준을 꼭 봐야할 컬럼을 해야하는 것은 아님!
select userID from usertbl order by height;

######## distinct ########################################################
# 1)전체 지역이 몇 종류가 있는지 파악하기
select addr from usertbl;
select addr from usertbl order by addr; -- 데이터의 수는 # usertbl = # 쿼리
select distinct addr from usertbl; -- unique한 값들만 보여줘 -> 가로줄의 수가 줄어듬
select distinct addr from usertbl order by addr;

######## limit N : N개만 보여줘 ##############################################
# --> order by와 같이 사용해서 top10, top5 이런 랭킹같은 것도 사용 가능
# 예)employees DB로 변환
use employees;
# 1)emmployees 테이블에서 emp_no, hire_date의 값들을 hire_date를 기준으로 보자
# 일단 제일 먼저 입사한 사람을 맨 앞에 보려고 한다
select emp_no, hire_date from employees order by hire_date;
# 2)우리회사 제일먼저 입사한 사람 top5는 누구?
select emp_no, hire_date from employees order by hire_date limit 5;
# 3)우리회사 최근에 입사한 신입 5명은 누구?
select emp_no, hire_date from employees order by hire_date desc limit 5;

######## create table + sub query ##########################################
#sqldb로 다시 가서
use sqldb;
# 1)buytbl의 값을 buytbl2에 복사
select * from buytbl;
create table buytbl2 (select * from buytbl);
select * from buytbl2;

# 2) buytbl에서 고객 아이디와 상품명만 추려서 백업을 buytbl3에 하기
create table buytbl3 (select userID, prodName from buytbl);
select * from buytbl3;

######### group by ###########################################################
#구매 테이블에서 어느 회원이 도대체 몇 건이나 주문 하였나?
# -> 회원ID, 총 구매 건수
select * from buytbl;
select userID, sum(amount) from buytbl group by userID;
#잠시) 컬럼 이름 변경 : as
select userID, sum(amount) as "총구매건수" from buytbl group by userID;
#참고) 계산 함수가 꼭 group by에만 가능? -> NO
# 전체 구매자가 구매한 물품 amount의 평균 얼마? -> 소비자가 우리 회사의 물건을 살 때 주로 몇 개 사는지
select amount from buytbl; 
select avg(amount) from buytbl;
select avg(amount) as "평균 구매 건수" from buytbl;
# 1)회원ID하고 그 사람이 구매할 때 구매한 구매 건수를 보여주세요 (전체 구매 데이터)
select userID, amount from buytbl;
# 2)회원ID별로 구매한 물품의 총 개수를 보고자 함 : group by 
#   -> 단, 회원ID로 정렬해서 a~z순으로 : order by
select userID, sum(amount) from buytbl group by userID order by userID;
#컬럼 이름을 사용자아이디, 총구매건수로 컬럼이름을 변경해서 결과 보기 
select userID as "사용자아이디" , sum(amount) as "총구매건수" from buytbl group by userID order by userID;
#회원ID 별로  총 소비금액을 보고자 한다 -> 여러 컬럼을 동시에 활용해서 계산하자
select userID as "사용자아이디" , sum(amount*price) as "총구매금액" from buytbl group by userID order by userID;
# 3)사용자별로 한 번 구매할 때 평균적으로 몇 개의 물건을 구매했는지
select userID, avg(amount) as "평균 구매 건수" from buytbl group by userID order by userID;
select userID, avg(amount) as "평균 구매 건수" from buytbl group by userID order by avg(amount);
# 3-1)한 번 사갈 때 제일 많이 구매하는 회원 top3는 누구? : 3명 감사 쿠폰
select userID, avg(amount) as "평균 구매 건수" from buytbl group by userID order by avg(amount) desc limit 3;
# 4-1)회원 정보를 보고, 가장 키가 큰 회원의 이름과 키를 출력하기
select name, max(height) from usertbl; -- 에러는 안나지만 우리가 원하는 값이 아니기 때문에 서브 쿼리 이용
select name, height from usertbl where height = (select max(height) from usertbl);
# 4-2)회원 정보를 보고, 가장 키가 큰 회원의 이름과 키, 가장 키가 작은 회원의 이름과 키 출력
select name, height from usertbl where height = (select max(height) from usertbl) or height = (select min(height) from usertbl)
										order by height desc;
# 5)휴대폰 정보가 있는 사용자의 수는 몇 명인가요?
#   ->count할 때 null은 빠져서 계산이 된다
select count(mobile1) from usertbl;
# 6)usertbl의 회원 수는 몇 명?
#   -> 가장 기본이 되는 쿼리문 
select count(*) from usertbl;

########## having : 집계함수에 조건을 걸 때#####################################
# 참고) 일반적인 조건 : where
# 1)사용자별로 총 구매액
select userID, sum(price*amount) from buytbl group by userID;
select userID, sum(price*amount) from buytbl group by userID where sum(price*amount) > 1000; -- 오류남
select userID, sum(price*amount) from buytbl  where sum(price*amount) > 1000 group by userID; -- 오류남
select userID, sum(price*amount) from buytbl group by userID having sum(price*amount) > 1000; -- having으로 바꿔주면 됨
select userID, sum(price*amount) from buytbl group by userID having sum(price*amount) > 1000 order by sum(price*amount); 
select userID, sum(price*amount) from buytbl  having sum(price*amount) > 1000 group by userID order by sum(price*amount); -- 순서 주의 (having절은 group by다음에 나와야 함!!)

########## rollup : 총합 또는 중간 합계 ########################################
# 상황) groupName별로  매출의 총계를 내면서 전체 총계까지 할 때
select num, groupName, sum(price*amount) as "비용" from buytbl group by groupName, num with rollup;
select groupName, sum(price*amount) as "비용" from buytbl group by groupName with rollup;

########### insert ##########################################################
# 1)정의된 컬럼 순서대로 값들이 다 있을 때
create table testtbl (id int, userNAme char(3), age int);
insert into testtbl values(1, "홍길동", 25);
select * from testtbl;

# 2)특정한 컬럼과 그에 해당하는 값만 지정해서 
insert into testtbl (id, userName) values (2, "설현");
select * from testtbl;
#전체 컬럼을 의미하면서, 그에 맞지 않은 값을 제정하면 -> 에러
insert into testtbl values (3, "설현"); -> 개수가 맞지 않음
insert into testtbl  values ("하나", 26, 3); -> 개수 맞아도 순서가 다르면 int자리에 문자 쓰면 안 들어감

# 3)입력하는 값의 컬럼 순서를 변경하면?
insert into testtbl (userName, age, id) values ("하나", 26, 3);
select * from testtbl;



