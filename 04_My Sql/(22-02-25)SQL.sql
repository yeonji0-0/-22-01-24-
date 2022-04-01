######## insert auto increment 관련 ##################
use sqldb;
create table testtbl2 (
	id int auto_increment primary key,
    userName char(3),
    age int
    );
insert into testtbl2 values ( null, "지민", 25);
insert into testtbl2 values ( null, "유나", 22);
insert into testtbl2 values ( null, "유경", 21);
select * from testtbl2;

#alter : sql에서 변경에 대한 것을 지정할 때 사용
alter table testtbl2 auto_increment = 100;
insert into testtbl2 values (null, "찬미", 23);
select * from testtbl2;

######## auto_increment : 1에서 시작을 기본 -> 변경 alter 이용해서... alter
# -> 항상 +1만 할꺼냐 간격!
create table testtbl3 (
	id int auto_increment primary key,
    userName char(3),
    age int
    );

#alter : sql에서 변경에 대한 것을 지정할 때 사용
alter table testtbl3 auto_increment = 100;
set @@auto_increment_increment = 3;
insert into testtbl3 values ( null, "나연", 20);
insert into testtbl3 values ( null, "정연", 18);
insert into testtbl3 values ( null, "모모", 19);
select * from testtbl3;

#데이터를 밀어 넣을 때, 밀어 넣을 데이터만 쓴다
insert into testtbl3 values ( null, "나연", 20),( null, "정연", 18),( null, "모모", 19);
select * from testtbl3;

#insert table + select 서브 쿼리 조합
#testtbl4 테이블  id 컬럼은 int Fname varchar(50), Lname varchar (50) 만들기
create table testtbl4 ( 
	id int,
    Fname varchar(50),
    Lname varchar(50)
    );
select * from testtbl4;
# 기존에 employeesDB에 있는 employees Table에서 사번(emp_no), first_name, last_name을 가지고 와서 testtbl4에 밀어넣고 싶다
insert into testtbl4 select emp_no, first_name, last_name from employees.employees;
select * from testtbl4;

create table testtbl5 select emp_no, first_name, last_name from employees.employees;
select * from testtbl5; -- 테이블 껍데기 없이 바로 밀어 넣어서 employees 그대로 들어와서 컬럼이름도 그대로 둘어옴

######## update #####################################################
#기존 데이터의 값을 변경할 때 사용
#update는 늘 주의해서 사용!
select * from testtbl4; -- 사번, 이름을 저장 employees에서
#에러가 없는 것만 보는게 아니라  밑에 메시지에서 구체적으로 몇 개가 변경이 되었는지 확인!
update testtbl4 set Lname = "없음" where Fname = "Kimchi"; -- 실제 데이터가 없는 경우 요청시 (0개 changed)
#실제 데이터가 있을 때 요청
update testtbl4 set Lname = "없음" where Fname = "kyoichi"; -- 실제 Fname이 있는 경우 요청시

#기존 데이터를 지울려고 한다 (단위 : 데이터)
# -> 줄(가로)단위로 날라가게 된다
#주의사항) where 안 쓰면 싹 날라감
#참고) 지울 대상이 테이블일 때... drop(완전히 흔적없이), truncate(데이터만 날리고, 테이블 구조는 그대로)
#대상 : 데이터
#testtbl4에서 Fname이 Aamer인 사들을 지우자~ 
delete from testtbl4 where Fname = "Aamer";
delete from testtbl4 where Fname = "Aamer" limit 5;
#대상 : 테이블
create table bigtbl1 (select * from employees.employees);
create table bigtbl2 (select * from employees.employees);
create table bigtbl3 (select * from employees.employees);
#테이블을 날리자
delete from bigtbl1; -- delete는 데이터 기반으로 데이터만 사라짐 tbl은 유지
drop table bigtbl2; -- drop DB, tbl 다 사라짐
truncate table bigtbl3; -- 데이터만 날리고, 그대로...

########## 데이터 밀어 넣을 때 중복이 발생해서 에러가 날 때 ###########################
create table membertbl (
	select userID, name, addr from usertbl limit 3);
select * from membertbl;
alter table membertbl add constraint pk_membertbl primary key (userID);
select * from membertbl;
#아래 3개의 insert를 한 번에 실행 할 때
insert into membertbl values ("BBK", "비비코", "미국"); -- 기존 userID와 중첩
insert into membertbl values ("SJK", "서장훈", "서울");
insert into membertbl values ("HYK", "현주협", "경기");
select * from membertbl; -- 위에 BBK에서 이미 에러가 발생해서 뒤에 2개는 안됨

