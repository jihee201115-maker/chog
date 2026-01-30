@echo off
echo GitHub에 배포 중입니다...
git add .
git commit -m "Restore main profile design and merge with SNS feed"
git push origin main
echo 배포가 완료되었습니다! 잠시 후 사이트에서 확인해보세요.
pause
