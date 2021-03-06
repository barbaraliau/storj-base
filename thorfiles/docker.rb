class Docker < ThorBase
  include Open3

  desc 'up <env>', 'starts up a docker composition for the given environment'

  def up(env)
    @env = env

    popen2e "docker-compose -f dockerfiles/#{env}.yml up", chdir: PROJECT_DIR do |stdin, stdout_stderr, wait_thread|
      Signal.trap('INT') { shut_down }
      Signal.trap('TERM') { shut_down }

      while line = stdout_stderr.gets do
        print line
      end
    end
  end

  desc 'build [env]', 'builds a docker container for the given environment (defaults to production)'

  def build(env = 'production')
    @env = env

    popen2e "docker-compose -f dockerfiles/#{env}.yml build", chdir: PROJECT_DIR do |stdin, stdout_stderr, wait_thread|
      while line = stdout_stderr.gets do
        print line
      end
    end
  end

  private

  def shut_down
    spawn("docker-compose -f dockerfiles/#{@env}.yml kill", chdir: PROJECT_DIR)
    sleep 1
    exit
  end
end