# -> 에러가 발생하면 그 아래 쿼리가 다 실행 안되니 중간에 에러가 나면 에러가 나는 얘는 빼고 남은 애들은 실행하려면
# --> 중간에 안 되는 얘는 경고문으로 알려줌
insert ignore membertbl values ("BBK", "비비코", "미국"); -- 기존 userID와 중첩
insert ignore membertbl values ("SJK", "서장훈", "서울");
insert ignore membertbl values ("HYK", "현주협", "경기");
select * from membertbl;

#앞에서 일단 되는 애들은 실행하고 처리를 하고, 안 되는 것들은 메시지로 처리
#들어갈 때 중복되면 수정되어ㅣ서 들어가도록 설정
#쿼리문 자체에서 문제발생시 대처 요렁을 알려주고 실행
insert into membertbl values ("BBK", "비비코","미국") on duplicate key update name = "비비코", addr = "미국";
 -- 위의 케이스는 기존 정보에서 업데이트를 하게 됨
 select * from membertbl;
 
 #중복될 경우가 없다면
 insert into membertbl values ("DJM", "동짜몽","일본") on duplicate key update name = "동짜몽", addr = "일본";
 select * from membertbl;

########## with :간단히 개념적으로 생각하면 중간에 만드는 임시 테이블 ###################
# why? 쿼리문이 생각보다 복잡한 경우가 많아서 단순화 시키면서 보고 하기 위해
# 실행이 끝나면 사라짐 table처럼 저장되는 것은 아님
#예) 앞에서한 예제: 사용자별로, 총 구매금액을 계산
# -> 구매금액 : 가격 * 수량 -> 집계함수1
# -> 사용자별 : group by(전체 건 by 데이터를 사용자별로 묶어야 하니)
select userID, sum(price*amount) as "총구매액" from buytbl group by userID;
#매출액 기준으로 내림차순
select userID, sum(price*amount) as "총구매액" from buytbl group by userID order by  sum(price*amount) desc;
#집계함수에 조건을 걸 때 -> having ( group by 다음에 having 와야함)
select userID, sum(price*amount) as "총구매액" from buytbl group by userID having sum(price*amount) > 1000;

#집계함수한 컬럼에 대해서 정렬
select userID, sum(price*amount) as "총구매액" from buytbl group by userID  order by  "총구매액"  desc; 
select userID, sum(price*amount) as "총구매액" from buytbl group by userID  order by  총구매액  desc;  -- 공백이 없으면 가능
#집계함수에 대한 별칭을 만들고, 이에 대한 재활용할 때 백틱으로 
select userID, sum(price*amount) as "총구매액" from buytbl group by userID  order by  `총구매액`  desc; 

#위의 쿼리문을 with을 활용해서 임시 테이블을 만들어서 진행
# step1) 일단 구매테이블에서 사용자별로 매출액 테이블을 만들자
# step2 )그 다음에 그것을 보고 정렬/조건하던지
with abc ( userid, total) as (select userID, sum(price*amount) as "총구매액" from buytbl group by userID) 
 select * from abc order by total desc;
 
 # 1) usertbl에서 지역별로 최고의 키들을 대상으로, 이들의 평균 구하기
 #지역별로 제일 큰 사람들이 키의 평균값을 구하고자 한다
 select addr, max(height) from usertbl group by addr;
with adhtbl (addr, maxHeight) as (select addr, max(height) from usertbl group by addr)
 select avg(maxHeight) as "지역최장신평균" from adhtbl;
 
######## mysql에서 설정 ###################################################
set @myVar1 = 5; -- myVar1 = 5
set @myVar2 = 3;
set @myVar3 = 4.25;
set @myVar4 = "가수이름 ==>";

select @myVar1;
select @myVar2 + @myVar3;
select @myVar4, name from usertbl;

######## 형변환 : cast, convert ############################################
select avg(amount) as "평균판매수" from buytbl;
#정수로 형변환을 해서 처리하고자 함
select cast(avg(amount) as signed integer) as "평균판매수" from buytbl;
select convert(avg(amount), signed integer) as "평균판매수" from buytbl;

#구매 테이블에 있는 건당 매출액을 보려고 함
select num, price*amount from buytbl;
select num, price, amount, price*amount from buytbl;
select num, concat ( cast(price as char(10)), "X", cast(amount as char(4)), "=") as "단가X수량"  , price*amount as "매출액" from buytbl;
 
