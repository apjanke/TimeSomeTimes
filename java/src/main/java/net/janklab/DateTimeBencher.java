package net.janklab;

import java.time.Instant;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.Date;

public class DateTimeBencher {

    public int numIters = 10000;

    public static void main(String[] args) {
        DateTimeBencher dtb = new DateTimeBencher();
        dtb.benchBasicDatetimeOps();
    }

    private void announce(String fmt, Object ... args) {
        String msg = String.format(fmt, args);
        System.out.println(msg);
    }

    private long tic() {
        return System.currentTimeMillis();
    }

    private double toc(long t0) {
        long elapsedMillis = System.currentTimeMillis() - t0;
        double elapsedSec = ((double)elapsedMillis) / 1000;
        return elapsedSec;
    }

    public void benchBasicDatetimeOps() {
        int N = numIters;

        System.out.println("Bench Java, " + N + " iters:");
        String fmt = "%-45s %.09f s";

        // Get current system time in local time, unzoned.
        // TODO
        long t0;
        double te;
        long rawMillis;
        Date date;
        ZonedDateTime zdt;
        ZoneId utcZone = ZoneId.of("UTC");

        t0 = tic();
        for (int i = 0; i < N; i++) {

        }

        // Current system time in UTC, raw
        t0 = tic();
        for (int i = 0; i < N; i++) {
            rawMillis = System.currentTimeMillis();
        }
        te = toc(t0);
        announce(fmt, "current UTC time (raw):", te/N);

        // Current system time, local time zone, as object (old java.util)
        t0 = tic();
        for (int i = 0; i < N; i++) {
            date = new Date();
        }
        te = toc(t0);
        announce(fmt, "current unzoned local time (java.util):", te/N);

        // Current system time, local time zone, as zoned object (new java.time)
        t0 = tic();
        for (int i = 0; i < N; i++) {
            zdt = ZonedDateTime.now();
        }
        te = toc(t0);
        announce(fmt, "current zoned local time (java.time):", te/N);

        // Current system time, UTC, as zoned object (new java.time)
        t0 = tic();
        for (int i = 0; i < N; i++) {
            zdt = ZonedDateTime.now(utcZone);
        }
        te = toc(t0);
        announce(fmt, "current UTC time (java.time):", te/N);

        // UTC raw time to object
        long someRandomEpochMillis = 420;
        t0 = tic();
        for (int i = 0; i < N; i++) {
            Instant inst = Instant.ofEpochMilli(someRandomEpochMillis);
            zdt = ZonedDateTime.ofInstant(inst, utcZone);
        }
        te = toc(t0);
        announce(fmt, "UTC raw time to object (java.time):", te/N);
        
    }

}
