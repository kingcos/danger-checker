# frozen_string_literal: false

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
    # An attribute that you can read/write from your Dangerfile
    #
    # @return   [Array<String>]
    attr_accessor :my_attribute

    # A method that you can call from your Dangerfile
    # @return   [Array<String>]
    #
    def warn_on_mondays
      warn "Trying to merge code on a Monday" if Date.today.wday == 1
    end
  end
end
