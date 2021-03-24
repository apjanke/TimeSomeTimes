classdef DateTimeBencher
  % Some basic datetime benchmarks
  %
  % Remember to call each method here a couple times, to omit function-load
  % times and warm up the JIT!
  %
  % Examples:
  %
  % DateTimeBencher.doIt
  
  %#ok<*MANU>
  %#ok<*CTPCT>
  %#ok<*NASGU>

  properties
    % Number of times to run each basic operation in a benchmark.
    numIters = 10000
    % Display format.
    fmt = '%-45s %s s\n';
    % Whether to display header in output.
    showHeader = true;
    % Sizes of datetime arrays to bench nonscalar ops on.
    arraySizes (1,:) double = [100 10000 30000]
    % Max array size to run datevec tests on
    maxArraySizeForDatevec = 10000;
  end
  
  methods (Static)
    
    function doIt
      dtb = DateTimeBencher;
      dtb.benchBasicDatetimeOps;
    end
    
  end
  
  methods
    
    function header(this)
      if ~this.showHeader
        return
      end
      fprintf('Bench Matlab under %s on %s, %d iters:\n', ...
        ['R' version('-release')], computer, this.numIters);            
    end
    
    function say(this, msg, etimePerIter)
      fprintf(this.fmt, msg, formatEtime(etimePerIter));
    end
    
    function benchAll(this)
      this.header;
      t = this;
      t.showHeader = false;
      t.benchBasicDatetimeOps;
      t.benchRawUtcToDatetimeUtc;
      t.benchDatevec;
      t.benchDumbPropertySetting;
    end
    
    function benchRawUtcToDatetimeUtc(this)
      this.header;
      N = this.numIters;
      someRandomDatenum = datenum(1966, 6, 14, 2, 3, 4);
      
      t0 = tic;
      for i = 1:N
        dt = datetime(someRandomDatenum, 'ConvertFrom', 'datenum');
        dt.TimeZone = 'UTC';
      end
      te = toc(t0);
      this.say('zoned UTC datetime from UTC datenum:', te/N);

      t0 = tic;
      dt = datetime(someRandomDatenum, 'ConvertFrom', 'datenum');
      for i = 1:N
        dt.TimeZone = 'UTC';
      end
      te = toc(t0);
      this.say('set unzoned datetime to UTC zone:', te/N);
      
    end
        
    function benchBasicDatetimeOps(this)
      % Benchmark some basic datetime ops and display results.
      N = this.numIters;
      this.header;
      
      % Current system time in local time, unzoned

      % datenum version
      t0 = tic;
      for i = 1:N
        x = now; 
      end
      te = toc(t0);
      this.say('current unzoned local time (datenum now):', te/N);
      
      % datetime version
      t0 = tic;
      for i = 1:N
        x = datetime; 
      end
      te = toc(t0);
      this.say('current unzoned local time (datetime):', te/N);
      
      % Current system time in local time, zoned

      % datenum version
      t0 = tic;
      for i = 1:N
        x = now; 
      end
      te = toc(t0);
      this.say('current zoned local time (datenum now):', te/N);
      
      % datetime version
      t0 = tic;
      for i = 1:N
        x = datetime('now', 'TimeZone', datetime.SystemTimeZone); 
      end
      te = toc(t0);
      this.say('current zoned local time (datetime):', te/N);
      
      % Current system time in UTC

      % datenum version: oh crap, how do we do this? Guess we have to drop
      % down to Java
      msecPerDay = 1000 * 60 * 60 * 24;
      unixEpochDatenum = datenum(1970, 1, 1);
      t0 = tic;
      for i = 1:N
        posixMillis = java.lang.System.currentTimeMillis;
        dnum = (double(posixMillis) / (msecPerDay)) + unixEpochDatenum; 
      end
      te = toc(t0);
      this.say('current zoned UTC time (datenum):', te/N);
      % Wow, this is actually really fast, compared to the datetime
      % version. Bummer!
      
      % datetime version
      t0 = tic;
      for i = 1:N
        x = datetime('now', 'TimeZone','UTC'); 
      end
      te = toc(t0);
      this.say('current zoned UTC time (datetime):', te/N);
      
      % Construct unzoned datetime object from raw time
      
      % datetime version
      dnum = now;
      t0 = tic;
      for i = 1:N
        x = datetime(dnum, 'ConvertFrom', 'datenum'); 
      end
      te = toc(t0);
      this.say('unzoned object from raw time (datetime):', te/N);

      % Construct zoned datetime object from raw UTC time
      
      % Just pretend this is the known UTC time we care about
      utcDatenum = datenum(1966, 6, 14, 2, 3, 4);
      
      % datetime version
      t0 = tic;
      for i = 1:N
        x = datetime(utcDatenum, 'ConvertFrom','datenum');
        x.TimeZone = 'UTC';
      end
      te = toc(t0);
      this.say('UTC raw time to object (datetime):', te/N);
      
      % datetime version 2
      t0 = tic;
      for i = 1:N
        x = datetime(utcDatenum, 'ConvertFrom','datenum', 'TimeZone','UTC'); 
      end
      te = toc(t0);
      this.say('UTC raw time to object (, ''TimeZone''):', te/N);
      
      % Construct zoned datetime object from raw local time
      
      localDatenum = datenum(1966, 6, 14, 2, 3, 4);
      systemTimeZone = datetime.SystemTimeZone;
      
      % datenum version - ehh, let's just skip it; datenum isn't zoned so
      % this isn't meaningful.
      
      % datetime version
      t0 = tic;
      for i = 1:N
        x = datetime(localDatenum, 'ConvertFrom','datenum');
        x.TimeZone = systemTimeZone;
      end
      te = toc(t0);
      this.say('local raw time to object (datetime):', te/N);
      
      % datetime version v2
      t0 = tic;
      for i = 1:N
        x = datetime(localDatenum, 'ConvertFrom','datenum', 'TimeZone',systemTimeZone);
      end
      te = toc(t0);
      this.say('local raw time to object (datetime v2):', te/N);
      
      % Zoned datetime object time zone "conversion"
      
      utcDt = datetime('now', 'TimeZone','UTC');
      targetTz = 'America/Chicago';
      
      % datetime version
      t0 = tic;
      for i = 1:N
        dt2 = utcDt;
        dt2.TimeZone = targetTz;
      end
      te = toc(t0);
      this.say('change time zone on zoned datetime:', te/N);
      
      % Note that an unzoned datetime is actually UTC
      
      unzonedDate = datetime;
      
      % datetime version
      t0 = tic;
      for i = 1:N
        utcDate = unzonedDate;
        utcDate.TimeZone = 'UTC';
      end
      te = toc(t0);
      this.say('say that unzoned datetime is UTC (datetime):', te/N);

      for k = this.arraySizes
        dnum = datenum(1966, 6, 14, 2, 3, 4);
        dnums = dnum + [1:k]; %#ok<NBRAK>
        
        dnum = now;
        t0 = tic;
        for i = 1:N
          x = datetime(dnums, 'ConvertFrom', 'datenum'); 
        end
        te = toc(t0);
        this.say(sprintf('unzoned object from raw time (k=%d):', k), te/N);
        fprintf('    per element: %s s\n', formatEtime(te/N/k));
      end
      
      for k = this.arraySizes
        dnum = datenum(1966, 6, 14, 2, 3, 4);
        dnums = dnum + [1:k]; %#ok<NBRAK>

        t0 = tic;
        for i = 1:N
          x = datetime(dnums, 'ConvertFrom','datenum', 'TimeZone','UTC'); 
        end
        te = toc(t0);
        this.say(sprintf('UTC raw time to object (k=%d) (ctor):', k), te/N);
        fprintf('    per element: %s s\n', formatEtime(te/N/k));
      end

      for k = this.arraySizes
        dnum = datenum(1966, 6, 14, 2, 3, 4);
        dnums = dnum + [1:k]; %#ok<NBRAK>
        dts = datetime(dnums, 'ConvertFrom', 'datenum');

        t0 = tic;
        for i = 1:N
          x = dts;
          x.TimeZone = 'UTC';
        end
        te = toc(t0);
        this.say(sprintf('set unzoned datetime to UTC zone (k=%d):', k), te/N);
        fprintf('    per element: %s s\n', formatEtime(te/N/k));
      end

      for k = this.arraySizes
        dnum = datenum(1966, 6, 14, 2, 3, 4);
        dnums = dnum + [1:k]; %#ok<NBRAK>
        dts = datetime(dnums, 'ConvertFrom', 'datenum');

        t0 = tic;
        for i = 1:N
          dt2 = dts;
          dt2.TimeZone = targetTz;
        end
        te = toc(t0);
        this.say(sprintf('set unzoned datetime to local zone (k=%d):', k), te/N);
        fprintf('    per element: %s s\n', formatEtime(te/N/k));
      end
      
    end
    
    function benchDatevec(this)
      N = this.numIters;
      this.header;
      
      dnum = datenum(1966, 6, 14, 2, 3, 4);
      dt = datetime(dnum, 'ConvertFrom', 'datenum');
      
      t0 = tic;
      for i = 1:N
        dv = datevec(dnum);
      end
      te = toc(t0);
      this.say('datevec (datenum):', te/N);
      
      t0 = tic;
      for i = 1:N
        dv = datevec(dt);
      end
      te = toc(t0);
      this.say('datevec (datetime):', te/N);
      
      arrSizes = this.arraySizes;
      arrSizes(arrSizes > this.maxArraySizeForDatevec) = [];
      for k = arrSizes
        dnums = dnum + [1:k]; %#ok<NBRAK>
        dts = datetime(dnums, 'ConvertFrom', 'datenum');

        t0 = tic;
        for i = 1:N
          dv = datevec(dnums);
        end
        te = toc(t0);
        this.say(sprintf('datevec (1-by-%d) (datenum):', k), te/N);
        fprintf('    per element: %s s\n', formatEtime(te/N/k));
        
        t0 = tic;
        for i = 1:N
          dv = datevec(dts);
        end
        te = toc(t0);
        this.say(sprintf('datevec (1-by-%d) (datetime):', k), te/N);
        fprintf('    per element: %s s\n', formatEtime(te/N/k));

      end
      
    end
    
    function benchDumbPropertySetting(this)
      N = this.numIters;
      this.header;

      t0 = tic;
      for i = 1:N
        obj = DumbClassWithOneProperty;
      end
      te = toc(t0);
      this.say('construct object (one prop):', te/N);    

      t0 = tic;
      for i = 1:N
        obj = SomeDumbClass;
      end
      te = toc(t0);
      this.say('construct object (larger):', te/N);    

      obj = SomeDumbClass;
      
      t0 = tic;
      for i = 1:N
        obj.foo = 42;
      end
      te = toc(t0);
      this.say('set property:', te/N);    
      
      t0 = tic;
      for i = 1:N
        obj.barWithSetter = 42;
      end
      te = toc(t0);
      this.say('set property with setter:', te/N);  
      
      t0 = tic;
      for i = 1:N
        obj.charProperty = 'foo';
      end
      te = toc(t0);
      this.say('set validated char property:', te/N);
      
      t0 = tic;
      for i = 1:N
        obj.charvecProperty = 'foo';
      end
      te = toc(t0);
      this.say('set validated charvec property:', te/N);      
    end
  
  end
  
end

function out = formatEtime(etime)
str = sprintf('%0.09f', etime);
ix = find(str == '.');
out = [str(1:ix-1) '.' str(ix+(1:3)) '_' str(ix+(4:6)) '_' str(ix+(7:9))];
end

