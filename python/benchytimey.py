from datetime import datetime, timezone
import time

N = 10000

print(f'Bench Python, {N} iters:')

def tic():
  return time.time()

def toc(t0):
  return time.time() - t0

fmt = '%-45s %.09f s'

# Current raw time in UTC, raw

t0 = tic()
for i in range(0, N):
  blah = time.time()
te = toc(t0)
print(fmt % ('current raw UTC time:', te/N))

# Current system time in local zone

t0 = tic()
for i in range(0, N):
  dt = datetime.now()
te = toc(t0)
print(fmt % ('current zoned local time:', te/N))

# Current system time in local zone

t0 = tic()
for i in range(0, N):
  dt = datetime.utcnow()
te = toc(t0)
print(fmt % ('current zoned UTC time:', te/N))

# UTC raw time to object

someRandomPosixTimestamp = int("-112060800")

t0 = tic()
for i in range(0, N):
  dt = datetime.utcfromtimestamp(someRandomPosixTimestamp)
te = toc(t0)
print(fmt % ('UTC raw time to object:', te/N))
