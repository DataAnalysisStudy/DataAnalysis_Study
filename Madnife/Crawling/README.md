
# Web Crawling in R
R을 활용하여 Web에 있는 다양한 데이터를 크롤링하는 코드 모음


## Naver News Header Crawling
> 네이버 뉴스 헤더를 크롤링하는 코드로 세부내용은 블로그(http://nife0719.blog.me/220982416637) 참고

1. 네이버 랭킹 뉴스 中 많이 본 뉴스의 각 카테고리별 Top 5 헤드라인 내용 수집
 
2. 네이버 언론사 뉴스 中 신문게재 기사의 A1면 헤드라인 내용 수집

#### [1] 네이버 랭킹 뉴스 헤드라인 크롤링 
> ※ 사이트: https://news.naver.com/main/ranking/popularDay.nhn?mid=etc&sid1=111&date=20180811
```
library(rvest)
library(stringr)

urlNews <- "http://news.naver.com/main/ranking/popularDay.nhn?mid=etc&sid1=111&date=20180804"   # 웹 스크래핑을 할 url을 입력합니다.
newsData <- read_html(urlNews)   # 입력된 url에서 html을 읽어옵니다.

sectionName <- c("Policy","Economy","Society","Life","World","IT")   # 카테고리 명칭 작성
newsHead <- data.frame(head_1=c(1:6), head_2=NA, head_3=NA, head_4=NA, head_5=NA)   # 헤드라인 5개를 각 카테고리 별로 입력하는 데이터 프레임을 만듭니다.
rownames(newsHead) <- sectionName   # row name을 카테고리 명칭으로 변경 (추출하는 csv에서 첫 번째 열에 나타납니다.)

for(i in 1:(ncol(newsHead))){   # 1~5면의 헤드에 대한 for문입니다.
  findNum <- paste0('.num',i)   # 헤드라인 마다 번호가 다르므로 번호를 바꿀 수 있도록 합니다. 
  nodeValue <- html_nodes(newsData, findNum)   # i가 1일 경우, num1에 해당하는 노드를 찾아냅니다. 
  
  for(j in 1:nrow(newsHead)){   # 정치 ~ IT/과학까지의 카테고리에 대한 for문입니다.
    extractHead <- gsub("\t","",nodeValue[j] %>% html_text()) %>% strsplit("\n")  # j 번째 노드에서 text를 추출한 후에 탭(\t)을 제거한 후 \n으로 구분합니다.
    trimHead <- trimws(extractHead[[1]]) # 글자 앞뒤의 빈 공간을 없애줍니다.
    selectHead <- trimHead[-which(trimHead=="")]   # 공란으로 된 character를 제외한 나머지를 추출합니다.
    if(selectHead[1]=="동영상기사"){ # 가끔 동영상 기사의 경우, 헤드 보다 앞에 표시가 되어 구분하여 헤드를 추출합니다.
      newsHead[j,i] <- selectHead[2]
    }else{
      newsHead[j,i] <- selectHead[1]  
    }
  }
}
```


#### [2] 언론사 뉴스 A1 헤드라인 크롤링
> ※ 사이트: https://news.naver.com/main/list.nhn?mode=LPOD&mid=sec&oid=023&listType=paper&date=20180811
```
oidList <- read.csv("paper_oid.csv", header = TRUE, colClasses = c("character", "character", "character"))   # 저장해놓은 oid가 포함된 csv를 읽어들입니다. oid를 숫자로 읽으면 앞에 0이 사라지므로 colClasses를 통해 column의 타입을 character로 읽어들입니다.
newsTop <- data.frame(Paper=oidList$Paper, A1_Top=NA)   # 언론사별로 1면의 헤드라인을 저장할 데이터 프레임을 만듭니다.

for(i in 1:nrow(newsTop)){
  urlNews <- paste0("http://news.naver.com/main/list.nhn?oid=",oidList$oid[i],"&listType=paper&mid=sec&mode=LPOD&date=20180803")   # 웹 스크래핑을 할 url을 입력합니다.
  newsData <- read_html(urlNews)   # 입력된 url에서 html을 읽어옵니다.
  firstList <- html_nodes(newsData, '.type13.firstlist')   # "type13 firstlist"에 해당하는 노드를 찾아냅니다. 
  topText <- firstList[1] %>% html_text()  # 첫 번째 노드에서 text를 추출합니다.
  topText <- gsub("\t","",topText)   # text의 탭(\t)을 제거합니다.
  topText <- gsub(" ","",topText)   # text의 공란을 제거합니다.
  topTextSplit <- trimws(strsplit(topText, "\n")[[1]])   # text를 엔터(\n)로 잘라냅니다. list로 반환됩니다. vector로 바꾸기 위해 [[1]]을 뒤에 붙여줍니다.
  topTextSplit <- topTextSplit[-which(topTextSplit=="")]   # 공란으로 된 character를 제외한 나머지를 추출합니다.
  newsTop[i,'A1_Top'] <- topTextSplit[1]   # vector의 첫 번째에 헤드라인이 들어있습니다. 이를 앞서 설정한 데이터 프레임에 넣어줍니다.
}

write.csv(newsTop,"newsA1Top.csv")   # csv 파일로 저장합니다. 디렉토리 설정을 안하면 문서 폴더 내에 저장됩니다.
```
<br>

## Google PlayStore Review Crawling
> 구글 플레이스토어의 리뷰를 크롤링하는 코드로 세부내용은 블로그(http://nife0719.blog.me/221329685115) 참고

#### [1] 앱 리뷰 크롤링
> 예시로 STEPS 앱 리뷰 크롤링을 진행
> ※ 사이트: https://play.google.com/store/apps/details?id=plus.steps.sapp&showAllReviews=true
```
library(rvest)
library(RSelenium)
library(httr)
library(stringr)

ch=wdman::chrome(port=4567L) #크롬드라이버를 포트 4567번에 배정
remDr=remoteDriver(port=4567L, browserName='chrome') #remort설정
remDr$open() #크롬 Open
remDr$navigate("https://play.google.com/store/apps/details?id=plus.steps.sapp&showAllReviews=true") #설정 URL로 이동

webElem <- remDr$findElement("css", "body")
webElem$sendKeysToElement(list(key = "end")) #화면 제일 하단으로 이동 

flag <- TRUE
endCnt <- 0

while (flag) {
  Sys.sleep(10)
  webElemButton <- remDr$findElements(using = 'css selector',value = '.ZFr60d.CeoRYc') #더보기 버튼 찾기
  
  if(length(webElemButton)==1){
    endCnt <- 0 #cnt 초기화
    webElem$sendKeysToElement(list(key = "home")) #화면 제일 상단으로 이동 
    webElemButton <- remDr$findElements(using = 'css selector',value = '.ZFr60d.CeoRYc') #더보기 버튼 찾기
    remDr$mouseMoveToLocation(webElement = webElemButton[[1]]) #해당 버튼으로 포인터 이동
    remDr$click() #버튼 클릭
    webElem$sendKeysToElement(list(key = "end")) #화면 제일 하단으로 이동
  }else{
    if(endCnt>3){
      flag <- FALSE #종료 플래그 활성화
    }else{
      endCnt <- endCnt + 1
    }
  }
}

frontPage <- remDr$getPageSource() #페이지 전체 소스 가져오기
reviewNames <- read_html(frontPage[[1]]) %>% html_nodes('.bAhLNe.kx8XBd') %>% html_nodes('.X43Kjb') %>%  html_text() #페이지 전체 소스에서 리뷰 정보(이름, 날짜) 부분 추출하기 
reviewDates <- read_html(frontPage[[1]]) %>% html_nodes('.bAhLNe.kx8XBd') %>% html_nodes('.p2TkOb') %>%  html_text() #페이지 전체 소스에서 리뷰 정보(이름, 날짜) 부분 추출하기 
reviewComments <- read_html(frontPage[[1]]) %>% html_nodes('.UD7Dzf') %>%  html_text() #페이지 전체 소스에서 리뷰 정보(이름, 날짜) 부분 추출하기 
reviewData <- data.frame(name=reviewNames, date=reviewDates, comment=reviewComments)

write.csv(reviewData, paste0("stepsAppReview(",nrow(reviewData),").csv"))

remDr$close()
```
 
<br>

## Melon Chart & Lyrics Crawling
> 멜론 차트 및 가사 크롤링 코드로 세부내용은 블로그(http://nife0719.blog.me/221329685115) 참고

#### [1] 멜론 Top 100 차트 리스트 크롤링 
> ※ 사이트: http://www.melon.com/chart/index.htm
```
library(rvest)
library(RSelenium)
library(httr)
library(stringr)

ch=wdman::chrome(port=4567L) #크롬드라이버를 포트 4567번에 배정
remDr=remoteDriver(port=4567L, browserName='chrome') #remort설정
remDr$open() #크롬 Open
remDr$navigate("http://www.melon.com/chart/index.htm") #설정 URL로 이동
frontPage <- remDr$getPageSource() #페이지 전체 소스 가져오기
remDr$close() #크롬 Close

songNames <- read_html(frontPage[[1]]) %>% html_nodes('.ellipsis.rank01') %>% html_text() #노래 이름 부분 추출하기 
songNames <- gsub("\t","",songNames[c(2:101)]) #노이즈 글자 제거  
songNames <- gsub("\n","",songNames) #노이즈 글자 제거 

songSingers <- read_html(frontPage[[1]]) %>% html_nodes('.ellipsis.rank02') %>% html_text() #가수 이름 부분 추출하기 
songSingers <- gsub("\t","",songSingers[c(2:101)]) #노이즈 글자 제거 
songSingers <- gsub("\n","",songSingers) #노이즈 글자 제거 
songSingers <- substring(songSingers,1,nchar(songSingers)/2) #글자가 2개씩 수집되서 앞의 1개만 잘라서 가져오기  

#노래 번호가 할당되어 있어서 url로 접근이 가능함. 노래 번호만 가져오면 됨
songNums<- read_html(frontPage[[1]]) %>% html_nodes('.btn.button_icons.type03.song_info') %>% html_attr('href') #노래 번호 부분 추출하기
songNums <- gsub("javascript:melon.link.goSongDetail\\('","",songNums[c(2:101)]) #노이즈 글자 제거 
songNums <- gsub("'\\);","",songNums) #노이즈 글자 제거 

melonResult <- data.frame(Song=songNames, Singer=songSingers, Url=paste0("https://www.melon.com/song/detail.htm?songId=", songNums))
```

#### [2] 멜론 노래 가사 크롤링
> 위의 [1]에서 수집한 Top 100 리스트의 모든 가사 수집 (1번 코드 우선 실행 필수) 
> ※ 예시 가사(레드벨벳의 Power Up) 사이트: https://www.melon.com/song/detail.htm?songId=31230093
```
ch=wdman::chrome(port=4567L) #크롬드라이버를 포트 4567번에 배정
remDr=remoteDriver(port=4567L, browserName='chrome') #remort설정
remDr$open() #크롬 Open

for(i in 1:100){
  remDr$navigate(melonResult$Url[i]) #설정 URL로 이동
  frontPage <- remDr$getPageSource() #페이지 전체 소스 가져오기
  
  songLyrics <- read_html(frontPage[[1]]) %>% html_nodes('.wrap_lyric') %>% html_text() #노래 이름 부분 추출하기 
  songLyrics <- gsub("\t","",songLyrics) #노이즈 글자 제거  
  songLyrics <- gsub("\n","",songLyrics) #노이즈 글자 제거 
  
  melonResult[i,'Lyric'] <- songLyrics
}

remDr$close() #크롬 Close
```
 
 
 
 
 
 
 
