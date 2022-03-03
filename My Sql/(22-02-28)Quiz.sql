######### Quiz 01 #######################################################
use test_quiz;
CREATE TABLE tCar
(
    car VARCHAR(30) NOT NULL,   	 -- 이름
    capacity INT NOT NULL,   		 -- 배기량
    price INT NOT NULL,   		 -- 가격
    maker VARCHAR(30) NOT NULL   	 -- 제조사
);

INSERT INTO tCar (car, capacity, price, maker) VALUES ('소나타', 2000, 2500, '현대');
INSERT INTO tCar (car, capacity, price, maker) VALUES ('티볼리', 1600, 2300, '쌍용');
INSERT INTO tCar (car, capacity, price, maker) VALUES ('A8', 3000, 4800, 'Audi');
INSERT INTO tCar (car, capacity, price, maker) VALUES ('SM5', 2000, 2600, '삼성');

CREATE TABLE tMaker
(
    maker VARCHAR(30) NOT NULL,   	 -- 회사
    factory CHAR(10) NOT NULL,   		 -- 공장
    domestic CHAR(1) NOT NULL   	 -- 국산 여부. Y/N
);

INSERT INTO tMaker (maker, factory, domestic) VALUES ('현대', '부산', 'y');
INSERT INTO tMaker (maker, factory, domestic) VALUES ('쌍용', '청주', 'y');
INSERT INTO tMaker (maker, factory, domestic) VALUES ('Audi', '독일', 'n');
INSERT INTO tMaker (maker, factory, domestic) VALUES ('기아', '서울', 'y');

select * from tCar;
select * from tMaker;
#2번
select * from tCar cross join tMaker;
select * from tCar, tMaker;
#3번
select * from tCar cross join tMaker where tCar.maker = tMaker.maker;
#4번
select C.car, C.price, C.maker, M.factory  from tCar C cross join tMaker M where C.maker = M.maker;
#5번
select tCar.*, tMaker.factory from tCar cross join tMaker where tCar.maker = tMaker.maker;
#6번
select C.car,C.price, C.maker,M.factory from tCar C inner join tMaker M on C.maker = M.maker;
# 7) 자동차  정보를 중심으로 제조사의 정보를 가져오기 -> outter join(L, R)
# 포인트 -> 컬럼의 이름이 같을 때, 어느 테이블의 컬럼을 볼지 명확히
select C.car, C.price, C.maker,M.factory from tCar C left join tMaker M on C.maker = M.maker;
#8) 제조사 정보에서 자동차의 정보가 있으면 붙여라 -> outter join(L,R)
select C.car, C.price, M.maker,M.factory from tCar C right join tMaker M on C.maker = M.maker;
select C.car, C.price, M.maker,M.factory from tMaker M  left join tCar C on C.maker = M.maker;


####### Quiz 02 ##########################################################
CREATE TABLE tCity
(
	name CHAR(10) PRIMARY KEY,
	area INT NULL ,
	popu INT NULL ,
	metro CHAR(1) NOT NULL,
	region CHAR(6) NOT NULL
);

INSERT INTO tCity VALUES ('서울',605,974,'y','경기');
INSERT INTO tCity VALUES ('부산',765,342,'y','경상');
INSERT INTO tCity VALUES ('오산',42,21,'n','경기');
INSERT INTO tCity VALUES ('청주',940,83,'n','충청');
INSERT INTO tCity VALUES ('전주',205,65,'n','전라');
INSERT INTO tCity VALUES ('순천',910,27,'n','전라');
INSERT INTO tCity VALUES ('춘천',1116,27,'n','강원');
INSERT INTO tCity VALUES ('홍천',1819,7,'n','강원');

SELECT * FROM tCity;

CREATE TABLE tStaff
(
	name CHAR (15) PRIMARY KEY,
	depart CHAR (10) NOT NULL,
	gender CHAR(3) NOT NULL,
	joindate DATE NOT NULL,
	grade CHAR(10) NOT NULL,
	salary INT NOT NULL,
	score DECIMAL(5,2) NULL
);

