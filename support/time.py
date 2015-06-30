from datetime import timedelta

times = ['00:02:20','00:4:40']

def average(times): 
  print(str(timedelta(seconds=sum(map(lambda f: int(f[0])*3600 + int(f[1])*60 + int(f[2]), map(lambda f: f.split(':'), times)))/len(times))))

average(times)
