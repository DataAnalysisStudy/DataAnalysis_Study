---
title: "K-means"
output: html_document
---


# Clustering
군집화는 데이터를 클러스터(유사 아이템의 그룹)으로 자동 분리하는 자율(unsupervised) 머신 러닝 작업이다.
그룹이 어떻게 보이게 될지 사전에 듣지 못하고 군집화가 이루어지므로 예측보다는 지식의 발견에 사용된다.

# 머신 러닝 작업으로서 군집화
군집화는 작업이 자율 분류(unsupervised classification)으로 언급되기도 하는데 군집화는 레이블이 없는 예시를 분류하기 때문이다.

# K-means clustering
k 평균 군집 알고리즘은 n개의 데이터를 k개의 클러스터 중 하나에 할당한다. k는사전에 결정된 숫자이다.
목표는 클러스터 내의 차이를 최소화하고 클러스터 간 차이를 최대화하는 것이다. 그리고 지역 최적해를 찾는 휴리스틱 과정을 사용한다. 초기의 추정으로 부터 할당을 조금 수정하여 클러스터 내 동질성을 향상시키는 지를 확인한다.
(greedy algorithm과 유사)

# 절차
k개의 초기 클러스터 집합에 예시 데이터를 할당하고, 현재 클러스터에 분류된 예시 데이터에 따라 클러스터 경계를 조정하여 할당을 수정한다. 할당과 수정 과정은 변경이 더 이상 클러스터 적합도가 향상하지 못할 때까지 발생하고 중단되며 클러스터는 완성된다.

# 문제와 해결
k-평균 알고리즘은 클러스터 중심의 출발 위치에 매우 민감한데, 시작 조건을 약간 변경해도 최종 클러스터 집합 결과에 상당한 영향을 준다. 그래서 k-평균의 초기 중심을 선택하는 방법을 다르게 한다.

## 할당 단계
1. 각 예시 데이터를 클러스터에 임의로 할당하여 알고리즘 수정 단계로 바로 진행한다.
2. 초기 클러스터 중심을 선택하고 각 예시 데이터는 **거리 함수**에 따라 가장 가까운 클러스터 중심에 할당한다.
3. 거리 함수로 각 예시 데이터와 각 클러스터 중심 사이의 거리를 알아낸다.

### 거리 함수
k 평균은 전통적으로 유클리드 거리를 사용하고, 이외에 맨해튼 거리, 민코스키 거리도 사용한다.

```r
# 5번의 컴퓨터 과학 발표와 1번 수학 발표를 한 게스트와 0번 컴퓨터 과학 논문과 2번의 수학 논문을 쓴 게스트 비교한 유클리드 거리
sqrt((5-0)^2 + (1-2)^2)
```

```
## [1] 5.09902
```


## 수정 단계
1. 초기 중심을 **새로운 위치(중심점, centroid)**로 이동시키기
2. 중심점은 해당 클러스터에 현재 할당된 점들의 평균 위치로 계산
3. 클러스터 중심이 새로운 중심점으로 이동할 때 보로노이 다이어그램 경계 이동(일종의 결정 경계)
4. 재할당 및 재수정
5. 재할당이 일어나지 않는 경우 종료

## 최종 클러스터 보고
1. 각 예시에 대해 클러스터 할당을 간단히 보고(A,B,C 클러스터)
2. 최종 수정 후 클러스터 중심점의 좌표 보고
3. 이를 통해 중심점 계싼하거나 각 예시 데이터를 가장 가까운 클러스터에 할당하여 클러스터 경계 정의

## 적합한 클러스터 개수(k) 선택
k-평균은 클러스터 수에 매우 민감하다. k가 매우 크면 클러스터 동질성이 향상되고, 과적합 위험이 있다.
1. 실제 그룹에 대한 선험적(사전) 지식 기반
2. 경험 법칙으로 k를 (n/2)의 제곱근과 동일하게 설정
3. 엘보법, 실루엣 방법, gap statistics

# 예제: 10대 시장의 세분화

## 데이터 수집


```r
teens = read.csv('snsdata.csv')
```

```
## Warning in file(file, "rt"): cannot open file 'snsdata.csv': No such file
## or directory
```

```
## Error in file(file, "rt"): cannot open the connection
```

```r
str(teens)
```

```
## Error in str(teens): object 'teens' not found
```

### 결측값 제거

```r
table(teens$gender, useNA = 'ifany')
```

```
## Error in table(teens$gender, useNA = "ifany"): object 'teens' not found
```

```r
summary(teens$age)
```

```
## Error in summary(teens$age): object 'teens' not found
```
na는 총 5086개가 존재한다. 또한, 최대 최소도 상식적이지 않다. 3세나 106세는 고등학교 다니지 않는다.
이를 방지하고자 나이를 제한한다.


```r
teens$age = ifelse(teens$age >= 13 & teens$age < 20, teens$age, NA)
```

```
## Error in ifelse(teens$age >= 13 & teens$age < 20, teens$age, NA): object 'teens' not found
```

```r
summary(teens$age)
```

