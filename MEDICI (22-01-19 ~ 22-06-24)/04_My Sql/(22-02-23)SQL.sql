### 사용할 데티어 베이스 지정 : use ###
use shopdb; -- 데이터 베이스가 있는 경우
use mysqlqqqqq; -- 데이터베이스가 없는 것을 지정하면 에러 메시지 : Unknown DB

### select ##########
#1) DB에 없는 테이블에서 할 때
select * from myssss; -- 에러메시지 지금 사용하는 DB에 이 테이블 없어요

#2) select ~~~
use employees;
select * from titles;
#3) 내가 지금 사용하는 DB가 아니라 다른 DB에 있는 테이블로 조회
select * from shopdb.membertbl;

#4) emlpoyees테이블에서 first_name만 보자
select first_name from employees;

#5) employees 테이블에서 first_name, last_name, gender를 보자
# --> 내가 보고자 하는 컬럼들ㄹ을 순서대로 나열
select first_name, last_name, gender from employees;
select gender, first_name, last_name from employees;

#생일, 성, 이름, 입사일에 대한 정보를 추출하세요
select * from employees;
select birth_date, first_name, last_name, hire_date from employees;

#기본적인 데이터베이스
show databases;
#기본적인 테이블들
show tables; -- 주어진 DB에서 속한 테이블들 복수!
#전체적으로 다 보려면
show table status; -- 디테일한 정보들 다 보려고

#테이블의 대략적인 정보 확인 : pandas의 df.info()
#단, 혼동 df.describe() -> 수치형 데이터의 간략 정보
describe employees;
desc employees;

#조회를 해서 컬럼을 가지고 올 때, 별칭을 만들어서
select gender as 성별 , first_name as 성, last_name as 이름, hire_date as "회사 입사일" from employees;  -- 공란이 있을 때는 따움표로 묶기

######### TEST DB #######################
# 1)기존에 DB가 있다면 지우고, 없다면 새로 만들어서 시작
drop database if exists sqldb; -- sqldb가 있다면 지워줘
create database sqldb; -- sqldb DB를 만들어주세요
# 2)사용 DB를 sqldb로 전환
use sqldb;
# 3)테이블 만들자 
create table usertbl (        -- 회원 테이블
	userID char(8) not null primary key,
    name varchar(10) not null,
    birthYear int not null,
    addr char(2) not null,
    mobile1 char(3),
    mobile2 char(8),
    height smallint,
    mDate date  );
create table buytbl (       -- 회원 구매 테이블  
	num int auto_increment not null primary key,
	userID char(8) not null,
	prodName char(6) not null,
	groupName char(4),
	price int not null,
	amount smallint not null,
	foreign key (userID) references usertbl(userID) );
    
#실제 데이터 입력하기
insert into usertbl values('LSG', '이승기', 1987, '서울', '011', '11111111', 182, '2008-8-8');
insert into usertbl values('KBS', '김범수', 1979, '경남', '011', '22222222', 173, '2012-4-4');
insert into usertbl values('KKH', '김경호', 1971, '전남', '019', '33333333', 177, '2007-7-7');
insert into usertbl values('JYP', '조용필', 1950, '경기', '011', '44444444', 166, '2009-4-4');
insert into usertbl values('SSK', '성시경', 1979, '서울', NULL, NULL, 186, '2013-12-12');
insert into usertbl values('LJB', '임재범', 1963, '서울', '016', '66666666', 182, '2009-9-9');
insert into usertbl values('YJS', '윤종신', 1969, '경남', NULL, NULL, 170, '2005-5-5');
insert into usertbl values('EJW', '은지원', 1972, '경북', '011', '88888888', 174, '2014-3-3');
insert into usertbl values('JKW', '조관우', 1965, '경기', '018', '99999999', 172, '2010-10-10');
insert into usertbl values('BBK', '바비킴', 1973, '서울', '010', '00000000', 176, '2013-5-5');

insert into buytbl values(NULL, 'KBS', '운동화', NULL, 30, 2);
insert into buytbl values(NULL, 'KBS', '노트북', '전자', 1000, 1);
insert into buytbl values(NULL, 'JYP', '모니터', '전자', 200, 1);
insert into buytbl values(NULL, 'BBK', '모니터', '전자', 200, 5);
insert into buytbl values(NULL, 'KBS', '청바지', '의류', 50, 3);
insert into buytbl values(NULL, 'BBK', '메모리', '전자', 80, 10);
insert into buytbl values(NULL, 'SSK', '책', '서적', 15, 5);
insert into buytbl values(NULL, 'EJW', '책', '서적', 15, 2);
insert into buytbl values(NULL, 'EJW', '청바지', '의류', 50, 1);
insert into buytbl values(NULL, 'BBK', '운동화', NULL, 30, 2);
insert into buytbl values(NULL, 'EJW', '책', '서적', 15, 1);
insert into buytbl values(NULL, 'BBK', '운동화', NULL, 30, 2);

#이름이 김범수를 찾아줘
select * from usertbl where name = "김범수";
#지역이 서울 
select * from usertbl where addr = "서울";
#출생년도가 1973인 사람
select * from usertbl where birthYear = 1973;
#mobile1의 정보가 없는 사람들
select * from usertbl where mobile1 is null;
#select * from usertbl where mobile1 = null; -- 에러도 안 뜨기 때문에 주의!!
#핸드폰 정보가 있는 사람
select * from usertbl where mobile1 is not null;
#1970년 이후 출생이고, 신장이 182이상인 사람
select * from usertbl where birthYear >= 1970 and height >= 182;
#1970년 이후 출생이고, 신장이 182이상인 사람중에서 그 사람의 아이디와 이름 조회
select userID, name from usertbl where birthYear >= 1970 and height >= 182;
#주소지가 서울인 사람들의 모든 정보 조회
select * from usertbl where addr = "서울";
#주소지가 서울이면서 mobile1의 번호를 011로 사용한 사람의 모든 정보 조회
select * from usertbl where addr = "서울" and mobile1 = 011;
#주소지가 서울이면서 mobile1의 번호를 011로 사용하는 사람의 아이디,이름,mobile1과 mobile2를 조회해보자
select userID,name,mobile1, mobile2 from usertbl where addr = "서울" and mobile1 = 011; 
#핸드폰 번호를 합쳐서 보자 -> 보고자 하는 컬럼을 그룹화
select userID,name,concat(mobile1,mobile2) from usertbl where addr = "서울" and mobile1 = 011; 
select userID,name,concat(mobile1,"-",mobile2) as phonenumber from usertbl where addr = "서울" and mobile1 = 011;
