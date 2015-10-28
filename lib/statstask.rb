# Stats class for collecting git LOC and other stats
class StatsTask
  include Common
  include Gitbase

  def execute(top_dir_name, api_key, host)
    agent = Mechanize.new
    agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    auth_headers = { 'X-User-Token' => api_key }

    repos = read_bliss_file(top_dir_name)
    dir_names = []

    dir_list = get_directory_list(top_dir_name)
    dir_list.each do |git_dir|
      name = git_dir.split('/').last
      repo = repos[name]
      repo_key = repo['repo_key']
      loop do
        repo_return = agent.get(
        "#{host}/api/gitlog/stats_todo?repo_key=#{repo_key}",
        auth_headers)
        json_return = JSON.parse(repo_return.body)
        puts "Working on: #{name}".green
        json_return.each do |metric|
          commit = metric['commit']
          puts "Getting stats for #{commit}...".blue

          stat_command = "git log --pretty=tformat: --numstat #{commit}"
          cmd = get_cmd("cd #{git_dir}; #{stat_command}")
          # puts "\t\t#{cmd}"
          added_lines = 0
          deleted_lines = 0
          @stats = %x{#{cmd}}
          @stats.split("\n").each do |stt|
            match = stt.match(/(\d+)\t(\d+)/)
            if match
              added_lines += match[1].to_i
              deleted_lines += match[2].to_i
            end
          end
          checkout_commit(git_dir, commit)
          language = sense_project_type(git_dir)
          cmd = "perl #{cloc_command} #{git_dir} #{cloc_options}"

          puts "\tCounting total lines of code. This may take a while...".blue
          begin
            total_cloc = `#{cmd}`
          rescue
            puts "\tPerl is not installed! Please refer to the docs at https://github.com/founderbliss/collector to ensure all dependencies are installed.".red
            $logger.warn("#{Time.now}: Dependency Error: Perl not installed...")
          end

          remove_open_source_files(git_dir)
          cmd = "perl #{cloc_command} #{git_dir} #{cloc_options}"

          puts "\tCounting original lines of code. This may take a while...".blue
          begin
            cloc = `#{cmd}`
          rescue
            puts "\tPerl is not installed! Please refer to the docs at https://github.com/founderbliss/collector to ensure all dependencies are installed.".red
            $logger.warn("#{Time.now}: Dependency Error: Perl not installed...")
          end

          puts "\tCounting lines of test code. This may take a while...".blue
          cloc_test_dirs = get_test_dirs(git_dir)
          if !cloc_test_dirs.nil?
            cmd = "perl #{cloc_command} #{cloc_test_dirs} #{cloc_options}"
            # puts "\t\t#{cmd}"
            begin
              cloc_tests = `#{cmd}`
            rescue
              puts "\tPerl is not installed! Please refer to the docs at https://github.com/founderbliss/collector to ensure all dependencies are installed.".red
              $logger.warn("#{Time.now}: Dependency Error: Perl not installed...")
            end
          else
            puts "\tNo known test pattern for cloc to run - skipped".blue
          end
          stat_payload = {
            repo_key: repo_key,
            commit: commit,
            added_lines: added_lines,
            deleted_lines: deleted_lines,
            total_cloc: total_cloc,
            cloc: cloc,
            cloc_tests: cloc_tests
          }
          puts "\tPosting commit stats to Bliss...".blue
          stats_response = agent.post(
          "#{host}/api/commit/stats",
          stat_payload,
          auth_headers)
          stats_return = JSON.parse(stats_response.body)
          puts "\tSuccessfully saved stats for commit #{commit}.".green
          # puts "\t\tstats_response: #{stats_response.inspect}"
        end
        puts "All stats are finished.".green if json_return.empty?
        break if json_return.empty?
      end

      # Go back to master at the end
      checkout_commit(git_dir, 'master')
    end

    puts dir_names.join
    puts "Stats finished.".green
  end
end
