# frozen_string_literal: true

module Danger
  # Simply check your text as you like.
  # For more, please visit [danger-text_checker](https://github.com/kingcos/danger-text_checker)
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Ensure people are well warned about merging on Mondays
  #
  #          my_plugin.warn_on_mondays
  #
  # @see  kingcos/danger-text_checker
  # @tags ci, danger-plugin, checker
  #
  class DangerTextChecker < Plugin
    attr_accessor :matched_files
    attr_writer :rules_file_path
    attr_writer :rules_pattern

    # Setup the file regex patterns as you need
    #
    #
    # @return   [void]
    def file_patterns=(file_patterns)
      if file_patterns.nil? || file_patterns.zero?
        return
      end

      @matched_files = [] if @matched_files.nil?
      (git.modified_files + git.added_files).each do |line|
        file_patterns.each do |pattern|
          @matched_files += [line] unless line.match(pattern).nil?
        end
      end
    end

    # Setup the file extesions as you need
    #
    #
    # @return   [void]
    def file_extensions=(file_extensions)
      if file_extensions.nil? || file_extensions.zero?
        return
      end

      extensions = file_extensions.reduce do |total, extension|
        return total + "|" + extension
      end

      extensions_regex = "(?-mix:^[^\\.].*\\.(" + extensions + ")$)"

      @matched_files = [] if @matched_files.nil?
      (git.modified_files + git.added_files).each do |line|
        @matched_files += [line] unless line.match(extensions_regex).nil?
      end
    end

    # Start to check
    #
    #
    # @return   [void]
    def check(check_patterns)
      puts check_patterns
      puts "---"
      puts @matched_files

      puts "---"
      puts git.modified_files
      puts "---"
      puts git.added_files
      puts "---"
      # puts @matched_files

      # @matched_files.each do |file|
      #   puts git.diff_for_file(file)
      # end
    end
  end
end
