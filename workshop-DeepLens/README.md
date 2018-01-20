# AWS DeepLens기반 시각인식 ML
---

## 개요
AWS Reinvent 2017에서 발표한 AWS 딥렌즈를 이용하여 미리 만들어진 모델을 이용하여 실제로 객체를 인식하고 분류하는 것을 실습합니다.

이번 실습은 [실제로 Reivent2017에서 진행하였던 핸즈온](https://github.com/aws-samples/reinvent-2017-deeplens-workshop)을 기반으로 합니다.

## 순서

- 1. Face-Detection(Sample Project) 모델 
- 2. Squeezenet을 사용한 Mask 분류 모델 만들기


## 시작하기 전에 주의할 점

진행하는 AWS Console은 N.virginia 리전이어야 합니다.

현재 크롬 웹브라우져 외(ex. 파이어폭스)에는 정상적으로 작동하지 않는 경우를 발견하였습니다. 크롬 웹브라우져로 진행 부탁드립니다.




## 1. Face-Detection(Sample Project) 모델

- [AWS CLOUD 2018 DeepLens](https://www.slideshare.net/awskorea/utilizing-amazon-deeplens-and-computer-version-deep-learning-application-junghee-kang)
33Page부터 참조

- project templates에서 Object Detection이 아니라 Face Detection을 선택합니다.

[AWS 문서(DeepLens) - Sample Project](https://docs.aws.amazon.com/ko_kr/deeplens/latest/dg/deeplens-templated-projects-overview.html)

## 2. Squeezenet을 사용한 Mask 분류 모델 만들기

- AWS DeepLens가 기본으로 탑재하고 있는 Squeezenet 모델을 응용하여 Mask를 분류하도록 만들어 봅시다.

[Fine-tuning 문서](http://gluon.mxnet.io/chapter08_computer-vision/fine-tuning.html)

[Squeezenet 문서](https://arxiv.org/abs/1602.07360)

[Imagenet의 Label목록](https://gist.github.com/yrevar/942d3a0ac09ec9e5eb3a#file-imagenet1000_clsid_to_human-txt-L641)

- 2.1. AWS Lambda 함수 생성하기

1. Lambda 콘솔로 들어갑니다 : https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions

2. US East-1 (N.Virginia) 리전인지 확인합니다

3. Create function을 클릭합니다

4. Author from scratch을 클릭합니다.

5. function Name을 deeplens-hotdog-no-hotdog-your-full-name 으로 짓습니다. 이때 full name을 자신의 이름으로 넣습니다. (이때 deeplens-hotdog-not-hotdog 는 반드시 prefix이어야 합니다.) 

6. Choose an existing role 을 선택하여 deeplens_lambda role을 넣습니다. 

7. Create function을 클릭합니다.

- 2.2. AWS Lambda 함수 설정하기

1. Runtime을 python 2.7으로 바꿉니다.

2. handler box의 내용을 greengrassHelloWorld.function_handler 로 바꿉니다.  

3. code entry type을 'Upload a file from Amazon S3'로 바꾸고 다음의 링크를 s3 link로 붙여 넣습니다.

https://s3.amazonaws.com/deeplens-managed-resources/lambdas/hotdog-no-hotdog/new_hot_dog_lambda.zip

4. Save를 클릭하여 lambda를 저장합니다.


- 2.3. AWS Lambda 함수 수정하기



이를 위해서는 DBMS처럼 Athena에 database를 생성하고 table을 생성해야 한다.

Query Editor 항목에서 아래와 같은 쿼리를 입력하고 Run query를 한다.

```sql
# awskrug라는 database 생성
CREATE DATABASE IF NOT EXISTS awskrug
```

database를 생성하였다. 다음은 Athena가 이해할 수 있도록 CSV파일의 따른 table을 생성해주어야 한다.

```sql
# Catalog Manager로 생성
CREATE EXTERNAL TABLE IF NOT EXISTS awskrug.free_wifi_standard_data (
  `name` string,
  `detail` string,
  `city` string,
  `gungu` string,
  `facility` string,
  `service_provider` string,
  `wifi_ssid` string,
  `installed_at` DATE,
  `road_name_address` string,
  `parcel_address` string,
  `management_agency` string,
  `management_agency_phone` string,
  `latitude` float,
  `longitude` float,
  `created_at` DATE
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = ',',
  'field.delim' = ',',
  "serialization.encoding"='utf-8'
) LOCATION 's3://<USER_BUCKET_NAME>/csv/'
TBLPROPERTIES ('has_encrypted_data'='false');
```

제대로 생성했다면 아래와 같은 쿼리를 실행했을 때 결과가 나와야 한다.

```sql
SELECT * FROM awskrug.free_wifi_standard_data LIMIT 100;
```

## QuickSight - Athena 로 확인하기

1. QuickSight 열기
2. Manage Data 클릭
3. New Data Set 클릭
4. Athena를 데이터 소스로 선택
5. 데이터 소스명을 입력 awskrug
6. Create Data Source 클릭
7. awskrug database 를 선택
8. free_wifi_standard_data 테이블 선택

### 실행 결과
|![시도별 와이파이 설치](./img/count_by_city.png)   |![시도별 와이파이 서비스 제공업체](./img/count_by_service.png)|
|---|---|
| - 시도별 와이파이 설치| - 시도별 와이파이 서비스 제공업체|

상단의 Capture 버튼을 동해 스토리를 생성할 수 있다.

## QuickSight - uploaded file 로 확인하기

2. Manage Data 클릭
3. New Data Set 클릭
4. Upload a file 클릭
5. S3에 있는 CSV파일 다운로드 후 QuickSight에 업로드
6. 데이터 소스명을 입력 awskrug-upload
6. Create Data Source 클릭
7. Create Analysis로 전국무료와이파이표준데이터.csv 생성

이전과 같은 과정 반복하여 결과 확인

## 고찰
- Athena & 공공데이터 포털
  - 인코딩 문제
    - 공공데이터 포털에서 제공해주는 CSV파일이 EUC-KR로 되어 있었음
    - 별도로 EUC-KR에서 UTF-8로 수정하여 해결
    - 변환작업하는 OS가 Window일 경우 줄 시퀀스가 CRLF로 되어 있다면 LF로 바꾸어 저장할 것(Linux기반 OS와 Windows의 줄바꿈의 기준이 다르기 때문)
  - 공공데이터 포털의 대부분은 XML형식으로 이루어져 있기 때문에 만약 XML의 파일을 사용한다면 별도로 데이터 변환작업이 필요함
    - Python: [https://github.com/hay/xml2json](https://github.com/hay/xml2json)
    - Javascript: [https://github.com/Leonidas-from-XIV/node-xml2js](https://github.com/Leonidas-from-XIV/node-xml2js)
  - 공공데이터 포털의 데이터는 각 시군구 데이터의 형식이 다를 경우도 있기 때문에 전국적인 데이터로 사용하기 위해서는 전처리 작업이 필요함
- QuickSight
  - QuickSight 계정에서 Account Setting > Account Permissions > Edit AWS permissions에서 문제가 발생했을 경우
    - AWS IAM에서 이전에 생성된 IAM Role 및 policy(QuickSight로 검색)을 삭제해주면 정상적으로 다시 권한을 부여할 수 있음
  - 장점
    - 별도로 BI툴을 운영하거나 관리할 필요가 없음
    - 튜토리얼만 따라한다면 진입장벽이 높지 않음
    - Filter 기능을 통해 다양한 쿼리를 시각적으로 구현할 수 있음
    - 스토리로 저장할 수 있기 때문에 차트 관리에 유리
  - 단점
    - 한글화된 문서가 거의 존재하지 않음
    - 실제로 기업에서 사용한 사례가 많지 않기 때문에 도입하기가 쉽지 않음(보통은 Excel을 선호하기 때문에)
    - Suggested를 보면 추천되는 모형이 있지만 정규화가 제대로 되어있지 않은 데이터에 대해서는 쓸모가 없음(별도로 필터링이 필요)

- Cross-Region
  - S3-Athena는 다른 리전간에도 사용 가능. (현재 서울리전에서 가장 가까운 곳은 도쿄리전)
  - Athena-Quicksight는 같은 리전에서만 사용 가능.
  
  
## 사례 모음
- Athena
  - [https://aws.amazon.com/ko/blogs/korea/category/amazon-athena/](https://aws.amazon.com/ko/blogs/korea/category/amazon-athena/)
  - [https://aws.amazon.com/ko/blogs/korea/top-10-performance-tuning-tips-for-amazon-athena/](https://aws.amazon.com/ko/blogs/korea/top-10-performance-tuning-tips-for-amazon-athena/)

## 샘플
- Athena
  - [https://github.com/awskrug/athena-workshop](https://github.com/awskrug/athena-workshop)
- QuickSight
  - [https://aws.amazon.com/ko/blogs/aws/category/amazon-quicksight/](https://aws.amazon.com/ko/blogs/aws/category/amazon-quicksight/)


## References
- [https://prestodb.io/](https://prestodb.io/)
- [http://docs.aws.amazon.com/athena/latest/ug/json.html](http://docs.aws.amazon.com/athena/latest/ug/json.html)
- [https://aws.amazon.com/ko/blogs/korea/amazon-quicksight-fast-easy-to-use-business-intelligence-for-big-data-at-110th-the-cost-of-traditional-solutions/](https://aws.amazon.com/ko/blogs/korea/amazon-quicksight-fast-easy-to-use-business-intelligence-for-big-data-at-110th-the-cost-of-traditional-solutions/)
- [https://www.slideshare.net/awskorea/6-aws-bigdata-architecture-pattern-and-good-cases](https://www.slideshare.net/awskorea/6-aws-bigdata-architecture-pattern-and-good-cases)