```
## Error in summary(teens$age): object 'teens' not found
```

## 결측치 더미 코딩


```r
teens$female = ifelse(teens$gender == 'F' & !is.na(teens$gender), 1, 0)
```

```
## Error in ifelse(teens$gender == "F" & !is.na(teens$gender), 1, 0): object 'teens' not found
```

```r
teens$no_gender = ifelse(is.na(teens$gender),1,0)
```

```
## Error in ifelse(is.na(teens$gender), 1, 0): object 'teens' not found
```

```r
table(teens$gender, useNA = "ifany")
```

```
## Error in table(teens$gender, useNA = "ifany"): object 'teens' not found
```

```r
table(teens$female, useNA = "ifany")
```

```
## Error in table(teens$female, useNA = "ifany"): object 'teens' not found
```

```r
table(teens$no_gender, useNA = "ifany")
```

```
## Error in table(teens$no_gender, useNA = "ifany"): object 'teens' not found
```

```r
aggregate(data = teens, age ~ gradyear, mean, na.rm = TRUE)
```

```
## Error in eval(m$data, parent.frame()): object 'teens' not found
```

```r
ave_age <- ave(teens$age, teens$gradyear, FUN = function(x) mean(x, na.rm = T))
```

```
## Error in interaction(...): object 'teens' not found
```

```r
teens$age = ifelse(is.na(teens$age), ave_age, teens$age)
```

```
## Error in ifelse(is.na(teens$age), ave_age, teens$age): object 'teens' not found
```

```r
summary(teens$age)
```

```
## Error in summary(teens$age): object 'teens' not found
```
결측치가 완전히 제거 되었다. 이제 데이터에 대해 모델 훈련시킨다.

## k-means clustering  in stats package

```r
library(stats)
# myclusters = kmeans(mydata, k)
# mydata는 군집화될 예시가 있는 행렬 혹은 데이터 프레임
# k는 희망 클러스터의 개수
# 이 함수는 클러스터에 대한 정보를 저장하는 클러스터 객체 반환

# mycluster$cluster 는 kmeans() 함수에서 얻은 클러스터의 할당된 벡터
# mycluster$centers 는 각 특징과 클러스터 조합별 평균값 나타내는 행렬
# myclusters$size 각 클러스터에 할당된 데이터 개수
```

36개 특징만을 이용한 데이터 프레임을 만들고 이를 기반으로 클러스터 분석을 시작한다.
분석할 때 거리 계산을 할 경우 일반적으로 분석 전에 **정규화, z-점수 표준화** 한다.


```r
interests = teens[5:40]
```

```
## Error in eval(expr, envir, enclos): object 'teens' not found
```

```r
interests_z = as.data.frame(lapply(interests, scale))
```

```
## Error in lapply(interests, scale): object 'interests' not found
```
lapply는 행렬로 반환하므로 이를 다시 데이터 프레임 형태로 강제 반환해야 한다.
마지막으로 클러스터의 희망 개수인 k를 결정해야 한다.

k-평균 알고리즘은 임의의 출발점을 사용하므로, 반복해서 같은 결과를 얻으려면 seed 값을 부여하라.


```r
set.seed(2345)
teen_clusters = kmeans(interests_z, 5)
```

```
## Error in as.matrix(x): object 'interests_z' not found
```

## 평가하기

모델의 성능을 평가해보자. 이 알고리즘이 10대의 관심사 데이터를 얼마나 잘 분리했는지 조사해서 확인한다.

```r
teen_clusters$size
```

```
## Error in eval(expr, envir, enclos): object 'teen_clusters' not found
```

여기서 5개 클러스터를 확인해보자. 가장 작은 클러스터는 600명의 10대이고, 가장 큰 클러스터는 21528명을 가진다. 각 클러스터의 격차가 조금 커서 우려되지만, 이 그룹들을 좀 더 신중하게 살펴보지 않으면 문제인지 모를 것이다.


```r
teen_clusters$centers
```

```
## Error in eval(expr, envir, enclos): object 'teen_clusters' not found
```
결과를 보면 cluster 1은 공주, cluster 3은 운동선수 그룹, cluster 4 는 범죄자 그룹임을 추측할 수 있다. cluster 5은 평범한 집단으로 전반적인 수준이 낮다.


```r
teens$cluster = teen_clusters$cluster
```

```
## Error in eval(expr, envir, enclos): object 'teen_clusters' not found
```

```r
teens[1:5, c("cluster","gender","age","friends")]
```

```
## Error in eval(expr, envir, enclos): object 'teens' not found
```

```r
aggregate(data = teens, age ~ cluster, mean)
```

```
## Error in eval(m$data, parent.frame()): object 'teens' not found
```

```r
aggregate(data = teens, female ~ cluster, mean)
```

```
## Error in eval(m$data, parent.frame()): object 'teens' not found
```

```r
aggregate(data = teens, friends ~ cluster, mean)
```

```
## Error in eval(m$data, parent.frame()): object 'teens' not found
```

인기있으면 친구도 많다. 

