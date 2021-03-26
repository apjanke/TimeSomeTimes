from datetime import datetime, timezone
import time

N = 10000

print(f'Bench Python, {N} iters:')

def tic():
  return time.time()

def toc(t0):
  return time.time() - t0

def format_etime(te):
  st = '%.09f' % (te)
  ix = st.index('.')
  return st[0:ix] + '.' + st[ix+1:ix+4] + '_' + st[ix+4:ix+7] + '_' + st[ix+7:ix+10]

fmt = '%-45s %s s'

def say(msg, te):
  print(fmt % (msg + " (Python):", format_etime(te)))

# Current raw time in UTC, raw

t0 = tic()
for i in range(0, N):
  blah = time.time()
te = toc(t0)
say('current raw UTC time', te/N)

# Current system time in local zone

t0 = tic()
for i in range(0, N):
  dt = datetime.now()
te = toc(t0)
say('current zoned local time', te/N)

# Current system time in local zone

t0 = tic()
for i in range(0, N):
  dt = datetime.utcnow()
te = toc(t0)
say('current zoned UTC time', te/N)

# UTC raw time to object

someRandomPosixTimestamp = int("-112060800")

t0 = tic()
for i in range(0, N):
  dt = datetime.utcfromtimestamp(someRandomPosixTimestamp)
te = toc(t0)
say('UTC raw time to object', te/N)
