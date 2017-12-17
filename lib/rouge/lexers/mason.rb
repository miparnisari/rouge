# -*- coding: utf-8 -*- #

module Rouge
    module Lexers
      class Mason < RegexLexer
        title "Mason"
        desc %q(<desc for="this-lexer">Mason</desc>)
        tag 'mason'
        filenames '*.mi', '*.m'
        mimetypes 'text/x-mason', 'application/x-mason'

        def initialize(*)
            super
            @perl = Perl.new(options)
            @html = HTML.new(options)
          end
  
        def self.detect?(text)
          return false if text.doctype?(/[html|xml]/)
          return true if text.doctype?
        end

        blocks = %w(
            cleanup doc args flags attr once shared init perl text filter
        )

        subcomponents = %w(
            def method
        )
  
        state :root do

            # Comments
            rule /^#.*?$/, Comment::Single

            # doc block
            rule /(<%doc>)([^<]*)(<\/%doc>)/ do |m|
                token Keyword::Constant, m[1]
                token Text, m[2]
                token Keyword::Constant, m[3]
            end

            # text block (not interpreted)
            rule /(<%text>)([^<]*)(<\/%text>)/ do |m|
                token Keyword::Constant, m[1]
                token Text, m[2]
                token Keyword::Constant, m[3]
            end

            # args block
            rule /(<%args>)([^<]*)(<\/%args>)/ do |m|
                token Keyword::Constant, m[1]
                delegate @perl, m[2]
                token Keyword::Constant, m[3]
            end

            # flags block
            rule /(<%flags>)([^<]*)(<\/%flags>)/ do |m|
                token Keyword::Constant, m[1]
                delegate @perl, m[2]
                token Keyword::Constant, m[3]
            end

            # attr block
            rule /(<%attr>)([^<]*)(<\/%attr>)/ do |m|
                token Keyword::Constant, m[1]
                delegate @perl, m[2]
                token Keyword::Constant, m[3]
            end

            # init block
            rule /(<%init>)([^<]*)(<\/%init>)/ do |m|
                token Keyword::Constant, m[1]
                delegate @perl, m[2]
                token Keyword::Constant, m[3]
            end

            # once block
            rule /(<%once>)([^<]*)(<\/%once>)/ do |m|
                token Keyword::Constant, m[1]
                delegate @perl, m[2]
                token Keyword::Constant, m[3]
            end

            # shared block
            rule /(<%shared>)([^<]*)(<\/%shared>)/ do |m|
                token Keyword::Constant, m[1]
                delegate @perl, m[2]
                token Keyword::Constant, m[3]
            end

            # perl block
            rule /(<%perl>)([^<]*)(<\/%perl>)/ do |m|
                token Keyword::Constant, m[1]
                delegate @perl, m[2]
                token Keyword::Constant, m[3]
            end

            # cleanup block
            rule /(<%cleanup>)([^<]*)(<\/%cleanup>)/ do |m|
                token Keyword::Constant, m[1]
                delegate @perl, m[2]
                token Keyword::Constant, m[3]
            end

            # filter block
            rule /(<%filter>)([^<]*)(<\/%filter>)/ do |m|
                token Keyword::Constant, m[1]
                delegate @perl, m[2]
                token Keyword::Constant, m[3]
            end

            # def block
            rule /(<%def([^>]*)>)([^<]*)(<\/%def>)/ do |m|
                token Keyword::Constant, m[1]
                token Keyword::Type, m[2]
                delegate @perl, m[3]
                token Keyword::Constant, m[4]
            end

            # method block
            rule /(<%method([^>]*)>)([^<]*)(<\/%method>)/ do |m|
                token Keyword::Constant, m[1]
                token Keyword::Type, m[2]
                delegate @perl, m[3]
                token Keyword::Constant, m[4]
            end

            # component call
            rule /(<&)(.*)(&>)/ do |m|
                token Keyword::Constant, m[1]
                token Text, m[2]
                token Keyword::Constant, m[3]
            end

            # component substitution
            rule /(<%)(.*)(%>)/ do |m|
                token Keyword::Constant, m[1]
                delegate @perl, m[2]
                token Keyword::Constant, m[3]
            end

            rule /^%.*/ do
                delegate @perl
            end

            rule /.*/ do
                delegate @html
            end
        end
      end
    end
  end
  