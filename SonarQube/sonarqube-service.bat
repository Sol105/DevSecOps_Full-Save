@echo off
chcp 65001 > nul

REM Store the original directory
set "ORIGINAL_DIR=%CD%"

echo SonarQube 서비스 배포 중...

REM Create namespace if it doesn't exist
kubectl create namespace devops 2>nul

REM Apply Kubernetes configurations
kubectl apply -f k8s/sonarqube-config.yaml
kubectl apply -f k8s/sonarqube-pv.yaml
kubectl apply -f k8s/sonarqube-service.yaml
kubectl apply -f k8s/sonarqube-deployment.yaml

echo.
echo SonarQube Pod 준비 상태 확인 중...
:wait_pod
for /f "tokens=1,2,3 delims= " %%a in ('kubectl get pods -l app^=sonarqube -n devops ^| findstr "sonarqube"') do (
    set "POD_NAME=%%a"
    set "READY=%%b"
    set "STATUS=%%c"
)
if "%STATUS%"=="Running" (
    goto :pod_ready
)
echo 현재 상태: %READY% 컨테이너 준비됨 ^| Pod 상태: %STATUS%
echo SonarQube 준비 중...
timeout /t 5 /nobreak > nul
goto :wait_pod

:pod_ready
echo.
echo SonarQube Pod가 준비되었습니다!

echo.
echo SonarQube 서비스가 배포되었습니다:
echo - NodePort 접속 주소: http://localhost:30900
echo - 기본 접속 계정: admin/admin
echo.
echo 초기화가 완료될 때까지 몇 분 정도 소요될 수 있습니다.

cd /d "%ORIGINAL_DIR%"