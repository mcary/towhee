module BenchmarkSupport
  def benchmark(descr)
    @benchmark_git_sha ||= `git describe --always --dirty=-dirty`.chomp
    require 'benchmark'
    tms = Benchmark.measure { yield }
    # Extract helper for project_root?
    project_root = File.dirname(File.dirname(File.dirname(__FILE__)))
    file = caller.first.split(":", 2).first.sub(project_root, ".")
    timestamp = Time.now.strftime("%F") # %T.%6N -- too wide
    times = [
      fmt_time(tms.real),
      fmt_time(tms.total), # Total CPU of self and children
      fmt_time(tms.stime + tms.cstime), # System CPU time of self ahd children
      fmt_time(tms.utime + tms.cutime), # User CPU time of self and children
    ]
    puts "  ⏱️   #{descr}: #{times.join(' ')}"
    info = [
      timestamp,
      @benchmark_git_sha,
      *times,
      descr.inspect,
      file,
      self.inspect,
    ]
    msg = info.join("\t") + "\n"
    # Ideally we'd check whether the example passed before logging...
    File.open("benchmarks.csv", "a") do |f|
      f.write(msg)
    end
  end

  def fmt_time(delta)
    "%.6f" % delta
  end
end
