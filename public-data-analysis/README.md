# 공공데이터를 이용한 데이터 만들기부터 분석까지
---
### 개요
---
빅데이터를 직접 모으는 방법이 있지만, [공공데이터 포털](https://www.data.go.kr/)과 [네이버 데이터랩](http://datalab.naver.com/)처럼
정해진 API를 통해 접근하거나 데이터를 JSON, XML, CSV와 같은 형식으로 지원해주는 사이트들을 적극 활용해볼 수 있다.

이번에는 [공공데이터 포털](https://www.data.go.kr/)에서 예제를 통해 전국무료와이파이 표준데이터에 대해서 AWS Athena로 쿼리하는 것을 진행한다.

---
### 공공데이터 포털에서 데이터 가져오기
---

공공포털에 계정이 있다면 [전국무료와이파이 표준데이터](https://www.data.go.kr/dataset/15013116/standard.do)에서 CSV파일을 다운받고,
자신의 Bucket에 업로드하면 된다.

없다면 아래와 같은 명령어로 자신의 S3 bucket에 복사해와야 한다.

```bash
$ aws s3 cp s3://awskrug-novemberde s3://<USER_BUCKET_NAME> --recursive
```

버킷을 확인하면 아래와 같은 두 파일이 있을 것이다.

- 전국무료와이파이표준데이터.xls
- 전국무료와이파이표준데이터.csv

우리는 CSV파일을 통해 Athena로 쿼리를 던져 결과를 받아볼 것이다.

---
### Athena에서 테이블 생성하기
---
Athena에서 S3저장소에 있는 CSV파일에 대해서 쿼리하기 위해서는 파일 형식에 대해 Athena가 이해하고 있어야 가능하다.

이를 위해서는 DBMS처럼 Athena에 database를 생성하고 table을 생성해야 한다.

Query Editor 항목에서 아래와 같은 쿼리를 입력하고 Run query를 한다.

```sql
# awskrug라는 database 생성
CREATE DATABASE IF NOT EXISTS awskrug
```

database를 생성하였다. 다음은 Athena가 이해할 수 있도록 CSV파일의 따른 table을 생성해주어야 한다.

```sql
# 됨. 하지만 encoding 깨짐
CREATE EXTERNAL TABLE IF NOT EXISTS free_wifi_standard_data (
  test string ) 
  ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
LOCATION 's3://awskrug-novemberde/csv';

# 안됨. Alter를 할 수 없는 건가? Queries of this type are not supported
ALTER TABLE awskrug.free_wifi_standard_data SET serdeproperties ('serialization.encoding'='UTF-8');

# 안됨. 같은현상.
CREATE EXTERNAL TABLE IF NOT EXISTS free_wifi_standard_data (
  test string ) 
  ROW FORMAT SERDE "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
   WITH SERDEPROPERTIES ( 
    "separatorChar" = ",", 
    "quoteChar" = "\"", 
    "escapeChar" = "\\", 
    "serialization.encoding"='utf-8',
    'store.charset'='utf-8',
    'retrieve.charset'='utf-8') 
LOCATION 's3://awskrug-novemberde/csv';
```