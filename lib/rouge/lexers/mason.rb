# -*- coding: utf-8 -*- #

module Rouge
    module Lexers
      class Mason < RegexLexer
        title "Mason"
        desc %q(<desc for="this-lexer">Mason</desc>)
        tag 'mason'
        filenames '*.mi', '*.mc', '*.mas', '*.mhtml', '*.mcomp', "autohandler", "dhandler"
        mimetypes 'text/x-mason', 'application/x-mason'

        def initialize(*)
            super
            @perl = Perl.new()
            @html = HTML.new()
          end
  
        def self.detect?(text)
          return false if text.doctype?(/[html|xml]/)
          return true if text.doctype?
        end

        textblocks = %w(
            doc text
        )

        perlblocks = %w(
            args flags attr init once shared perl cleanup filter
        )

        components = %w(
            def method
        )
  
        state :root do

            ### Perl specific syntax

            rule /^%(.*)$/ do |m|
                token Operator, '%'
                delegate @perl, m[1]
            end

            rule /^#.*?$/, Comment::Single

            # uninterpreted blocks
            rule /(<%(#{textblocks.join('|')})>)([^<]*)(<\/%\2>)/ do |m|
                token Keyword::Constant, m[1]
                token Text, m[3]
                token Keyword::Constant, m[4]
            end

            # perl blocks
            rule /(<%(#{perlblocks.join('|')})>)([^<]*)(<\/%\2>)/ do |m|
                token Keyword::Constant, m[1]
                delegate @perl, m[3]
                token Keyword::Constant, m[4]
            end

            # component blocks
            rule /(<%(#{components.join('|')})[^>]*>)(.*)(<\/%\2>)/m do |m|
                token Keyword::Constant, m[1]
                delegate @perl, m[3]   # TODO delegate to mason
                token Keyword::Constant, m[4]
            end

            ### Mason specific syntax

            # component calls
            rule /(<&)(.*)(&>)/ do |m|
                token Keyword::Constant, m[1]
                token Text, m[2]
                token Keyword::Constant, m[3]
            end

            # component substitutions
            rule /(<%)(.*)(%>)/ do |m|
                token Keyword::Constant, m[1]
                delegate @perl, m[2]
                token Keyword::Constant, m[3]
            end

            rule /^.*$/ do
                delegate @html
            end
        end
      end
    end
  end
  