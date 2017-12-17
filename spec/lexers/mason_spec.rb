# -*- coding: utf-8 -*- #

describe Rouge::Lexers::Mason do
  let(:subject) { Rouge::Lexers::Mason.new }
  let(:bom) { "\xEF\xBB\xBF" }

  describe 'guessing' do
    include Support::Guessing

    it 'guesses by filename' do
      assert_guess :filename => 'foo.mas'
      assert_guess :filename => 'foo.mi'
      assert_guess :filename => 'foo.mas'
    end

    it 'guesses by mimetype' do
      assert_guess :mimetype => 'text/x-mason'
      assert_guess :mimetype => 'application/x-mason'
    end

  end
end
