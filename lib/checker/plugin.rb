# frozen_string_literal: true

module Danger
  # Simply check your changes as you like.
  # For more, please visit [danger-checker](https://github.com/kingcos/danger-checker)
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Ensure people are well warned about merging on Mondays
  #
  #          my_plugin.warn_on_mondays
  #
  # @see  kingcos/danger-checker
  # @tags ci, danger-plugin, checker
  #
  class DangerChecker < Plugin
    # Filter files by file extensions
    #
    # @param   [string or [string]]
    # @return  [[string]]
    attr_accessor :file_extensions

    # Filter files by regex expressions
    #
    # @param   [string or [string]]
    # @return  [[string]]
    attr_accessor :file_patterns

    # Filter changed lines by regex expressions
    #
    # @param   [string or [string]]
    # @return  [[string]]
    attr_accessor :check_patterns

    # Preprocess user input data
    #
    # @param   [void]
    # @return  [void]
    def file_extensions
      [@file_extensions].flatten.compact.uniq
    end

    # Preprocess user input data
    #
    # @param   [void]
    # @return  [void]
    def file_patterns
      [@file_patterns].flatten.compact.uniq
    end

    # Preprocess user input data
    #
    # @param   [void]
    # @return  [void]
    def check_patterns
      [@check_patterns].flatten.compact.uniq
    end

    def should_less_than(contrast_list)
      matched_strings = preprocess(contrast_list)

      # def check_strings(matched_strings, contrast_list)
      #   not_matched_strings = []
      #   matched_strings.each do |string|
      #     not_matched_strings += [string] unless contrast_list.include?(string)
      #   end
      #   return not_matched_strings
      # end

      reset
    end

    def should_greater_than(contrast_list)
      a = preprocess(contrast_list)

      reset
    end

    def should_equal(contrast_list)
      a = preprocess(contrast_list)

      reset
    end

    def warn
      def should_less_than(_contrast_list)
        warn
      end

      def should_greater_than(contrast_list); end

      def should_equal(contrast_list); end
    end

    def fail
      def should_less_than(contrast_list); end

      def should_greater_than(contrast_list); end

      def should_equal(contrast_list); end
    end

    private

    # Preprocess
    # then return added lines.
    #
    # @param   [[string]]
    # @return  [[string]]
    def preprocess(contrast_list)
      contrast_list = [contrast_list].flatten.compact.uniq
      if contrast_list.empty?
        warn("danger-checker Warning: You have to setup the contrast list.")
      else
        matched_files = filter_matched_files
        matched_lines = filter_matched_lines(matched_files)
        matched_strings = match_strings(matched_lines).compact.uniq

        return matched_strings
      end
    end

    # Filter git changes by matched files,
    # then return added lines.
    #
    # @param   [[string]]
    # @return  [[string]]
    def filter_matched_files
      matched_files = []

      unless file_extensions.empty?
        extensions = file_extensions.reduce do |total, extension|
          total + "|" + extension.downcase
        end
        extensions_regex = "^(.+" + extensions + ")$"
        (git.modified_files + git.added_files).each do |file|
          matched_files += [file] unless file.downcase.match(extensions_regex).nil?
        end
      end

      unless file_patterns.empty?
        (git.modified_files + git.added_files).each do |line|
          file_patterns.each do |pattern|
            matched_files += [line] unless line.downcase.match(pattern.downcase).nil?
          end
        end
      end

      return [matched_files].flatten.compact
    end

    # Filter git changes by matched files,
    # then return added lines.
    #
    # @param   [[string]]
    # @return  [[string]]
    def filter_matched_lines(matched_files)
      matched_lines = []

      matched_files.each do |file|
        diff = git.diff_for_file(file)
        next if diff.binary?

        patch_lines = diff.patch.split("\n").map(&:strip)
        diff_start_line = [patch_lines.select { |line| line.start_with? "@@" }].flatten.compact
        next if diff_start_line.empty?

        start_line_number = patch_lines.index(diff_start_line[0]) + 1
        matched_lines += patch_lines[start_line_number, patch_lines.count - 1]
          .map(&:strip)
          .select { |line| line.start_with? "+" }
      end

      return [matched_lines].flatten.compact
    end

    # Match lines by check_patterns,
    # then return matched strings.
    #
    # @param   [[string]]
    # @return  [[string]]
    def match_strings(matched_lines)
      matched_strings = []

      matched_lines.each do |line|
        check_patterns.each do |pattern|
          line.scan(pattern).each do |matched|
            matched_strings += matched
          end
        end
      end

      return matched_strings
    end

    # Reset values for next check
    #
    # @param   [void]
    # @return  [void]
    def reset
      @file_extensions = []
      @file_patterns = []
      @check_patterns = []
    end
  end
end
