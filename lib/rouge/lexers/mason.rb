# -*- coding: utf-8 -*- #

module Rouge
    module Lexers
      class Mason < RegexLexer
        title 'Mason'
        desc %q(<desc for="this-lexer">Mason</desc>)
        tag 'mason'
        filenames '*.mi', '*.mc', '*.mas', '*.mhtml', '*.mcomp', 'autohandler', 'dhandler'
        mimetypes 'text/x-mason', 'application/x-mason'

        def initialize(*)
            super
            @perl = Perl.new
            @html = HTML.new
        end
  
        def self.detect?(text)
          return false if text.doctype?(/[html|xml]/)
          return true if text.doctype?
        end

        textblocks = %w(
            text doc
        )
        perlblocks = %w(
            args flags attr init once shared perl cleanup filter
        )
        components = %w(
            def method
        )
  
        state :root do

            # uninterpreted blocks
            rule /(\s*)(<%(#{textblocks.join('|')})>)([^<]*)(<\/%\3>\s*)/m do |m|
                token Keyword::Declaration, m[1]
                token Keyword::Declaration, m[2]
                token Comment::Single, m[4]
                token Keyword::Declaration, m[5]
            end

            # perl blocks
            rule /(\s*)(<%(#{perlblocks.join('|')})>)([^<]*)(<\/%\3>\s*)/m do |m|
                token Keyword::Declaration, m[1]
                token Keyword::Declaration, m[2]
                delegate @perl, m[4]
                token Keyword::Declaration, m[5]
            end

            # start of a component
            rule /(\s*)(<%(#{components.join('|')})[^>]*>)/ do |m|
                token Keyword::Constant, m[2]
                push :component
            end
            
            rule // do
              push :html
            end

        end

        state :component do

            # uninterpreted blocks
            rule /(<%(#{textblocks.join('|')})>)([^<]*)(<\/%\2>\s*)/ do |m|
                token Keyword::Declaration, m[1]
                token Text, m[3]
                token Keyword::Declaration, m[4]
            end

            # perl blocks
            rule /(<%(#{perlblocks.join('|')})>)([^<]*)(<\/%\2>\s*)/ do |m|
                token Keyword::Declaration, m[1]
                delegate @perl, m[3]
                token Keyword::Declaration, m[4]
            end

            # end of component
            rule /(<\/%(#{components.join('|')})>\s*)/ do |m|
                token Keyword::Constant, m[1]
                pop!
            end

            rule // do
                push :html
            end

        end

        state :html do

            # perl comment
            rule /^(#.*\s*)/ do |m|
                token Comment::Single, m[1]
                pop!
            end

            # perl line
            rule /^%(.*\s*)/ do |m|
                token Operator, '%'
                delegate @perl, m[1]
                pop!
            end

            rule // do
                push :mason_components
            end

        end

        state :mason_components do

          # start of component call or substitution
          rule /(.*?)(?=<[&%]\s*)/ do |m|
            delegate @html, m[1]
            push :sub_component
          end

          rule /(.*\s*)/ do |m|
            delegate @html, m[1]
            pop! 2
          end
        end

        state :sub_component do

            # component substitution: <% ... %>
            rule /(\s*<%)(?!&>)(.+?)(%>)/m do |m|
                token Keyword::Constant, m[1]
                token Text, m[2]
                token Keyword::Constant, m[3]
                pop! 3
            end

            # component call: <& ... &>
            rule /(\s*<&)(?!&>)(.+?)(&>)/m do |m|
                token Keyword::Constant, m[1]
                delegate @perl, m[2]
                token Keyword::Constant, m[3]
                pop! 3
            end

        end
      end
    end
  end
  