INSERT INTO tStaff VALUES ('김유신','총무부','남','2000-2-3','이사',420,88.8);
INSERT INTO tStaff VALUES ('유관순','영업부','여','2009-3-1','과장',380,NULL);
INSERT INTO tStaff VALUES ('안중근','인사과','남','2012-5-5','대리',256,76.5);
INSERT INTO tStaff VALUES ('윤봉길','영업부','남','2015-8-15','과장',350,71.25);
INSERT INTO tStaff VALUES ('강감찬','영업부','남','2018-10-9','사원',320,56.0);
INSERT INTO tStaff VALUES ('정몽주','총무부','남','2010-9-16','대리',370,89.5);
INSERT INTO tStaff VALUES ('허난설헌','인사과','여','2020-1-5','사원',285,44.5);
INSERT INTO tStaff VALUES ('신사임당','영업부','여','2013-6-19','부장',400,92.0);
INSERT INTO tStaff VALUES ('성삼문','영업부','남','2014-6-8','대리',285,87.75);
INSERT INTO tStaff VALUES ('논개','인사과','여','2010-9-16','대리',340,46.2);
INSERT INTO tStaff VALUES ('황진이','인사과','여','2012-5-5','사원',275,52.5);
INSERT INTO tStaff VALUES ('이율곡','총무부','남','2016-3-8','과장',385,65.4);
INSERT INTO tStaff VALUES ('이사부','총무부','남','2000-2-3','대리',375,50);
INSERT INTO tStaff VALUES ('안창호','영업부','남','2015-8-15','사원',370,74.2);
INSERT INTO tStaff VALUES ('을지문덕','영업부','남','2019-6-29','사원',330,NULL);
INSERT INTO tStaff VALUES ('정약용','총무부','남','2020-3-14','과장',380,69.8);
INSERT INTO tStaff VALUES ('홍길동','인사과','남','2019-8-8','차장',380,77.7);
INSERT INTO tStaff VALUES ('대조영','총무부','남','2020-7-7','차장',290,49.9);
INSERT INTO tStaff VALUES ('장보고','인사과','남','2005-4-1','부장',440,58.3);
INSERT INTO tStaff VALUES ('선덕여왕','인사과','여','2017-8-3','사원',315,45.1);

SELECT * FROM tStaff;

#2번 
select  * from tcity;
# 3) 컬럼 선별 
select  * from tStaff;
# 4) 컬럼 선별 : as -> as 컬럼 명으로 where 사용 못 함 
select name, popu from tCity;
# 5) 컬럼 선별  
select name, region, area from tCity;
# 6)
select name, Salary from tStaff;
# 7)
select name as "이름", depart as "부서", grade as "직급" from tStaff;
# 8) 컬럼에 as 사용
select name as "도시명" , area as "면접(제곱km)", popu as "인구(만명)" from tCity;
# 9) 집계함수
select name, popu*10000 as "인구명" from tCity;  
# 10) 
select name as "도시명" , area as "면접", Popu as "인구", (popu*10000/area) as "인구밀도" from tCity;
# 11) 조건 검색 : where
select name from tCity where area >= 1000;
# 12) 조건 검색 + 컬럼
select name, area from tCity where Area >= 1000;
# 13) 
select Name from tCity where Popu < 10;
# 14)
select * from tCity where region = "전라";
# 15)
select Name from tStaff where Salary >= 400;
# 16)
select * from tStaff where score is null;
# 17)
select * from tStaff where score is not null;
# 18)
select * from tCity where popu >= 100 and area >= 700;
# 19)
select * from tCity where (region = "경기" and popu >= 50) or (region != "경기" and popu < 50 and area >= 500);
# 20)
select Name from tStaff where Salary <= 300 and Score >= 60;
# 21)
select Name from tStaff where depart = "영업부" and gender = "여";
# 22)
select * from tCity where Name like "%천%";
# 23)
select * from tStaff where Name like "정%";
# 24)
select * from tStaff where name like "%신%";
select * from tStaff where (name like "_신") or (name like"신%");
# 25) 
select * from tCity where Popu between 50 and 100;
# 26)
select  * from tStaff where joindate between "2015-01-01" and "2018-12-31";
# 27) 
select * from tCity where Area between 50 and 1000;
# 28) 
select * from tStaff where Salary between 200 and 299;
# 29)
select * from tCity where (Region = "경상") or (Region = "전라");
select * from tCity where region in ("경상" or "전리");
# 30)
select * from tCity order by Popu;
# 31)
select Region, Name, Area, popu from tCity order by Region ,Name;
# 32)
select * from tCity order by Area;
# 33)
select Name from tCtiy order by Popu;
# 34)
select * from tCity  where region = "경기" order by popu;
# 35)
select * from tStaff order by salary asc, score desc;
# 36)
select * from tStaff where depart = "영업부" order by joindate;








