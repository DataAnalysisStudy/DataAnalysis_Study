
# GPS Plotting using R
R을 활용하여 GPS Data(Latitude, Longitude)를 Google Map에 Dot Plot을 활용하여 Mapping하는 작업 

## Dataset
> Student Life Dataset: Dartmouth Univ.에서 학생들의 생활을 다양한(Sensor, EMA, Survey 등) 형태로 수집한 데이터 

1. Link: http://studentlife.cs.dartmouth.edu/dataset.html
2. Paper: http://ksuweb.kennesaw.edu/~she4/2015Summer/cs7860/Reading/318p3-wang.pdf

 
## Library
> ggplot2, ggmap 활용 (plotly 및 shiny 적용  찾는중)
1. ggplot2: https://ggplot2.tidyverse.org/index.html
2. ggmap: https://github.com/dkahle/ggmap
 
## 특이사항
> Dataset 및 GPS Plotting 과정에서 발생한 특이사항(참고사항)

### Dataset
 1. GPS Data(Latitude, Longitude) 활용
 2. Timestamp를 Date로 변경 (timezone: Eastern Time Zone)
 3. 학생 1명(gps_u00.csv)에게만 예시로 적용

### Plotting
GPS plotting 하면서 5가지 지역을 이동한 것 확인 (5개 GPS Plot 생성)
 1. Main Area: Boston
 2. Sub Area 1(Europe): Paris, London, Venezia
 3. Sub Area 2(America): Washington


## Result

### [1] Main Area: Boston
 
#### Dataset Preprocessing
 1. Timestamp를 Date 형태로 변경
 2. subData(Europe, America) 구분 및 boston data 추출
```
library(ggplot2)
library(ggmap)

gpsData <- read.csv("gps_u00.csv", header = TRUE)
gpsData[,'date'] <- as.Date(as.POSIXct(gpsData$time, tz="EST", origin="1970-01-01")) # timestamp to date 변경

subEurope <- which(gpsData$longitude>-70) # Europe data 구분
subAmerica <- which(gpsData$latitude<40) # Boston 제외한 나머지 Amrica data 구분

boston <- gpsData[-append(subEurope, subAmerica),]
bostonLabel <- boston[c(1,nrow(boston)),] # Boston Data 시작과 끝 지점 추출

nudgeX <- (max(boston$longitude) - min(boston$longitude))*0.1 # 지도 라벨링과 실제 spot 사이의 간격 조절
nudgeY <- (max(boston$latitude) - min(boston$latitude))*0.1 # 지도 라벨링과 실제 spot 사이의 간격 조절
```

#### Google Map Setting
 1. 지도 중심(center), 확대 정도(zoom), 지도 형태(maptype) 설정
```
mapImageData <- get_googlemap(
  center = c(lon = (min(boston$longitude) + nudgeX*5), lat = (min(boston$latitude) + nudgeY*5)), # 지도 중심 지점 설정(최대, 최소의 중간)
  zoom = 8, # 확대 정도 설정(3 ~ 21). 
  maptype = c("roadmap") # 지도 형태 설정("terrain", "satellite", "roadmap", and "hybrid")
) 
```

#### Plotting
 1. ggmap에 ggplot을 붙이는 형태로 진행
 2. plot 결과 저장
```
bostonPlot <- ggmap(mapImageData) + 
              geom_point(aes(x = boston$longitude, y = boston$latitude, color=boston$time), 
                         data=boston, size = 3, pch = 20) + 
              ggtitle(paste0("Boston GPS Plot\n", bostonLabel$date[1], " ~ ", bostonLabel$date[2])) + # 타이틀 명칭
              labs(x = "Longitude(경도)", y = "Latitude(위도)") + # x, y축 명칭 설정
              geom_label(aes(x=bostonLabel$longitude, y=bostonLabel$latitude, label = c("S", "E")), 
                         data=bostonLabel, nudge_x = nudgeX, nudge_y = nudgeY) + # 시작과 끝 포인트 라벨 설정
              theme(legend.position = "none", # 범례 제거
                    plot.title = element_text(family = "serif", face = "bold", hjust = 0.5, size = 13, color = "darkblue")) + # 타이틀 설정
              scale_color_gradient(low = "black", high = "red") # dot plot 색상 설정
  
ggsave("180722_Boston_Plot.png", plot = bostonPlot,  dpi = 600) # plot 저장
```

![Boston Plot Result]

[Boston Plot Result]: 180728_Boston_Plot.png


### [2] Sub Area: Europe
#### [2-1] London Plotting

```
europe <- gpsData[subEurope,] # Europe data 추출

london <- europe[which(europe$latitude>50),]
londonLabel <- london[c(1,nrow(london)),]

nudgeX <- (max(london$longitude) - min(london$longitude))*0.1
nudgeY <- (max(london$latitude) - min(london$latitude))*0.1

mapImageData <- get_googlemap(
  center = c(lon = (min(london$longitude) + nudgeX*5), lat = (min(london$latitude) + nudgeY*5)),
  zoom = 10, 
  maptype = c("roadmap")
)

londonPlot <- ggmap(mapImageData) + 
              geom_point(aes(x = london$longitude, y = london$latitude, color=london$time), 
                        data=london, size = 5, pch = 20) + 
              ggtitle(paste0("London GPS Plot\n", londonLabel$date[1], " ~ ", londonLabel$date[2])) +
              labs(x = "Longitude(경도)", y = "Latitude(위도)", color = "Date") +
              geom_label(aes(x=londonLabel$longitude, y=londonLabel$latitude, label = c("S", "E")), 
                         data=londonLabel, nudge_x = nudgeX, nudge_y = nudgeY) +
              theme(legend.position = "none", 
                    plot.title = element_text(family = "serif", face = "bold", hjust = 0.5, size = 13, color = "darkblue")) +
              scale_color_gradient(low = "black", high = "red")

ggsave("180728_London_Plot.png", plot = londonPlot,  dpi = 600)
```

