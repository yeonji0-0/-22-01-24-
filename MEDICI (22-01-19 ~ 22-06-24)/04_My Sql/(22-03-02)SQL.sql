use sqldb;
select * from membertbl;

select case when addr in ("서울", "경기") then "수도권"
			when addr in ("경북", "경남") then "경상도"
            else "기타 지역"
            end
            from usertbl;
# 예) 수도권과 비수도권으로 나눠서, 각 지역에 거주하는 고객의 수까지 같이 볼 때
select case when addr in ("서울", "경기") then "수도권" else "비수도권" end as "수도권구분", 
		count(userID) from usertbl
        group by case when addr in ("서울", "경기") then "수도권" else "비수도권" end;
        
select case when addr in ("서울", "경기") then "수도권" else "비수도권" end as "수도권구분", 
		count(userID) from usertbl
        group by 1;
 
 #내가 필요한 부분만 집계해서 볼 때 -> 서울에 대해서만 
select sum(case when addr = "서울" then 1 else 0 end) as "SEOUL" from usertbl;

#쿼리문 인라인
select * from (select * from usertbl) A;

select userID from usertbl where addr = "서울";

select userID from (select userID from usertbl where addr = "서울") a; -- from 안에 select 쿼리문 실행 할 때 뒤에 약어 써야함!

########## EDA Dataset 1 ################################################
use prodreviews;
select * from dataset2;

# Q) Division Name별 평균 평점을 구하세요
# -> division으로 묶어야 한다 볼 것은 평점에 대한 평균집계 -> 정렬
select `Division Name` as DivisionName from dataset2;
select `Division Name` as DivisionName, Rating from dataset2;
select `Division Name` as DivisionName, Rating from dataset2 group by `Division Name`;
select `Division Name` as DivisionName, avg(Rating) from dataset2 group by `Division Name` order by avg(Rating) desc;

# Q) Depart Name별로  평균 평점을 구하세요
# -> Division별로는 크게 평점 차이가 나지 않아서 좀 더 세분화된 Department별로 차이 나는지 보기 위해
select `Department Name` as DepartmentName, avg(Rating) from dataset2 group by `Department Name`;
select `Department Name` as DepartmentName, avg(Rating) from dataset2 group by `Department Name` order by avg(Rating) desc;

# Q) Trend Depart가 낮다 -> 왜 낮을 까 리뷰를 보자 
# 평점이 3점보다 낮은 것들을 보자
select * from dataset2 where `Department Name` = "Trend" and Rating <= 3 ;
#그러면 도대체 누가 평점을 낮게 주는지 보고자 한다
# 일단, 연령대별로 평점 차이가 있나? 10대씩 끊어서 보자
select age, rating from  dataset2;
select floor(age/10)*10, rating from dataset2;
select floor(age/10)*10, rating from dataset2 where `Department Name` = "Trend" and Rating <= 3 ;
#여기서 나이대별로 묶어야 하고 묶었을 때 데이터가 몇 개가 있는가? 나이가 많은 순대로 정렬
select floor(age/10)*10 as ageband , count(*) as cnt from dataset2 where `Department Name` = "Trend" and Rating <= 3 group by ageband order by cnt desc;
#이 결과를 보니 40~50대가 전체적인 리뷰를 많이 써서 악평 리뷰가 많은건지
#아니면 리뷰를 그렇게 많이 쓰지 않지만, 유독 40~50대가 불편하게 느낀게 무엇인지
select floor(age/10)*10 as ageband , count(*) as cnt from dataset2 where `Department Name` = "Trend"  group by ageband order by cnt desc;
#50대들이 Department에 Trend에 남긴 악평중에서 10개만 보자
select * from dataset2  where `Department Name` = "Trend" and rating <= 3 and age between 50 and 59 limit 10;

#어떤 상품의 평점이 좋으며, 그 상품은 어느 department인지 보자
select `Department Name`, `Clothing ID`, Rating from dataset2;
select `Department Name`as DEP_NAME, `Clothing ID` as CLOTH_ID, avg(Rating) as AVG_RATE from dataset2 
	group by `Department Name`, `Clothing ID` order by avg(Rating) desc;

