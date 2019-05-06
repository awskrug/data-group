#!/bin/bash
    
echo "============================== ADD NEW USER FOR ZEPPELIN =============================="

# 새로운 사용자 추가
sudo useradd -m ds_handson_20190509

# 새로운 사용자의 암호 설정
sudo passwd ds_handson_20190509

# 새로운 사용자의 HDFS 디렉토리 생성
hadoop fs -mkdir /user/ds_handson_20190509

# 새로운 사용자의 HDFS 디렉토리 권한 수정
hadoop fs -chmod 777 /user/ds_handson_20190509

echo "============================== INSTALL AND UPDATE PACKAGES =============================="

# 필요한 패키지 업데이트
sudo yum update -y
sudo yum install python36 -y
sudo yum install python36-setuptools -y
sudo yum install python36-pip -y

# 필요한 python3 패키지 설치
sudo python3 -m pip install --upgrade pip
sudo python3 -m pip install numpy==1.16.3
sudo python3 -m pip install scipy==1.2.1
sudo python3 -m pip install pytz==2019.1
sudo python3 -m pip install six==1.12.0
sudo python3 -m pip install python-dateutil==2.8.0
sudo python3 -m pip install pandas==0.24.2
sudo python3 -m pip install scikit-learn==0.20.3
sudo python3 -m pip install matplotlib==3.0.3
sudo python3 -m pip install boto3
sudo python3 -m pip install google-api-python-client
sudo python3 -m pip install oauth2client

echo "============================== SET PYSPARK CONF =============================="

# python3 버전 확인
python3 -c "import sys;print(sys.version)"

# echo 명령 수행을 위해 spark-env.sh 파일에 쓰기 권한 임시 부여
sudo chmod 666 /etc/spark/conf.dist/spark-env.sh

# spark-env.sh 파일에 공백 줄 추가
echo "" >> /etc/spark/conf.dist/spark-env.sh
echo "" >> /etc/spark/conf.dist/spark-env.sh

# spark-env.sh 파일에 PYSPARK_PYTHON=python3 옵션 추가
echo "export PYSPARK_PYTHON=python3" >> /etc/spark/conf.dist/spark-env.sh

# spark-env.sh 파일 권한 복원
sudo chmod 644 /etc/spark/conf.dist/spark-env.sh

# spark-env.sh 파일 실행
source /etc/spark/conf.dist/spark-env.sh

echo "============================== SET ZEPPELIN CONF =============================="

# 설정 변경 전, Zeppelin 종료
sudo stop zeppelin

# /etc/zeppelin/conf.dist/zeppelin-site.xml 파일 생성 (zeppelin-site.xml.template 파일 복사)
sudo cp /etc/zeppelin/conf.dist/zeppelin-site.xml.template /etc/zeppelin/conf.dist/zeppelin-site.xml

# zeppelin을 로그인 없이 사용할 수 없도록 설정 (/etc/zeppelin/conf.dist/zeppelin-site.xml 수정)
sudo perl -i~ -0pe 's/zeppelin.anonymous.allowed<\/name>\n\s\s<value>true/zeppelin.anonymous.allowed<\/name>\n  <value>false/g' /etc/zeppelin/conf.dist/zeppelin-site.xml

# zeppelin 출력 사이즈 제한 조정 (102400bytes -> 1024000bytes)
sudo perl -i~ -0pe 's/zeppelin.interpreter.output.limit<\/name>\n\s\s<value>102400/zeppelin.interpreter.output.limit<\/name>\n  <value>1024000/g' /etc/zeppelin/conf.dist/zeppelin-site.xml

# echo 명령 수행을 위해 zeppelin-site.xml 파일에 쓰기 권한 임시 부여 (644 -> 666)
sudo chmod 666 /etc/zeppelin/conf.dist/zeppelin-site.xml

# property 추가를 위한 </configuration> 태그 임시 제거
sudo perl -i~ -0pe 's/<\/configuration>//g' /etc/zeppelin/conf.dist/zeppelin-site.xml