####### 조건문 if ###########################################################
select if (100>200, "true", "false");
 
####### 간단한 기능적인 부분들 ##################################################
#문자열 관련
select ascii("a");
select ascii("A");
select char("65");
select ascii("A"), char(65);

######## concat_ws(구분자, 값들 ...) -> 처음값 구분자 두번째 구분자 .. 맨 마지막 #######
#-> 날짜, 시간대..
select concat_ws("/", "2022","02","25");
select concat("2022","/","02","/","25");

select insert("abcdefghi", 3, 4, "@@@@"); -- ab@@@@ghi
select insert("abcdefghi", 3, 2, "@@@@"); -- ab@@@@efghi

######## pivot table ######################################################
create table pivotTest (uName char(3), season char(2), amount int);
insert into pivotTest values("김범수", "겨울", 10),
								("윤종신","여름",15),
								("김범수","가을",25),
								("김범수","봄",37),
                                ("윤종신","겨울",40),
                                ("김범수","여름",14),
                                ("김범수","겨울",22),
                                ("윤동신","여름",64);
select * from pivotTest;
#가로 : 소비자 / 세로 : 계절별 합계
select uName, sum(if (season = "봄", amount, 0)) as "봄",
			  sum(if (season = "여름", amount, 0)) as "여름",
              sum(if (season = "가을", amount, 0)) as "가을",
              sum(if (season = "겨울", amount, 0)) as "겨울",
              sum(amount) as "총계"
			  from pivotTest group by uName;

#가로 : 계절별 / 세로 : 사람별로
select season, sum(if (uName = "김범수", amount, 0)) as "김범수", 
			   sum(if (uName = "윤종신", amount, 0)) as "윤종신", 
               sum(amount) as "총계" 
               from pivotTest group by season order by season; 
               
############# join ########################################################
#기본이 되는 데이터 베이스를 test_join DB로 이동
use test_join;
select * from members;
select * from movies;

# 1) 영화와 고객에 대해서 cross join
select * from movies cross join members;
select * from members cross join movies;
# 1-1) 파생적으로 간략히 cross join 쓸 때
select * from movies, members;
select * from members, movies;

# 2) inner join에 대해서
# 2-1) 서브 쿼리를 활용해서 ~~ : 고객이름, 빌려본 영화
select members.first_name, members.last_name, movies.title from members, movies;
#위의 쿼리는 모든 조합을 다 나타낸 것일뿐, 빌린 것에 대한 정보 + 안 빌린 정보 섞어 조건문을 걸어 줄이겠다
select members.first_name, members.last_name, movies.title from members, movies where members.movie_id = movies.id;
# 2-2) 양 테이블에 공통된 inner join -> 명시적으로
#  고객들이 빌려본 영화가 뭐지?
#  우리 영화들 중에서 고객들이 빌려간게 뭐지?
#  --> 어느 테이블 소속인지 명시해줘야 함 (주의!)
select first_name, last_name, title from members ME inner join movies M on ME.movie_id = M.id;
select members.first_name, members.last_name, movies.title from members inner join movies on members.movie_id = movies.id;
#2-3) 컬럼에 대해서 특별하게 하지 않고 
select * from members ME inner join movies M on ME.movie_id = M.id;
select * from movies M inner join members ME on ME.movie_id = M.id;

# 3) left, right join
# 3-1)영화에 대한 정보를 기준으로 빌려간 고객 정보가 있다면 같이 보자 (없음 말고)
select * from movies M left join members ME on M.id = ME.movie_id;
# 3-2) 영화에 대한 정보를 기준으로 빌려간 고객 정보가 있다면, 같이 보고자 한다. 그런데 볼 것은 영화이름, 빌려간 사람 성/이름 항목만 보겠다
-- 컬럼에서는 join을 해도, 겹치는 컬럼이 없다면, 컬럼에대한 소속을 지정하지 않아도 문제는 없지만
select M.title, ME.first_name, ME.last_name from movies M left join members ME on M.id = ME.movie_id;
-- 아래와 같이 모호한 컬럼인 경우에는 에러가 발생 
-- 결론> 컬럼에 대한 소속을 밝히자
select title, first_name, last_name, id from movies M left join members ME on M.id = ME.movie_id;
# 3-3) 회원 정보를 기준으로, 회원중에 영화를 빌려간 회원이 있다면, 그 회원의 이름(성, 이름), 빌려간 영화 제목을 보자
select ME.first_name, ME.last_name, M.title from members ME left join movies M on ME.movie_id = M.id;



