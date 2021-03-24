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

  properties
    % Number of times to run each basic operation in a benchmark.
    numIters = 10000
    % Display format
    fmt = '%-45s %.09f s\n';
  end
  
  methods (Static)
    
    function doIt
      dtb = DateTimeBencher;
      dtb.benchBasicDatetimeOps;
    end
    
  end
  
  methods
    
    function header(this)
      fprintf('Bench Matlab under %s on %s, %d iters:\n', ...
        ['R' version('-release')], computer, N);            
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
      fprintf(this.fmt, 'zoned UTC datetime from UTC datenum:', te/N);

      t0 = tic;
      dt = datetime(someRandomDatenum, 'ConvertFrom', 'datenum');
      for i = 1:N
        dt.TimeZone = 'UTC';
      end
      te = toc(t0);
      fprintf(this.fmt, 'set unzoned datetime to UTC zone:', te/N);
      
    end
        
    function benchBasicDatetimeOps(this)
      % Benchmark some basic datetime ops and display results.
      N = this.numIters;
      this.header;
      
      % Current system time in local time, unzoned

      % datenum version
      t0 = tic;
      for i = 1:N
        x = now; %#ok<NASGU>
      end
      te = toc(t0);
      fprintf(this.fmt, 'current unzoned local time (datenum now):', te/N);
      
      % datetime version
      t0 = tic;
      for i = 1:N
        x = datetime; %#ok<NASGU>
      end
      te = toc(t0);
      fprintf(this.fmt, 'current unzoned local time (datetime):', te/N);
      
      % Current system time in local time, zoned

      % datenum version
      t0 = tic;
      for i = 1:N
        x = now; %#ok<NASGU>
      end
      te = toc(t0);
      fprintf(this.fmt, 'current zoned local time (datenum now):', te/N);
      
      % datetime version
      t0 = tic;
      for i = 1:N
        x = datetime('now', 'TimeZone', datetime.SystemTimeZone); %#ok<NASGU>
      end
      te = toc(t0);
      fprintf(this.fmt, 'current zoned local time (datetime):', te/N);
      
      % Current system time in UTC

      % datenum version: oh crap, how do we do this? Guess we have to drop
      % down to Java
      msecPerDay = 1000 * 60 * 60 * 24;
      unixEpochDatenum = datenum(1970, 1, 1);
      t0 = tic;
      for i = 1:N
        posixMillis = java.lang.System.currentTimeMillis;
        dnum = (double(posixMillis) / (msecPerDay)) + unixEpochDatenum; %#ok<NASGU>
      end
      te = toc(t0);
      fprintf(this.fmt, 'current zoned UTC time (datenum):', te/N);
      % Wow, this is actually really fast, compared to the datetime
      % version. Bummer!
      
      % datetime version
      t0 = tic;
      for i = 1:N
        x = datetime('now', 'TimeZone','UTC'); %#ok<NASGU>
      end
      te = toc(t0);
      fprintf(this.fmt, 'current zoned UTC time (datetime):', te/N);
      
      % Construct unzoned datetime object from raw time
      
      % datetime version
      dnum = now;
      t0 = tic;
      for i = 1:N
        x = datetime(dnum, 'ConvertFrom', 'datenum'); %#ok<NASGU>
      end
      te = toc(t0);
      fprintf(this.fmt, 'unzoned object from raw time (datetime):', te/N);

      % Construct zoned datetime object from raw UTC time
      
      % Just pretend this is the known UTC time we care about
      utcDatenum = datenum(1966, 6, 14, 2, 3, 4);
      
      % datenum version - not really applicable! datenum doesn't know about zones!
      % So I guess we could just say it's the identity transformation, and 
      % the surrounding code just has to know from context that it's a UTC
      % datenum.
      % datetime version
      t0 = tic;
      for i = 1:N
        x = utcDatenum; %#ok<NASGU>
      end
      te = toc(t0);
      fprintf(this.fmt, 'UTC raw time to object (datenum):', te/N);
      
      % datetime version
      t0 = tic;
      for i = 1:N
        x = datetime(utcDatenum, 'ConvertFrom','datenum');
        x.TimeZone = 'UTC';
      end
      te = toc(t0);
      fprintf(this.fmt, 'UTC raw time to object (datetime):', te/N);
      
      % datetime version 2
      t0 = tic;
      for i = 1:N
        x = datetime(utcDatenum, 'ConvertFrom','datenum', 'TimeZone','UTC'); %#ok<NASGU>
      end
      te = toc(t0);
      fprintf(this.fmt, 'UTC raw time to object (datetime v2):', te/N);
      
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
      fprintf(this.fmt, 'local raw time to object (datetime):', te/N);
      
      % datetime version v2
      t0 = tic;
      for i = 1:N
        x = datetime(localDatenum, 'ConvertFrom','datenum', 'TimeZone',systemTimeZone); %#ok<NASGU>
      end
      te = toc(t0);
      fprintf(this.fmt, 'local raw time to object (datetime v2):', te/N);
      
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
      fprintf(this.fmt, 'change time zone on zoned datetime:', te/N);
      
      % Note that an unzoned datetime is actually UTC
      
      unzonedDate = datetime;
      
      % datetime version
      t0 = tic;
      for i = 1:N
        utcDate = unzonedDate;
        utcDate.TimeZone = 'UTC';
      end
      te = toc(t0);
      fprintf(this.fmt, 'say that unzoned datetime is UTC (datetime):', te/N);

    end
    
    function benchDumbPropertySetting(this)
      N = this.numIters;
      this.header;

      obj = SomeDumbClass;
      
      t0 = tic;
      for i = 1:N
        obj.foo = 42;
      end
      te = toc(t0);
      fprintf(this.fmt, 'set property:', te/N);    
      
      t0 = tic;
      for i = 1:N
        obj.barWithSetter = 42;
      end
      te = toc(t0);
      fprintf(this.fmt, 'set property with setter:', te/N);      
    end
  
  end
  
end