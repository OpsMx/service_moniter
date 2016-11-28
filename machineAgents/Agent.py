import time
import subprocess

checks = ["python /opt/agents/monitor/SystemCheck.py","python /opt/agents/monitor/NetworkCheck.py"]

if __name__ == "__main__":
     while True:
	procs = [subprocess.Popen(['python', check]) for check in checks]
	#       procs = [subprocess.Popen(['svn', 'update', repo]) for repo in repos]		       	
        time.sleep(4)