#########################################################################
select * from dataset2;
#위에서 department&clothID를 보니 종류가 상당히 많았음 특히, 평점이 5점인 것들도 많았고..
#평균평점을 기준으로 department에 대해서 순위를 ㅣ부여하고자 함
# -> 랭킹의 기준을 평점의 평균으로 하려고 함 그런데 이 기준이 주어진 dataset2에 기본으로 있는 값은 아님 만들어내야함
select `Department Name`,`Clothing ID`, avg(Rating) from dataset2 group by  `Department Name`,`Clothing ID`;
#위의 평균 평점을 가진 테이블을 바탕으로 우리가 랭킹을 하고자 한다
select *, row_number() over(partition by `Department Name` order by AVG_RATE ) as Rnk 
		from (select `Department Name`,`Clothing ID`, avg(Rating) as AVG_RATE from dataset2
        group by `Department Name`, `Clothing ID`) A;

#위에서 하나 것들 종류가 너무 많다 각 Department별로 top 10만 보려고 한다
#-> 방금 위에서 한 쿼리문에 대한 결과 테이블을 기반으로
#select * from ( 지금 보이는 테이블) where Rnk <= 10 order by `Department Name`;
select * from (select *, row_number() over(partition by `Department Name` order by AVG_RATE ) as Rnk 
		from (select `Department Name`,`Clothing ID`, avg(Rating) as AVG_RATE from dataset2
        group by `Department Name`, `Clothing ID`) A ) B  where Rnk <= 10 order by `Department Name`;
	
#이제 좀 길게 나타나게 되고, 복잡하고, 이 테이블 기반으로 다른 사항을 보려면
#또 앞에와 같이 길게 쿼리문을 하기에는 귀찮음
create temporary table stat as 
	select * from (select *, row_number() over(partition by `Department Name` 
		order by AVG_RATE ) as Rnk 
        from (select `Department Name`, `Clothing ID`, 
						avg(Rating) as AVG_RATE 
		from dataset2 
        group by `Department Name`, `Clothing ID`) A) B
		where Rnk <=10 
        order by `Department Name`; 
select * from stat;
#-> 앞에 department 상위 10개 지정한 임시 테이블에서 cloth ID만 보자
select Clothing ID from stat where `Department Name` = "Bottoms";

#지금 임시로 만든 stat테이블 기반으로
#bottom  Depart에서 평점이 낮은 10개의 리뷰를 보려고 함
select * from dataset2 where `Clothing ID` in (select `Clothing ID` from stat where `Department Name` = "Bottoms"); 

# Q1) Department별로, 다시 연령대(10, 20, 30,...)별로 묶어서
# -> 묶어서 평점에 대해서 평균을 대표값으로 나타내서
select `Department Name`, Age, Rating from dataset2;
#나이를 나이대로 변환
select `Department Name`, floor(Age/10)*10, Rating from dataset2;
# + 그룹별로 보기 Depart &  나이대
select `Department Name`, floor(Age/10)*10, avg(Rating) as AVG_RATE
		from dataset2
        group by `Department Name`, floor(Age/10)*10 ;

select `Department Name` as DEP_NAME, 
		floor(Age/10)*10 as AGE_BAND, 
        avg(Rating) as AVG_RATE
		from dataset2
        group by DEP_NAME, AGE_BAND;
        
select `Department Name` as DEP_NAME, 
		floor(Age/10)*10 as AGE_BAND, 
        avg(Rating) as AVG_RATE
		from dataset2
        group by DEP_NAME, AGE_BAND
        order by AVG_RATE asc;
        
# groupo by 에 컬럼명을 다 쓰기 귀찮아서 순서 정수로 지정할 수 있음
select `Department Name` as DEP_NAME, 
		floor(Age/10)*10 as AGE_BAND, 
        avg(Rating) as AVG_RATE
		from dataset2
        group by 1,2;