![London Plot Result]

[London Plot Result]: 180728_London_Plot.png


#### [2-2] Paris Plotting

```
europeSub <- europe[which(europe$latitude<50),]

paris <- europeSub[which(europeSub$latitude>48),]
parisLabel <- paris[c(1,nrow(paris)),]

nudgeX <- (max(paris$longitude) - min(paris$longitude))*0.1
nudgeY <- (max(paris$latitude) - min(paris$latitude))*0.1

mapImageData <- get_googlemap(
  center = c(lon = (min(paris$longitude) + nudgeX*5), lat = (min(paris$latitude) + nudgeY*5)),
  zoom = 11,
  maptype = c("roadmap")
)

parisPlot <- ggmap(mapImageData) + 
             geom_point(aes(x = paris$longitude, y = paris$latitude, color=paris$time), 
                        data=paris, size = 5, pch = 20) + 
             ggtitle(paste0("Paris GPS Plot\n", parisLabel$date[1], " ~ ", parisLabel$date[2])) +
             labs(x = "Longitude(경도)", y = "Latitude(위도)", color = "Date") +
             geom_label(aes(x=parisLabel$longitude, y=parisLabel$latitude, label = c("S", "E")), 
                        data=parisLabel, nudge_x = nudgeX, nudge_y = nudgeY) +
             theme(legend.position = "none", 
                   plot.title = element_text(family = "serif", face = "bold", hjust = 0.5, size = 13, color = "darkblue")) +
             scale_color_gradient(low = "black", high = "red")

ggsave("180728_Paris_Plot.png", plot = parisPlot,  dpi = 600)
```

![Paris Plot Result]

[Paris Plot Result]: 180728_Paris_Plot.png


#### [2-3] Venezia Plotting

```
venezia <- europeSub[which(europeSub$latitude<48),]
veneziaLabel <- venezia[c(1,nrow(venezia)),]

nudgeX <- (max(venezia$longitude) - min(venezia$longitude))*0.1
nudgeY <- (max(venezia$latitude) - min(venezia$latitude))*0.1

mapImageData <- get_googlemap(
  center = c(lon = (min(venezia$longitude) + nudgeX*5), lat = (min(venezia$latitude) + nudgeY*5)),
  zoom = 13,
  maptype = c("roadmap")
)

veneziaPlot <- ggmap(mapImageData) + 
               geom_point(aes(x = venezia$longitude, y = venezia$latitude, color=venezia$time), 
                          data=venezia, size = 5, pch = 20) + 
               ggtitle(paste0("Venezia GPS Plot\n", veneziaLabel$date[1], " ~ ", veneziaLabel$date[2])) +
               labs(x = "Longitude(경도)", y = "Latitude(위도)", color = "Date") +
               geom_label(aes(x=veneziaLabel$longitude, y=veneziaLabel$latitude, label = c("S", "E")), 
                          data=veneziaLabel, nudge_x = nudgeX, nudge_y = nudgeY) +
               theme(legend.position = "none", 
                     plot.title = element_text(family = "serif", face = "bold", hjust = 0.5, size = 13, color = "darkblue")) +
               scale_color_gradient(low = "black", high = "red")

ggsave("180728_Venezia_Plot.png", plot = veneziaPlot,  dpi = 600)
```

![Venezia Plot Result]

[Venezia Plot Result]: 180728_Venezia_Plot.png



### [3] Sub Area: America Other Area
#### [3-1] Washington Plotting

```
washington <- gpsData[subAmerica,]
washingtonLabel <- washington[c(1,nrow(washington)),]

nudgeX <- (max(washington$longitude) - min(washington$longitude))*0.1
nudgeY <- (max(washington$latitude) - min(washington$latitude))*0.1

mapImageData <- get_googlemap(
  center = c(lon = (min(washington$longitude) + nudgeX*5), lat = (min(washington$latitude) + nudgeY*5)),
  zoom = 12,
  maptype = c("roadmap")
)

washingtonPlot <- ggmap(mapImageData) + 
                  geom_point(aes(x = washington$longitude, y = washington$latitude, color=washington$time), 
                             data=washington, size = 5, pch = 20) + 
                  ggtitle(paste0("Washington GPS Plot\n", washingtonLabel$date[1], " ~ ", washingtonLabel$date[2])) +
                  labs(x = "Longitude(경도)", y = "Latitude(위도)", color = "Date") +
                  geom_label(aes(x=washingtonLabel$longitude, y=washingtonLabel$latitude, label = c("S", "E")), 
                             data=washingtonLabel, nudge_x = nudgeX, nudge_y = nudgeY) +
                  theme(legend.position = "none", 
                        plot.title = element_text(family = "serif", face = "bold", hjust = 0.5, size = 13, color = "darkblue")) +
                  scale_color_gradient(low = "black", high = "red")

ggsave("180728_Washington_Plot.png", plot = washingtonPlot,  dpi = 600)
```

![Washington Plot Result]

[Washington Plot Result]: 180728_Washington_Plot.png
