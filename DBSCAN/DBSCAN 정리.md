
# DBSCAN

## DBSCAN(density-based spatial clustering of applications with noise)
### 유용한 군집 알고리즘(잡음을 활용한 밀도 기반 공간 군집분석)

#### 특징
1. 특성 공간에서 가까운 데이터가 많아 붐비는 지역의 포인트 찾는다.
2. 이 지역을 특성 공간의 **밀집 지역(dense region)**이라 한다.
3. 데이터의 밀집 지역이 한 클러스터를 구성하여 비교적 **비어있는 지역을 경계**로 타 클러스터와 구분한다.
4. 밀집 지역에 있는 포인트를 **핵심 샘플(포인트)** 로 말한다.

#### 핵심 샘플(or 핵심 포인트)
1. DBSCAN에 두 개의 매개변수 min_samples, eps 존재
2. 데이터 포인트에서 eps까지 거리 안에 기준
3. 데이터가 min_samples 개수만큼 있다 -> 이 데이터 포인트가 **핵심 샘플**로 분류
4. eps보다 가까운 핵심 샘플은 DBSCAN에 의해 동일한 클러스터로 합침
5. 거리 측정 방식은 metric 매개변수로 조절 가능, default는 유클리드 거리

#### 장점
1. 클러스터 개수(k)를 미리 지정할 필요가 없다.
2. 복잡한 형상도 찾는다.
3. 어떤 클래스에도 속하지 않는 포인트 구분이 가능하다.
4. 병합 군집이나 k-평균보다는 느리지만 큰 데이터셋에도 적용 가능하다.
 
 
 #### K-means vs. DBSCAN
 * Kmeans vs. DBSCAN: https://arogozhnikov.github.io/2017/07/10/opera-clustering.html
 
 1. 일반적인 K-means clustering
 ![clustering-kmeans-circles](https://user-images.githubusercontent.com/35090655/42416567-60ffc916-82ad-11e8-909e-dd6e5a3a9a7d.gif)
 
 2. Smile 모양의 데이터 포인트를 K-means로 군집
![clustering-kmeans-smiley2](https://user-images.githubusercontent.com/35090655/42416568-64345af2-82ad-11e8-9d57-7cc24e4c7020.gif)

**K-means clustering**의 경우 Smile 모양이라도 중심점을 찾고 중심점을 기준으로 군집하므로 복잡한 형상인 Smile 모양을 정확히 분류하기 어렵다.

3. Smile 모양의 데이터 포인트를 DBSCAN으로 군집
![clustering-dbscan-smiley3](https://user-images.githubusercontent.com/35090655/42416569-68a68588-82ad-11e8-966e-6234b46bdb9a.gif)

**DBSCAN**의 경우 noise를 활용하며 클러스터를 구분하는 동시에 핵심포인트를 찾고 계속해서 이웃한 모든 포인트를 탐색하여 군집하므로 복잡한 형상이라도 정확한 인식이 가능하다.


#### 알고리즘
1. 무작위로 포인트 선택
2. 포인트에서 eps 거리 안의 모든 포인트 찾기
3. eps 거리 안에 있는 포인트 수가 min_samples보다 적으면 그 포인트는 어느 클래스에도 속하지 않는 잡음noise로 명명한다.
4. eps 거리 안에 있는 포인트 수가 min_samples보다 많은 포인트가 있다면 그 포인트는 핵심 샘플로 명명하고 새로운 클러스터 레이블을 할당한다.
5. 그 포인트의 모든 이웃(eps 거리 내부) 탐색해서 어떤 클러스터에도 아직 할당되지 않으면 바로 전에 만든 클러스터 레이블을 할당.
6. 만약 핵심 샘플이면 그 포인트의 이웃을 차례로 방문.
7. 1~6 과정을 반복하여 클러스터는 eps 거리 안에 더 이상 핵심 샘플이 없을 때까지 자라난다. 아직 방문하지 못한 포인트를 선택하여 같은 과정 반복한다.

#### 포인트
1. 핵심 포인트
2. 경계 포인트(핵심 포인트에서 eps 거리 안에 있는 포인트)
3. 잡음 포인트

#### 포인트의 특징
1. DBSCAN을 한 데이터셋에 여러번 실행시 핵심 포인트의 군집은 항상 같고 매번 같은 포인트를 잡음으로 레이블한다.
2. 경계 포인트는 한 개 이상의 클러스터 핵심 샘플의 이웃일 수 있다.
3. 경계 포인트의 클러스터는 포인트 방문 순서에 따라 달라진다.
4. 경계 포인트는 많지 않으며 포인트 순서 때문에 받는 영향이 적어 중요하지 않다.


```python
%load_ext watermark
%watermark -v -p sklearn,numpy,scipy,matplotlib
```

    CPython 3.6.3
    IPython 6.1.0
    
    sklearn 0.19.1
    numpy 1.14.2
    scipy 0.19.1
    matplotlib 2.1.0



```python
from sklearn.cluster import DBSCAN
from sklearn.datasets import make_blobs
X, y = make_blobs(random_state=0, n_samples=12)

dbscan = DBSCAN()
clusters = dbscan.fit_predict(X)
print("클러스터 레이블:\n{}".format(clusters))
```

    클러스터 레이블:
    [-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1]


여기서는 모든 포인트에 잡음 포인트를 의미하는 -1 레이블 할당했다.
이는 작은 샘플 데이터셋에 적합하지 않은 eps, min_samples 기본값 때문이다.
여러가지 min_samples, eps에 대한 클러스터 할당을 해봅시다.


```python
mglearn.plots.plot_dbscan()
```

    min_samples: 2 eps: 1.000000  클러스터: [-1  0  0 -1  0 -1  1  1  0  1 -1 -1]
    min_samples: 2 eps: 1.500000  클러스터: [0 1 1 1 1 0 2 2 1 2 2 0]
    min_samples: 2 eps: 2.000000  클러스터: [0 1 1 1 1 0 0 0 1 0 0 0]
    min_samples: 2 eps: 3.000000  클러스터: [0 0 0 0 0 0 0 0 0 0 0 0]
    min_samples: 3 eps: 1.000000  클러스터: [-1  0  0 -1  0 -1  1  1  0  1 -1 -1]
    min_samples: 3 eps: 1.500000  클러스터: [0 1 1 1 1 0 2 2 1 2 2 0]
    min_samples: 3 eps: 2.000000  클러스터: [0 1 1 1 1 0 0 0 1 0 0 0]
    min_samples: 3 eps: 3.000000  클러스터: [0 0 0 0 0 0 0 0 0 0 0 0]
    min_samples: 5 eps: 1.000000  클러스터: [-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1]
    min_samples: 5 eps: 1.500000  클러스터: [-1  0  0  0  0 -1 -1 -1  0 -1 -1 -1]
    min_samples: 5 eps: 2.000000  클러스터: [-1  0  0  0  0 -1 -1 -1  0 -1 -1 -1]
    min_samples: 5 eps: 3.000000  클러스터: [0 0 0 0 0 0 0 0 0 0 0 0]

![output_10_2](https://user-images.githubusercontent.com/35090655/42120205-6b7eff1c-7c52-11e8-803b-54d1e585ce3b.png)



흰 점이 잡음 포인트입니다. eps가 커질수록 하나의 클러스터로 분류하는 경우가 많음을 알 수 있고, min_samples는 5일때 다른 클러스터의 개입이 없이(경계 포인트가 없이) 분류되는 과정을 볼 수 있습니다.


```python
from sklearn.datasets import make_moons
from sklearn.preprocessing import StandardScaler
X, y = make_moons(n_samples=200, noise=0.05, random_state=0)

# 평균이 0, 분산이 1이 되도록 데이터의 스케일을 조정합니다
scaler = StandardScaler()
scaler.fit(X)
X_scaled = scaler.transform(X)

dbscan = DBSCAN()
clusters = dbscan.fit_predict(X_scaled)
# 클러스터 할당을 표시합니다
plt.scatter(X_scaled[:, 0], X_scaled[:, 1], c=clusters, cmap=mglearn.cm2, s=60, edgecolors='black')
plt.xlabel("feature 0")
plt.ylabel("feature 1")
```




    Text(0,0.5,'feature 1')


![output_12_2](https://user-images.githubusercontent.com/35090655/42120180-d8c7aebc-7c51-11e8-9672-cc5c57a7ee32.png)


#### 군집 알고리즘의 비교와 평가
##### 타겟값으로 군집 평가하기


```python
from sklearn.metrics.cluster import adjusted_rand_score
from sklearn.cluster import KMeans
from sklearn.cluster import AgglomerativeClustering

X, y = make_moons(n_samples=200, noise=0.05, random_state=0)

# Rescale the data to zero mean and unit variance
scaler = StandardScaler()
scaler.fit(X)
X_scaled = scaler.transform(X)

fig, axes = plt.subplots(1, 4, figsize=(15, 3),
                         subplot_kw={'xticks': (), 'yticks': ()})

# make a list of algorithms to use
algorithms = [KMeans(n_clusters=2), AgglomerativeClustering(n_clusters=2),
              DBSCAN()]

# create a random cluster assignment for reference
random_state = np.random.RandomState(seed=0)
random_clusters = random_state.randint(low=0, high=2, size=len(X))

# plot random assignment
axes[0].scatter(X_scaled[:, 0], X_scaled[:, 1], c=random_clusters,
                cmap=mglearn.cm3, s=60)
axes[0].set_title("Random assignment - ARI: {:.2f}".format(
        adjusted_rand_score(y, random_clusters)))

for ax, algorithm in zip(axes[1:], algorithms):
    # plot the cluster assignments and cluster centers
    clusters = algorithm.fit_predict(X_scaled)
    ax.scatter(X_scaled[:, 0], X_scaled[:, 1], c=clusters,
               cmap=mglearn.cm3, s=60)
    ax.set_title("{} - ARI: {:.2f}".format(algorithm.__class__.__name__,
                                           adjusted_rand_score(y, clusters)))
```

![output_14_1](https://user-images.githubusercontent.com/35090655/42120182-dcf80e46-7c51-11e8-9cdb-bd2f15521d9d.png)


##### 타겟값 없이 군집 평가하기


```python
from sklearn.metrics.cluster import silhouette_score

X, y = make_moons(n_samples=200, noise=0.05, random_state=0)

# 평균이 0, 분산이 1이 되도록 데이터의 스케일을 조정합니다
scaler = StandardScaler()
scaler.fit(X)
X_scaled = scaler.transform(X)

fig, axes = plt.subplots(1, 4, figsize=(15, 3),
                         subplot_kw={'xticks': (), 'yticks': ()})

# 비교를 위해 무작위로 클러스터 할당을 합니다
random_state = np.random.RandomState(seed=0)
random_clusters = random_state.randint(low=0, high=2, size=len(X))

# 무작위 할당한 클러스터를 그립니다
axes[0].scatter(X_scaled[:, 0], X_scaled[:, 1], c=random_clusters,
                cmap=mglearn.cm3, s=60, edgecolors='black')
axes[0].set_title("Random assignment: {:.2f}".format(
        silhouette_score(X_scaled, random_clusters)))

algorithms = [KMeans(n_clusters=2), AgglomerativeClustering(n_clusters=2),
              DBSCAN()]

for ax, algorithm in zip(axes[1:], algorithms):
    clusters = algorithm.fit_predict(X_scaled)
    # 클러스터 할당과 클러스터 중심을 그립니다
    ax.scatter(X_scaled[:, 0], X_scaled[:, 1], c=clusters, cmap=mglearn.cm3,
               s=60, edgecolors='black')
    ax.set_title("{} : {:.2f}".format(algorithm.__class__.__name__,
                                      silhouette_score(X_scaled, clusters)))
```

![output_16_1](https://user-images.githubusercontent.com/35090655/42120184-e06fd8a6-7c51-11e8-8e4e-033a23fc4334.png)