# zeppelin-site.xml 파일에 공백 줄 추가
echo "" >> /etc/zeppelin/conf.dist/zeppelin-site.xml
echo "" >> /etc/zeppelin/conf.dist/zeppelin-site.xml

# cron 작업 설정이 가능하도록 zeppelin.notebook.cron.enable: true 속성 추가
echo "<property>" >> /etc/zeppelin/conf.dist/zeppelin-site.xml
echo "  <name>zeppelin.notebook.cron.enable</name>" >> /etc/zeppelin/conf.dist/zeppelin-site.xml
echo "  <value>true</value>" >> /etc/zeppelin/conf.dist/zeppelin-site.xml
echo "</property>" >> /etc/zeppelin/conf.dist/zeppelin-site.xml

# </configuration> 태그 추가
echo "" >> /etc/zeppelin/conf.dist/zeppelin-site.xml
echo "</configuration>" >> /etc/zeppelin/conf.dist/zeppelin-site.xml

# zeppelin-site.xml 권한 복원 (666 -> 644)
sudo chmod 644 /etc/zeppelin/conf.dist/zeppelin-site.xml

# /etc/zeppelin/conf.dist/shiro.ini 파일 생성 (shiro.ini.template 파일 복사)
sudo cp /etc/zeppelin/conf.dist/shiro.ini.template /etc/zeppelin/conf.dist/shiro.ini

# 로그인한 모든 zeppelin 이용자에게 interpreter 설정 및 재시작 권한 부여 (/etc/zeppelin/conf.dist/shiro.ini 수정)
sudo perl -pi -e 's/authc, roles\[admin\]/authc/g' /etc/zeppelin/conf.dist/shiro.ini

# 사용하지 않는 인증 요소 비활성화
sudo perl -pi -e 's/admin = password1, admin/#admin = password1, admin/g' /etc/zeppelin/conf.dist/shiro.ini
sudo perl -pi -e 's/user1 = password2, role1, role2/#user1 = password2, role1, role2/g' /etc/zeppelin/conf.dist/shiro.ini
sudo perl -pi -e 's/user2 = password3, role3/#user2 = password3, role3/g' /etc/zeppelin/conf.dist/shiro.ini
sudo perl -pi -e 's/user3 = password4, role2/#user3 = password4, role2/g' /etc/zeppelin/conf.dist/shiro.ini

# pam 기반 사용자 인증 활성화
sudo perl -pi -e 's/#pamRealm=org.apache.zeppelin.realm.PamRealm/pamRealm=org.apache.zeppelin.realm.PamRealm/g' /etc/zeppelin/conf.dist/shiro.ini
sudo perl -pi -e 's/#pamRealm.service=sshd/pamRealm.service=sshd/g' /etc/zeppelin/conf.dist/shiro.ini

# zeppelin에서 마스터 인스턴스의 사용자 암호를 확인할 수 있도록 /etc/shadow 파일에 읽기 권한 부여
sudo setfacl -m user:zeppelin:r /etc/shadow

echo "============================== SET ZEPPELIN INTERPRETER CONF =============================="

# /etc/zeppelin/conf.dist/interpreter.json 수정 (value: python인 값을 value: python3로 수정)
sudo perl -pi -e 's/"value": "python"/"value": "python3"/g' /etc/zeppelin/conf.dist/interpreter.json

# zeppelin.spark.uiWebUrl 제거하고, spark.yarn.executor.memoryOverhead 추가
sudo perl -i~ -0pe 's/"zeppelin.spark.uiWebUrl":\s{\n\s\s\s\s\s\s\s\s\s\s"name":\s"zeppelin.spark.uiWebUrl",\n\s\s\s\s\s\s\s\s\s\s"value":\s"",\n\s\s\s\s\s\s\s\s\s\s"type":\s"string"\n\s\s\s\s\s\s\s\s}/"spark.yarn.executor.memoryOverhead": {\n          "name": "spark.yarn.executor.memoryOverhead",\n          "value": "4096",\n          "type": "number"\n        }/g' /etc/zeppelin/conf.dist/interpreter.json

sudo start zeppelin

echo "============================== END OF JOB =============================="
