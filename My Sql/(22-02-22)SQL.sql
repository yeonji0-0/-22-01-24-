use shopdb;
# select *내가 볼 컬럼들 from 테이블 이름 where 조건; (모든 데이터 출력하려면 *로 적기)
select * from membertbl;

#회원이름, 회원주소만 보려고 하면 
select memberName, memberAddress from membertbl;

#membertbl에서 이름이 지운이에 대한 정보 다 가지고 오기
select * from membertbl where memberName = "지운이";

#membertbl에서 지운이가 있다면 그 사람 회원 주소만 보자
select memberAddress from membertbl where memberName = "지운이";

# shopdb 데이터 베이스에서 쿼리문을 직접 작성해서 테이블을 추가해보자~
# 공란 때문에 백틱...`
create table `my testTBL` (id INT);
#select * from my testTBL;
select * from `my testTBL`;

#테이블 제거하기 
drop table `my testtbl`;

########### 인덱스 ####################################
create table indextbl (first_name varchar(14), 
						last_name varchar(16),
						hire_date date);
insert into indextbl select first_name, last_name, hire_date 
					from employees.employees limit 500;
select * from indextbl;

## indextbl에서 first_name 이 Mary인 사람을 찾아보세요
select * from indextbl where first_name="Mary";

# 전체 데이터를 단순히 일순하면 데이터의 수에 비례해서 너무 시간이 오래걸림
# -> 인덱스를 만들어보자
# create index 만들고자하는 인덱스이름 on 어디에~
create index idx_indextbl_firstname on indextbl(first_name);
# 좀 전에 인덱스 지정하지 않고 조회한 쿼리문 그대로
select * from indextbl where first_name="Mary";

########### 뷰(가상의 테이블) ###########################
#  뷰를 만들어야 함 
# create view 뷰이름 as select ~~~
create view uv_membertbl 
			as select memberName, memberAddress 
            from membertbl;

# 그러면 view 만든거 뭐 있는지 보자
select * from uv_membertbl;						

########## 스토어드 프로시저 #######
# 맴버 이름이 당탕이, 제픔 이름이 냉장고를 조회\
select * from membertbl where memberName = "당탕이";
select * from producttbl where productName ="냉장고";

# 이런 여러 쿼리문들을 한 번에 할 수 있도록 함수화
DELIMITER //
create procedure myProc()
begin
	select * from membertbl where memberName = "당탕이";
	select * from producttbl where productName ="냉장고";
end //
DELIMITER;

call myProc();
#gui로 만들기
call myProc2();

########### 트리거 ####################################
select * from membertbl;
insert into membertbl values ("figure","연아","경기도 군포시 당정동");
update membertbl set memberAddress = "서울시 강남구 역삼동" where memberName = "연아";
select * from membertbl;
#트리거 세팅 : 일단 탈되한 사람들 정보 담을 테이블 -> 탈퇴할 때 그 테이블에 기록
create table deletedmembertbl (
	memberID CHAR(8),
    memberNAme CHAR(5),
    memberAddress CHAR(20),
    deletedDate DATE
);
select * from deletedmembertbl;

DELIMITER //
create trigger trg_deletedmembertbl   -- 트리거 이름
	after delete                      -- delete 이벤트가 발생하고 나서
    on membertbl                      -- 우리가 감시할 테이블
    for each row                      -- 각 행마다 적용하겠다
begin
	-- old 테이블의 내용을 지워지면 벡업 테이블에 추가하겠다
    insert into deletedmembertbl values (old.memberID, old.memberName, 
                                         old.memberAddress, curdate());
end //
DELIMITER ;

delete from membertbl where memberName = "당탕이";
select * from membertbl;
select * from deletedmembertbl;

##데이터를 백업 했으니 지우는 테스트 진행
delete from producttbl;
select * from prodicttbl;

use sys;
use shopdb;
