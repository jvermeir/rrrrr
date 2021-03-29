while true; do
  date
  /Library/Frameworks/R.framework/Resources/bin/Rscript test.R &> runLog.txt
  sleep 60*5
done
