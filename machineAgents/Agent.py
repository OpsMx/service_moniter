import time
import subprocess

try:
 import potsdb
except:
  subprocess.call("pip install potsdb",shell=True)

checks = ["python /opt/agents/monitor/SystemCheck.py","python /opt/agents/monitor/NetworkCheck.py"]

if __name__ == "__main__":
     i = 4;	
     while True:
	procs = [subprocess.Popen(check, shell=True) for check in checks]		       			       	
        print "created subprocess" 
        #i = i-1
        time.sleep(4)