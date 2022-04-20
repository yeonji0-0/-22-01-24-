train = read.csv("C:/Users/MEDICI/Downloads/bus_data/train.csv",fileEncoding='utf-8')
test = read.csv("C:/Users/MEDICI/Downloads/bus_data/test.csv",fileEncoding='utf-8')
bts = read.csv("C:/Users/MEDICI/Downloads/bus_data/bus_bts.csv",fileEncoding='utf-8')

# date 전처리
library('lubridate')
train$date = as.Date(train$date)
train['weekday'] = wday(train$date)

test$date = as.Date(test$date)
test['weekday'] = wday(test$date)
dim(train)
dim(test)

#in_out 인코딩
train[train$in_out == "시외",'in_out'] = 1
train[train$in_out == "시내",'in_out'] = 0

test[test$in_out == "시외",'in_out'] = 1
test[test$in_out == "시내",'in_out'] = 0

# 두 시간 기준으로 변수 추가 
train['r68']=train['X6.7_ride']+train['X7.8_ride'] # 6 ~ 8시 승차인원
train['r810']=train['X8.9_ride']+train['X9.10_ride']
train['r1012']=train['X10.11_ride']+train['X11.12_ride']

train['t68']=train['X6.7_takeoff']+train['X7.8_takeoff'] # 6 ~ 8시 하차인원
train['t810']=train['X8.9_takeoff']+train['X9.10_takeoff']
train['t1012']=train['X10.11_takeoff']+train['X11.12_takeoff']

test['r68']=test['X6.7_ride']+test['X7.8_ride'] # 6 ~ 8시 승차인원
test['r810']=test['X8.9_ride']+test['X9.10_ride']
test['r1012']=test['X10.11_ride']+test['X11.12_ride']

test['t68']=test['X6.7_takeoff']+test['X7.8_takeoff'] # 6 ~ 8시 하차인원
test['t810']=test['X8.9_takeoff']+test['X9.10_takeoff']
test['t1012']=test['X10.11_takeoff']+test['X11.12_takeoff']

# 원핫인코딩
library('caret')
dmy <- dummyVars(~., data = train)
n_train <- data.frame(predict(dmy, newdata = train))

dmy <- dummyVars(~., data = test)
n_test <- data.frame(predict(dmy, newdata = test))

# 거리 측정 + 변수 생성 
library("geosphere")
jeju=c( 126.52969,33.51411) # 제주 측정소 근처
gosan=c(126.16283 ,33.29382 ) #고산 측정소 근처
seongsan=c(126.8802,33.38677 ) #성산 측정소 근처
po=c(126.5653,33.24616 ) #서귀포 측정소 근처

train['dis_jeju']=0
train['dis_gosan']=0
train['dis_seongsan']=0
train['dis_po']=0
for(i in 1:nrow(train)){
  train$dis_jeju[i]= distGeo(jeju, c(train$longitude[i], train$latitude[i]))
  train$dis_gosan[i]= distGeo(gosan, c(train$longitude[i], train$latitude[i]))
  train$dis_seongsan[i]= distGeo(seongsan, c(train$longitude[i], train$latitude[i]))
  train$dis_po[i]= distGeo(po, c(train$longitude[i], train$latitude[i]))

}
a = cbind(train['dis_jeju'] ,train['dis_gosan'],train['dis_seongsan'] ,train['dis_po'])
train['dist_min'] = apply(a,1, min)
train['dis_name']=0
for(i in 1:nrow(train)){
  if(train$dis_jeju[i] == train$dist_min[i]){
    train$dis_name[i] = 1
  }else if(train$dis_gosan[i] == train$dist_min[i]){
    train$dis_name[i] = 2
  }else if(train$dis_po[i] == train$dist_min[i]){
    train$dis_name[i] = 3
  }else if(train$dis_seongsan[i] == train$dist_min[i]){
    train$dis_name[i] = 4
  }
}


test['dis_jeju']=0
test['dis_gosan']=0
test['dis_seongsan']=0
test['dis_po']=0
for(i in 1:nrow(test)){
  test$dis_jeju[i]= distGeo(jeju, c(test$longitude[i], test$latitude[i]))
  test$dis_gosan[i]= distGeo(gosan, c(test$longitude[i], test$latitude[i]))
  test$dis_seongsan[i]= distGeo(seongsan, c(test$longitude[i], test$latitude[i]))
  test$dis_po[i]= distGeo(po, c(test$longitude[i], test$latitude[i]))
  
}
b = cbind(test['dis_jeju'] ,test['dis_gosan'],test['dis_seongsan'] ,test['dis_po'])
test['dist_min'] = apply(b,1, min)
test['dis_name']=0
for(i in 1:nrow(test)){
  if(test$dis_jeju[i] == test$dist_min[i]){
    test$dis_name[i] = 1
  }else if(test$dis_gosan[i] == test$dist_min[i]){
    test$dis_name[i] = 2
  }else if(test$dis_po[i] == test$dist_min[i]){
    test$dis_name[i] = 3
  }else if(test$dis_seongsan[i] == test$dist_min[i]){
    test$dis_name[i] = 4
  }
}

# lm
tr <- train[c('X18.20_ride','in_out' ,'station_code','latitude','longitude','weekday','r810', 'r1012', 'r68', 't68', 't810','t1012','dis_name')]
te <- test[c('in_out' ,'station_code','latitude','longitude','weekday','r810', 'r1012', 'r68', 't68', 't810','t1012','dis_name')]
model_lm <- lm(X18.20_ride ~  ., data = tr)

install.packages('forecast')
library(forecast)
accuracy(model_lm)

# 랜덤포레스트
install.packages('randomForest')
library(randomForest)
forest_m <- randomForest(X18.20_ride ~ ., data=tr)
forest_m$predicted 
forest_m$importance
y_pred = predict(forest_m, te)

memory.size(max = TRUE)    # OS에서 얻은 최대 메모리 크기 = OS로부터 R이 사용 가능한 메모리
memory.size(max = FALSE)   # 현재 사용중인 메모리 크기
memory.limit(size = NA)    # 컴퓨터의 최대 메모리 한계치 

# 컴퓨터의 최대 메모리 한계치 약 49GB로 높이기
memory.limit(size = 50000)   




library(MASS)
?randomForest
#머신러닝
install.packages('reticulate')
library(reticulate)
py_config()
use_python('C:/Users/MEDICI/Anaconda3/envs/r-reticulate/python.exe')
sk <- import('sklearn.linear_model')
