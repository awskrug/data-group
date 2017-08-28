# 공공데이터를 이용한 데이터 만들기부터 분석까지
---

## 개요
빅데이터를 직접 모으는 방법이 있지만, [공공데이터 포털](https://www.data.go.kr/)과 [네이버 데이터랩](http://datalab.naver.com/)처럼
정해진 API를 통해 접근하거나 데이터를 JSON, XML, CSV와 같은 형식으로 지원해주는 사이트들을 적극 활용해볼 수 있다.

이번에는 [공공데이터 포털](https://www.data.go.kr/)에서 예제를 통해 전국무료와이파이 표준데이터에 대해서 AWS Athena로 쿼리하는 것을 진행한다.
또한, 결과에 대해 BI도구인 AWS QuickSight로 시각화해서 확인한다.

## 서비스 소개

- AWS Athena
  - 표준 SQL을 사용해 Amazon S3에 저장된 데이터를 간편하게 분석할 수 있는 대화식 쿼리 서비스
  - 서버리스 서비스이므로 관리할 인프라가 없으며 실행한 쿼리에 대해서만 과금
  - Amazon S3에 저장된 데이터를 지정하고 스키마를 정의한 후 표준 SQL을 사용하여 쿼리
  - Athena에서는 데이터 분석을 준비하기 위한 복잡한 ETL(Extract, transform, load) 작업이 필요없음
  - ANSI SQL을 지원하는 [Presto](https://prestodb.io/)를 사용하며, CSV, JSON, ORC, Avro, Parquet 등 표준 데이터 형식과 호환됨
- AWS QuickSight
  - BI 도구
  - 데이터 소스 접근
    - 기존의 Redshift, RDS, Amazon Aurora, EMR, DynamoDB, Kinesis, S3 및 기존 파일도 가능하며 Salesforce 같은 서드파티에 저장된 데이터 접근 커넥터도 제공
  - 빠른 데이터 연산
    - 고속의 병렬 인메모리 최적화된 연산 엔진(Super-fast, Parallel, In-memory optimized Calculation Engine, SPICE)을 가지고 있으며, 클라우드 기반으로 더 빠른 상호 작용 기반으로 데이터 시각화를 위한 사용자 경험을 제공
  - 손 쉬운 사용법
    - AWS 데이터 소스를 자동으로 발견하고 손쉽게 연결
    - 테이블 및 항목을 선택하면 최적의 데이터 그래프 형태와 시각화 방법을 제공
    - 이렇게 만들어진 리포트를 친구들에게 공유하거나, 몇몇 다른 리포트와 합쳐서 데이터가 말하는 바를 전달 할 수 있으며, 웹사이트에 임베딩해서 출력 가능
  - 높은 확장성 지원 
    - 빠른 분석 및 시각화를 제공하는 데, 이를 위해 수백 및 수천 사용자와 기관별로 테라바이트 급 데이터를 높은 확장성을 기반으로 처리
  - 저비용 구조
    - 기존 온프레미스 환경의 1/10 비용 만으로 스마트한 BI를 구성
  - 파트너 지원
    - ODBC 커넥터를 지원하여 파트너사의 기존 BI 도구를 연결 가능
    - SQL을 통해 SPICE 엔진이 기존 도구를 지원할 수 있으며, Domo, Qlik, Tableau 및 Tibo 같은 파트너와 협력
  

## 공공데이터 포털에서 데이터 가져오기

공공데이터포털에 계정이 있다면 [전국무료와이파이 표준데이터](https://www.data.go.kr/dataset/15013116/standard.do)에서 CSV파일을 다운받고,
자신의 Bucket에 업로드하면 된다.

없다면 아래와 같은 명령어로 자신의 S3 bucket에 복사해와야 한다.

```bash
$ aws s3 cp s3://awskrug-novemberde s3://<USER_BUCKET_NAME> --recursive
```

버킷을 확인하면 아래와 같은 두 파일이 있을 것이다.

- 전국무료와이파이표준데이터.xls
- csv/전국무료와이파이표준데이터.csv

우리는 CSV파일을 통해 Athena로 쿼리를 던져 결과를 받아볼 것이다.


## Athena에서 테이블 생성하기
Athena에서 S3저장소에 있는 CSV파일에 대해서 쿼리하기 위해서는 파일 형식에 대해 Athena가 이해하고 있어야 가능하다.

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
) LOCATION 's3://awskrug-novemberde/csv/'
TBLPROPERTIES ('has_encrypted_data'='false');
```

제대로 생성했다면 아래와 같은 쿼리를 실행했을 때 결과가 나와야 한다.

```sql
SELECT * FROM awskrug.free_wifi_standard_data LIMIT 100;
```

## QuickSight로 확인하기


## 고찰
- 인코딩 문제
  - 공공데이터 포털에서 제공해주는 CSV파일이 EUC-KR로 되어 있었음
  - 별도로 EUC-KR에서 UTF-8로 수정하여 해결
  - 변환작업하는 OS가 Window일 경우 줄 시퀀스가 CRLF로 되어 있다면 LF로 바꾸어 저장할 것(Linux기반 OS와 Windows의 줄바꿈의 기준이 다르기 때문)

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