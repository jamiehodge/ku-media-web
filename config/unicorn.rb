worker_processes 2

timeout 30

listen File.expand_path('tmp/sockets/unicorn.sock'), backlog: 64

pid File.expand_path('tmp/pids/unicorn.pid')

before_fork do |server, worker|
  defined?(Sequel) and DB.disconnect
  
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill sig, File.read(old_pid).to_i
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
  
  sleep 1
end

after_fork do |server, worker|
  defined?(Sequel) and DB = Sequel.connect(ENV['DATABASE_URL'])
end
