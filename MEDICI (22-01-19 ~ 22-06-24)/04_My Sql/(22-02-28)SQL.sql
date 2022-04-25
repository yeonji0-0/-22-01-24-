use test_join;

#cross jpin -> n: m 모든 경우의 수 
# 1) FM
select * from movies cross join members;
# 2) 간략하게 볼 때
select * from movies, members;

########## inner join ###################################################
# 1) 서브 쿼리를 활용.. cross join을 해서 모든 경우의 수 만들고 그 중에 보고자 하는 것만 선택 
select members.fisrt_name, movies.title from members, movies;
select members.fisrt_name, movies.title from members, movies where members.movie_id = movies.id;
# 2) 명시적으로 inner join
select members.first_name, members.last_name, title from members inner join movies on members.movie_id = movies.id;
# 2-1) 소속을 좀 간결하게 별칭으로 하자
# 참고) 컬럼 별칭 as, 테이블 별칭은 공란으로 대문자를
 select ME.first_name, ME.last_name, M.title from members ME inner join movies M on ME.movie_id = M.id;
 
 ######### left/right join ################################################
 # -> 한쪽 master를 기준으로 reference table 붙임( 단, 있으면 붙이고 없으면 안 붙임 )
 select * from movies left join members on movies.id = members.movie_id;
 select * from movies M left join members ME on M.id = ME.movie_id;
 #동일한 결과를 right join
 select * from members ME right join movies M on ME.movie_id = M.id;

########### U : full join -> union을 살짝 우회해서 사용###########################
select * from members ME left join movies M on ME.movie_id = M.id union
select * from members ME right join movies M on ME.movie_id = M.id;

#### 잠시 iner join에 대해서
use sqldb;
#고객들이 무엇을 구매했는지 -> 고객 정보& 구매 정보 
select * from buytbl inner join usertbl on buytbl.userID = usertbl.userID where buytbl.userID = "JYP";
#회원ID, 산 상품, 가격, 수량, 이름, 지역 
select buytbl.userID, buytbl.prodName, buytbl.price, buytbl.amount, usertbl.name, usertbl.addr from buytbl inner join usertbl on buytbl.userID = usertbl.userID where buytbl.userID = "JYP";

# Q1) 회원ID,구매 상품 이름, 구매 상품 그룹, 회원 이름, 회원 지역, 회원 연락처 
# -> 내가 필요한 정보들을 어디서 가지고 올지 1개 테이블, 여러개냐..
# -> 여러개면 어디에서 가지고 올지 소속
# -> 앞에서 한 리뷰 : 연락처 mobile1, 2의 정보를 합쳐야 함 : concat
select B.userID, B.prodName, B.groupName, US.name, US.addr, concat(US.mobile1, US.mobile2) as "연락처" 
	from buytbl B inner join usertbl US on B.userID = US.userID;

# Q2) 회원 테이블을 기준으로 JYP라는 아이디가 구매한 물건의 목록을 찾아보세요 단, 보일 컬럼을 아이디, 이름, 상품이름, 지역, 연락처
 select U.userID, B.prodName, U.addr, concat(U.mobile1, U.mobile2) as "연락처" from usertbl U inner join  buytbl B 
	on U.userID = B.userID where U.userID = "JYP";

# Q3) 전체 회원들이 구매한 목록을 모두 출력하려고 한다 단, userID로 정렬
 select U.userID, B.prodName, U.addr, concat(U.mobile1, U.mobile2) as "연락처" from usertbl U inner join  buytbl B 
	on U.userID = B.userID order by U.userID; 

# Q4) 우리 쇼핑몰에서 고객들에게 감사 쿠폰을 발행하려고 함
# 기준) 우리 쇼핑몰에서 1번이라도 구매한 기록이 있는 회원들에게 쿠폰을 발행하려 함
# -> 어느 회원들에게 발송하면 되는지 정보를( 아이디, 이름, 지역, 연락처) 지역을 기준으로 정렬까지 좀 
select distinct U.userID, U.name, U.addr, concat(U.mobile1, U.mobile2) as "연락처" from usertbl U inner join buytbl B on U.userID = B.userID order by  U.addr;

############# 테이블 3 생성 ###################################################
USE sqldb;
CREATE TABLE stdtbl 
( stdName    VARCHAR(10) NOT NULL PRIMARY KEY,
  addr	  CHAR(4) NOT NULL
);
CREATE TABLE clubtbl 
( clubName    VARCHAR(10) NOT NULL PRIMARY KEY,
  roomNo    CHAR(4) NOT NULL
);
CREATE TABLE stdclubtbl
(  num int AUTO_INCREMENT NOT NULL PRIMARY KEY, 
   stdName    VARCHAR(10) NOT NULL,
   clubName    VARCHAR(10) NOT NULL,
FOREIGN KEY(stdName) REFERENCES stdtbl(stdName),
FOREIGN KEY(clubName) REFERENCES clubtbl(clubName)
);
INSERT INTO stdtbl VALUES ('김범수','경남'), ('성시경','서울'), ('조용필','경기'), ('은지원','경북'),('바비킴','서울');
INSERT INTO clubtbl VALUES ('수영','101호'), ('바둑','102호'), ('축구','103호'), ('봉사','104호');
INSERT INTO stdclubtbl VALUES (NULL, '김범수','바둑'), (NULL,'김범수','축구'), (NULL,'조용필','축구'), (NULL,'은지원','축구'), (NULL,'은지원','봉사'), (NULL,'바비킴','봉사');