# 위의 쿼리문을 바탕으로 나이대별로 묶어서 정렬은 평균평점으로 해서 rank
select *, row_number() over( partition by AGE_BAND order by AVG_RATE) as RNK 
		from (앞에 만든 테이블에서...);

select *, row_number() over( partition by AGE_BAND order by AVG_RATE) as RNK 
		from (select `Department Name` as DEP_NAME, 
		floor(Age/10)*10 as AGE_BAND, 
        avg(Rating) as AVG_RATE
		from dataset2
        group by 1,2) A;
        
# 위의 테이블을 기반으로해서 평점이 안 좋은 나이대별로 top1을 보자
# --> 위의 테이블이 있다고 하고, 이 테이블에서 rank=1인 친구들만 추리면 된다
select * from (위에 만든 테이블) 
			where RNK=1;

select * from (select *, row_number() over( partition by AGE_BAND order by AVG_RATE) as RNK 
		from (select `Department Name` as DEP_NAME, 
		floor(Age/10)*10 as AGE_BAND, 
        avg(Rating) as AVG_RATE
		from dataset2
        group by 1,2) A ) B 
			where RNK=1;

# 리뷰 중에서 size관련된 리뷰만 추려서 보고싶다
#단순히 그런 리뷰만 보고 땡이 아니라, 비율이나 이런 부분까지 고려하고 싶어서
# -> size관련 단어 있으면 1, 없으면 0으로 해서 새로운 지표
# -> now column -> select 두에
select `Review Text`, case 
			when `Review Text` like "%size%" 	
				then 1 
			else 0 
		end as SIZE_YN
        from dataset2;
# -> case when을 복잡하게 생각할 것이 아니라 그냥 집계함수 중 하나라고 생각하면 보다 쉽게 접근 용이
#   뒤에는 case when을 기반으로 다시 그 결과를 집계합수로~ 문제가 있음

#카운딩에 대해서 처리 : 0/1로 되어 있을 때 비율 mean, 합계 sum 그냥 전체 수를 볼 때 count(*) 암기!
select sum( case when `Review Text` like "%size%" then 1 else 0 end) as N_SIZE,
	count(*) as N_TOTAL
    from dataset2;

select sum(SIZE_YN), count(*) as N_TOTAL 
	from(select `Review Text`, case when `Review Text` like "%size%" then 1 else 0 end as SIZE_YN
    from dataset2) A;
##쿼리 속도 체크를 위해서 설정 변경 ##
SET PROFILING =1;
show profiles;

#Large, Loose, samll,tight로 세분화해서 리뷰의 분포 보기
select sum( case when `Review Text` like "%size%" then 1 else 0 end) as N_SIZE, -- as 안 써줘도 됨
		sum( case when `Review Text` like "%large%" then 1 else 0 end) as N_LARGE,
        sum( case when `Review Text` like "%loose%" then 1 else 0 end) as N_LOOSE,
        sum( case when `Review Text` like "%small%" then 1 else 0 end) as N_SMALL,
        sum( case when `Review Text` like "%tight%" then 1 else 0 end) as N_TIGHT,
	count(*) as N_TOTAL -- sum(1) N_TOTAL 이라고 해줘도 됨
    from dataset2;
    
#앞에서 한 사이즈별로 항목별로 다시 디테일하게 쪼개면 -> group by
select `Department Name`, 
		sum( case when `Review Text` like "%size%" then 1 else 0 end) as N_SIZE,
		sum( case when `Review Text` like "%large%" then 1 else 0 end) as N_LARGE,
        sum( case when `Review Text` like "%loose%" then 1 else 0 end) as N_LOOSE,
        sum( case when `Review Text` like "%small%" then 1 else 0 end) as N_SMALL,
        sum( case when `Review Text` like "%tight%" then 1 else 0 end) as N_TIGHT,
	count(*) as N_TOTAL
    from dataset2 group by `Department Name`;
    
