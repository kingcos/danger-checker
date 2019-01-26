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
        # File extensions
        # @param [string or [string]]
        # @return  [[string]]
        attr_accessor :file_extensions
        
        # File patterns
        # @param [string or [string]]
        # @return  [[string]]
        attr_accessor :file_patterns
        
        # Rules file path
        # @return  [void]
        attr_writer :rules_file_path
        
        # Rules pattern
        # @return  [void]
        attr_writer :rules_pattern
        
        def file_extensions
            [@file_extensions].flatten.compact
        end
        
        def file_patterns
            [@file_patterns].flatten.compact
        end
        
        # Filter matched files
        #
        # @param    [void]
        # @return   [[string]]
        def filter_matched_files
            matched_files = []
            
            unless file_extensions.count.zero?
                extensions = file_extensions.reduce do |total, extension|
                    total + "|" + extension.downcase
                end
                extensions_regex = "^(.+" + extensions + ")$"
                (git.modified_files + git.added_files).each do |file|
                    matched_files += [file] unless file.downcase.match(extensions_regex).nil?
                end
            end
            
            unless file_patterns.count.zero?
                (git.modified_files + git.added_files).each do |line|
                    file_patterns.each do |pattern|
                        matched_files += [line] unless line.downcase.match(pattern.downcase).nil?
                    end
                end
            end
            
            return [matched_files].flatten.compact
        end
        
        def filter_matched_lines(matched_files)
            matched_lines = []
            
            matched_files.each do |file|
                diff = git.diff_for_file(file)
                next if diff.binary?
                
                patch_lines = diff.patch.split("\n").map(&:strip)
                diff_start_line = [patch_lines.select { |line| line.start_with? "@@" }].flatten.compact
                next if diff_start_line.count.zero?
                
                start_line_number = patch_lines.index(diff_start_line[0]) + 1
                matched_lines += patch_lines[start_line_number, patch_lines.count - 1]
                .map(&:strip)
                .select { |line| line.start_with? "+" }
            end
            
            return [matched_lines].flatten.compact
        end
        
        # Start to check
        #
        #
        # @return   [void]
        def check(_check_patterns)
            matched_files = filter_matched_files
            matched_lines = filter_matched_lines(matched_files)
            
            
            
            # Reset
            @file_extensions = []
            @file_patterns = []
        end
    end
end