select * from stdtbl S left join stdclubtbl SC on S.stdName = SC.stdName left join clubtbl C on  SC.clubName = C.clubName  where C.clubName = "축구" order by S.stdName;          
#참고) select문에서 order by는 늘 위치가 맨 마지막이여야 함

############# outer join ###################################################
# buytbl, usertbl에서 회원정보들을 기준으로 산 물건에 대한 정보가 있으면 가지고 오고 없으면 안 가져오고
# -> 회원 정보는 다 있어야 함 (물건을 사든 안 사든)
# -> 볼 컬럼을 아이디, 이름, 산 물건 이름, 가격
select U.userID, U.name, B.prodName, B.price from usertbl U left join buytbl B on U.userID = B.userID order by B.price desc;
#아래와 같은 결과를 right join을 써서 해보세요
select U.userID, U.name, B.prodName, B.price from usertbl U left join buytbl B on U.userID = B.userID order by B.price desc;   -- right join check!
#1번도 구매한 적이 없는 회원들의 정보? -> 출력 : 회원아이디, 이름, 지역, 연락처, 참고(구매상품)
select U.userID, U.name, U.addr, concat(U.mobile1, U.mobile2) as "연락처", B.prodName from usertbl U left join buytbl B on U.userID = B.userID where B.prodName is null order by U.userID;        
#학생들 전체가 무슨 동아리를 가입을 했고 어느 방으로 가야하는지 보고 싶다 단, 혹시 동아리에 아직 가입을 하지 않은 친구가 있으면 동아리를 추천하고자 함
# -> 학생들에 대해서 동아리 정보가 있으면 가지고 오고, 없다면 없다는 정보 가져옴
select * from stdtbl S left join stdclubtbl SC on S.stdName = SC.stdName left join clubtbl C on SC.clubName = C.clubName;
#클럼들이 학생들을 잘 모집했는지 보려고 한다 어느 클럽에 어느 학생들이 왔고, 어느 클럽이 혹시 학생 모집을 못 했는지 보려고 한다
select * from clubtbl C left join stdclubtbl SC on C.clubName = SC.clubName left join stdtbl S on SC.stdName = S.stdName;
#위와 동일하게 나오도록 join을 수정하세요
select * from stdtbl S left join stdclubtbl SC on S.stdName = SC.stdName right join clubtbl C on SC.clubName = C.clubName;
#그러면 학생과 가입한 동아리에 대해서 가입정보가 있으면 보이고, 없으면 null보이게 
#동아리가 학생을 받았으면 속한 학생, 회원모집 못한 클럽은 그대로 
select * from stdtbl S left join stdclubtbl SC on S.stdName = SC.stdName left join clubtbl C on SC.clubName = C.clubName
union
select * from stdtbl S left join stdclubtbl SC on S.stdName = SC.stdName right join clubtbl C on SC.clubName = C.clubName;

######## 기타 : union, union all ##############################################
select stdName, addr from stdtbl
union
select clubName, roomNo from clubtbl;

select stdName, addr from stdtbl
union all
select clubName, roomNo from clubtbl;

#전화번호가 없는 사람들을 제외하고자 하면
select name, concat(mobile1, mobile2) as "연락처" from usertbl where name not in (select name from usertbl where mobile1 is null);
#아차하는 순간 잘 안 보임
#쿼리문을 

########### 동영상, 텍스트 파일 저장 관련 ###########################################
create database moviedb;
use moviedb;

#저장하려는 데이터의 특성에 맞는 컬럼 캐릭터 지정
#특히 텍스트 처리시에는 인코딩 부분
create table movietbl (
	movie_id INT,
    movie_title varchar(30),
    movie_director varchar(20),
    movie_star varchar(20),
    movie_script longtext,
    movie_film longblob 
)default charset = utf8mb4;
select * from movietbl;

insert into movietbl values (1, "쉰들러 리스트","스필버그","리암 니슨", 
							load_file("C:\Users\MEDICI\Documents\Python codes\movies\Schindler.txt"),
                            load_file("C:\Users\MEDICI\Documents\Python codes\movies\Schindler.mp4"));
select * from movietbl;
#파일이 mysql에 들어가지 않는 이유 체크 2가지
# 1) 최대 패킷 제한
show variables like "max_allowed_packet";
# 2) 파일 업로드, 다운로드 관련 폴더 제한하고 있음 보안 때문에
show variables like "secure_file_priv";

use moviedb;
truncate movietbl;
select * from movietbl;
insert into movietbl values (1, "쉰들러 리스트","스필버그","리암 니슨", 
							load_file("C:\Users\MEDICI\Documents\Python codes\movies\Schindler.txt"),
                            load_file("C:\Users\MEDICI\Documents\Python codes\movies\Schindler.mp4"));
select * from movietbl;