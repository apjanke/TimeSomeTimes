# TimeSomeTimes

Benchmarks for datetime construction in various languages

This repo contains some super-simple benchmarks for timing basic datetime object construction and time zone conversion in various languages. It was written to support my MathWorks Technical Support case #04794314 "datetime('now', 'TimeZone',...) and datetime.SystemTimeZone are slow".

Apologies to the MathWorks Tech Support staff; I had been drinking when I filed this bug report.

## Operations

There are a few basic operations of interest I'm working on here. They are:

1. Get current system time in local time zone, as whatever
2. Get current system time in UTC, as whatever
3. Construct a zoned datetime object from a raw UTC time
4. Construct a zoned datetime object from a raw local time

When I say "raw" time here, I mean some basic numeric representation of time; whatever you would have gotten in this language before OOP came around, or what its lower-level system call APIs present.

By a "zoned" datetime object I mean whatever variant of datetime object that language has which is timezone-aware, correctly represents its underlying date value as a "point in real time", as UTC or some equivalent, and maybe has some local time zone for presentation and broken-down calendar components purposes.
